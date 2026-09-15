import SwiftUI

/// Màn hình debug dùng để nhìn trước các family widget khi không có Simulator.
struct WidgetPreviewHostView: View {
    private let sampleEntry = WeekTimelineBuilder.makeEntry(
        referenceDate: .now,
        events: SharedEventSeed.sampleEvents
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Xem trước widget")
                    .font(.title.bold())

                Text("Màn hình xem trước các kích thước widget.")
                    .foregroundStyle(.secondary)

                previewSection(title: "Tròn trên màn hình khóa") {
                    LockScreenSummaryView(entry: sampleEntry, style: .circular)
                        .frame(width: 76, height: 76)
                }

                previewSection(title: "Chữ nhật trên màn hình khóa") {
                    LockScreenSummaryView(entry: sampleEntry, style: .rectangular)
                        .frame(width: 172, height: 76)
                }

                previewSection(title: "Dòng trên màn hình khóa") {
                    LockScreenSummaryView(entry: sampleEntry, style: .inline)
                        .frame(width: 340, height: 44)
                }

                previewSection(title: "Widget lớn") {
                    WeekGridView(entry: sampleEntry)
                        .frame(width: 364, height: 382)
                }

                previewSection(title: "Màu danh mục") {
                    EventPalettePreviewView()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
        }
        .accessibilityIdentifier("WidgetPreviewHost")
    }

    private func previewSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

private struct EventPalettePreviewView: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 10)], spacing: 10) {
            ForEach(EventCategory.allCases) { category in
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.gradient(for: category))
                        .frame(height: 64)
                        .overlay {
                            Image(systemName: category.symbolName)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .widgetAccentable()
                        }
                    Text(category.displayName)
                        .font(.caption.weight(.semibold))
                }
            }
        }
    }
}

#Preview {
    WidgetPreviewHostView()
}
