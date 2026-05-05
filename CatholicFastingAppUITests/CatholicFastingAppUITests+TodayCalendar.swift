import Foundation
import XCTest

extension CatholicFastingAppUITests {
    func testSmokeFastingDaysControlsVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fasting Days", in: app)

        let scopePicker = app.segmentedControls["fasting_days.scope_picker"].firstMatch
        XCTAssertTrue(scrollToElement(scopePicker, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("fasting_days.filters.customize", in: app), in: app))
    }

    func testSmokeGuidanceDestinationOpens() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Guidance & Rules", in: app)

        XCTAssertTrue(app.navigationBars["Guidance & Rules"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(elementByIdentifier("more.guidanceAndRules.hero", in: app).waitForExistence(timeout: 4))
    }

    func testDeepGuidanceSacredGalleryVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Guidance & Rules", in: app)

        let gallery = elementByIdentifier("guidance.sacred_gallery", in: app)
        XCTAssertTrue(scrollToElement(gallery, in: app))
    }

    func testDeepDashboardHeroVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let heroByID = elementByIdentifier("dashboard.hero", in: app)
        let heroTitle = app.staticTexts["Daily Catholic Fasting Plan"].firstMatch
        XCTAssertTrue(scrollToElement(heroByID, in: app) || scrollToElement(heroTitle, in: app))
    }

    func testDeepUnofficialNoticeVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let notice = elementByIdentifier("notice.unofficial", in: app)
        XCTAssertTrue(scrollToElement(notice, in: app))
    }

    func testDeepDashboardOpenFastingDaysQuickAction() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let openFastingDays = app.buttons["dashboard.open_fasting_days"].firstMatch
        XCTAssertTrue(scrollToElement(openFastingDays, in: app))
        openFastingDays.tap()

        XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Fasting Days"].firstMatch.waitForExistence(timeout: 4))
    }

    func testDeepDashboardFocusRequiredQuickAction() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let focusRequired = app.buttons["dashboard.focus_required"].firstMatch
        XCTAssertTrue(scrollToElement(focusRequired, in: app))
        focusRequired.tap()

        XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Fasting Days"].firstMatch.exists)
    }

    func testDeepTodayFoodGuidanceShortcutOpensGuidanceRules() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let foodShortcut = app.buttons["today.decision.open_full_food_guidance"].firstMatch
        XCTAssertTrue(scrollToElement(foodShortcut, in: app))
        foodShortcut.tap()

        let foodSection = elementByIdentifier("guidance.food.section", in: app)
        XCTAssertTrue(foodSection.waitForExistence(timeout: 4))
    }

    func testIPhoneCanadaModeCanMoveAcrossTodayFastingDaysAndGuidance() {
        let app = makeApp(regionProfile: "canada")
        app.launch()
        ensureOnHomeScreen(app)

        openSurface("Today", in: app)
        XCTAssertTrue(scrollToElement(app.staticTexts["Canada baseline"].firstMatch, in: app))

        let foodShortcut = app.buttons["today.decision.open_full_food_guidance"].firstMatch
        XCTAssertTrue(scrollToElement(foodShortcut, in: app))
        foodShortcut.tap()
        XCTAssertTrue(scrollToElement(app.otherElements["guidance.food.section"].firstMatch, in: app))

        openSurface("Fasting Days", in: app)
        XCTAssertTrue(scrollToElement(app.staticTexts["Modeled"].firstMatch, in: app))

        openSurface("More", in: app)
        XCTAssertTrue(app.otherElements["surface.more.ready"].waitForExistence(timeout: 4))
    }

    func testDeepFastingDaysScopePickerVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fasting Days", in: app)

        let scopePicker = app.segmentedControls["fasting_days.scope_picker"].firstMatch
        XCTAssertTrue(scrollToElement(scopePicker, in: app))
    }

    func testDeepRecoveryPlanVisibleWhenMissedSeeded() {
        let app = makeApp(seedMissed: true)
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let recoveryTitle = app.staticTexts["today.recovery.title"].firstMatch
        XCTAssertTrue(scrollToElement(recoveryTitle, in: app))
    }

    func testMainSurfacesShowStableHeroAnchors() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        let surfaces: [(label: String, identifier: String)] = [
            ("Today", "dashboard.hero"),
            ("Fasting Days", "fasting_days.hero"),
            ("Track Fast", "intermittent.hero"),
            ("More", "more.hub.hero"),
        ]

        for surface in surfaces {
            openSurface(surface.label, in: app)
            let anchor = elementByIdentifier(surface.identifier, in: app)
            XCTAssertTrue(
                anchor.waitForExistence(timeout: 4) || scrollToElement(anchor, in: app),
                "\(surface.label) did not expose its stable hero anchor")
        }
    }

    func testMoreDestinationsExposeStableHeroAnchors() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("More", in: app)

        let destinations: [(title: String, identifier: String)] = [
            ("Support & Premium", "supportAndPremium"),
            ("Setup & Reminders", "setupAndReminders"),
            ("Profile & Norms", "profileAndNorms"),
            ("Guidance & Rules", "guidanceAndRules"),
            ("Privacy & Data", "privacyAndData"),
        ]

        for destination in destinations {
            openMoreDestination(destination.title, in: app)
            let hero = elementByIdentifier("more.\(destination.identifier).hero", in: app)
            XCTAssertTrue(
                hero.waitForExistence(timeout: 4) || scrollToElement(hero, in: app),
                "\(destination.title) did not expose its stable destination hero")

            let backButton = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(backButton.waitForExistence(timeout: 3))
            backButton.tap()
            XCTAssertTrue(app.otherElements["surface.more.ready"].waitForExistence(timeout: 4))
        }
    }

    func testIPadTodayDashboardShowsHeroAndCoreCards() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)

        XCTAssertTrue(app.otherElements["ipad.today.workspace"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.today.hero"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.today.primary_card"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.today.metrics"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.today.actions"].waitForExistence(timeout: 4))
    }

    func testIPadFastingDaysSelectionShowsDetail() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("fasting_days", in: app)

        let row = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "ipad.fasting_days.row."))
            .firstMatch
        XCTAssertTrue(scrollToElement(row, in: app))
        row.tap()

        let detail = app.otherElements["ipad.fasting_days.detail"].firstMatch
        XCTAssertTrue(detail.waitForExistence(timeout: 4))
    }

    func testIPadFastingDaysShowsFiltersAndQuickDates() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("fasting_days", in: app)

        XCTAssertTrue(app.otherElements["ipad.fasting_days.filters"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.fasting_days.quick_dates"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.fasting_days.center_list"].waitForExistence(timeout: 4))
    }

    func testIPadFastingDaysFoodGuidanceShortcutOpensMoreGuidance() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("fasting_days", in: app)

        let row = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "ipad.fasting_days.row."))
            .firstMatch
        XCTAssertTrue(scrollToElement(row, in: app))
        row.tap()

        let shortcut = app.buttons["ipad.fasting_days.open_food_guidance"].firstMatch
        XCTAssertTrue(scrollToElement(shortcut, in: app))
        shortcut.tap()

        XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
        let guidanceSection = app.otherElements["guidance.food.section"].firstMatch
        XCTAssertTrue(scrollToElement(guidanceSection, in: app))
    }

    func testIPadCanadaModeShowsModeledBaselineContext() {
        let app = makeApp(regionProfile: "canada")
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)
        XCTAssertTrue(scrollToElement(app.staticTexts["Canada baseline"].firstMatch, in: app))

        openIPadSurface("fasting_days", in: app)
        XCTAssertTrue(scrollToElement(app.staticTexts["Modeled"].firstMatch, in: app))
    }

    func testIPhoneTodaySpanishShowsLocalizedCoreSections() {
        let app = makeApp(languageMode: "spanish")
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        XCTAssertTrue(app.otherElements["surface.today.ready"].exists)
        XCTAssertTrue(scrollToElement(app.buttons["today.quick.fasting_days"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["today.decision.open_full_food_guidance"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Preguntas comunes"].firstMatch, in: app))
    }

    func testIPhoneFastingDaysSpanishShowsLocalizedPlanningCopy() {
        let app = makeApp(languageMode: "spanish")
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fasting Days", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Días de ayuno"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Personalizar lista"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Recordatorios"].firstMatch, in: app))
    }

    func testIPadGuidanceFrenchCanadianShowsLocalizedSectionTitles() {
        let app = makeApp(languageMode: "frenchCanadian")
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("guidanceAndRules", in: app)

        XCTAssertTrue(scrollToElement(app.otherElements["guidance.food.section"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Guide alimentaire"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Orientation pastorale"].firstMatch, in: app))
    }

    func testIPadMoreGuidanceDestinationShowsFoodSection() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("guidanceAndRules", in: app)

        let foodSection = app.otherElements["guidance.food.section"].firstMatch
        XCTAssertTrue(scrollToElement(foodSection, in: app))
        XCTAssertTrue(scrollToElement(app.otherElements["guidance.food.if_unsure"].firstMatch, in: app))
    }

    func testIPadMorePrivacyDestinationShowsDataTools() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("privacyAndData", in: app)

        XCTAssertTrue(app.navigationBars["Privacy & Data"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["launch.export_data"].firstMatch.waitForExistence(timeout: 4))
    }
}
