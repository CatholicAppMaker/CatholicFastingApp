import Foundation
import XCTest

final class CatholicFastingAppUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testSmokeOnboardingCanBeCompleted() throws {
    let app = makeApp(skipOnboarding: false)
    app.launch()

    let continueButton = app.buttons["onboarding.continue"]
    XCTAssertTrue(continueButton.waitForExistence(timeout: 4))
    continueButton.tap()

    XCTAssertTrue(app.navigationBars["Catholic Fasting"].waitForExistence(timeout: 4))
    XCTAssertTrue(app.otherElements["surface.today.ready"].waitForExistence(timeout: 4))
  }

  func testSmokeCalendarFilterControlsVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Calendar", in: app)

    let filterVisible =
      app.segmentedControls["calendar.filter_picker"].waitForExistence(timeout: 4)
      || app.otherElements["calendar.filter_picker"].waitForExistence(timeout: 1)
    XCTAssertTrue(filterVisible)
    XCTAssertTrue(app.textFields["calendar.search_field"].firstMatch.exists)
    XCTAssertTrue(app.buttons["calendar.year.current"].firstMatch.exists)
  }

  func testSmokeExportsRequireLegalAcknowledgment() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openMoreDestination("Privacy & Data", in: app)

    let legalToggle = app.switches["launch.accept_legal_notice"].firstMatch
    XCTAssertTrue(scrollToElement(legalToggle, in: app))
    let initialValue = legalToggle.value as? String
    XCTAssertTrue(initialValue == "0" || initialValue == "Off")

    let exportButton = app.buttons["launch.export_data"].firstMatch
    XCTAssertTrue(scrollToElement(exportButton, in: app))
    XCTAssertFalse(exportButton.isEnabled)
  }

  func testSmokeGuidanceScenarioControlVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openMoreDestination("Guidance & Rules", in: app)

    let scenarioByID = elementByIdentifier("guidance.scenario", in: app)
    XCTAssertTrue(scrollToElement(scenarioByID, in: app))
  }

  func testSmokePremiumSupportControlsVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openMoreDestination("Support & Premium", in: app)

    let sectionTitle = app.staticTexts["Free Core + Premium + Optional Tip"].firstMatch
    XCTAssertTrue(scrollToElement(sectionTitle, in: app))

    let restoreButton = app.buttons["premium.restore"].firstMatch
    XCTAssertTrue(scrollToElement(restoreButton, in: app))
    XCTAssertTrue(restoreButton.isEnabled)

    let manageButton = app.buttons["premium.manage"].firstMatch
    XCTAssertTrue(scrollToElement(manageButton, in: app))
    XCTAssertTrue(manageButton.isEnabled)

    let lockedPreview = app.staticTexts["premium.locked_feature_preview"].firstMatch
    XCTAssertTrue(scrollToElement(lockedPreview, in: app))
  }

  func testDeepGuidanceSacredGalleryVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openMoreDestination("Guidance & Rules", in: app)

    let gallery = elementByIdentifier("guidance.sacred_gallery", in: app)
    XCTAssertTrue(scrollToElement(gallery, in: app))
  }

  func testDeepCanOpenFridayNotesHistory() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openMoreDestination("Setup & Reminders", in: app)

    let historyLink = app.staticTexts["Friday Notes History"].firstMatch
    XCTAssertTrue(scrollToElement(historyLink, in: app))
    historyLink.tap()

    XCTAssertTrue(app.navigationBars["Friday Notes"].waitForExistence(timeout: 4))
  }

  func testDeepLaunchReadinessControlsVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openMoreDestination("Privacy & Data", in: app)

    let exportButton = app.buttons["launch.export_data"].firstMatch
    XCTAssertTrue(scrollToElement(exportButton, in: app))

    let deleteButton = app.buttons["launch.delete_all_data"].firstMatch
    XCTAssertTrue(scrollToElement(deleteButton, in: app))
  }

  func testDeepDashboardHeroVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Today", in: app)

    let heroByID = elementByIdentifier("dashboard.hero", in: app)
    let heroTitle = app.staticTexts["Daily Catholic Fasting Plan"].firstMatch
    XCTAssertTrue(scrollToElement(heroByID, in: app) || scrollToElement(heroTitle, in: app))
  }

  func testDeepUnofficialNoticeVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Today", in: app)

    let notice = elementByIdentifier("notice.unofficial", in: app)
    XCTAssertTrue(scrollToElement(notice, in: app))
  }

  func testDeepDashboardOpenCalendarQuickAction() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Today", in: app)

    let openCalendar = app.buttons["dashboard.open_calendar"].firstMatch
    XCTAssertTrue(scrollToElement(openCalendar, in: app))
    openCalendar.tap()

    XCTAssertTrue(app.otherElements["surface.calendar.ready"].waitForExistence(timeout: 4))
    XCTAssertTrue(app.staticTexts["calendar.filter_summary"].firstMatch.waitForExistence(timeout: 4))
  }

  func testDeepDashboardFocusRequiredQuickAction() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Today", in: app)

    let focusRequired = app.buttons["dashboard.focus_required"].firstMatch
    XCTAssertTrue(scrollToElement(focusRequired, in: app))
    focusRequired.tap()

    XCTAssertTrue(app.otherElements["surface.calendar.ready"].waitForExistence(timeout: 4))
    XCTAssertTrue(app.staticTexts["calendar.filter_summary"].firstMatch.exists)
  }

  func testDeepCalendarResetFiltersButtonVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Calendar", in: app)

    let resetButton = app.buttons["calendar.reset_filters"].firstMatch
    XCTAssertTrue(scrollToElement(resetButton, in: app))
  }

  func testIntermittentCanStartAndCancelFast() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Track Fast", in: app)

    let startButton = app.buttons["intermittent.start_fast"].firstMatch
    XCTAssertTrue(scrollToElement(startButton, in: app))
    startButton.tap()

    let elapsed = app.staticTexts["intermittent.active_elapsed"].firstMatch
    XCTAssertTrue(elapsed.waitForExistence(timeout: 4))

    let cancelButton = app.buttons["intermittent.cancel_fast"].firstMatch
    XCTAssertTrue(scrollToElement(cancelButton, in: app))
    cancelButton.tap()

    XCTAssertTrue(app.staticTexts["intermittent.no_active"].firstMatch.waitForExistence(timeout: 4))
  }

  func testIntermittentCanEndFastAndWriteSessionHistory() throws {
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

  func testIntermittentTargetPickerVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Track Fast", in: app)

    let targetPicker = elementByIdentifier("intermittent.target_picker", in: app)
    XCTAssertTrue(scrollToElement(targetPicker, in: app))
  }

  func testDeepRecoveryPlanVisibleWhenMissedSeeded() throws {
    let app = makeApp(seedMissed: true)
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Today", in: app)

    let recoveryTitle = app.staticTexts["today.recovery.title"].firstMatch
    XCTAssertTrue(scrollToElement(recoveryTitle, in: app))
  }

  func testDeepTodaySetupCardOpensQuickSetup() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openSurface("Today", in: app)

    let setupButton = app.buttons["today.setup.open_quick_setup"].firstMatch
    XCTAssertTrue(scrollToElement(setupButton, in: app))
    setupButton.tap()

    XCTAssertTrue(app.otherElements["surface.more.ready"].waitForExistence(timeout: 4))
    let setupDestination = app.staticTexts["Setup & Reminders"].firstMatch
    XCTAssertTrue(scrollToElement(setupDestination, in: app))
    setupDestination.tap()

    let quickProgress = app.staticTexts["settings.quick.progress"].firstMatch
    XCTAssertTrue(scrollToElement(quickProgress, in: app))
  }

  func testDeepQuickSetupConsentIncrementsProgress() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openMoreDestination("Setup & Reminders", in: app)

    let progress = app.staticTexts["settings.quick.progress"].firstMatch
    XCTAssertTrue(scrollToElement(progress, in: app))

    let consentToggle = app.switches["settings.quick.consent"].firstMatch
    XCTAssertTrue(scrollToElement(consentToggle, in: app))
    if switchIsOn(consentToggle) {
      consentToggle.tap()
    }

    guard let beforeCount = progressCount(from: progress.label) else {
      XCTFail("Unable to parse setup progress from label: \(progress.label)")
      return
    }

    consentToggle.tap()
    XCTAssertTrue(
      waitUntil(timeout: 3) { (progressCount(from: progress.label) ?? beforeCount) >= beforeCount + 1 },
      "Expected setup progress to increment after consent toggle. Before: \(beforeCount), label now: \(progress.label)"
    )
  }

  func testDeepQuickSetupReminderActionsVisible() throws {
    let app = makeApp()
    app.launch()
    ensureOnHomeScreen(app)
    openMoreDestination("Setup & Reminders", in: app)

    let status = app.staticTexts["settings.quick.reminder_status"].firstMatch
    XCTAssertTrue(scrollToElement(status, in: app))
    let permissionButton = app.buttons["settings.quick.request_permission"].firstMatch
    XCTAssertTrue(scrollToElement(permissionButton, in: app))
    let requiredButton = app.buttons["settings.quick.schedule_required"].firstMatch
    XCTAssertTrue(scrollToElement(requiredButton, in: app))
    let supportButton = app.buttons["settings.quick.schedule_support"].firstMatch
    XCTAssertTrue(scrollToElement(supportButton, in: app))
  }

  private func makeApp(skipOnboarding: Bool = true, seedMissed: Bool = false) -> XCUIApplication {
    let app = XCUIApplication()
    var args = ["-uitest-reset", "-uitest-seed-deterministic", "-uitest-disable-animations"]
    if skipOnboarding {
      args.append("-uitest-skip-onboarding")
    }
    if seedMissed {
      args.append("-uitest-seed-missed")
    }
    app.launchArguments = args
    app.launchEnvironment["UITEST_MODE"] = "1"
    return app
  }

  private func ensureOnHomeScreen(_ app: XCUIApplication) {
    let continueButton = app.buttons["onboarding.continue"]
    if continueButton.waitForExistence(timeout: 1) {
      continueButton.tap()
    }
    XCTAssertTrue(app.navigationBars["Catholic Fasting"].waitForExistence(timeout: 4))
    XCTAssertTrue(app.otherElements["home.ready"].waitForExistence(timeout: 4))
  }

  private func openSurface(_ label: String, in app: XCUIApplication) {
    let tabBar = app.tabBars.firstMatch
    XCTAssertTrue(tabBar.waitForExistence(timeout: 3))

    let tab = tabBar.buttons[label].firstMatch
    XCTAssertTrue(tab.waitForExistence(timeout: 3), "Unable to find tab \(label)")
    tab.tap()
    waitForSurfaceReady(label, in: app)
  }

  private func openMoreDestination(_ title: String, in app: XCUIApplication) {
    openSurface("More", in: app)

    let destinationButton = app.buttons[title].firstMatch
    if destinationButton.exists || destinationButton.waitForExistence(timeout: 1) {
      XCTAssertTrue(scrollToElement(destinationButton, in: app))
      destinationButton.tap()
      XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4))
      return
    }

    let destinationText = app.staticTexts[title].firstMatch
    XCTAssertTrue(scrollToElement(destinationText, in: app), "Unable to find More destination \(title)")
    destinationText.tap()
    XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4))
  }

  private func waitForSurfaceReady(_ label: String, in app: XCUIApplication) {
    let markerID: String
    switch label {
    case "Today":
      markerID = "surface.today.ready"
    case "Calendar":
      markerID = "surface.calendar.ready"
    case "Track Fast":
      markerID = "surface.intermittent.ready"
    case "More":
      markerID = "surface.more.ready"
    default:
      return
    }
    XCTAssertTrue(app.otherElements[markerID].waitForExistence(timeout: 4))
  }

  private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 12)
    -> Bool
  {
    if element.exists && element.isHittable {
      return true
    }

    let scrollContainer: XCUIElement
    if app.collectionViews.firstMatch.exists {
      scrollContainer = app.collectionViews.firstMatch
    } else if app.tables.firstMatch.exists {
      scrollContainer = app.tables.firstMatch
    } else if app.scrollViews.firstMatch.exists {
      scrollContainer = app.scrollViews.firstMatch
    } else {
      scrollContainer = app
    }

    for _ in 0..<maxSwipes {
      scrollContainer.swipeUp()
      if element.exists && element.isHittable {
        return true
      }
    }

    for _ in 0..<maxSwipes {
      scrollContainer.swipeDown()
      if element.exists && element.isHittable {
        return true
      }
    }

    return element.exists && element.isHittable
  }

  private func elementByIdentifier(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    app.descendants(matching: .any).matching(identifier: identifier).firstMatch
  }

  private func switchIsOn(_ element: XCUIElement) -> Bool {
    let rawValue = element.value as? String
    return rawValue == "1" || rawValue == "On"
  }

  private func progressCount(from label: String) -> Int? {
    guard let range = label.range(of: #"\d+/\d+"#, options: .regularExpression) else {
      return nil
    }
    let token = label[range]
    guard let numerator = token.split(separator: "/").first else {
      return nil
    }
    return Int(numerator)
  }

  private func waitUntil(
    timeout: TimeInterval,
    pollInterval: TimeInterval = 0.1,
    condition: () -> Bool
  ) -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if condition() {
        return true
      }
      RunLoop.current.run(until: Date().addingTimeInterval(pollInterval))
    }
    return condition()
  }
}
