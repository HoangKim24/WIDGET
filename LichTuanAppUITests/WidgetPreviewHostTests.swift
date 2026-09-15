import XCTest

final class WidgetPreviewHostTests: XCTestCase {
    func testCaptureWidgetPreviews() {
        let app = XCUIApplication()

        app.launch()
        let mainScreenshot = XCTAttachment(screenshot: app.screenshot())
        mainScreenshot.name = "main-calendar-screen"
        mainScreenshot.lifetime = .keepAlways
        add(mainScreenshot)

        app.terminate()
        app.launchArguments = ["UITEST_WIDGET_PREVIEW"]
        app.launch()

        let host = app.descendants(matching: .any)["WidgetPreviewHost"]
        XCTAssertTrue(host.waitForExistence(timeout: 15))

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "widget-preview-host"
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
