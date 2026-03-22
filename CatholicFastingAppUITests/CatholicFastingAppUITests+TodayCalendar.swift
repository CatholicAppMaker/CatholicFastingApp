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
        expandDisclosureGroup("Customize List", in: app)

        let fullYearToggle = app.switches["fasting_days.toggle.full_year"].firstMatch
        XCTAssertTrue(scrollToElement(fullYearToggle, in: app))
        let optionalToggle = app.switches["fasting_days.toggle.optional"].firstMatch
        XCTAssertTrue(scrollToElement(optionalToggle, in: app))
        let celebrationsToggle = app.switches["fasting_days.toggle.celebrations"].firstMatch
        XCTAssertTrue(scrollToElement(celebrationsToggle, in: app))
    }

    func testSmokeGuidanceScenarioControlVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Guidance & Rules", in: app)

        let scenarioByID = elementByIdentifier("guidance.scenario", in: app)
        XCTAssertTrue(scrollToElement(scenarioByID, in: app))
        let foodSection = elementByIdentifier("guidance.food.section", in: app)
        XCTAssertTrue(scrollToElement(foodSection, in: app))
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

    func testScrollMainSurfacesTopToBottomAndBack() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        let surfaces: [(label: String, id: String)] = [
            ("Today", "today"),
            ("Fasting Days", "fasting_days"),
            ("Track Fast", "intermittent"),
            ("More", "more"),
        ]

        for surface in surfaces {
            openSurface(surface.label, in: app)
            let bottomMarker = app.otherElements["surface.\(surface.id).bottom"].firstMatch
            XCTAssertTrue(scrollToElement(bottomMarker, in: app), "Could not reach bottom of \(surface.label)")
            let topMarker = app.otherElements["surface.\(surface.id).top"].firstMatch
            XCTAssertTrue(scrollToElement(topMarker, in: app), "Could not return to top of \(surface.label)")
        }
    }

    func testScrollMoreDestinationsTopToBottomAndBack() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("More", in: app)

        let destinations: [(title: String, id: String)] = [
            ("Support & Premium", "supportAndPremium"),
            ("Setup & Reminders", "setupAndReminders"),
            ("Profile & Norms", "profileAndNorms"),
            ("Guidance & Rules", "guidanceAndRules"),
            ("Privacy & Data", "privacyAndData"),
        ]

        for destination in destinations {
            openMoreDestination(destination.title, in: app)
            let bottomMarker = app.otherElements["more.\(destination.id).bottom"].firstMatch
            XCTAssertTrue(
                scrollToElement(bottomMarker, in: app),
                "Could not reach bottom of \(destination.title)")
            let topMarker = app.otherElements["more.\(destination.id).top"].firstMatch
            XCTAssertTrue(
                scrollToElement(topMarker, in: app),
                "Could not return to top of \(destination.title)")

            let backButton = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(backButton.waitForExistence(timeout: 3))
            backButton.tap()
            XCTAssertTrue(app.navigationBars["Catholic Fasting"].waitForExistence(timeout: 4))
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

        XCTAssertTrue(scrollToElement(app.staticTexts["Plan diario de ayuno católico"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Guía de alimentos"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Acciones rápidas"].firstMatch, in: app))
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

        XCTAssertTrue(scrollToElement(app.otherElements["settings.privacy.details"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["launch.export_data"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["launch.delete_all_data"].firstMatch, in: app))
    }
}
