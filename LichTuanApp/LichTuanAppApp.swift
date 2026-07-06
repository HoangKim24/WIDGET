import SwiftUI

@main
struct LichTuanAppApp: App {
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.arguments.contains("UITEST_WIDGET_PREVIEW") {
                WidgetPreviewHostView()
            } else {
                ContentView()
            }
        }
    }
}

