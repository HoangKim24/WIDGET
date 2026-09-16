import SwiftUI

/// Màn hình thêm/sửa sự kiện. UI này chỉ lo nhập liệu, còn lưu dữ liệu do ContentView quyết định.
struct EventEditorView: View {
    private let existingEvent: CalendarEvent?
    private let onSave: (CalendarEvent) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var selectedCategory: EventCategory

    init(event: CalendarEvent?, onSave: @escaping (CalendarEvent) -> Void) {
        self.existingEvent = event
        self.onSave = onSave
        _title = State(initialValue: event?.title ?? "")
        _startDate = State(initialValue: event?.startDate ?? Date())
        _endDate = State(initialValue: event?.endDate ?? Date().addingTimeInterval(60 * 60))
        _isAllDay = State(initialValue: event?.isAllDay ?? false)
        _selectedCategory = State(initialValue: event?.category ?? .other)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    EditorHeroView(category: selectedCategory)

                    VStack(spacing: 14) {
                        editorCard(title: "Thông tin chung") {
                            TextField("Tên sự kiện", text: $title)
                                .textInputAutocapitalization(.words)

                            Picker("Danh mục", selection: $selectedCategory) {
                                ForEach(EventCategory.allCases) { category in
                                    Label(category.displayName, systemImage: category.symbolName)
                                        .tag(category)
                                }
                            }

                            Toggle("Cả ngày", isOn: $isAllDay)
                        }

                        editorCard(title: "Thời gian") {
                            DatePicker("Bắt đầu", selection: $startDate)
                            DatePicker("Kết thúc", selection: $endDate)
                        }

                        editorCard(title: "Xem trước") {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppColors.gradient(for: selectedCategory))
                                    .frame(width: 54, height: 54)
                                    .overlay {
                                        Image(systemName: selectedCategory.symbolName)
                                            .foregroundStyle(.white)
                                            .font(.title3.weight(.semibold))
                                    }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(selectedCategory.displayName)
                                        .font(.headline)
                                    Text("Màu sắc và biểu tượng được chọn theo danh mục.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle(existingEvent == nil ? "Thêm sự kiện" : "Sửa sự kiện")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(
                    colors: [AppColors.primary.opacity(0.14), AppColors.accent.opacity(0.10), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        saveEvent()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && endDate >= startDate
    }

    private func saveEvent() {
        let savedEvent = CalendarEvent(
            id: existingEvent?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate,
            category: selectedCategory,
            isAllDay: isAllDay
        )

        onSave(savedEvent)
        dismiss()
    }

    @ViewBuilder
    private func editorCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

private struct EditorHeroView: View {
    let category: EventCategory

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppColors.gradient(for: category))
                    .frame(width: 72, height: 72)

                Image(systemName: category.symbolName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Tạo sự kiện của bạn")
                    .font(.title2.bold())
                Text("Chọn danh mục và thời gian để tự động xuất hiện trên hình nền lịch của bạn.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColors.primary.opacity(0.18), lineWidth: 1)
        )
    }
}

#Preview {
    EventEditorView(event: nil) { _ in }
}
