import Foundation
import XCTest

extension CatholicFastingAppUITests {
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

    func testDeepIPhonePremiumUnlockedShowsCurrentJourneyState() {
        let app = makeApp(premiumUnlocked: true)
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let journeyCard = app.otherElements["premium.sample_preview"].firstMatch
        XCTAssertTrue(scrollToElement(journeyCard, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Your Guided Seasonal Journey"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Current journey week:")).firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Next step:")).firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.restore"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.manage"].firstMatch, in: app))
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

    func testIPhonePremiumSpanishShowsLocalizedJourneyAndSupportCopy() {
        let app = makeApp(languageMode: "spanish")
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Apoyo y Premium"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Vea el Camino estacional guiado"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Propinas opcionales de apoyo"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.restore"].firstMatch, in: app))
    }

    func testIPadPremiumSpanishShowsLocalizedWorkspaceCopy() {
        let app = makeApp(languageMode: "spanish")
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("supportAndPremium", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Apoyo y Premium"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Vea el Camino estacional guiado"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Propinas opcionales de apoyo"].firstMatch, in: app))
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
}
