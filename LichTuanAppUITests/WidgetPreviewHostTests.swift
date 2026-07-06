import XCTest

final class WidgetPreviewHostTests: XCTestCase {
    func testCaptureWidgetPreviews() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_WIDGET_PREVIEW"]
        app.launch()

        let host = app.otherElements["WidgetPreviewHost"]
        XCTAssertTrue(host.waitForExistence(timeout: 15))

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
