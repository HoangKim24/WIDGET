import SwiftUI

/// Màn hình hướng dẫn chi tiết người dùng thiết lập Tự Động Hóa Màn Hình Khóa
/// qua ứng dụng Phím Tắt (Shortcuts) có sẵn trên iPhone (tương tự LockScreen Calendar Maker).
struct AutoWallpaperSetupGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)

                            Image(systemName: "bolt.badge.automatic.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                        }
                        .padding(.top, 8)

                        Text("Tự Động Hóa Màn Hình Khóa")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Hình nền lịch tự nhảy sang ngày mới mỗi sáng hoặc mỗi khi đóng app mà không cần đổi ảnh thủ công.")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 6)

                    // 3 Bước Cài Đặt Chi Tiết
                    VStack(alignment: .leading, spacing: 14) {
                        Text("3 BƯỚC CÀI ĐẶT (CHỈ LÀM 1 LẦN)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.blue.opacity(0.9))
                            .tracking(0.5)

                        guideStepRow(
                            number: "1",
                            title: "Mở ứng dụng Phím Tắt (Shortcuts)",
                            description: "Phím Tắt là ứng dụng chính thức của Apple có sẵn trên iPhone của bạn."
                        )

                        guideStepRow(
                            number: "2",
                            title: "Tạo Phím Tắt 'Cập Nhật Lịch Tuần'",
                            description: "Vào tab Phím tắt > Bấm '+' > Thêm tác vụ 'Cập Nhật Hình Nền Lịch Tuần' > Thêm tác vụ 'Đặt hình nền' (Màn hình khóa) > Đổi tên phím tắt thành: Cập Nhật Lịch Tuần."
                        )

                        guideStepRow(
                            number: "3",
                            title: "Bấm 'Cập Nhật' Trong App Là Đổi Ngay",
                            description: "Bất cứ lúc nào bấm nút 'Cập Nhật' trong app này, máy sẽ tự động chạy phím tắt và đổi màn hình khóa ngay lập tức! Bạn cũng có thể gắn phím tắt này vào tab Tự Động Hóa 00:01 để đổi mỗi đêm."
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(red: 0.12, green: 0.13, blue: 0.17))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    )

                    // Lưu ý quan trọng
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.yellow)

                        Text("Màn hình khóa của iPhone cần được tạo từ một tấm 'Ảnh' (Photo) để iOS cho phép Phím Tắt ghi đè hình nền tự động.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.yellow.opacity(0.12))
                    )

                    // Nút Mở Phím Tắt
                    Button {
                        if let url = URL(string: "shortcuts://") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.forward.app.fill")
                                .font(.system(size: 16))
                            Text("Mở Ứng Dụng Phím Tắt (Shortcuts)")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.18, green: 0.58, blue: 1.0), Color(red: 0.42, green: 0.36, blue: 0.91)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.blue.opacity(0.35), radius: 8, y: 3)
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .background(Color(red: 0.08, green: 0.08, blue: 0.10).ignoresSafeArea())
            .navigationTitle("Tự Động Hóa")
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
        }
    }

    private func guideStepRow(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color(red: 0.18, green: 0.58, blue: 1.0)))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)

                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
