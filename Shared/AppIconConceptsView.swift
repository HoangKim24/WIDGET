import SwiftUI

/// Ba phương án phối màu cho App Icon để xem trước bằng SwiftUI trước khi xuất PNG.
struct AppIconConceptsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("App Icon Concepts")
                    .font(.title.bold())

                Text("Ba hướng phối màu/gradient khác nhau để chọn trước khi xuất file icon thật.")
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    AppIconCard(
                        title: "Dawn Calendar",
                        subtitle: "Primary + accent, sáng và rõ",
                        background: AppColors.iconGradient(start: AppColors.primary, end: AppColors.accent),
                        foregroundSymbol: "calendar.circle.fill"
                    )

                    AppIconCard(
                        title: "Aurora Week",
                        subtitle: "Lớp gradient xanh/tím hiện đại",
                        background: AppColors.iconGradient(start: Color("CategoryStudy"), end: Color("CategoryWork")),
                        foregroundSymbol: "rectangle.grid.2x2.fill"
                    )

                    AppIconCard(
                        title: "Warm Schedule",
                        subtitle: "Ấm hơn, gần gũi hơn",
                        background: AppColors.iconGradient(start: Color("CategoryFamily"), end: Color("CategoryPersonal")),
                        foregroundSymbol: "calendar.badge.clock"
                    )
                }
            }
            .padding(16)
        }
    }
}

private struct AppIconCard: View {
    let title: String
    let subtitle: String
    let background: LinearGradient
    let foregroundSymbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(background)
                    .frame(height: 180)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white.opacity(0.12))
                    .frame(width: 116, height: 116)
                    .overlay {
                        Image(systemName: foregroundSymbol)
                            .font(.system(size: 50, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
            }

            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("App Icon Concepts") {
    AppIconConceptsView()
}

#Preview("App Icon Concepts - Compact") {
    AppIconConceptsView()
        .frame(width: 390, height: 844)
        .background(Color(.systemBackground))
}
