import Foundation
import XCTest

extension CatholicFastingAppUITests {
    func testFreshLaunchIPhoneCanCompleteOnboardingAndReachToday() {
        let app = makeFreshLaunchApp()
        app.launch()

        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertTrue(continueButton.waitForExistence(timeout: 6))
        continueButton.tap()

        XCTAssertTrue(app.otherElements["surface.today.ready"].waitForExistence(timeout: 6))
    }

    func testFreshLaunchIPadCanCompleteOnboardingAndRenderTodayWorkspace() {
        let app = makeFreshLaunchApp()
        app.launch()

        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertTrue(continueButton.waitForExistence(timeout: 6))
        continueButton.tap()

        XCTAssertTrue(app.otherElements["ipad.today.workspace"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.otherElements["ipad.today.hero"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.otherElements["ipad.today.primary_card"].waitForExistence(timeout: 6))
    }

    func testFreshLaunchOnboardingQuoteReminderCanBeEnabledAndStillComplete() {
        let app = makeFreshLaunchApp()
        app.launch()

        let quoteToggle = app.switches["onboarding.reminder_quote_toggle"].firstMatch
        XCTAssertTrue(scrollToElement(quoteToggle, in: app))
        if !switchIsOn(quoteToggle) {
            quoteToggle.tap()
        }

        let quoteTime = app.datePickers["onboarding.reminder_quote_time"].firstMatch
        XCTAssertTrue(scrollToElement(quoteTime, in: app))

        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertTrue(scrollToElement(continueButton, in: app))
        continueButton.tap()

        XCTAssertTrue(app.otherElements["surface.today.ready"].waitForExistence(timeout: 6))
    }

    func testSmokeOnboardingCanBeCompleted() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let continueButton = app.buttons["onboarding.continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 4))
        continueButton.tap()

        XCTAssertTrue(app.otherElements["surface.today.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(
            app.navigationBars["Today"].firstMatch.waitForExistence(timeout: 4)
                || app.staticTexts["Today"].firstMatch.waitForExistence(timeout: 4))
    }

    func testIPhoneOnboardingSpanishSelectionUpdatesVisibleCopy() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let languagePicker = app.pickers["onboarding.language"].firstMatch
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        selectMenuPicker(languagePicker, option: "Español", in: app)

        XCTAssertTrue(app.navigationBars["Bienvenido"].waitForExistence(timeout: 4))
        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertEqual(continueButton.label, "Finalizar configuración")
        XCTAssertTrue(app.staticTexts["Paso 2 de 4: Idioma y región"].firstMatch.waitForExistence(timeout: 4))
    }

    func testIPhoneOnboardingFrenchCanadianSelectionUpdatesVisibleCopy() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let languagePicker = app.pickers["onboarding.language"].firstMatch
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        selectMenuPicker(languagePicker, option: "Français (Canada)", in: app)

        XCTAssertTrue(app.navigationBars["Bienvenue"].waitForExistence(timeout: 4))
        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertEqual(continueButton.label, "Terminer la configuration")
        XCTAssertTrue(app.staticTexts["Étape 2 sur 4 : Langue et région"].firstMatch.waitForExistence(timeout: 4))
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
            let enabledCount = progressCount(from: progress.label)
            consentToggle.tap()
            XCTAssertTrue(
                waitUntil(timeout: 3) {
                    guard let enabledCount, let currentCount = progressCount(from: progress.label) else {
                        return false
                    }
                    return currentCount < enabledCount
                },
                "Expected setup progress to refresh after disabling consent. Label now: \(progress.label)")
        }

        guard let beforeCount = progressCount(from: progress.label) else {
            XCTFail("Unable to parse setup progress from label: \(progress.label)")
            return
        }

        consentToggle.tap()
        XCTAssertTrue(
            waitUntil(timeout: 3) { (progressCount(from: progress.label) ?? beforeCount) >= beforeCount + 1 },
            "Expected setup progress to increment after consent toggle. Before: \(beforeCount), label now: \(progress.label)")
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
        let quoteButton = app.buttons["settings.quick.schedule_quote"].firstMatch
        XCTAssertTrue(scrollToElement(quoteButton, in: app))
        let supportButton = app.buttons["settings.quick.schedule_support"].firstMatch
        XCTAssertTrue(scrollToElement(supportButton, in: app))
    }

    func testDeepQuickSetupQuoteReminderControlsVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        let quoteToggle = app.switches["settings.quick.quote_toggle"].firstMatch
        XCTAssertTrue(scrollToElement(quoteToggle, in: app))
        if !switchIsOn(quoteToggle) {
            quoteToggle.tap()
        }

        let quoteTime = app.datePickers["settings.quick.quote_time"].firstMatch
        XCTAssertTrue(scrollToElement(quoteTime, in: app))
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

    func testIPhoneQuickSetupFrenchCanadianShowsLocalizedSetupCopy() {
        let app = makeApp(languageMode: "frenchCanadian")
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Configuration rapide"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Réglez ceci une fois, puis utilisez surtout Aujourd’hui et Jours de jeûne."].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.pickers["settings.quick.language"].firstMatch, in: app))
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
}
