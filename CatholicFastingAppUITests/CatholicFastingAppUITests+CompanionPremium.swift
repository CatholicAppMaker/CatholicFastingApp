import Foundation
import UIKit
import XCTest

private struct CompanionPremiumExpectation {
    let rawValue: String
    let title: String
    let contentID: String
}

private let companionPremiumExpectations = [
    CompanionPremiumExpectation(rawValue: "planner", title: "Planner", contentID: "premium.planner"),
    CompanionPremiumExpectation(rawValue: "reminders", title: "Reminders", contentID: "premium.reminders"),
    CompanionPremiumExpectation(rawValue: "analytics", title: "Analytics", contentID: "premium.analytics"),
    CompanionPremiumExpectation(rawValue: "journal", title: "Journal", contentID: "premium.reflection"),
    CompanionPremiumExpectation(rawValue: "export", title: "Export", contentID: "premium.export_summary"),
]

extension CatholicFastingAppUITests {
    func testIPadCompanionPremiumToolsReachEveryDestination() {
        let app = makeApp(premiumUnlocked: true)
        app.launch()
        ensureOnHomeScreen(app)
        openIPadSurface("today", in: app)

        assertIPadPremiumToolsReachEveryDestination(in: app)
    }

    func testIPadMorePremiumToolsReachEveryDestination() {
        let app = makeApp(premiumUnlocked: true)
        app.launch()
        ensureOnHomeScreen(app)
        openIPadSurface("more", in: app)

        assertIPadPremiumToolsReachEveryDestination(in: app)
    }

    func testIPadCompanionPremiumToolsKeepUpgradeReachableWhenLocked() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openIPadSurface("today", in: app)

        assertIPadPremiumUpgradeReachable(in: app)
    }

    func testIPadMorePremiumToolsKeepUpgradeReachableWhenLocked() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openIPadSurface("more", in: app)

        assertIPadPremiumUpgradeReachable(in: app)
    }

    private func assertIPadPremiumToolsReachEveryDestination(in app: XCUIApplication) {
        let toolsCard = elementByIdentifier("ipad.premium.tools", in: app)
        XCTAssertTrue(scrollToElement(toolsCard, in: app, maxSwipes: 12))

        for expectation in companionPremiumExpectations {
            let row = elementByIdentifier("ipad.premium.tool.\(expectation.rawValue)", in: app)
            XCTAssertTrue(
                scrollToElement(row, in: app, maxSwipes: 12),
                "Unable to find iPad companion Premium row \(expectation.rawValue)")
            row.tap()

            XCTAssertTrue(
                app.navigationBars[expectation.title].waitForExistence(timeout: 4),
                "iPad Premium destination \(expectation.title) did not open")
            XCTAssertTrue(
                elementByIdentifier(expectation.contentID, in: app).waitForExistence(timeout: 4),
                "iPad Premium destination \(expectation.title) content is missing")

            let backButton = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(backButton.waitForExistence(timeout: 3))
            backButton.tap()
            XCTAssertTrue(toolsCard.waitForExistence(timeout: 4))
        }
    }

    private func assertIPadPremiumUpgradeReachable(in app: XCUIApplication) {
        let toolsCard = elementByIdentifier("ipad.premium.tools", in: app)
        XCTAssertTrue(scrollToElement(toolsCard, in: app, maxSwipes: 12))
        XCTAssertTrue(elementByIdentifier("ipad.premium.tools.upgrade", in: app).waitForExistence(timeout: 4))
        XCTAssertFalse(elementByIdentifier("ipad.premium.tool.planner", in: app).exists)

        app.buttons["ipad.premium.tools.upgrade"].tap()
        assertIPadWorkspaceVisible("more", in: app)
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.plan_choice", in: app), in: app))
    }
}
