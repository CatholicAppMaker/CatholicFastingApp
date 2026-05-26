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

        XCTAssertTrue(scrollToElement(app.staticTexts["intermittent.no_active"].firstMatch, in: app))
    }

    func testIntermittentCanEndFastAndWriteSessionHistory() {
        let app = makeApp(seedActiveFast: true)
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let noteField = app.textFields["intermittent.recap_note"].firstMatch
        if scrollToElementPresence(noteField, in: app, maxSwipes: 8) {
            noteField.tap()
            noteField.typeText("Parish intention")
        }

        let endButton = app.buttons["intermittent.end_fast"].firstMatch
        XCTAssertTrue(scrollToElementPresence(endButton, in: app, maxSwipes: 8))
        XCTAssertTrue(scrollToElement(endButton, in: app, maxSwipes: 8))
        endButton.tap()

        XCTAssertTrue(scrollToElementPresence(elementByIdentifier("intermittent.recap_card", in: app), in: app, maxSwipes: 8))
        let sessionsMetric = elementByIdentifier("intermittent.metric.sessions", in: app)
        XCTAssertTrue(scrollToElementPresence(sessionsMetric, in: app, maxSwipes: 8))
        let sessionSaved = NSPredicate(format: "value == '1'")
        expectation(for: sessionSaved, evaluatedWith: sessionsMetric)
        waitForExpectations(timeout: 4)
    }

    func testIntermittentLockedCustomTargetCanOpenPremiumUpgrade() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let unlockButton = app.buttons["intermittent.unlock_custom_targets"].firstMatch
        XCTAssertTrue(scrollToElement(unlockButton, in: app, maxSwipes: 12))
        unlockButton.tap()

        XCTAssertTrue(app.otherElements["surface.more.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(
            app.staticTexts["Premium Upgrade"].firstMatch.waitForExistence(timeout: 4)
                || elementByIdentifier("premium.hero", in: app).waitForExistence(timeout: 4))
    }

    func testIntermittentTargetPickerVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let targetPicker = elementByIdentifier("intermittent.target_picker", in: app)
        XCTAssertTrue(scrollToElement(targetPicker, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("intermittent.intention_picker", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["intermittent.intention_detail"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("intermittent.target_reminder", in: app), in: app))
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

        let editorToggle = elementByIdentifier("intermittent.schedule.toggle_editor", in: app)
        XCTAssertTrue(scrollToElement(editorToggle, in: app, maxSwipes: 12))
        editorToggle.tap()

        let scheduleName = app.textFields["intermittent.schedule.name"].firstMatch
        XCTAssertTrue(scrollToElementPresence(scheduleName, in: app, maxSwipes: 12))
        XCTAssertTrue(scrollToElementPresence(elementByIdentifier("intermittent.history_empty", in: app), in: app, maxSwipes: 24))
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
        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.intention", in: app), in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.start", in: app), in: app))
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
        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.start_date", in: app), in: app))
    }

    func testIPadTrackFastKeepsStartedTimeEditableAfterStart() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        let startButton = elementByIdentifier("ipad.intermittent.start", in: app)
        XCTAssertTrue(scrollToElement(startButton, in: app))
        startButton.tap()

        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.start_date", in: app), in: app))
    }

    func testIPadTrackFastDefaultsToLiveControlsAndCollapsedAdvancedTools() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        XCTAssertTrue(app.staticTexts["No active fast"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.start", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.otherElements["ipad.intermittent.advanced"].firstMatch, in: app))
        XCTAssertFalse(app.textFields["intermittent.schedule.name"].firstMatch.exists)
        XCTAssertTrue(scrollToElement(app.otherElements["ipad.intermittent.history"].firstMatch, in: app))
    }

    func testIPadTrackFastAdvancedToolsCanExpandWithoutHidingHistory() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        let identifiedDisclosure = elementByIdentifier("ipad.intermittent.advanced.disclosure", in: app)
        let disclosure = identifiedDisclosure.exists
            ? identifiedDisclosure
            : app.buttons["Show advanced tools"].firstMatch
        XCTAssertTrue(scrollToElement(disclosure, in: app, maxSwipes: 4))
        disclosure.tap()

        let editorToggle = elementByIdentifier("intermittent.schedule.toggle_editor", in: app)
        XCTAssertTrue(scrollToElement(editorToggle, in: app, maxSwipes: 8))
        editorToggle.tap()

        let scheduleName = elementByIdentifier("intermittent.schedule.name", in: app)
        XCTAssertTrue(scrollToElement(scheduleName, in: app, maxSwipes: 4))
        XCTAssertTrue(scrollToElement(app.otherElements["ipad.intermittent.history"].firstMatch, in: app, maxSwipes: 8))
    }
}
