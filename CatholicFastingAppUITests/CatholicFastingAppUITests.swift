import Foundation
import XCTest

final class CatholicFastingAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testSmokeOnboardingCanBeCompleted() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let continueButton = app.buttons["onboarding.continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 4))
        continueButton.tap()

        XCTAssertTrue(app.navigationBars["Catholic Fasting"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["surface.today.ready"].waitForExistence(timeout: 4))
    }

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

    func testSmokeExportsRequireLegalAcknowledgment() {
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

    func testSmokePremiumSupportControlsVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let sectionTitle = app.staticTexts["Premium Upgrade"].firstMatch
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

    func testSmokePremiumSubscriptionStoreVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let nativeStore = app.otherElements["premium.subscription_store"].firstMatch
        XCTAssertTrue(scrollToElement(nativeStore, in: app))
    }

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

    func testDeepIPhonePremiumScreenShowsPlansTipsAndLegal() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Premium Yearly"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Premium Monthly"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Optional support tips"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Yearly")).firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Monthly")).firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.restore"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.manage"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.legal.terms", in: app), in: app))
    }

    func testDeepIPhonePremiumUnlockButtonsExist() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let yearlyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Yearly")).firstMatch
        XCTAssertTrue(scrollToElement(yearlyButton, in: app))

        let monthlyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Monthly")).firstMatch
        XCTAssertTrue(scrollToElement(monthlyButton, in: app))
        XCTAssertLessThan(yearlyButton.frame.minY, monthlyButton.frame.minY)
    }

    func testDeepIPhonePremiumTipsAndLegalStayBelowSubscriptionPlans() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let monthlyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Monthly")).firstMatch
        let tipButton = app.buttons["premium.tip.com.kevpierce.catholicfasting.tip.small"].firstMatch
        let restoreButton = app.buttons["premium.restore"].firstMatch

        XCTAssertTrue(scrollToElement(monthlyButton, in: app))
        XCTAssertTrue(scrollToElement(tipButton, in: app))
        XCTAssertTrue(scrollToElement(restoreButton, in: app))

        XCTAssertLessThan(monthlyButton.frame.minY, tipButton.frame.minY)
        XCTAssertLessThan(tipButton.frame.minY, restoreButton.frame.minY)
    }

    func testDeepIPhonePremiumShowsJourneyPreview() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let preview = app.otherElements["premium.sample_preview"].firstMatch
        XCTAssertTrue(scrollToElement(preview, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Preview journey week:")).firstMatch, in: app))
    }

    func testDeepGuidanceSacredGalleryVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Guidance & Rules", in: app)

        let gallery = elementByIdentifier("guidance.sacred_gallery", in: app)
        XCTAssertTrue(scrollToElement(gallery, in: app))
    }

    func testDeepCanOpenFridayNotesHistory() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        let historyLink = app.staticTexts["Friday Notes History"].firstMatch
        XCTAssertTrue(scrollToElement(historyLink, in: app))
        historyLink.tap()

        XCTAssertTrue(app.navigationBars["Friday Notes"].waitForExistence(timeout: 4))
    }

    func testDeepLaunchReadinessControlsVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Privacy & Data", in: app)

        let exportButton = app.buttons["launch.export_data"].firstMatch
        XCTAssertTrue(scrollToElement(exportButton, in: app))

        let deleteButton = app.buttons["launch.delete_all_data"].firstMatch
        XCTAssertTrue(scrollToElement(deleteButton, in: app))
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

    func testDeepFastingDaysScopePickerVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Fasting Days", in: app)

        let scopePicker = app.segmentedControls["fasting_days.scope_picker"].firstMatch
        XCTAssertTrue(scrollToElement(scopePicker, in: app))
    }

    func testIntermittentCanStartAndCancelFast() {
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

    func testIntermittentCanEndFastAndWriteSessionHistory() {
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

    func testIntermittentLockedCustomTargetCanOpenPremiumUpgrade() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let unlockButton = app.buttons["intermittent.unlock_custom_targets"].firstMatch
        XCTAssertTrue(scrollToElement(unlockButton, in: app))
        unlockButton.tap()

        let premiumHero = app.otherElements["premium.hero"].firstMatch
        XCTAssertTrue(premiumHero.waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Premium Upgrade"].firstMatch.exists)
    }

    func testIntermittentTargetPickerVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let targetPicker = elementByIdentifier("intermittent.target_picker", in: app)
        XCTAssertTrue(scrollToElement(targetPicker, in: app))
    }

    func testIntermittentDefaultViewPrioritizesLiveStateAndKeepsAdvancedCollapsed() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        XCTAssertTrue(app.staticTexts["intermittent.no_active"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.buttons["intermittent.start_fast"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.otherElements["intermittent.advanced.disclosure"].firstMatch, in: app))
        XCTAssertFalse(app.textFields["intermittent.schedule.name"].firstMatch.exists)
    }

    func testIntermittentAdvancedToolsCanExpandFromCollapsedDefault() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Track Fast", in: app)

        let disclosure = app.otherElements["intermittent.advanced.disclosure"].firstMatch
        XCTAssertTrue(scrollToElement(disclosure, in: app))
        disclosure.tap()

        let scheduleName = app.textFields["intermittent.schedule.name"].firstMatch
        XCTAssertTrue(scrollToElement(scheduleName, in: app))
        XCTAssertTrue(app.otherElements["intermittent.history_empty"].firstMatch.exists)
    }

    func testDeepRecoveryPlanVisibleWhenMissedSeeded() {
        let app = makeApp(seedMissed: true)
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("Today", in: app)

        let recoveryTitle = app.staticTexts["today.recovery.title"].firstMatch
        XCTAssertTrue(scrollToElement(recoveryTitle, in: app))
    }

    func testDeepTodaySetupCardOpensQuickSetup() {
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

    func testDeepQuickSetupConsentIncrementsProgress() {
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

    func testDeepQuickSetupReminderActionsVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        expandDisclosureGroup("Reminder Actions", in: app)

        let status = app.staticTexts["settings.quick.reminder_status"].firstMatch
        XCTAssertTrue(scrollToElement(status, in: app))
        let permissionButton = app.buttons["settings.quick.request_permission"].firstMatch
        XCTAssertTrue(scrollToElement(permissionButton, in: app))
        let requiredButton = app.buttons["settings.quick.schedule_required"].firstMatch
        XCTAssertTrue(scrollToElement(requiredButton, in: app))
        let supportButton = app.buttons["settings.quick.schedule_support"].firstMatch
        XCTAssertTrue(scrollToElement(supportButton, in: app))
    }

    func testDeepQuickSetupShowsLanguageSelector() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        let languagePicker = app.pickers["settings.quick.language"].firstMatch
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        let regionPicker = app.pickers["settings.quick.region"].firstMatch
        XCTAssertTrue(scrollToElement(regionPicker, in: app))
    }

    func testDeepHouseholdProfileCanBeCreatedAndReapplied() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openMoreDestination("Setup & Reminders", in: app)

        let age14Toggle = app.switches["settings.quick.age14_toggle"].firstMatch
        XCTAssertTrue(scrollToElement(age14Toggle, in: app))
        if switchIsOn(age14Toggle) {
            age14Toggle.tap()
        }

        let age18Toggle = app.switches["settings.quick.age18_toggle"].firstMatch
        XCTAssertTrue(scrollToElement(age18Toggle, in: app))
        if switchIsOn(age18Toggle) {
            age18Toggle.tap()
        }

        returnToMoreHome(in: app)
        openMoreDestination("Profile & Norms", in: app)

        let newProfileField = app.textFields["settings.household.new_name"].firstMatch
        XCTAssertTrue(scrollToElement(newProfileField, in: app))
        newProfileField.tap()
        newProfileField.typeText("Teen Profile")

        let addProfileButton = app.buttons["settings.household.add"].firstMatch
        XCTAssertTrue(scrollToElement(addProfileButton, in: app))
        addProfileButton.tap()

        returnToMoreHome(in: app)
        openMoreDestination("Setup & Reminders", in: app)

        XCTAssertTrue(scrollToElement(age14Toggle, in: app))
        if !switchIsOn(age14Toggle) {
            age14Toggle.tap()
        }
        XCTAssertTrue(scrollToElement(age18Toggle, in: app))
        if !switchIsOn(age18Toggle) {
            age18Toggle.tap()
        }

        returnToMoreHome(in: app)
        openMoreDestination("Profile & Norms", in: app)

        let applyButton = app.buttons["settings.household.apply"].firstMatch
        XCTAssertTrue(scrollToElement(applyButton, in: app))
        applyButton.tap()

        returnToMoreHome(in: app)
        openMoreDestination("Setup & Reminders", in: app)

        XCTAssertTrue(scrollToElement(age14Toggle, in: app))
        XCTAssertFalse(switchIsOn(age14Toggle))
        XCTAssertTrue(scrollToElement(age18Toggle, in: app))
        XCTAssertFalse(switchIsOn(age18Toggle))
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
                "Could not reach bottom of \(destination.title)"
            )
            let topMarker = app.otherElements["more.\(destination.id).top"].firstMatch
            XCTAssertTrue(
                scrollToElement(topMarker, in: app),
                "Could not return to top of \(destination.title)"
            )

            let backButton = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(backButton.waitForExistence(timeout: 3))
            backButton.tap()
            XCTAssertTrue(app.navigationBars["Catholic Fasting"].waitForExistence(timeout: 4))
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

    func testIPadOnboardingShowsRegionSelector() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        XCTAssertTrue(app.pickers["onboarding.language"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.pickers["onboarding.region"].waitForExistence(timeout: 4))
    }

    func testIPadOnboardingLanguageSelectionUpdatesVisibleCopy() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let languagePicker = app.pickers["onboarding.language"].firstMatch
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        selectMenuPicker(languagePicker, option: "Español", in: app)

        XCTAssertTrue(app.navigationBars["Bienvenido"].waitForExistence(timeout: 4))

        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertTrue(continueButton.waitForExistence(timeout: 4))
        XCTAssertEqual(continueButton.label, "Finalizar configuración")
        XCTAssertTrue(app.staticTexts["Paso 2 de 4: Idioma y región"].firstMatch.waitForExistence(timeout: 4))
    }

    func testIPadOnboardingFrenchCanadianSelectionUpdatesVisibleCopy() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let languagePicker = app.pickers["onboarding.language"].firstMatch
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        selectMenuPicker(languagePicker, option: "Français (Canada)", in: app)

        XCTAssertTrue(app.navigationBars["Bienvenue"].waitForExistence(timeout: 4))

        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertTrue(continueButton.waitForExistence(timeout: 4))
        XCTAssertEqual(continueButton.label, "Terminer la configuration")
        XCTAssertTrue(app.staticTexts["Étape 2 sur 4 : Langue et région"].firstMatch.waitForExistence(timeout: 4))
    }

    func testIPadMoreProfileDestinationShowsRegionPicker() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("profileAndNorms", in: app)

        let regionPicker = app.pickers["settings.region_picker"].firstMatch
        XCTAssertTrue(scrollToElement(regionPicker, in: app))
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

    func testIPadPremiumWorkspaceShowsLegalLinks() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("supportAndPremium", in: app)

        let premiumWorkspace = app.otherElements["ipad.premium.workspace"].firstMatch
        XCTAssertTrue(premiumWorkspace.waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.premium.dashboard"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["ipad.premium.legal_footer"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.legal.terms", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.links["Privacy Policy"].firstMatch, in: app))
    }

    func testIPadPremiumWorkspaceShowsJourneyOrPlanContext() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("supportAndPremium", in: app)

        XCTAssertTrue(app.otherElements["ipad.premium.dashboard"].waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.staticTexts["Guided Journey"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Current journey actions"].firstMatch, in: app))
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

    func testIPhoneQuickSetupFrenchCanadianShowsLocalizedSetupCopy() {
        let app = makeApp(languageMode: "frenchCanadian")
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Configuration rapide"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Réglez ceci une fois, puis utilisez surtout Aujourd’hui et Jours de jeûne."].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.pickers["settings.quick.language"].firstMatch, in: app))
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

    func testIPadMoreCompactPremiumShowsPlansAndLegal() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("supportAndPremium", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Support & Premium"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Premium Yearly"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Premium Monthly"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Yearly")).firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Monthly")).firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.restore"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.legal.terms", in: app), in: app))
    }

    func testIPadPremiumYearlyAppearsBeforeMonthly() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("supportAndPremium", in: app)

        let yearlyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Yearly")).firstMatch
        let monthlyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Monthly")).firstMatch
        XCTAssertTrue(scrollToElement(yearlyButton, in: app))
        XCTAssertTrue(scrollToElement(monthlyButton, in: app))
        XCTAssertLessThan(yearlyButton.frame.minY, monthlyButton.frame.minY)
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

    func testIPadPremiumTipsAndLegalStayBelowSubscriptionPlans() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("supportAndPremium", in: app)

        let monthlyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Unlock Premium Monthly")).firstMatch
        let tipButton = app.buttons["ipad.more.tip.com.kevpierce.catholicfasting.tip.small"].firstMatch
        let restoreButton = app.buttons["premium.restore"].firstMatch

        XCTAssertTrue(scrollToElement(monthlyButton, in: app))
        XCTAssertTrue(scrollToElement(tipButton, in: app))
        XCTAssertTrue(scrollToElement(restoreButton, in: app))

        XCTAssertLessThan(monthlyButton.frame.minY, tipButton.frame.minY)
        XCTAssertLessThan(tipButton.frame.minY, restoreButton.frame.minY)
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
        XCTAssertTrue(scrollToElement(app.buttons["ipad.intermittent.start"].firstMatch, in: app))
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

    func testIPhoneAccessibilitySettingsDoNotShowVoiceSummary() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openSurface("More", in: app)
        openMoreDestination("Setup & Reminders", in: app)

        let advancedAccessibility = app.buttons["settings.accessibility.advanced"].firstMatch
        XCTAssertTrue(scrollToElement(advancedAccessibility, in: app))
        advancedAccessibility.tap()

        XCTAssertFalse(app.switches["settings.accessibility.voice_summary"].firstMatch.exists)
        XCTAssertFalse(app.buttons["Read Voice Summary"].firstMatch.exists)
        XCTAssertFalse(app.staticTexts["Enable Voice Summary"].firstMatch.exists)
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
    }

    func testIPadTrackFastDefaultsToLiveControlsAndCollapsedAdvancedTools() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        XCTAssertTrue(app.staticTexts["No active fast"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(scrollToElement(app.buttons["ipad.intermittent.start"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.otherElements["ipad.intermittent.advanced"].firstMatch, in: app))
        XCTAssertFalse(app.textFields["intermittent.schedule.name"].firstMatch.exists)
        XCTAssertTrue(scrollToElement(app.otherElements["ipad.intermittent.history"].firstMatch, in: app))
    }

    func testIPadTrackFastAdvancedToolsCanExpandWithoutHidingHistory() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadSurface("intermittent", in: app)

        let disclosure = app.otherElements["ipad.intermittent.advanced.disclosure"].firstMatch
        XCTAssertTrue(scrollToElement(disclosure, in: app))
        disclosure.tap()

        let scheduleName = app.textFields["intermittent.schedule.name"].firstMatch
        XCTAssertTrue(scrollToElement(scheduleName, in: app))
        XCTAssertTrue(scrollToElement(app.otherElements["ipad.intermittent.history"].firstMatch, in: app))
    }

    private func makeApp(
        skipOnboarding: Bool = true,
        seedMissed: Bool = false,
        regionProfile: String? = nil,
        languageMode: String? = nil
    ) -> XCUIApplication {
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
        if let regionProfile {
            app.launchEnvironment["UITEST_REGION_PROFILE"] = regionProfile
        }
        if let languageMode {
            app.launchEnvironment["UITEST_LANGUAGE_MODE"] = languageMode
        }
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

        let tab = tabButton(for: label, in: app)
        XCTAssertTrue(tab.waitForExistence(timeout: 3), "Unable to find tab \(label)")
        tab.tap()
        waitForSurfaceReady(label, in: app)
    }

    private func tabButton(for label: String, in app: XCUIApplication) -> XCUIElement {
        let tabBar = app.tabBars.firstMatch
        let direct = tabBar.buttons[label].firstMatch
        if direct.exists {
            return direct
        }
        if label == "Fasting Days" {
            let fastingDays = tabBar.buttons["Fasting Days"].firstMatch
            if fastingDays.exists {
                return fastingDays
            }
        }
        return direct
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

    private func openIPadSurface(_ rawValue: String, in app: XCUIApplication) {
        let button = app.buttons["ipad.sidebar.\(rawValue)"].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 4), "Unable to find iPad sidebar surface \(rawValue)")
        button.tap()
    }

    private func openIPadMoreDestination(_ rawValue: String, in app: XCUIApplication) {
        openIPadSurface("more", in: app)

        if rawValue == "supportAndPremium" {
            return
        }

        let destination = app.buttons["ipad.more.destination.\(rawValue)"].firstMatch
        let compactDestination = app.buttons["ipad.more.compact.\(rawValue)"].firstMatch
        let target = destination.waitForExistence(timeout: 2) ? destination : compactDestination
        XCTAssertTrue(target.waitForExistence(timeout: 4), "Unable to find iPad More destination \(rawValue)")
        XCTAssertTrue(scrollToElement(target, in: app))
        target.tap()
    }

    private func assertIPadMoreDestinationContent(_ rawValue: String, in app: XCUIApplication) {
        switch rawValue {
        case "supportAndPremium":
            XCTAssertTrue(scrollToElement(app.staticTexts["Premium Yearly"].firstMatch, in: app))
        case "setupAndReminders":
            XCTAssertTrue(scrollToElement(app.pickers["settings.region_picker"].firstMatch, in: app))
        case "profileAndNorms":
            XCTAssertTrue(scrollToElement(app.pickers["settings.region_picker"].firstMatch, in: app))
        case "guidanceAndRules":
            XCTAssertTrue(scrollToElement(app.otherElements["guidance.food.section"].firstMatch, in: app))
        case "privacyAndData":
            XCTAssertTrue(scrollToElement(app.buttons["launch.export_data"].firstMatch, in: app))
        default:
            XCTFail("Unhandled iPad More destination \(rawValue)")
        }
    }

    private func waitForSurfaceReady(_ label: String, in app: XCUIApplication) {
        let markerID: String
        switch label {
        case "Today":
            markerID = "surface.today.ready"
        case "Fasting Days":
            markerID = "surface.fasting_days.ready"
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
        if element.exists, element.isHittable {
            return true
        }

        let scrollContainer: XCUIElement = if app.scrollViews.firstMatch.exists {
            app.scrollViews.firstMatch
        } else if app.tables.firstMatch.exists {
            app.tables.firstMatch
        } else if app.collectionViews.firstMatch.exists {
            app.collectionViews.firstMatch
        } else {
            app
        }

        for _ in 0 ..< maxSwipes {
            scrollContainer.swipeUp()
            if element.exists, element.isHittable {
                return true
            }
        }

        for _ in 0 ..< maxSwipes {
            scrollContainer.swipeDown()
            if element.exists, element.isHittable {
                return true
            }
        }

        return element.exists && element.isHittable
    }

    private func elementByIdentifier(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func expandDisclosureGroup(_ label: String, in app: XCUIApplication) {
        let button = app.buttons[label].firstMatch
        if scrollToElement(button, in: app) {
            button.tap()
            return
        }

        let text = app.staticTexts[label].firstMatch
        XCTAssertTrue(scrollToElement(text, in: app), "Unable to find disclosure group \(label)")
        text.tap()
    }

    private func selectMenuPicker(_ picker: XCUIElement, option: String, in app: XCUIApplication) {
        XCTAssertTrue(scrollToElement(picker, in: app), "Unable to find picker \(picker)")
        picker.tap()

        let optionButton = app.buttons[option].firstMatch
        XCTAssertTrue(optionButton.waitForExistence(timeout: 4), "Unable to find picker option \(option)")
        optionButton.tap()
    }

    private func returnToMoreHome(in app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.navigationBars["Catholic Fasting"].waitForExistence(timeout: 4))
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
