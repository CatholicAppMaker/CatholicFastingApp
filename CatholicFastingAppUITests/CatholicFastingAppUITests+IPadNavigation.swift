import Foundation
import XCTest

extension CatholicFastingAppUITests {
    func testIPhoneMoreHubRowsOpenExpectedDestinationContent() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        let destinations = [
            "supportAndPremium",
            "setupAndReminders",
            "profileAndNorms",
            "guidanceAndRules",
            "historyOfFasting",
            "privacyAndData",
        ]

        for destination in destinations {
            openSurfaceThroughVisibleNavigation("More", in: app)

            let row = elementByIdentifier("more.hub.\(destination)", in: app)
            XCTAssertTrue(scrollToElement(row, in: app), "Unable to find iPhone More destination row \(destination)")
            row.tap()

            guard let title = moreDestinationTitle(for: destination) else {
                XCTFail("Unhandled iPhone More destination \(destination)")
                return
            }
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4), "More destination \(title) did not open")
            assertIPhoneMoreDestinationContent(destination, in: app)
            returnToMoreHome(in: app)
        }
    }

    func testIPhoneVisibleTabBarSwitchesAllPrimarySurfaces() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        for surface in ["Calendar", "Fast", "More", "Today"] {
            openSurfaceThroughVisibleNavigation(surface, in: app)
        }
    }

    func testIPhoneMoreSupportDestinationReturnsDirectlyToMoreHome() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openMoreDestination("Support & Premium", in: app)
        XCTAssertTrue(app.navigationBars["Support & Premium"].waitForExistence(timeout: 4))
        XCTAssertTrue(elementByIdentifier("premium.surface_picker", in: app).waitForExistence(timeout: 4))

        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()

        XCTAssertTrue(app.otherElements["surface.more.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(elementByIdentifier("more.hub.supportAndPremium", in: app), in: app))
        XCTAssertFalse(app.navigationBars["Privacy & Data"].firstMatch.exists)
    }

    func testIPadSidebarSwitchesPrimaryWorkspaces() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)
        assertIPadWorkspaceVisible("today", in: app)

        openIPadSurface("fasting_days", in: app)
        assertIPadWorkspaceVisible("fastingDays", in: app)

        openIPadSurface("intermittent", in: app)
        assertIPadWorkspaceVisible("intermittent", in: app)

        openIPadSurface("more", in: app)
        assertIPadWorkspaceVisible("more", in: app)
    }

    func testIPadSidebarLoopsAcrossAllWorkspacesAfterCanadaFrenchSelection() {
        let app = makeApp(regionProfile: "canada", languageMode: "frenchCanadian")
        app.launch()
        ensureOnHomeScreen(app)

        for _ in 0 ..< 2 {
            openIPadSurface("today", in: app)
            assertIPadWorkspaceVisible("today", in: app)
            openIPadSurface("fasting_days", in: app)
            assertIPadWorkspaceVisible("fastingDays", in: app)
            openIPadSurface("intermittent", in: app)
            assertIPadWorkspaceVisible("intermittent", in: app)
            openIPadSurface("more", in: app)
            assertIPadWorkspaceVisible("more", in: app)
        }
    }

    func testIPadMoreProfileDestinationShowsRegionPicker() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("profileAndNorms", in: app)

        let regionPicker = elementByIdentifier("settings.region_picker", in: app)
        XCTAssertTrue(scrollToElement(regionPicker, in: app))
    }

    func testIPadMoreSetupDestinationShowsReminderControls() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("setupAndReminders", in: app)

        XCTAssertTrue(scrollToElement(elementByIdentifier("settings.quick.language", in: app), in: app))
        let regionPicker = elementByIdentifier("settings.region_picker", in: app)
        XCTAssertTrue(scrollToElement(regionPicker, in: app))
        XCTAssertTrue(scrollToElement(app.otherElements["settings.quick.reminder_actions"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.switches["settings.quick.quote_toggle"].firstMatch, in: app))
    }

    func testIPhoneHistoryOfFastingOpensEraArticle() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openMoreDestination("History of Fasting", in: app)

        let earlyChurch = app.buttons["history.article.earlyChurch"].firstMatch
        XCTAssertTrue(scrollToElement(earlyChurch, in: app))
        earlyChurch.tap()

        XCTAssertTrue(app.navigationBars["Early Church foundations"].waitForExistence(timeout: 4))
        XCTAssertTrue(elementByIdentifier("history.article.body.earlyChurch", in: app).waitForExistence(timeout: 4))
    }

    func testIPadHistoryOfFastingWorkspaceOpensArticleList() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("historyOfFasting", in: app)

        assertIPadWorkspaceVisible("more", in: app)
        XCTAssertTrue(scrollToElement(app.buttons["history.article.earlyChurch"].firstMatch, in: app))
    }

    func testIPadMoreDefaultsToPremiumWorkspace() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("more", in: app)

        assertIPadWorkspaceVisible("more", in: app)
        XCTAssertTrue(scrollToElement(app.staticTexts["Support & Premium"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.plan_choice", in: app), in: app))
    }

    func testIPadTodayQuickActionsOpenTargetWorkspaces() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)

        let openFastingDays = app.buttons["ipad.today.action.open_fasting_days"].firstMatch
        XCTAssertTrue(scrollToElement(openFastingDays, in: app))
        openFastingDays.tap()
        assertIPadWorkspaceVisible("fastingDays", in: app)

        openIPadSurface("today", in: app)
        let openPlanning = app.buttons["ipad.today.action.open_planning"].firstMatch
        XCTAssertTrue(scrollToElement(openPlanning, in: app))
        openPlanning.tap()
        assertIPadWorkspaceVisible("more", in: app)
        XCTAssertTrue(scrollToElement(elementByIdentifier("settings.region_picker", in: app), in: app))

        openIPadSurface("today", in: app)
        let openPremium = app.buttons["ipad.today.action.open_premium"].firstMatch
        XCTAssertTrue(scrollToElement(openPremium, in: app))
        openPremium.tap()
        assertIPadWorkspaceVisible("more", in: app)
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.plan_choice", in: app), in: app))
    }

    func testIPadTodayQuickActionsRemainResponsiveAcrossRepeatedCycles() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        for _ in 0 ..< 2 {
            openIPadSurface("today", in: app)

            let openFastingDays = app.buttons["ipad.today.action.open_fasting_days"].firstMatch
            XCTAssertTrue(scrollToElement(openFastingDays, in: app))
            openFastingDays.tap()
            assertIPadWorkspaceVisible("fastingDays", in: app)

            openIPadSurface("today", in: app)
            let openPlanning = app.buttons["ipad.today.action.open_planning"].firstMatch
            XCTAssertTrue(scrollToElement(openPlanning, in: app))
            openPlanning.tap()
            assertIPadWorkspaceVisible("more", in: app)
            XCTAssertTrue(scrollToElement(elementByIdentifier("settings.region_picker", in: app), in: app))

            openIPadSurface("today", in: app)
            let openPremium = app.buttons["ipad.today.action.open_premium"].firstMatch
            XCTAssertTrue(scrollToElement(openPremium, in: app))
            openPremium.tap()
            assertIPadWorkspaceVisible("more", in: app)
            XCTAssertTrue(scrollToElement(elementByIdentifier("premium.plan_choice", in: app), in: app))
        }
    }

    func testIPadTodayActionsDoNotShowVoiceSummaryAndRemainResponsive() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)

        XCTAssertFalse(app.buttons["ipad.today.action.read_voice_summary"].firstMatch.exists)
        assertIPadWorkspaceVisible("today", in: app)

        let openPlanning = app.buttons["ipad.today.action.open_planning"].firstMatch
        XCTAssertTrue(scrollToElement(openPlanning, in: app))
        openPlanning.tap()

        assertIPadWorkspaceVisible("more", in: app)
        XCTAssertTrue(scrollToElement(elementByIdentifier("settings.region_picker", in: app), in: app))
    }

    func testIPadMoreDestinationsRemainResponsiveAcrossRepeatedCycles() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        let destinations = [
            "supportAndPremium",
            "setupAndReminders",
            "profileAndNorms",
            "guidanceAndRules",
            "historyOfFasting",
            "privacyAndData",
        ]

        for _ in 0 ..< 2 {
            for destination in destinations {
                openIPadMoreDestination(destination, in: app)
                assertIPadWorkspaceVisible("more", in: app)
                let railSelection = app.buttons["ipad.more.destination.\(destination)"].firstMatch
                let compactSelection = app.buttons["ipad.more.compact.\(destination)"].firstMatch
                let selected = railSelection.exists ? railSelection : compactSelection
                XCTAssertTrue(selected.waitForExistence(timeout: 4))
                XCTAssertTrue(selected.isSelected, "iPad More did not select \(destination) after repeated navigation")
            }
        }
    }
}
