import SwiftUI
import WidgetKit

@main
struct LichTuanWidget: Widget {
    let kind: String = "LichTuanWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeekTimelineProvider()) { entry in
            WidgetRootView(entry: entry)
        }
        .configurationDisplayName("Lich Tuan")
        .description("Lich tuan va tom tat su kien sap toi.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .systemLarge])
    }
}
