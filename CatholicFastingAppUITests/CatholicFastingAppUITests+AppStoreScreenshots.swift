import Foundation
import UIKit
import XCTest

extension CatholicFastingAppUITests {
    func testIPhoneAppStoreScreenshots() throws {
        try XCTSkipIf(
            AppStoreScreenshotConfig.load() == nil,
            "Run through scripts/generate_app_store_screenshots.sh to enable screenshot capture.")

        try captureAppStoreScreen("01-today") { app in
            app.launch()
            ensureOnHomeScreen(app)
            XCTAssertTrue(app.otherElements["surface.today.ready"].firstMatch.waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("02-track-fast", seedActiveFast: true) { app in
            app.launch()
            ensureOnHomeScreen(app)
            openSurface("Track Fast", in: app)
            XCTAssertTrue(app.staticTexts["intermittent.active_elapsed"].firstMatch.waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("03-privacy") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openMoreDestination("Privacy & Data", in: app)
            XCTAssertTrue(scrollToElementPresence(elementByIdentifier("launch.export_data", in: app), in: app))
        }

        try captureAppStoreScreen("04-fasting-days") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openSurface("Fasting Days", in: app)
        }

        try captureAppStoreScreen("05-premium") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openMoreDestination("Support & Premium", in: app)
            XCTAssertTrue(scrollToElement(elementByIdentifier("premium.sample_preview", in: app), in: app))
        }
    }

    func testIPadAppStoreScreenshots() throws {
        try XCTSkipIf(
            AppStoreScreenshotConfig.load() == nil,
            "Run through scripts/generate_app_store_screenshots.sh to enable screenshot capture.")

        try captureAppStoreScreen("01-today") { app in
            app.launch()
            ensureOnHomeScreen(app)
            XCTAssertTrue(app.otherElements["ipad.today.workspace"].waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("02-track-fast", seedActiveFast: true) { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadSurface("intermittent", in: app)
            XCTAssertTrue(app.otherElements["ipad.intermittent.live"].waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("03-privacy") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadSurface("more", in: app)
            let workspaceReady = app.otherElements["ipad.more.workspace"].firstMatch.waitForExistence(timeout: 4)
                || app.otherElements["surface.more.ready"].firstMatch.waitForExistence(timeout: 4)
            XCTAssertTrue(workspaceReady)
            _ = scrollToElementInApp(elementByIdentifier("ipad.more.destination.privacyAndData", in: app), in: app)
        }

        try captureAppStoreScreen("04-fasting-days") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadSurface("fastingDays", in: app)
            XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("05-premium") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadMoreDestination("supportAndPremium", in: app)
            XCTAssertTrue(app.otherElements["ipad.more.premium"].waitForExistence(timeout: 4))
        }
    }

    private func captureAppStoreScreen(
        _ name: String,
        seedActiveFast: Bool = false,
        configure: (XCUIApplication) throws -> Void) throws
    {
        let app = makeApp(seedActiveFast: seedActiveFast, premiumUnlocked: true)
        defer { app.terminate() }
        try configure(app)
        waitForAppStoreScreenshotSettling()
        try writeAppStoreScreenshot(named: name)
    }

    private func waitForAppStoreScreenshotSettling() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.6))
    }

    private func writeAppStoreScreenshot(named name: String) throws {
        guard let config = AppStoreScreenshotConfig.load() else {
            throw XCTSkip("App Store screenshot config is required.")
        }

        let deviceDirectory = config.deviceDirectory.isEmpty
            ? appStoreScreenshotDeviceDirectory
            : config.deviceDirectory
        let rawDirectory = URL(fileURLWithPath: config.outputRoot)
            .standardizedFileURL
            .appendingPathComponent(deviceDirectory)
            .appendingPathComponent("raw")
        try FileManager.default.createDirectory(at: rawDirectory, withIntermediateDirectories: true)

        let screenshot = XCUIScreen.main.screenshot()
        let destination = rawDirectory.appendingPathComponent("\(name).png")
        try screenshot.pngRepresentation.write(to: destination, options: [.atomic])
        add(XCTAttachment(screenshot: screenshot))
    }

    private var appStoreScreenshotDeviceDirectory: String {
        UIDevice.current.userInterfaceIdiom == .pad ? "ipad-pro-13" : "iphone-17-pro-max"
    }
}

private struct AppStoreScreenshotConfig: Decodable {
    let outputRoot: String
    let deviceDirectory: String

    static func load() -> Self? {
        let configURL = URL(fileURLWithPath: "/tmp/catholic-fasting-app-store-screenshot-config.json")
        guard let data = try? Data(contentsOf: configURL) else {
            return nil
        }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}
