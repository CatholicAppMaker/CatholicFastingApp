import Foundation
import XCTest

extension CatholicFastingAppUITests {
    func testFreshLaunchIPhoneCanCompleteOnboardingAndReachToday() {
        let app = makeFreshLaunchApp()
        app.launch()

        advancePastLanguageSelection(in: app)
        acceptOnboardingNotice(in: app)
        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertTrue(continueButton.waitForExistence(timeout: 4))
        XCTAssertTrue(waitUntil(timeout: 3) { continueButton.isHittable })
        continueButton.tap()

        XCTAssertTrue(app.otherElements["surface.today.ready"].waitForExistence(timeout: 6))
        XCTAssertFalse(app.staticTexts["Setup checklist: 2/3"].firstMatch.exists)
    }

    func testFreshLaunchIPadCanCompleteOnboardingAndRenderTodayWorkspace() {
        let app = makeFreshLaunchApp()
        app.launch()

        advancePastLanguageSelection(in: app)
        acceptOnboardingNotice(in: app)
        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertTrue(scrollToElement(continueButton, in: app))
        continueButton.tap()

        assertIPadWorkspaceVisible("today", in: app, timeout: 6)
        XCTAssertTrue(app.otherElements["companion.dashboard"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.otherElements["ipad.today.actions"].waitForExistence(timeout: 6))
    }

    func testOnboardingFinishRequirementExplainsAndRevealsAcknowledgment() {
        let app = makeFreshLaunchApp()
        app.launch()

        advancePastLanguageSelection(in: app)

        let finishButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertTrue(finishButton.waitForExistence(timeout: 4))
        XCTAssertFalse(finishButton.isEnabled)

        let requirementTitle = app.staticTexts["onboarding.legal_requirement.title"].firstMatch
        XCTAssertTrue(requirementTitle.waitForExistence(timeout: 4))

        let reviewButton = app.buttons["onboarding.legal_requirement.review"].firstMatch
        XCTAssertTrue(reviewButton.waitForExistence(timeout: 4))
        reviewButton.tap()

        let acknowledgment = app.switches["onboarding.accept_legal_notice"].firstMatch
        XCTAssertTrue(acknowledgment.waitForExistence(timeout: 4))
        XCTAssertTrue(waitUntil(timeout: 3) { acknowledgment.isHittable })
        XCTAssertFalse(switchIsOn(acknowledgment))

        turnOnOnboardingToggle("onboarding.accept_legal_notice", in: app)
        XCTAssertTrue(waitUntil(timeout: 3) { finishButton.isEnabled })
        XCTAssertTrue(waitUntil(timeout: 3) { !requirementTitle.exists })
    }

    func testIPhoneOnboardingSpanishSelectionUpdatesVisibleCopy() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let languagePicker = elementByIdentifier("onboarding.language", in: app)
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        selectMenuPicker(languagePicker, option: "Español", in: app)

        XCTAssertTrue(app.navigationBars["Bienvenido"].waitForExistence(timeout: 4))
        let languageContinue = app.buttons["onboarding.language_continue"].firstMatch
        XCTAssertEqual(languageContinue.label, "Continuar")
        languageContinue.tap()
        XCTAssertTrue(app.staticTexts["Básicos"].firstMatch.waitForExistence(timeout: 4))
    }

    func testIPhoneOnboardingFrenchCanadianSelectionUpdatesVisibleCopy() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let languagePicker = elementByIdentifier("onboarding.language", in: app)
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        selectMenuPicker(languagePicker, option: "Français (Canada)", in: app)

        XCTAssertTrue(app.navigationBars["Bienvenue"].waitForExistence(timeout: 4))
        let languageContinue = app.buttons["onboarding.language_continue"].firstMatch
        XCTAssertEqual(languageContinue.label, "Continuer")
        languageContinue.tap()
        XCTAssertTrue(app.staticTexts["Base"].firstMatch.waitForExistence(timeout: 4))
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

    func testIPhoneSetupOpensFridayNotesHistory() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        let historyLink = app.staticTexts["Friday Notes History"].firstMatch
        XCTAssertTrue(scrollToElement(historyLink, in: app, maxSwipes: 16))
        historyLink.tap()

        XCTAssertTrue(app.navigationBars["Friday Notes"].waitForExistence(timeout: 4))
    }

    func testIPhonePrivacyDataShowsExportAndDeleteControls() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Privacy & Data", in: app)

        let exportButton = app.buttons["launch.export_data"].firstMatch
        XCTAssertTrue(scrollToElement(exportButton, in: app))

        let deleteButton = app.buttons["launch.delete_all_data"].firstMatch
        XCTAssertTrue(scrollToElement(deleteButton, in: app))
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
            tapSwitch(consentToggle, in: app)
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

        tapSwitch(consentToggle, in: app)
        XCTAssertTrue(
            waitUntil(timeout: 3) {
                let refreshedProgress = app.staticTexts["settings.quick.progress"].firstMatch
                let refreshedToggle = app.switches["settings.quick.consent"].firstMatch
                return (progressCount(from: refreshedProgress.label) ?? beforeCount) >= beforeCount + 1
                    || switchIsOn(refreshedToggle)
            },
            "Expected setup progress to increment after consent toggle. Before: \(beforeCount), label now: \(progress.label)")
    }

    func testDeepQuickSetupReminderActionsVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        setSwitch(app.switches["settings.quick.reminder_support"].firstMatch, to: true, in: app)

        let actions = elementByIdentifier("settings.quick.reminder_actions", in: app)
        XCTAssertTrue(
            scrollToElement(actions, in: app, maxSwipes: 8),
            "Enabling reminder support did not expose Reminder Actions")
        expandDisclosureGroup("Reminder Actions", in: app)
        let permissionButton = app.buttons["Request Notification Permission"].firstMatch
        XCTAssertTrue(
            scrollToElementPresence(permissionButton, in: app, maxSwipes: 8),
            "Expanding Reminder Actions did not reveal the permission action")
        let requiredButton = app.buttons["Schedule Required-Day Reminders"].firstMatch
        XCTAssertTrue(
            scrollToElementPresence(requiredButton, in: app, maxSwipes: 8),
            "Expanding Reminder Actions did not reveal required-day scheduling")
        let quoteButton = app.buttons["Schedule Daily Quote Reminder"].firstMatch
        XCTAssertTrue(
            scrollToElementPresence(quoteButton, in: app, maxSwipes: 8),
            "Expanding Reminder Actions did not reveal quote scheduling")
        let supportButton = app.buttons["Schedule Daily Support Reminders"].firstMatch
        XCTAssertTrue(
            scrollToElementPresence(supportButton, in: app, maxSwipes: 8),
            "Expanding Reminder Actions did not reveal support scheduling")
    }

    func testIPhoneNotificationDenialShowsSettingsRecoveryGuidance() {
        let app = makeApp(notificationAuthorization: "denied")
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)
        setSwitch(app.switches["settings.quick.consent"].firstMatch, to: true, in: app)
        setSwitch(app.switches["settings.quick.reminder_support"].firstMatch, to: true, in: app)
        expandDisclosureGroup("Reminder Actions", in: app)

        let status = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'denied' AND label CONTAINS[c] 'Settings'"))
            .firstMatch
        XCTAssertTrue(
            scrollToElementPresence(status, in: app, maxSwipes: 8),
            "Expanding Reminder Actions did not reveal notification status")
        XCTAssertTrue(
            waitUntil(timeout: 4) {
                status.label.localizedCaseInsensitiveContains("denied")
            },
            "Denied notification status did not appear")
        XCTAssertTrue(
            status.label.localizedCaseInsensitiveContains("Settings"),
            "Denied notification guidance does not direct the user to Settings")
    }

    func testDeepQuickSetupQuoteReminderControlsVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        let quoteToggle = app.switches["settings.quick.quote_toggle"].firstMatch
        setSwitch(quoteToggle, to: true, in: app)

        let quoteTime = elementByIdentifier("settings.quick.quote_time", in: app)
        XCTAssertTrue(scrollToElement(quoteTime, in: app))
    }

    func testDeepQuickSetupShowsLanguageSelector() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        let languagePicker = elementByIdentifier("settings.quick.language", in: app)
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        let regionPicker = elementByIdentifier("settings.quick.region", in: app)
        XCTAssertTrue(scrollToElement(regionPicker, in: app))
    }

    func testDeepHouseholdProfileCanBeCreatedAndReapplied() {
        let app = makeApp(abstinenceAgeEligible: false, fastingAgeEligible: false)
        app.launch()
        ensureOnHomeScreen(app)

        openMoreDestination("Profile & Norms", in: app)

        let nameField = app.textFields["settings.household.new_name"].firstMatch
        XCTAssertTrue(scrollToElement(nameField, in: app))
        nameField.tap()
        nameField.typeText("Teen Profile")

        let addButton = app.buttons["settings.household.add"].firstMatch
        XCTAssertTrue(scrollToElement(addButton, in: app))
        addButton.tap()

        returnToMoreHub(in: app)
        openMoreDestination("Setup & Reminders", in: app)
        let age14Toggle = app.switches["settings.quick.age14_toggle"].firstMatch
        let age18Toggle = app.switches["settings.quick.age18_toggle"].firstMatch
        setSwitch(age14Toggle, to: true, in: app)
        setSwitch(age18Toggle, to: true, in: app)

        returnToMoreHub(in: app)
        openMoreDestination("Profile & Norms", in: app)
        let applyButton = app.buttons["settings.household.apply"].firstMatch
        XCTAssertTrue(scrollToElement(applyButton, in: app))
        applyButton.tap()

        returnToMoreHub(in: app)
        openMoreDestination("Setup & Reminders", in: app)
        XCTAssertEqual(app.switches["settings.quick.age14_toggle"].firstMatch.value as? String, "0")
        XCTAssertEqual(app.switches["settings.quick.age18_toggle"].firstMatch.value as? String, "0")
    }

    func testIPadOnboardingShowsRegionSelector() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        XCTAssertTrue(elementByIdentifier("onboarding.language", in: app).waitForExistence(timeout: 4))
        advancePastLanguageSelection(in: app)
        XCTAssertTrue(elementByIdentifier("onboarding.region", in: app).waitForExistence(timeout: 4))
    }

    func testIPadOnboardingLanguageSelectionUpdatesVisibleCopy() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let languagePicker = elementByIdentifier("onboarding.language", in: app)
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        selectMenuPicker(languagePicker, option: "Español", in: app)

        XCTAssertTrue(app.navigationBars["Bienvenido"].waitForExistence(timeout: 4))

        let languageContinue = app.buttons["onboarding.language_continue"].firstMatch
        XCTAssertTrue(languageContinue.waitForExistence(timeout: 4))
        XCTAssertEqual(languageContinue.label, "Continuar")
        languageContinue.tap()
        XCTAssertTrue(app.staticTexts["Básicos"].firstMatch.waitForExistence(timeout: 4))
    }

    func testIPadOnboardingFrenchCanadianSelectionUpdatesVisibleCopy() {
        let app = makeApp(skipOnboarding: false)
        app.launch()

        let languagePicker = elementByIdentifier("onboarding.language", in: app)
        XCTAssertTrue(scrollToElement(languagePicker, in: app))
        selectMenuPicker(languagePicker, option: "Français (Canada)", in: app)

        XCTAssertTrue(app.navigationBars["Bienvenue"].waitForExistence(timeout: 4))

        let languageContinue = app.buttons["onboarding.language_continue"].firstMatch
        XCTAssertTrue(languageContinue.waitForExistence(timeout: 4))
        XCTAssertEqual(languageContinue.label, "Continuer")
        languageContinue.tap()
        XCTAssertTrue(app.staticTexts["Base"].firstMatch.waitForExistence(timeout: 4))
    }

    func testIPhoneQuickSetupFrenchCanadianShowsLocalizedSetupCopy() {
        let app = makeApp(languageMode: "frenchCanadian")
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Setup & Reminders", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Configuration rapide"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Réglez ceci une fois, puis utilisez surtout Aujourd’hui et Calendrier."].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("settings.quick.language", in: app), in: app))
    }

    func testIPhoneAccessibilitySettingsDoNotShowVoiceSummary() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openMoreDestination("Profile & Norms", in: app)

        let advancedAccessibility = app.buttons["settings.accessibility.advanced"].firstMatch
        XCTAssertTrue(scrollToElement(advancedAccessibility, in: app))
        advancedAccessibility.tap()

        XCTAssertFalse(app.switches["settings.accessibility.voice_summary"].firstMatch.exists)
        XCTAssertFalse(app.buttons["Read Voice Summary"].firstMatch.exists)
        XCTAssertFalse(app.staticTexts["Enable Voice Summary"].firstMatch.exists)
    }

    func advancePastLanguageSelection(in app: XCUIApplication) {
        let languageContinue = app.buttons["onboarding.language_continue"].firstMatch
        XCTAssertTrue(languageContinue.waitForExistence(timeout: 6))
        languageContinue.tap()
    }

    func acceptOnboardingNotice(in app: XCUIApplication) {
        turnOnOnboardingToggle("onboarding.accept_legal_notice", in: app)
        let continueButton = app.buttons["onboarding.continue"].firstMatch
        XCTAssertTrue(waitUntil(timeout: 2) { continueButton.isEnabled })
    }

    func turnOnOnboardingToggle(_ identifier: String, in app: XCUIApplication) {
        let toggle = app.switches[identifier].firstMatch
        XCTAssertTrue(scrollToElement(toggle, in: app))
        if !switchIsOn(toggle) {
            turnOnOnboardingToggleControl(toggle)
            let finishButton = app.buttons["onboarding.continue"].firstMatch
            let reachedEnabledState = {
                if finishButton.exists, finishButton.isEnabled {
                    return true
                }
                let refreshed = app.switches[identifier].firstMatch
                return refreshed.exists && self.switchIsOn(refreshed)
            }

            if !waitUntil(timeout: 1, condition: reachedEnabledState) {
                let refreshed = app.switches[identifier].firstMatch
                XCTAssertTrue(scrollToElement(refreshed, in: app))
                tapTrailingOnboardingSwitchControl(refreshed)
            }

            XCTAssertTrue(
                waitUntil(timeout: 3) {
                    // Accepting the notice removes the requirement inset and can recycle the
                    // List row on iPadOS. The enabled Finish button is the stable, user-visible
                    // result of operating the real switch; only query the refreshed switch as
                    // a fallback while its row remains materialized.
                    reachedEnabledState()
                },
                "Expected onboarding switch \(identifier) to become enabled")
        }
    }

    func turnOnOnboardingToggleControl(_ toggle: XCUIElement) {
        XCTAssertTrue(toggle.isHittable, "Expected onboarding switch \(toggle.identifier) to be hittable")
        // iPadOS 27 exposes the full labeled Toggle row as the Switch accessibility frame,
        // while its visual control is a nested native switch. A directional switch gesture
        // operates that real control without depending on the row width or label hit region.
        toggle.swipeRight()
    }

    func tapTrailingOnboardingSwitchControl(_ toggle: XCUIElement) {
        XCTAssertTrue(toggle.isHittable, "Expected onboarding switch \(toggle.identifier) to be hittable")
        // The outer Switch frame spans the whole List row on iPadOS 27. Resolve the native
        // control from the row's trailing edge instead of a normalized row percentage.
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0.5))
            .withOffset(CGVector(dx: -30, dy: 0))
            .tap()
    }
}
