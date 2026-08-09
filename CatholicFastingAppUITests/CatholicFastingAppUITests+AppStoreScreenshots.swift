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
            openSurface("Fast", in: app)
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
            openSurface("Calendar", in: app)
        }

        try captureAppStoreScreen("05-premium") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openMoreDestination("Support & Premium", in: app)
            XCTAssertTrue(scrollToElement(elementByIdentifier("premium.journey.preview", in: app), in: app))
        }
    }

    func testIPhoneChromeScreenshots() throws {
        try XCTSkipIf(
            AppStoreScreenshotConfig.load() == nil,
            "Run through scripts/generate_app_store_screenshots.sh to enable screenshot capture.")

        let config = AppStoreScreenshotConfig.load()
        let app = makeApp(
            regionProfile: config?.regionProfile,
            languageMode: config?.languageMode,
            premiumUnlocked: true)
        defer { app.terminate() }
        app.launch()
        ensureOnHomeScreen(app)

        openSurface("Fast", in: app)
        XCTAssertTrue(app.otherElements["surface.intermittent.ready"].waitForExistence(timeout: 4))
        app.swipeUp()
        try captureCurrentScreen("06-chrome-fast-scrolled", in: app)

        openSurface("Calendar", in: app)
        XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].waitForExistence(timeout: 4))
        app.swipeUp()
        try captureCurrentScreen("07-chrome-calendar-scrolled", in: app)

        openMoreDestination("Support & Premium", in: app)
        let toolsSegment = app.buttons["Premium Tools"].firstMatch
        guard revealAndTapForScreenshot(toolsSegment, named: "Premium Tools", in: app) else { return }
        app.swipeUp()
        try captureCurrentScreen("08-chrome-more-premium-scrolled", in: app)

        let plannerRow = elementByIdentifier("premium.tool.planner", in: app)
        guard revealAndTapForScreenshot(plannerRow, named: "Planner", in: app) else { return }
        XCTAssertTrue(elementByIdentifier("premium.planner", in: app).waitForExistence(timeout: 4))
        app.swipeUp()
        try captureCurrentScreen("09-chrome-premium-planner-scrolled", in: app)
    }

    func testIPadAppStoreScreenshots() throws {
        try XCTSkipIf(
            AppStoreScreenshotConfig.load() == nil,
            "Run through scripts/generate_app_store_screenshots.sh to enable screenshot capture.")

        try captureAppStoreScreen("01-today") { app in
            app.launch()
            ensureOnHomeScreen(app)
            assertIPadWorkspaceVisible("today", in: app)
        }

        try captureAppStoreScreen("02-track-fast", seedActiveFast: true) { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadSurface("intermittent", in: app)
            let workspaceReady = app.otherElements["surface.intermittent.ready"].waitForExistence(timeout: 8)
                || elementByIdentifier("ipad.intermittent.live", in: app).waitForExistence(timeout: 8)
            XCTAssertTrue(workspaceReady)
            XCTAssertTrue(scrollToElementPresence(elementByIdentifier("ipad.intermittent.live", in: app), in: app))
        }

        try captureAppStoreScreen("03-privacy", initialMoreDestination: "privacyAndData") { app in
            app.launch()
            XCTAssertTrue(app.otherElements["home.ready"].waitForExistence(timeout: 4))
            assertIPadWorkspaceVisible("more", in: app)
            XCTAssertTrue(scrollToElementPresence(elementByIdentifier("launch.export_data", in: app), in: app))
        }

        try captureAppStoreScreen("04-fasting-days") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadSurface("fastingDays", in: app)
            XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("05-premium", initialMoreDestination: "supportAndPremium") { app in
            app.launch()
            XCTAssertTrue(app.otherElements["home.ready"].waitForExistence(timeout: 4))
            XCTAssertTrue(app.otherElements["ipad.more.premium"].waitForExistence(timeout: 4))
        }
    }

    func testIPadChromeScreenshots() throws {
        try XCTSkipIf(
            AppStoreScreenshotConfig.load() == nil,
            "Run through scripts/generate_app_store_screenshots.sh to enable screenshot capture.")

        let config = AppStoreScreenshotConfig.load()
        let app = makeApp(
            seedActiveFast: true,
            regionProfile: config?.regionProfile,
            languageMode: config?.languageMode,
            premiumUnlocked: true)
        defer { app.terminate() }
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)
        XCTAssertTrue(elementByIdentifier("ipad.intermittent.live", in: app).waitForExistence(timeout: 4))
        app.swipeUp()
        try captureCurrentScreen("06-chrome-fast-scrolled", in: app)

        openIPadSurface("fastingDays", in: app)
        XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].waitForExistence(timeout: 4))
        app.swipeUp()
        try captureCurrentScreen("07-chrome-calendar-scrolled", in: app)

        openIPadMoreDestination("supportAndPremium", in: app)
        XCTAssertTrue(app.otherElements["ipad.more.premium"].waitForExistence(timeout: 4))
        app.swipeUp()
        try captureCurrentScreen("08-chrome-more-premium-scrolled", in: app)
    }

    func testIPhoneFastQAScreenshots() throws {
        try XCTSkipIf(
            AppStoreScreenshotConfig.load() == nil,
            "Run through scripts/generate_track_fast_qa_screenshots.sh to enable screenshot capture.")

        try captureAppStoreScreen("01-track-fast-idle") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openSurface("Fast", in: app)
            XCTAssertTrue(app.staticTexts["intermittent.no_active"].firstMatch.waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("02-track-fast-active", seedActiveFast: true) { app in
            app.launch()
            ensureOnHomeScreen(app)
            openSurface("Fast", in: app)
            let elapsed = app.staticTexts["intermittent.active_elapsed"].firstMatch
            XCTAssertTrue(elapsed.waitForExistence(timeout: 4))
            XCTAssertTrue(elementIsVisible(elapsed, in: app))
        }

        try captureAppStoreScreen("03-track-fast-recap", seedActiveFast: true) { app in
            app.launch()
            ensureOnHomeScreen(app)
            openSurface("Fast", in: app)
            let endButton = app.buttons["intermittent.end_fast"].firstMatch
            XCTAssertTrue(endButton.waitForExistence(timeout: 4) || scrollToElement(endButton, in: app, maxSwipes: 4))
            endButton.tap()
            XCTAssertTrue(elementByIdentifier("intermittent.recap_card", in: app).waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("04-track-fast-history", seedActiveFast: true) { app in
            app.launch()
            ensureOnHomeScreen(app)
            openSurface("Fast", in: app)
            let endButton = app.buttons["intermittent.end_fast"].firstMatch
            XCTAssertTrue(endButton.waitForExistence(timeout: 4) || scrollToElement(endButton, in: app, maxSwipes: 4))
            endButton.tap()
            let disclosure = elementByIdentifier("intermittent.advanced.disclosure", in: app)
            XCTAssertTrue(scrollToElement(disclosure, in: app, maxSwipes: 8))
            disclosure.tap()
            XCTAssertTrue(scrollToElement(elementByIdentifier("intermittent.session_row", in: app), in: app, maxSwipes: 12))
            swipePageUp(in: app)
        }
    }

    func testIPadFastQAScreenshots() throws {
        try XCTSkipIf(
            AppStoreScreenshotConfig.load() == nil,
            "Run through scripts/generate_track_fast_qa_screenshots.sh to enable screenshot capture.")

        try captureAppStoreScreen("01-ipad-track-fast-workspace", seedActiveFast: true) { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadSurface("intermittent", in: app)
            XCTAssertTrue(elementByIdentifier("ipad.intermittent.live", in: app).waitForExistence(timeout: 4))
            XCTAssertTrue(app.buttons["ipad.intermittent.end"].waitForExistence(timeout: 4))
            XCTAssertTrue(elementIsVisible(elementByIdentifier("ipad.intermittent.live", in: app), in: app))
        }
    }

    func testIPhoneAppCleanQAScreenshots() throws {
        try XCTSkipIf(
            AppStoreScreenshotConfig.load() == nil,
            "Run through scripts/generate_app_clean_qa_screenshots.sh to enable screenshot capture.")

        try captureAppStoreScreen("01-today") { app in
            app.launch()
            ensureOnHomeScreen(app)
            XCTAssertTrue(app.otherElements["surface.today.ready"].firstMatch.waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("02-fasting-days") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openSurface("Calendar", in: app)
            XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].firstMatch.waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("03-track-fast-active", seedActiveFast: true) { app in
            app.launch()
            ensureOnHomeScreen(app)
            openSurface("Fast", in: app)
            XCTAssertTrue(app.staticTexts["intermittent.active_elapsed"].firstMatch.waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("04-premium") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openMoreDestination("Support & Premium", in: app)
            XCTAssertTrue(elementByIdentifier("premium.journey.preview", in: app).waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("05-more-hub") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openSurface("More", in: app)
            XCTAssertTrue(app.otherElements["surface.more.ready"].waitForExistence(timeout: 4))
        }
    }

    func testIPadAppCleanQAScreenshots() throws {
        try XCTSkipIf(
            AppStoreScreenshotConfig.load() == nil,
            "Run through scripts/generate_app_clean_qa_screenshots.sh to enable screenshot capture.")

        try captureAppStoreScreen("01-ipad-today") { app in
            app.launch()
            ensureOnHomeScreen(app)
            assertIPadWorkspaceVisible("today", in: app)
        }

        try captureAppStoreScreen("02-ipad-fasting-days") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadSurface("fastingDays", in: app)
            assertIPadWorkspaceVisible("fastingDays", in: app)
            let yearPicker = elementByIdentifier("ipad.fasting_days.year", in: app)
            XCTAssertTrue(yearPicker.waitForExistence(timeout: 4))
            XCTAssertEqual(yearPicker.value as? String, "2026", "Calendar years must render as verbatim dates without thousands separators")
        }

        try captureAppStoreScreen("03-ipad-track-fast", seedActiveFast: true) { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadSurface("intermittent", in: app)
            XCTAssertTrue(elementByIdentifier("ipad.intermittent.live", in: app).waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("04-ipad-premium") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadMoreDestination("supportAndPremium", in: app)
            XCTAssertTrue(app.otherElements["ipad.more.premium"].waitForExistence(timeout: 4))
            XCTAssertTrue(elementByIdentifier("premium.plan_choice_state", in: app).waitForExistence(timeout: 4))
        }

        try captureAppStoreScreen("05-ipad-more") { app in
            app.launch()
            ensureOnHomeScreen(app)
            openIPadSurface("more", in: app)
            XCTAssertTrue(app.otherElements["ipad.more.premium"].waitForExistence(timeout: 4))
        }
    }

    private func captureAppStoreScreen(
        _ name: String,
        seedActiveFast: Bool = false,
        initialMoreDestination: String? = nil,
        configure: (XCUIApplication) throws -> Void) throws
    {
        let config = AppStoreScreenshotConfig.load()
        let app = makeApp(
            seedActiveFast: seedActiveFast,
            regionProfile: config?.regionProfile,
            languageMode: config?.languageMode,
            initialMoreDestination: initialMoreDestination,
            premiumUnlocked: true)
        defer { app.terminate() }
        try configure(app)
        dismissSystemNotificationBanner(in: app)
        waitForAppStoreScreenshotSettling()
        try writeAppStoreScreenshot(named: name)
    }

    private func captureCurrentScreen(_ name: String, in app: XCUIApplication) throws {
        dismissSystemNotificationBanner(in: app)
        waitForAppStoreScreenshotSettling()
        try writeAppStoreScreenshot(named: name, attachToResult: false)
    }

    private func revealAndTapForScreenshot(
        _ element: XCUIElement,
        named name: String,
        in app: XCUIApplication) -> Bool
    {
        if !element.waitForExistence(timeout: 1) || !element.isHittable {
            app.swipeUp()
        }
        guard element.waitForExistence(timeout: 2), element.isHittable else {
            XCTFail("Could not reveal \(name) with one deterministic swipe.")
            return false
        }
        element.tap()
        return true
    }

    private func dismissSystemNotificationBanner(in app: XCUIApplication) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let banner = springboard.otherElements["NotificationShortLookView"].firstMatch
        guard banner.exists else { return }

        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.14))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.02))
        start.press(forDuration: 0.05, thenDragTo: end)
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))
    }

    private func waitForAppStoreScreenshotSettling() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.6))
    }

    private func writeAppStoreScreenshot(named name: String, attachToResult: Bool = true) throws {
        guard let config = AppStoreScreenshotConfig.load() else {
            throw XCTSkip("App Store screenshot config is required.")
        }

        let deviceDirectory = config.deviceDirectory.isEmpty
            ? appStoreScreenshotDeviceDirectory
            : config.deviceDirectory
        let rawDirectory = config.rawDirectoryURL ?? URL(fileURLWithPath: config.outputRoot)
            .standardizedFileURL
            .appendingPathComponent(deviceDirectory)
            .appendingPathComponent("raw")
        try FileManager.default.createDirectory(at: rawDirectory, withIntermediateDirectories: true)

        let screenshot = XCUIScreen.main.screenshot()
        let destination = rawDirectory.appendingPathComponent("\(name).png")
        try screenshot.pngRepresentation.write(to: destination, options: [.atomic])
        if attachToResult {
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "App Store screenshot: \(name)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }

    private var appStoreScreenshotDeviceDirectory: String {
        UIDevice.current.userInterfaceIdiom == .pad ? "ipad-pro-13" : "iphone-17-pro-max"
    }
}

private struct AppStoreScreenshotConfig: Decodable {
    let outputRoot: String
    let deviceDirectory: String
    let rawDirectory: String?
    let languageMode: String?
    let regionProfile: String?

    var rawDirectoryURL: URL? {
        guard let rawDirectory, rawDirectory.isEmpty == false else {
            return nil
        }
        return URL(fileURLWithPath: rawDirectory).standardizedFileURL
    }

    static func load() -> Self? {
        let configURL = URL(fileURLWithPath: "/tmp/catholic-fasting-app-store-screenshot-config.json")
        guard let data = try? Data(contentsOf: configURL) else {
            return nil
        }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}
