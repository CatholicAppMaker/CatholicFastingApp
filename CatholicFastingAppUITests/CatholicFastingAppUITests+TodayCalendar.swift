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
        XCTAssertTrue(elementByIdentifier("guidance.sacred_gallery", in: app).waitForExistence(timeout: 4))
    }

    func testDeepGuidanceSacredGalleryVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Guidance & Rules", in: app)

        let gallery = elementByIdentifier("guidance.sacred_gallery", in: app)
        XCTAssertTrue(scrollToElement(gallery, in: app))
    }

    func testTodayShowsDecisionActionAndAuthorityInInitialViewport() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        XCTAssertTrue(elementIsVisible(elementByIdentifier("companion.dashboard", in: app), in: app))
        XCTAssertTrue(elementIsVisible(elementByIdentifier("companion.sacred_masthead", in: app), in: app))
        XCTAssertTrue(elementIsVisible(app.staticTexts["companion.rule.obligation"].firstMatch, in: app))
        XCTAssertTrue(elementIsVisible(app.buttons["companion.primary_action.button"].firstMatch, in: app))
        XCTAssertTrue(elementIsVisible(elementByIdentifier("companion.rule.source", in: app), in: app))
    }

    func testTodayExposesNextObservanceAndPersonalFastStatusWithoutFormationClutter() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        XCTAssertTrue(elementIsVisible(elementByIdentifier("companion.dashboard", in: app), in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("companion.live_state", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.buttons["companion.live.action"].firstMatch, in: app))
        XCTAssertFalse(elementIsVisible(elementByIdentifier("companion.formation", in: app), in: app))
    }

    func testIPhoneLiturgicalThemeToggleExplainsOrdinaryTimeFallback() {
        let app = makeApp(fixedDate: "2026-03-06")
        app.launch()
        ensureOnHomeScreen(app)

        let seasonBadge = elementByIdentifier("home.season_badge", in: app)
        XCTAssertTrue(seasonBadge.waitForExistence(timeout: 4))
        XCTAssertTrue(seasonBadge.label.localizedCaseInsensitiveContains("Lent"))

        openMoreDestination("Profile & Norms", in: app)
        let toggle = app.switches["settings.liturgical_theme_toggle"].firstMatch
        XCTAssertTrue(scrollToElement(toggle, in: app, maxSwipes: 12))
        XCTAssertEqual(toggle.value as? String, "1")
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()

        let disabled = NSPredicate(format: "value == %@", "0")
        let disabledExpectation = XCTNSPredicateExpectation(predicate: disabled, object: toggle)
        XCTAssertEqual(XCTWaiter.wait(for: [disabledExpectation], timeout: 3), .completed)
        let context = elementByIdentifier("settings.liturgical_theme_context", in: app)
        XCTAssertTrue(scrollToElement(context, in: app, maxSwipes: 3))
        XCTAssertTrue(context.exists)
        XCTAssertTrue(context.label.localizedCaseInsensitiveContains("Ordinary Time"))
    }

    func testDeepCompanionActiveFastPrimaryActionOpensTrackFast() {
        let app = makeApp(seedActiveFast: true)
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        XCTAssertTrue(scrollToElement(elementByIdentifier("companion.live.progress", in: app), in: app))
        let primaryAction = app.buttons["companion.primary_action.button"].firstMatch
        XCTAssertTrue(scrollToElement(primaryAction, in: app))
        primaryAction.tap()

        XCTAssertTrue(app.otherElements["surface.intermittent.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.staticTexts["intermittent.active_elapsed"].firstMatch, in: app, maxSwipes: 8))
    }

    func testDeepUnofficialNoticeVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        // Authority context stays next to the decision; legal acknowledgement lives in More.
        XCTAssertTrue(scrollToElement(elementByIdentifier("companion.rule.source", in: app), in: app))
        openMoreDestination("Privacy & Data", in: app)
        XCTAssertTrue(scrollToElement(app.switches["launch.accept_legal_notice"].firstMatch, in: app))
    }

    func testDeepDashboardOpenFastingDaysQuickAction() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fasting Days", in: app)

        XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Calendar"].firstMatch.waitForExistence(timeout: 4))
    }

    func testDeepDashboardFocusRequiredQuickAction() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let focusRequired = app.buttons["companion.primary_action.button"].firstMatch
        XCTAssertTrue(scrollToElement(focusRequired, in: app))
        focusRequired.tap()

        XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Calendar"].firstMatch.exists)
        XCTAssertTrue(scrollToElement(elementByIdentifier("fasting_days.filter_tags", in: app), in: app))
        XCTAssertTrue(app.staticTexts["Required Only"].firstMatch.exists)
    }

    func testDeepTodayFoodGuidanceShortcutOpensGuidanceRules() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let foodShortcut = app.buttons["today.decision.open_full_food_guidance"].firstMatch
        XCTAssertTrue(scrollToElement(foodShortcut, in: app))
        foodShortcut.tap()

        assertMoreDestinationOpened("guidanceAndRules", title: "Guidance & Rules", in: app)
        let foodSection = elementByIdentifier("guidance.food.section", in: app)
        XCTAssertTrue(scrollToElement(foodSection, in: app))
    }

    func testIPhoneCanadaModeCanMoveAcrossTodayFastingDaysAndGuidance() {
        let app = makeApp(regionProfile: "canada")
        app.launch()
        ensureOnHomeScreen(app)

        openSurface("Today", in: app)
        XCTAssertTrue(app.otherElements["companion.dashboard"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["companion.rule.source"].firstMatch.waitForExistence(timeout: 4))

        openMoreDestination("Guidance & Rules", in: app)
        XCTAssertTrue(scrollToElement(elementByIdentifier("guidance.food.section", in: app), in: app))

        openSurface("Fasting Days", in: app)
        XCTAssertTrue(app.staticTexts[
            "Canada profile: the national baseline keeps Fridays penitential all year and models Canada-wide holy day obligations."
        ].firstMatch.waitForExistence(timeout: 4))

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

    func testDeepFastingDaysAgendaOpensRuleSourceAndReminderDetail() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fasting Days", in: app)

        let detailLinks = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "fasting_days.detail."))
        let firstDetailLink = detailLinks.firstMatch
        XCTAssertTrue(scrollToElement(firstDetailLink, in: app, maxSwipes: 12))
        let detailIdentifier = firstDetailLink.identifier
        let visibleDetailLink = app.descendants(matching: .any)
            .matching(identifier: detailIdentifier)
            .firstMatch
        XCTAssertTrue(visibleDetailLink.waitForExistence(timeout: 3))
        visibleDetailLink.tap()

        XCTAssertTrue(app.staticTexts["Why this day matters"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(elementByIdentifier("fasting_days.detail.reminder_settings", in: app), in: app, maxSwipes: 12))
    }

    func testDeepRecoveryPlanVisibleWhenMissedSeeded() {
        let app = makeApp(seedMissed: true)
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let recoveryAction = app.buttons["companion.primary_action.button"].firstMatch
        XCTAssertTrue(scrollToElement(recoveryAction, in: app))
        XCTAssertTrue(recoveryAction.label.localizedCaseInsensitiveContains("recovery"))
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

    func testIPadTodayDashboardShowsHeroAndCoreCards() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)

        assertIPadWorkspaceVisible("today", in: app)
        XCTAssertTrue(app.otherElements["companion.dashboard"].waitForExistence(timeout: 4))
        XCTAssertTrue(elementByIdentifier("companion.sacred_masthead", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.today.actions"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["companion.live_state"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["companion.formation"].waitForExistence(timeout: 4))
        XCTAssertTrue(elementByIdentifier("ipad.sidebar.season_context", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["ipad.sidebar.today"].isSelected)
    }

    func testIPadTodayShowsDecisionActionsAndContextRail() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)

        XCTAssertTrue(app.otherElements["companion.dashboard"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.today.actions"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["companion.live_state"].waitForExistence(timeout: 4))
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

        XCTAssertTrue(app.otherElements["ipad.fasting_days.detail_pane"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["ipad.fasting_days.open_food_guidance"].waitForExistence(timeout: 4))
    }

    func testIPadFastingDaysShowsFiltersAndQuickDates() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("fasting_days", in: app)

        XCTAssertTrue(app.descendants(matching: .any)["ipad.fasting_days.filters"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.scrollViews["ipad.fasting_days.quick_dates"].waitForExistence(timeout: 4))
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

        assertIPadWorkspaceVisible("more", in: app)
        let guidanceSection = app.otherElements["guidance.food.section"].firstMatch
        XCTAssertTrue(scrollToElement(guidanceSection, in: app))
    }

    func testIPadCanadaModeShowsModeledBaselineContext() {
        let app = makeApp(regionProfile: "canada")
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)
        let canadaSource = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "CCCB")).firstMatch
        XCTAssertTrue(canadaSource.waitForExistence(timeout: 4))

        openIPadSurface("fasting_days", in: app)
        let filters = elementByIdentifier("ipad.fasting_days.filters", in: app)
        XCTAssertTrue(filters.waitForExistence(timeout: 4))
        XCTAssertTrue(String(describing: filters.value).localizedCaseInsensitiveContains("Modeled"))
    }

    func testIPhoneTodaySpanishShowsLocalizedCoreSections() {
        let app = makeApp(languageMode: "spanish")
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        XCTAssertTrue(app.otherElements["surface.today.ready"].exists)
        XCTAssertTrue(app.navigationBars["Hoy"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["companion.dashboard"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Próximo paso fiel"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["companion.primary_action.button"].firstMatch.waitForExistence(timeout: 4))
    }

    func testIPhoneFastingDaysSpanishShowsLocalizedPlanningCopy() {
        let app = makeApp(languageMode: "spanish")
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fasting Days", in: app)

        XCTAssertTrue(app.navigationBars["Calendario"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.segmentedControls["fasting_days.scope_picker"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.buttons["fasting_days.filters.customize"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Próximos días obligatorios"].firstMatch, in: app))
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
