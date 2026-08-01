import Foundation
import XCTest

extension CatholicFastingAppUITests {
    func testIPhoneFastCanStartAndCancel() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fast", in: app)

        let startButton = app.buttons["intermittent.start_fast"].firstMatch
        XCTAssertTrue(scrollToElement(startButton, in: app))
        startButton.tap()

        let elapsed = app.staticTexts["intermittent.active_elapsed"].firstMatch
        XCTAssertTrue(scrollToElementPresence(elapsed, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("intermittent.first_viewport_context", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.datePickers["intermittent.start_date"].firstMatch, in: app))

        let cancelButton = app.buttons["intermittent.cancel_fast"].firstMatch
        XCTAssertTrue(scrollToElementPresence(cancelButton, in: app, maxSwipes: 8))
        XCTAssertTrue(scrollToElement(cancelButton, in: app, maxSwipes: 20))
        let safeTapMinimumY = usableContentViewport(in: app).minY + 44
        if cancelButton.frame.midY < safeTapMinimumY {
            swipePageDown(in: app)
        }
        XCTAssertTrue(
            waitUntil(timeout: 3) {
                cancelButton.isHittable && cancelButton.frame.midY >= safeTapMinimumY
            },
            "Cancel did not move clear of the navigation bar")
        cancelButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let readyState = app.staticTexts["intermittent.no_active"].firstMatch
        let returnedStartButton = app.buttons["intermittent.start_fast"].firstMatch
        XCTAssertTrue(
            waitUntil(timeout: 4) {
                !cancelButton.exists && !elapsed.exists
            },
            "Cancel did not exit the active fast state")
        XCTAssertTrue(app.navigationBars["Fast"].firstMatch.exists)
        XCTAssertTrue(scrollToElementPresence(readyState, in: app, maxSwipes: 12))
        XCTAssertTrue(scrollToElement(returnedStartButton, in: app, maxSwipes: 12))
    }

    func testIPhoneFastCanEndAndWriteSessionHistory() {
        let app = makeApp(seedActiveFast: true)
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fast", in: app)

        let noteField = app.textFields["intermittent.recap_note"].firstMatch
        XCTAssertTrue(scrollToElementPresence(noteField, in: app, maxSwipes: 8))
        noteField.tap()
        noteField.typeText("Parish intention")
        let doneButton = app.buttons["intermittent.recap_note.done"].firstMatch
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3))
        doneButton.tap()
        XCTAssertTrue(waitUntil(timeout: 3, condition: { !app.keyboards.firstMatch.exists }))

        let endButton = app.buttons["intermittent.end_fast"].firstMatch
        XCTAssertTrue(scrollToElementPresence(endButton, in: app, maxSwipes: 8))
        XCTAssertTrue(scrollToElement(endButton, in: app, maxSwipes: 20))
        let safeTapMinimumY = usableContentViewport(in: app).minY + 44
        if endButton.frame.midY < safeTapMinimumY {
            swipePageDown(in: app)
        }
        XCTAssertTrue(
            waitUntil(timeout: 3) {
                endButton.isHittable && endButton.frame.midY >= safeTapMinimumY
            },
            "End & Review did not move clear of the navigation bar")
        endButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        let recapCard = elementByIdentifier("intermittent.recap_card", in: app)
        XCTAssertTrue(
            waitUntil(timeout: 4) {
                !app.buttons["intermittent.end_fast"].firstMatch.exists || recapCard.exists
            },
            "End & Review did not end the active fast")
        XCTAssertTrue(scrollToElementPresence(recapCard, in: app, maxSwipes: 20))
        XCTAssertTrue(String(describing: recapCard.value).localizedCaseInsensitiveContains("Parish intention"))
        let sessionsMetric = elementByIdentifier("intermittent.metric.sessions", in: app)
        XCTAssertTrue(scrollToElementPresence(sessionsMetric, in: app, maxSwipes: 20))
        let sessionSaved = NSPredicate(format: "value == '1'")
        expectation(for: sessionSaved, evaluatedWith: sessionsMetric)
        waitForExpectations(timeout: 4)
    }

    func testIPhoneFastLockedCustomTargetCanOpenPremiumUpgrade() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fast", in: app)

        let unlockButton = app.buttons["intermittent.unlock_custom_targets"].firstMatch
        XCTAssertTrue(scrollToElement(unlockButton, in: app, maxSwipes: 12))
        unlockButton.tap()

        XCTAssertTrue(app.otherElements["surface.more.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(elementByIdentifier("premium.surface_picker", in: app).waitForExistence(timeout: 4))
    }

    func testIPhoneFastPlanningControlsAreAvailable() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fast", in: app)

        let targetPicker = elementByIdentifier("intermittent.target_picker", in: app)
        XCTAssertTrue(scrollToElement(targetPicker, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("intermittent.intention_picker", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["intermittent.intention_detail"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("intermittent.target_reminder", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.datePickers["intermittent.start_date"].firstMatch, in: app))
    }

    func testIPhoneFastDefaultViewPrioritizesLiveStateAndKeepsAdvancedCollapsed() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fast", in: app)

        XCTAssertTrue(app.staticTexts["intermittent.no_active"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(elementIsVisible(app.buttons["intermittent.start_fast"].firstMatch, in: app))
        XCTAssertTrue(elementIsVisible(elementByIdentifier("intermittent.first_viewport_context", in: app), in: app))
        XCTAssertTrue(
            scrollToElement(
                elementByIdentifier("intermittent.advanced.disclosure", in: app),
                in: app,
                maxSwipes: 24))
        XCTAssertFalse(app.textFields["intermittent.schedule.name"].firstMatch.exists)
    }

    func testIPhoneFastAdvancedToolsCanExpandFromCollapsedDefault() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fast", in: app)

        let disclosure = elementByIdentifier("intermittent.advanced.disclosure", in: app)
        XCTAssertTrue(scrollToElement(disclosure, in: app, maxSwipes: 24))
        disclosure.tap()

        let editorToggle = elementByIdentifier("intermittent.schedule.toggle_editor", in: app)
        XCTAssertTrue(scrollToElement(editorToggle, in: app, maxSwipes: 24))
        editorToggle.tap()

        let scheduleName = app.textFields["intermittent.schedule.name"].firstMatch
        XCTAssertTrue(scrollToElementPresence(scheduleName, in: app, maxSwipes: 24))
        XCTAssertTrue(scrollToElementPresence(elementByIdentifier("intermittent.history_empty", in: app), in: app, maxSwipes: 24))
    }

    func testIPhoneFastCanCreateApplyAndDeleteNamedSchedule() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fast", in: app)

        let disclosure = elementByIdentifier("intermittent.advanced.disclosure", in: app)
        XCTAssertTrue(scrollToElement(disclosure, in: app, maxSwipes: 24))
        disclosure.tap()

        let editorToggle = elementByIdentifier("intermittent.schedule.toggle_editor", in: app)
        XCTAssertTrue(scrollToElement(editorToggle, in: app, maxSwipes: 24))
        editorToggle.tap()

        let scheduleName = app.textFields["intermittent.schedule.name"].firstMatch
        XCTAssertTrue(scrollToElementPresence(scheduleName, in: app, maxSwipes: 12))
        scheduleName.tap()
        scheduleName.typeText("Friday Rhythm")
        let returnKey = app.keyboards.buttons["return"].firstMatch
        if returnKey.exists {
            returnKey.tap()
        }

        let saveButton = app.buttons["intermittent.schedule.add"].firstMatch
        XCTAssertTrue(scrollToElement(saveButton, in: app, maxSwipes: 12))
        saveButton.tap()

        let savedSchedule = app.staticTexts["Friday Rhythm"].firstMatch
        XCTAssertTrue(scrollToElementPresence(savedSchedule, in: app, maxSwipes: 12))
        XCTAssertTrue(app.staticTexts["Applied"].firstMatch.waitForExistence(timeout: 3))

        let actions = elementByIdentifier("intermittent.schedule.actions", in: app)
        XCTAssertTrue(scrollToElement(actions, in: app, maxSwipes: 12))
        actions.tap()

        let deleteButton = app.buttons["Delete"].firstMatch
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 3))
        deleteButton.tap()

        XCTAssertTrue(
            waitUntil(timeout: 3) { !savedSchedule.exists },
            "Deleting the saved schedule did not remove its row")
    }

    func testIPadFastPresetSelectionStaysVisible() {
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

        XCTAssertTrue(elementByIdentifier("ipad.intermittent.controls", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.intention", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.buttons["ipad.intermittent.start"].firstMatch, in: app))
    }

    func testIPadFastKeepsStartedTimeEditableAfterStart() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        let startButton = app.buttons["ipad.intermittent.start"].firstMatch
        XCTAssertTrue(scrollToElement(startButton, in: app))
        startButton.tap()

        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.start_date", in: app), in: app))
    }

    func testIPadFastCanSaveRecapNote() {
        let app = makeApp(seedActiveFast: true)
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        let noteField = app.textFields["ipad.intermittent.recap_note"].firstMatch
        XCTAssertTrue(scrollToElement(noteField, in: app))
        noteField.tap()
        noteField.typeText("Evening intention")

        let doneButton = app.buttons["ipad.intermittent.recap_note.done"].firstMatch
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3))
        doneButton.tap()
        XCTAssertTrue(waitUntil(timeout: 3, condition: { !app.keyboards.firstMatch.exists }))

        let endButton = app.buttons["ipad.intermittent.end"].firstMatch
        XCTAssertTrue(scrollToElement(endButton, in: app))
        endButton.tap()

        let recapCard = elementByIdentifier("intermittent.recap_card", in: app)
        XCTAssertTrue(scrollToElementPresence(recapCard, in: app, maxSwipes: 12))
        XCTAssertTrue(String(describing: recapCard.value).localizedCaseInsensitiveContains("Evening intention"))
    }

    func testIPadFastDefaultsToLiveControlsAndCollapsedAdvancedTools() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        XCTAssertTrue(elementByIdentifier("ipad.intermittent.live", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(elementByIdentifier("ipad.intermittent.controls", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(elementByIdentifier("ipad.intermittent.planning", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["No active fast"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.buttons["ipad.intermittent.start"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["ipad.intermittent.advanced.disclosure"].firstMatch, in: app))
        XCTAssertFalse(app.textFields["intermittent.schedule.name"].firstMatch.exists)
        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.history", in: app), in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.start_date", in: app), in: app))
    }

    func testIPadFastAdvancedToolsCanExpandWithoutHidingHistory() {
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
        XCTAssertTrue(scrollToElement(elementByIdentifier("ipad.intermittent.history", in: app), in: app, maxSwipes: 8))
    }
}
