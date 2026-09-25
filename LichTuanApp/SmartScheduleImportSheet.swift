import SwiftUI
import PhotosUI

/// Giao diện nhập lịch trình thông minh từ Zalo / Ghi chú và Quét ảnh thời khóa biểu (OCR)
struct SmartScheduleImportSheet: View {
    @ObservedObject var viewModel: EventListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var inputText: String = ""
    @State private var parsedItems: [ScheduleTextParser.ParsedItem] = []
    @State private var isRecurringWeekly: Bool = false
    @State private var hasReminder: Bool = true
    @State private var showCopiedAlert: Bool = false

    // OCR State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isScanningOCR: Bool = false
    @State private var ocrErrorMessage: String? = nil
    @State private var showCameraPicker: Bool = false

    private let calendar = Calendar.current

    // Tính Thứ 2 của tuần hiện tại làm mốc
    private var currentMonday: Date {
        calendar.startOfWeek()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header hướng dẫn
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color(red: 0.18, green: 0.58, blue: 1.0))
                            Text("Nhập Lịch Thông Minh (AI Prompt & Quét Ảnh)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }

                        Text("Gõ câu nói tự nhiên (ví dụ: 'Sáng 2-4-6 tập gym 6h-7h, tối T3 học 19h'), dán tin nhắn Zalo hoặc quét ảnh thời khóa biểu.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)

                    // Gợi ý câu lệnh nhanh (AI Prompt Chips)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            promptChip(title: "⚡ 2-4-6 sáng 6h-7h Gym", prompt: "Sáng 2-4-6 tập gym 6h đến 7h")
                            promptChip(title: "⚡ 3-5-7 tối 19h-21h Tiếng Anh", prompt: "Tối 3-5-7 học tiếng Anh 19h đến 21h")
                            promptChip(title: "⚡ T7 cả ngày Dã ngoại", prompt: "Thứ 7 cả ngày đi dã ngoại")
                            promptChip(title: "⚡ T2-T6 8h-17h Đi làm", prompt: "Từ thứ 2 đến thứ 6: 08:00 - 17:00 Đi làm")
                        }
                        .padding(.horizontal, 2)
                    }

                    // Ô nhập văn bản & Trạng thái đang quét OCR
                    VStack(alignment: .trailing, spacing: 8) {
                        ZStack(alignment: .topLeading) {
                            if inputText.isEmpty && !isScanningOCR {
                                Text("Gõ câu nói tự nhiên hoặc dán tin nhắn Zalo vào đây...\n\nVí dụ câu lệnh:\n- Sáng 2-4-6 tập gym 6h-7h, tối T3 học tiếng Anh 19h\n- T7 cả ngày đi chơi với gia đình\n- Hoặc dán thời khóa biểu dạng Thứ 2: 8h-10h...")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.35))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                            }

                            TextEditor(text: $inputText)
                                .font(.system(size: 13))
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .padding(8)
                                .frame(minHeight: 140)
                                .onChange(of: inputText) { newValue in
                                    runParser(on: newValue)
                                }

                            if isScanningOCR {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.black.opacity(0.75))
                                    .overlay(
                                        VStack(spacing: 12) {
                                            ProgressView()
                                                .tint(.cyan)
                                                .scaleEffect(1.2)
                                            Text("Đang quét chữ từ hình ảnh...")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(.white)
                                        }
                                    )
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                        // Thông báo lỗi OCR nếu có
                        if let error = ocrErrorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.yellow)
                                Text(error)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.8))
                                Spacer()
                                Button("Đóng") {
                                    ocrErrorMessage = nil
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.cyan)
                            }
                            .padding(8)
                            .background(Color.yellow.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        // Hàng nút tiện ích: Dán nhanh & Quét ảnh OCR
                        HStack(spacing: 8) {
                            // Nút Dán nhanh
                            Button {
                                if let clip = UIPasteboard.general.string, !clip.isEmpty {
                                    inputText = clip
                                    runParser(on: clip)
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "doc.on.clipboard.fill")
                                    Text("Dán chữ")
                                        .font(.system(size: 11.5, weight: .semibold))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(Color(red: 0.18, green: 0.58, blue: 1.0).opacity(0.2))
                                .foregroundStyle(Color(red: 0.28, green: 0.70, blue: 1.0))
                                .clipShape(Capsule())
                            }

                            // Nút Quét từ Thư viện ảnh (PhotosPicker)
                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                HStack(spacing: 5) {
                                    Image(systemName: "photo.badge.magnifyingglass")
                                    Text("Quét từ ảnh")
                                        .font(.system(size: 11.5, weight: .semibold))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(Color.purple.opacity(0.25))
                                .foregroundStyle(Color.purple.opacity(0.95))
                                .clipShape(Capsule())
                            }
                            .onChange(of: selectedPhotoItem) { newItem in
                                if let item = newItem {
                                    processPhotoItem(item)
                                }
                            }

                            // Nút Chụp ảnh bằng Camera
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                Button {
                                    showCameraPicker = true
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "camera.fill")
                                        Text("Chụp ảnh")
                                            .font(.system(size: 11.5, weight: .semibold))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(Color.orange.opacity(0.25))
                                    .foregroundStyle(Color.orange)
                                    .clipShape(Capsule())
                                }
                            }

                            Spacer()
                        }
                    }

                    // Tùy chọn nâng cao
                    VStack(spacing: 12) {
                        Toggle(isOn: $isRecurringWeekly) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Lặp lại hàng tuần (Thời khóa biểu)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("Lịch trình sẽ tự động xuất hiện vào tuần sau và các tuần kế tiếp")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                        .tint(Color(red: 0.18, green: 0.58, blue: 1.0))

                        Divider().background(Color.white.opacity(0.1))

                        Toggle(isOn: $hasReminder) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bật thông báo chuông nhắc nhở")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("iPhone sẽ rung chuông báo trước 15 phút và ghim vào Reminders trên màn hình khóa")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                        .tint(Color(red: 0.18, green: 0.58, blue: 1.0))
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(red: 0.12, green: 0.13, blue: 0.17))
                    )

                    // Kết quả nhận diện (Live Preview)
                    if !parsedItems.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("ĐÃ NHẬN DIỆN ĐƯỢC (\(parsedItems.filter { $0.isSelected }.count)/\(parsedItems.count))")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color.green.opacity(0.9))

                                Spacer()

                                Button("Chọn tất cả") {
                                    for i in parsedItems.indices {
                                        parsedItems[i].isSelected = true
                                    }
                                }
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color(red: 0.18, green: 0.58, blue: 1.0))
                            }

                            VStack(spacing: 8) {
                                ForEach(parsedItems.indices, id: \.self) { idx in
                                    let item = parsedItems[idx]
                                    HStack(spacing: 10) {
                                        Button {
                                            parsedItems[idx].isSelected.toggle()
                                        } label: {
                                            Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 18))
                                                .foregroundStyle(item.isSelected ? Color(red: 0.18, green: 0.58, blue: 1.0) : Color.white.opacity(0.3))
                                        }

                                        Text(item.dayName)
                                            .font(.system(size: 11, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 6))

                                        Text(item.isAllDay ? "Cả ngày" : String(format: "%02d:%02d–%02d:%02d", item.startHour, item.startMinute, item.endHour, item.endMinute))
                                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                                            .foregroundStyle(.white.opacity(0.85))

                                        Text(item.title)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(item.category.color)
                                            .lineLimit(1)

                                        Spacer()
                                    }
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(red: 0.12, green: 0.13, blue: 0.17))
                                    )
                                }
                            }

                            // Nút xác nhận lưu vào bảng
                            Button {
                                importConfirmedItems()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Thêm \(parsedItems.filter { $0.isSelected }.count) Lịch Trình Vào Bảng")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.18, green: 0.58, blue: 1.0), Color(red: 0.42, green: 0.36, blue: 0.91)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Color.blue.opacity(0.35), radius: 8, y: 3)
                            }
                            .disabled(parsedItems.filter { $0.isSelected }.isEmpty)
                            .padding(.top, 6)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(red: 0.08, green: 0.09, blue: 0.12).ignoresSafeArea())
            .navigationTitle("Nhập Lịch Thông Minh")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Đóng") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                }
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraCaptureView { image in
                    processImage(image)
                }
            }
        }
    }

    private func processPhotoItem(_ item: PhotosPickerItem) {
        isScanningOCR = true
        ocrErrorMessage = nil

        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    await MainActor.run {
                        self.ocrErrorMessage = "Không thể đọc dữ liệu ảnh."
                        self.isScanningOCR = false
                    }
                    return
                }

                let text = try await ScheduleOCRScanner.recognizeText(from: image)
                await MainActor.run {
                    self.inputText = text
                    self.runParser(on: text)
                    self.isScanningOCR = false
                }
            } catch {
                await MainActor.run {
                    self.ocrErrorMessage = error.localizedDescription
                    self.isScanningOCR = false
                }
            }
        }
    }

    private func processImage(_ image: UIImage) {
        isScanningOCR = true
        ocrErrorMessage = nil

        Task {
            do {
                let text = try await ScheduleOCRScanner.recognizeText(from: image)
                await MainActor.run {
                    self.inputText = text
                    self.runParser(on: text)
                    self.isScanningOCR = false
                }
            } catch {
                await MainActor.run {
                    self.ocrErrorMessage = error.localizedDescription
                    self.isScanningOCR = false
                }
            }
        }
    }

    private func runParser(on text: String) {
        parsedItems = ScheduleTextParser.parse(text: text)
    }

    private func importConfirmedItems() {
        let monday = currentMonday

        for item in parsedItems where item.isSelected {
            guard let targetDate = calendar.date(byAdding: .day, value: item.dayOffset, to: monday) else { continue }

            let start = calendar.date(
                bySettingHour: item.startHour,
                minute: item.startMinute,
                second: 0,
                of: targetDate
            ) ?? targetDate

            let end = calendar.date(
                bySettingHour: item.endHour,
                minute: item.endMinute,
                second: 0,
                of: targetDate
            ) ?? start.addingTimeInterval(3600)

            let event = CalendarEvent(
                title: item.title,
                startDate: start,
                endDate: end,
                category: item.category,
                isAllDay: item.isAllDay,
                isRecurringWeekly: isRecurringWeekly,
                hasReminder: hasReminder
            )

            viewModel.add(event)

            if hasReminder {
                NotificationManager.shared.scheduleNotification(for: event)
            }
        }

        dismiss()
    }

    private func promptChip(title: String, prompt: String) -> some View {
        Button {
            inputText = prompt
            runParser(on: prompt)
        } label: {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.08))
                .foregroundStyle(.white.opacity(0.9))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        }
    }
}

/// Giao diện máy ảnh chụp thời khóa biểu
struct CameraCaptureView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, onImageCaptured: onImageCaptured)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let dismiss: DismissAction
        let onImageCaptured: (UIImage) -> Void

        init(dismiss: DismissAction, onImageCaptured: @escaping (UIImage) -> Void) {
            self.dismiss = dismiss
            self.onImageCaptured = onImageCaptured
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
