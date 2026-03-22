import Foundation
import XCTest

extension CatholicFastingAppUITests {
    func testDeepIPhoneMoreDestinationsOpenAndReturn() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        let destinations = [
            "Support & Premium",
            "Setup & Reminders",
            "Profile & Norms",
            "Guidance & Rules",
            "Privacy & Data",
        ]

        for destination in destinations {
            openMoreDestination(destination, in: app)
            XCTAssertTrue(app.navigationBars[destination].waitForExistence(timeout: 4))
            returnToMoreHome(in: app)
        }
    }

    func testIPadSidebarSwitchesPrimaryWorkspaces() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)
        XCTAssertTrue(app.otherElements["ipad.today.workspace"].waitForExistence(timeout: 4))

        openIPadSurface("fasting_days", in: app)
        XCTAssertTrue(app.otherElements["ipad.fasting_days.workspace"].waitForExistence(timeout: 4))

        openIPadSurface("intermittent", in: app)
        XCTAssertTrue(app.otherElements["ipad.intermittent.workspace"].waitForExistence(timeout: 4))

        openIPadSurface("more", in: app)
        XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
    }

    func testIPadSidebarLoopsAcrossAllWorkspacesAfterCanadaFrenchSelection() {
        let app = makeApp(regionProfile: "canada", languageMode: "frenchCanadian")
        app.launch()
        ensureOnHomeScreen(app)

        for _ in 0 ..< 2 {
            openIPadSurface("today", in: app)
            XCTAssertTrue(app.otherElements["ipad.today.workspace"].waitForExistence(timeout: 4))
            openIPadSurface("fasting_days", in: app)
            XCTAssertTrue(app.otherElements["ipad.fasting_days.workspace"].waitForExistence(timeout: 4))
            openIPadSurface("intermittent", in: app)
            XCTAssertTrue(app.otherElements["ipad.intermittent.workspace"].waitForExistence(timeout: 4))
            openIPadSurface("more", in: app)
            XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
        }
    }

    func testIPadMoreProfileDestinationShowsRegionPicker() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("profileAndNorms", in: app)

        let regionPicker = app.pickers["settings.region_picker"].firstMatch
        XCTAssertTrue(scrollToElement(regionPicker, in: app))
    }

    func testIPadMoreAllDestinationsOpenWithoutBreakingWorkspace() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        let destinations = [
            "supportAndPremium",
            "setupAndReminders",
            "profileAndNorms",
            "guidanceAndRules",
            "privacyAndData",
        ]

        for destination in destinations {
            openIPadMoreDestination(destination, in: app)
            XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
        }
    }

    func testIPadMoreSetupDestinationShowsReminderControls() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("setupAndReminders", in: app)

        XCTAssertTrue(scrollToElement(app.pickers["settings.quick.language"].firstMatch, in: app))
        let regionPicker = app.pickers["settings.region_picker"].firstMatch
        XCTAssertTrue(scrollToElement(regionPicker, in: app))
        XCTAssertTrue(scrollToElement(app.otherElements["settings.quick.reminder_actions"].firstMatch, in: app))
    }

    func testIPadMoreDefaultsToPremiumWorkspace() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("more", in: app)

        XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.staticTexts["Support & Premium"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Premium Yearly"].firstMatch, in: app))
    }

    func testIPadTodayAndMoreCanBeVisitedRepeatedly() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        for _ in 0 ..< 3 {
            openIPadSurface("today", in: app)
            XCTAssertTrue(app.otherElements["ipad.today.workspace"].waitForExistence(timeout: 4))
            openIPadSurface("more", in: app)
            XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
        }
    }

    func testIPadTodayQuickActionsOpenTargetWorkspaces() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)

        let openFastingDays = app.buttons["ipad.today.action.open_fasting_days"].firstMatch
        XCTAssertTrue(scrollToElement(openFastingDays, in: app))
        openFastingDays.tap()
        XCTAssertTrue(app.otherElements["ipad.fasting_days.workspace"].waitForExistence(timeout: 4))

        openIPadSurface("today", in: app)
        let openPlanning = app.buttons["ipad.today.action.open_planning"].firstMatch
        XCTAssertTrue(scrollToElement(openPlanning, in: app))
        openPlanning.tap()
        XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.pickers["settings.region_picker"].firstMatch, in: app))

        openIPadSurface("today", in: app)
        let openPremium = app.buttons["ipad.today.action.open_premium"].firstMatch
        XCTAssertTrue(scrollToElement(openPremium, in: app))
        openPremium.tap()
        XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.staticTexts["Premium Yearly"].firstMatch, in: app))
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
            XCTAssertTrue(app.otherElements["ipad.fasting_days.workspace"].waitForExistence(timeout: 4))

            openIPadSurface("today", in: app)
            let openPlanning = app.buttons["ipad.today.action.open_planning"].firstMatch
            XCTAssertTrue(scrollToElement(openPlanning, in: app))
            openPlanning.tap()
            XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
            XCTAssertTrue(scrollToElement(app.pickers["settings.region_picker"].firstMatch, in: app))

            openIPadSurface("today", in: app)
            let openPremium = app.buttons["ipad.today.action.open_premium"].firstMatch
            XCTAssertTrue(scrollToElement(openPremium, in: app))
            openPremium.tap()
            XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
            XCTAssertTrue(scrollToElement(app.staticTexts["Premium Yearly"].firstMatch, in: app))
        }
    }

    func testIPadTodayActionsDoNotShowVoiceSummaryAndRemainResponsive() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("today", in: app)

        XCTAssertFalse(app.buttons["ipad.today.action.read_voice_summary"].firstMatch.exists)
        XCTAssertTrue(app.otherElements["ipad.today.workspace"].waitForExistence(timeout: 4))

        let openPlanning = app.buttons["ipad.today.action.open_planning"].firstMatch
        XCTAssertTrue(scrollToElement(openPlanning, in: app))
        openPlanning.tap()

        XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.pickers["settings.region_picker"].firstMatch, in: app))
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
            "privacyAndData",
        ]

        for _ in 0 ..< 2 {
            for destination in destinations {
                openIPadMoreDestination(destination, in: app)
                XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
                assertIPadMoreDestinationContent(destination, in: app)
            }
        }
    }
}
