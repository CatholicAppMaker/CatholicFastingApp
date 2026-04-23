import XCTest

extension CatholicFastingMacAppUITests {
    func testFreshLaunchCanCompleteOnboardingAndReachTodaySurface() {
        let app = makeFreshLaunchApp()
        app.launch()

        let finishButton = identifiedElement("mac.onboarding.finish", in: app)
        XCTAssertTrue(finishButton.waitForExistence(timeout: 6))
        finishButton.tap()

        XCTAssertTrue(identifiedElement("mac.root.ready", in: app).waitForExistence(timeout: 6))
        XCTAssertTrue(waitForSurfaceReady(.today, in: app, timeout: 6))
    }

    func testSidebarSwitchesAcrossDesktopWorkspaces() {
        let app = makeApp()
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSidebarSurface(.today, in: app)
        openSidebarSurface(.calendar, in: app)
        openSidebarSurface(.intermittent, in: app)
        openSidebarSurface(.premium, in: app)
        openSidebarSurface(.guidance, in: app)
    }

    func testTodayWorkspaceShowsStatusAndReminderActions() {
        let app = makeApp()
        app.launch()
        ensureOnDesktopHomeScreen(app)

        XCTAssertTrue(waitForElement("mac.surface.today.ready", in: app))
        XCTAssertTrue(identifiedElement("mac.today.notification_status", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.today.request_permission", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.today.refresh_status", in: app).exists)
    }

    func testCalendarWorkspaceShowsFilteringAndDetailControls() {
        let app = makeApp()
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSidebarSurface(.calendar, in: app)

        XCTAssertTrue(waitForElement("mac.calendar.full_year", in: app))
        XCTAssertTrue(identifiedElement("mac.calendar.optional", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.calendar.feasts", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.calendar.list", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.calendar.status", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.calendar.note", in: app).exists)
    }

    func testGuidanceWorkspaceShowsRationaleForRegionalProfiles() {
        let app = makeApp(regionProfile: "canada")
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSidebarSurface(.guidance, in: app)

        XCTAssertTrue(waitForElement("mac.guidance.rationale", in: app))
    }

    func testSettingsWindowOpensFromKeyboardShortcut() {
        let app = makeApp()
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSettings(app)

        XCTAssertTrue(identifiedSwitch("mac.settings.profile.dispensation", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(identifiedElement("mac.settings.profile.language", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.profile.region", in: app).exists)
    }

    func testSettingsEditsUpdateVisibleState() {
        let app = makeApp()
        app.launch()
        XCTAssertTrue(waitForAppState(app, .runningForeground))

        let finishButton = identifiedElement("mac.onboarding.finish", in: app)
        if finishButton.waitForExistence(timeout: 2) {
            finishButton.tap()
        }

        openSettings(app)

        let dispensationToggle = identifiedSwitch("mac.settings.profile.dispensation", in: app)
        XCTAssertTrue(dispensationToggle.waitForExistence(timeout: 5))
        dispensationToggle.tap()

        XCTAssertTrue(
            identifiedElement("mac.settings.profile.dispensation_enabled", in: app)
                .waitForExistence(timeout: 5))
    }

    func testIntermittentFastCanStartEndAndCancel() {
        let app = makeApp()
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSidebarSurface(.intermittent, in: app)

        let startButton = identifiedElement("mac.intermittent.start", in: app)
        XCTAssertTrue(startButton.waitForExistence(timeout: 4))
        startButton.tap()

        let endButton = identifiedElement("mac.intermittent.end", in: app)
        XCTAssertTrue(endButton.waitForExistence(timeout: 4))
        endButton.tap()

        XCTAssertTrue(identifiedElement("mac.intermittent.start", in: app).waitForExistence(timeout: 4))
        identifiedElement("mac.intermittent.start", in: app).tap()

        let cancelButton = identifiedElement("mac.intermittent.cancel", in: app)
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 4))
        cancelButton.tap()

        XCTAssertTrue(identifiedElement("mac.intermittent.start", in: app).waitForExistence(timeout: 4))
    }

    func testPremiumWorkspaceShowsRestoreAndManageControls() {
        let app = makeApp(premiumUnlocked: true)
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSidebarSurface(.premium, in: app)

        XCTAssertTrue(identifiedElement("mac.premium.restore", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(identifiedElement("mac.premium.manage", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(identifiedElement("mac.premium.planner", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(identifiedElement("mac.premium.reminders", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(identifiedElement("mac.premium.analytics", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(identifiedElement("mac.premium.recovery", in: app).waitForExistence(timeout: 4))
    }

    func testPremiumWorkspaceShowsPlannerAndReminderActions() {
        let app = makeApp(premiumUnlocked: true)
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSidebarSurface(.premium, in: app)

        XCTAssertTrue(waitForElement("mac.premium.planner", in: app))
        XCTAssertTrue(identifiedElement("mac.premium.reminders", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.premium.analytics", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.premium.recovery", in: app).exists)
    }

    func testPremiumWorkspaceShowsJournalVirtueExportAndHouseholdSections() {
        let app = makeApp(premiumUnlocked: true)
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSidebarSurface(.premium, in: app)

        XCTAssertTrue(waitForElement("mac.surface.premium.ready", in: app))
        XCTAssertTrue(identifiedElement("mac.premium.planner", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.premium.reminders", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.premium.analytics", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.premium.recovery", in: app).exists)
    }

    func testPremiumLockedKeepsUpgradeAndGatedSupportVisible() {
        let app = makeApp(premiumUnlocked: false)
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSidebarSurface(.premium, in: app)

        XCTAssertTrue(waitForElement("mac.premium.restore", in: app))
        XCTAssertTrue(identifiedElement("mac.premium.manage", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.premium.reminders", in: app).exists)
    }

    func testReminderSettingsShowRequiredAndSupportActions() {
        let app = makeApp(premiumUnlocked: true)
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSettings(app)
        openSettingsTab(.reminders, in: app)

        XCTAssertTrue(identifiedElement("mac.settings.reminders.schedule_required", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(identifiedElement("mac.settings.reminders.schedule_quote", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.reminders.schedule_support", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.reminders.apply_smart", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.reminders.apply_rules", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.reminders.morning", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.reminders.evening", in: app).exists)
    }

    func testReminderSettingsShowPremiumHintWhenSupportIsLocked() {
        let app = makeApp(premiumUnlocked: false)
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSettings(app)
        openSettingsTab(.reminders, in: app)

        XCTAssertTrue(identifiedElement("mac.settings.reminders.support", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.reminders.premium_hint", in: app).exists)
        XCTAssertFalse(identifiedElement("mac.settings.reminders.morning", in: app).exists)
        XCTAssertFalse(identifiedElement("mac.settings.reminders.evening", in: app).exists)
    }

    func testPrivacyPaneShowsExportAndSupportControls() {
        let app = makeApp()
        app.launch()
        ensureOnDesktopHomeScreen(app)

        openSettings(app)
        openSettingsTab(.privacy, in: app)

        XCTAssertTrue(identifiedElement("mac.settings.privacy.export", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.privacy.copy_export", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.privacy.policy", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.privacy.support", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.privacy.legal_notice", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.privacy.terms", in: app).exists)
        XCTAssertTrue(identifiedElement("mac.settings.privacy.delete_all", in: app).exists)
    }
}
