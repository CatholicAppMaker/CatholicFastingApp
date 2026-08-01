import Foundation
import XCTest

extension CatholicFastingAppUITests {
    func testIPhoneDeepLinkAliasesOpenExpectedDestinations() {
        let routes: [(aliases: [String], marker: String)] = [
            (
                ["calendar", "fasting-days", "fastingdays"],
                "surface.fasting_days.ready"),
            (
                ["track", "intermittent", "fast"],
                "surface.intermittent.ready"),
        ]

        for route in routes {
            for alias in route.aliases {
                let app = makeApp(initialDeepLink: "catholicfasting://\(alias)")
                app.launch()
                XCTAssertTrue(
                    app.otherElements[route.marker].waitForExistence(timeout: 5),
                    "Deep-link alias \(alias) did not open \(route.marker)")
                app.terminate()
            }
        }
    }

    func testIPhoneMoreAndPremiumDeepLinkAliasesOpenExpectedDestinations() {
        for alias in ["more", "settings"] {
            let app = makeApp(initialDeepLink: "catholicfasting://\(alias)")
            app.launch()
            XCTAssertTrue(
                elementByIdentifier("settings.quick.language", in: app)
                    .waitForExistence(timeout: 5),
                "Deep-link alias \(alias) did not open Setup & Reminders")
            app.terminate()
        }

        for alias in ["premium", "support-premium", "support", "toolkit"] {
            let app = makeApp(initialDeepLink: "catholicfasting://\(alias)")
            app.launch()
            XCTAssertTrue(
                elementByIdentifier("premium.plan_choice", in: app)
                    .waitForExistence(timeout: 5),
                "Deep-link alias \(alias) did not open Support & Premium")
            app.terminate()
        }
    }

    func testIPhoneInvalidDeepLinkLeavesTodaySelected() {
        let app = makeApp(initialDeepLink: "https://example.com/calendar")
        app.launch()

        XCTAssertTrue(app.otherElements["surface.today.ready"].waitForExistence(timeout: 5))
        XCTAssertTrue(elementByIdentifier("companion.dashboard", in: app).waitForExistence(timeout: 5))
    }

    func testIPadCanonicalDeepLinksOpenExpectedWorkspaces() {
        let routes: [(url: String, marker: String)] = [
            ("catholicfasting://today", "companion.dashboard"),
            ("catholicfasting://fasting-days", "ipad.fasting_days.detail_pane"),
            ("catholicfasting://intermittent", "ipad.intermittent.live"),
            ("catholicfasting://premium", "premium.plan_choice"),
        ]

        for route in routes {
            let app = makeApp(initialDeepLink: route.url)
            app.launch()
            XCTAssertTrue(
                elementByIdentifier(route.marker, in: app).waitForExistence(timeout: 5),
                "Deep link \(route.url) did not expose \(route.marker)")
            app.terminate()
        }
    }

    func testSmokeCalendarControlsVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Calendar", in: app)

        let scopePicker = elementByIdentifier("fasting_days.scope_picker", in: app)
        XCTAssertTrue(scrollToElement(scopePicker, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("fasting_days.filters.customize", in: app), in: app))
    }

    func testSmokeGuidanceDestinationOpens() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Guidance & Rules", in: app)

        XCTAssertTrue(app.navigationBars["Guidance & Rules"].firstMatch.waitForExistence(timeout: 4))
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

    func testPhonePrimarySurfacesFillViewportAboveTabBar() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        for surface in ["Today", "Calendar", "Fast", "More"] {
            openSurface(surface, in: app)
            let anchor: XCUIElement = switch surface {
            case "Today":
                app.buttons["companion.live.action"].firstMatch
            case "Calendar":
                elementByIdentifier("fasting_days.hero", in: app)
            case "Fast":
                elementByIdentifier("intermittent.first_viewport_context", in: app)
            default:
                elementByIdentifier("more.hub.historyOfFasting", in: app)
            }
            assertPhoneSurfaceFillsViewport(
                surface,
                anchor: anchor,
                in: app,
                requiresFullVisibility: surface == "Today")
        }
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

    func testDeepCompanionActiveFastActionOpensFast() {
        let app = makeApp(seedActiveFast: true)
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        XCTAssertTrue(scrollToElement(elementByIdentifier("companion.live.progress", in: app), in: app))
        let openFast = app.buttons["companion.live.action"].firstMatch
        XCTAssertEqual(openFast.label, "Open Fast")
        XCTAssertTrue(scrollToElement(openFast, in: app))
        openFast.tap()

        XCTAssertTrue(app.otherElements["surface.intermittent.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.staticTexts["intermittent.active_elapsed"].firstMatch, in: app, maxSwipes: 8))
    }

    func testIPhoneTodayRequiredActionOpensFilteredCalendar() {
        let app = makeApp(fixedDate: "2026-07-18")
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let focusRequired = app.buttons["companion.primary_action.button"].firstMatch
        XCTAssertTrue(scrollToElement(focusRequired, in: app))
        XCTAssertEqual(focusRequired.label, "Plan the next required day")
        focusRequired.tap()

        XCTAssertTrue(app.otherElements["surface.fasting_days.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Calendar"].firstMatch.exists)
        let scopeControl = elementByIdentifier("fasting_days.scope_picker", in: app)
        XCTAssertTrue(scrollToElement(scopeControl, in: app))
        XCTAssertTrue(scopeControl.exists)
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
        XCTAssertTrue(scrollToGuidanceFoodSection(in: app))
    }

    func testIPhoneCanadaModeCanMoveAcrossTodayCalendarAndGuidance() {
        let app = makeApp(regionProfile: "canada")
        app.launch()
        ensureOnHomeScreen(app)

        openSurface("Today", in: app)
        XCTAssertTrue(app.otherElements["companion.dashboard"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["companion.rule.source"].firstMatch.waitForExistence(timeout: 4))

        openMoreDestination("Guidance & Rules", in: app)
        XCTAssertTrue(scrollToGuidanceFoodSection(in: app))

        openSurface("Calendar", in: app)
        XCTAssertTrue(app.staticTexts[
            "Canada profile: the national baseline keeps Fridays penitential all year and models Canada-wide holy day obligations."
        ].firstMatch.waitForExistence(timeout: 4))

        openSurface("More", in: app)
        XCTAssertTrue(app.otherElements["surface.more.ready"].waitForExistence(timeout: 4))
    }

    func testDeepCalendarAgendaOpensRuleSourceAndReminderDetail() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Calendar", in: app)

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

    func testIPadTodayShowsGuidanceActionsAndContext() {
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

    func testIPadCalendarSelectionShowsDetail() {
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

    func testIPadCalendarShowsFiltersAndQuickDates() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("fasting_days", in: app)

        XCTAssertTrue(app.descendants(matching: .any)["ipad.fasting_days.filters"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.scrollViews["ipad.fasting_days.quick_dates"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.fasting_days.center_list"].waitForExistence(timeout: 4))
    }

    func testIPadCalendarFoodGuidanceShortcutOpensMoreGuidance() {
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

    func testIPhoneCalendarSpanishShowsLocalizedPlanningCopy() {
        let app = makeApp(languageMode: "spanish")
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Calendar", in: app)

        XCTAssertTrue(app.navigationBars["Calendario"].waitForExistence(timeout: 4))
        XCTAssertTrue(elementByIdentifier("fasting_days.scope_picker", in: app).waitForExistence(timeout: 4))
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

    func scrollToGuidanceFoodSection(in app: XCUIApplication) -> Bool {
        let foodSection = elementByIdentifier("guidance.food.section", in: app)
        if foodSection.exists || elementIsVisible(foodSection, in: app) {
            return true
        }

        for _ in 0 ..< 16 {
            app.swipeUp()
            if foodSection.exists || elementIsVisible(foodSection, in: app) {
                return true
            }
        }

        return false
    }
}
