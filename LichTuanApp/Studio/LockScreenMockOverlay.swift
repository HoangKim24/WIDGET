import SwiftUI

/// Lớp phủ mô phỏng màn hình khóa iOS 17/18 chân thực trên iPhone 15.
/// Giúp người dùng căn chỉnh vị trí lịch không bị che khuất bởi đồng hồ hệ thống.
struct LockScreenMockOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            ZStack {
                // MARK: - Dynamic Island
                VStack {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: w * 0.32, height: h * 0.038)
                        .overlay(
                            HStack {
                                Circle()
                                    .fill(Color(white: 0.15))
                                    .frame(width: 10, height: 10)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                        )
                        .padding(.top, h * 0.015)
                    Spacer()
                }

                // MARK: - Status Bar (Cột sóng, Wifi, Pin)
                VStack {
                    HStack {
                        Text("Viettel")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName: "cellularbars")
                            Image(systemName: "wifi")
                            Image(systemName: "battery.100")
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, h * 0.018)
                    Spacer()
                }

                // MARK: - Cụm Đồng Hồ Màn Hình Khóa iOS (Né Lịch)
                VStack(spacing: 2) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.top, h * 0.065)

                    Text(currentVietnameseDateString())
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))

                    Text("09:41")
                        .font(.system(size: 78, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)

                    Spacer()
                }

                // MARK: - Hai Nút Tròn Đáy: Đèn Pin & Camera + Thanh Home
                VStack {
                    Spacer()

                    HStack {
                        // Nút Đèn Pin
                        Circle()
                            .fill(Material.ultraThinMaterial)
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "flashlight.on.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white)
                            )

                        Spacer()

                        // Nút Camera
                        Circle()
                            .fill(Material.ultraThinMaterial)
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white)
                            )
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, h * 0.04)

                    // Thanh Home Indicator
                    Capsule()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: w * 0.35, height: 5)
                        .padding(.bottom, 8)
                }
            }
            .allowsHitTesting(false) // Để người dùng vẫn chạm vào canvas bên dưới
        }
    }

    private func currentVietnameseDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, d 'tháng' M"
        let raw = formatter.string(from: Date())
        return raw.prefix(1).uppercased() + raw.dropFirst()
    }
}
