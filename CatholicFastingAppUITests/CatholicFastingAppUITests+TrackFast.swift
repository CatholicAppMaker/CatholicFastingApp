import Foundation
import XCTest

extension CatholicFastingAppUITests {
    func testIntermittentCanStartAndCancelFast() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let startButton = app.buttons["intermittent.start_fast"].firstMatch
        XCTAssertTrue(scrollToElement(startButton, in: app))
        startButton.tap()

        let elapsed = app.staticTexts["intermittent.active_elapsed"].firstMatch
        XCTAssertTrue(scrollToElementPresence(elapsed, in: app))
        XCTAssertTrue(scrollToElement(app.datePickers["intermittent.start_date"].firstMatch, in: app))

        let cancelButton = app.buttons["intermittent.cancel_fast"].firstMatch
        XCTAssertTrue(scrollToElement(cancelButton, in: app))
        cancelButton.tap()

        XCTAssertTrue(app.staticTexts["intermittent.no_active"].firstMatch.waitForExistence(timeout: 4))
    }

    func testIntermittentCanEndFastAndWriteSessionHistory() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let startButton = app.buttons["intermittent.start_fast"].firstMatch
        XCTAssertTrue(scrollToElement(startButton, in: app))
        startButton.tap()

        let endButton = app.buttons["intermittent.end_fast"].firstMatch
        XCTAssertTrue(endButton.waitForExistence(timeout: 4))
        endButton.tap()

        let historyRow = app.descendants(matching: .any).matching(identifier: "intermittent.session_row")
            .firstMatch
        XCTAssertTrue(scrollToElement(historyRow, in: app))
    }

    func testIntermittentLockedCustomTargetCanOpenPremiumUpgrade() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let unlockButton = app.buttons["intermittent.unlock_custom_targets"].firstMatch
        XCTAssertTrue(scrollToElement(unlockButton, in: app))
        unlockButton.tap()

        let premiumHero = app.otherElements["premium.hero"].firstMatch
        XCTAssertTrue(premiumHero.waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Premium Upgrade"].firstMatch.exists)
    }

    func testIntermittentTargetPickerVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let targetPicker = elementByIdentifier("intermittent.target_picker", in: app)
        XCTAssertTrue(scrollToElement(targetPicker, in: app))
        XCTAssertTrue(scrollToElement(app.datePickers["intermittent.start_date"].firstMatch, in: app))
    }

    func testIntermittentDefaultViewPrioritizesLiveStateAndKeepsAdvancedCollapsed() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        XCTAssertTrue(app.staticTexts["intermittent.no_active"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.buttons["intermittent.start_fast"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("intermittent.advanced.disclosure", in: app), in: app))
        XCTAssertFalse(app.textFields["intermittent.schedule.name"].firstMatch.exists)
    }

    func testIntermittentAdvancedToolsCanExpandFromCollapsedDefault() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let disclosure = elementByIdentifier("intermittent.advanced.disclosure", in: app)
        XCTAssertTrue(scrollToElement(disclosure, in: app))
        disclosure.tap()

        let scheduleName = app.textFields["intermittent.schedule.name"].firstMatch
        XCTAssertTrue(scrollToElement(scheduleName, in: app))
        XCTAssertTrue(app.otherElements["intermittent.history_empty"].firstMatch.exists)
    }

    func testIPadTrackFastPresetSelectionStaysVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        let sixteen = app.buttons["ipad.intermittent.plan.16"].firstMatch
        XCTAssertTrue(scrollToElement(sixteen, in: app))
        sixteen.tap()

        let twentyFour = app.buttons["ipad.intermittent.plan.24"].firstMatch
        XCTAssertTrue(scrollToElement(twentyFour, in: app))
        twentyFour.tap()

        XCTAssertTrue(app.otherElements["ipad.intermittent.controls"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.buttons["ipad.intermittent.start"].firstMatch, in: app))
    }

    func testIPadTrackFastShowsLiveWorkspaceAndControls() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        XCTAssertTrue(app.otherElements["ipad.intermittent.live"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.intermittent.controls"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.intermittent.planning"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.intermittent.advanced"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.intermittent.history"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.datePickers["ipad.intermittent.start_date"].firstMatch, in: app))
    }

    func testIPadTrackFastKeepsStartedTimeEditableAfterStart() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        let startButton = app.buttons["ipad.intermittent.start"].firstMatch
        XCTAssertTrue(scrollToElement(startButton, in: app))
        startButton.tap()

        XCTAssertTrue(scrollToElement(app.datePickers["ipad.intermittent.start_date"].firstMatch, in: app))
    }

    func testIPadTrackFastDefaultsToLiveControlsAndCollapsedAdvancedTools() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        XCTAssertTrue(app.staticTexts["No active fast"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.buttons["ipad.intermittent.start"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.otherElements["ipad.intermittent.advanced"].firstMatch, in: app))
        XCTAssertFalse(app.textFields["intermittent.schedule.name"].firstMatch.exists)
        XCTAssertTrue(scrollToElement(app.otherElements["ipad.intermittent.history"].firstMatch, in: app))
    }

    func testIPadTrackFastAdvancedToolsCanExpandWithoutHidingHistory() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        let disclosure = app.otherElements["ipad.intermittent.advanced.disclosure"].firstMatch
        XCTAssertTrue(scrollToElement(disclosure, in: app))
        disclosure.tap()

        let scheduleName = app.textFields["intermittent.schedule.name"].firstMatch
        XCTAssertTrue(scrollToElement(scheduleName, in: app))
        XCTAssertTrue(scrollToElement(app.otherElements["ipad.intermittent.history"].firstMatch, in: app))
    }
}
