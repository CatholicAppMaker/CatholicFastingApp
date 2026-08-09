import Foundation
import XCTest

private let premiumMonthlyProductID = "com.kevpierce.catholicfasting.premium.monthly.v3"
private let premiumYearlyProductID = "com.kevpierce.catholicfasting.premium.yearly.v3"

private struct PremiumToolRouteExpectation {
    let rawValue: String
    let contentID: String
    let title: String
}

extension CatholicFastingAppUITests {
    func testStoreKitCatalogLoadsMonthlyAndYearlyPrices() {
        let app = launchStoreKitPremiumScreen()
        assertStoreKitOffer(
            productID: premiumMonthlyProductID,
            expectedPrice: "$3.99",
            in: app)
        assertStoreKitOffer(
            productID: premiumYearlyProductID,
            expectedPrice: "$19.99",
            in: app)
    }

    func testIPhonePremiumLockedToolsAndAccountActionsRemainAvailable() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let toolsSegment = app.buttons["Premium Tools"].firstMatch
        XCTAssertTrue(toolsSegment.waitForExistence(timeout: 4))
        toolsSegment.tap()

        let lockedPreview = elementByIdentifier("premium.locked_feature_preview", in: app)
        XCTAssertTrue(scrollToElement(lockedPreview, in: app))

        let upgradeSegment = app.buttons["Upgrade"].firstMatch
        XCTAssertTrue(upgradeSegment.waitForExistence(timeout: 4))
        upgradeSegment.tap()

        let preview = elementByIdentifier("premium.sample_preview", in: app)
        XCTAssertTrue(scrollToElement(preview, in: app))

        let restoreButton = app.buttons["premium.restore"].firstMatch
        XCTAssertTrue(scrollToElement(restoreButton, in: app))
        XCTAssertTrue(restoreButton.isEnabled)

        let manageButton = app.buttons["premium.manage"].firstMatch
        XCTAssertTrue(scrollToElement(manageButton, in: app))
        XCTAssertTrue(manageButton.isEnabled)
    }

    func testSmokePremiumPlanLegalAndJourneyHierarchyVisible() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.plan_choice", in: app), in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.legal_actions", in: app), in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.journey", in: app), in: app))
    }

    func testIPhonePremiumShowsPlansAccountActionsAndLegal() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.plan_choice", in: app), in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.upgrade_summary", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.restore"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.manage"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.legal.terms", in: app), in: app))
    }

    func testDeepIPhonePremiumUnlockedShowsCurrentJourneyState() {
        let app = makeApp(premiumUnlocked: true)
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let journeyCard = elementByIdentifier("premium.sample_preview", in: app)
        XCTAssertTrue(scrollToElement(journeyCard, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Your Guided Seasonal Journey"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Current journey week:")).firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Next step:")).firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.restore"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.manage"].firstMatch, in: app))
    }

    func testIPhonePremiumToolsOpenAllDestinations() {
        let app = makeApp(premiumUnlocked: true)
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let toolsSegment = app.buttons["Premium Tools"].firstMatch
        XCTAssertTrue(toolsSegment.waitForExistence(timeout: 4))
        toolsSegment.tap()

        let routes = [
            PremiumToolRouteExpectation(rawValue: "planner", contentID: "premium.planner", title: "Planner"),
            PremiumToolRouteExpectation(rawValue: "reminders", contentID: "premium.reminders", title: "Reminders"),
            PremiumToolRouteExpectation(rawValue: "analytics", contentID: "premium.analytics", title: "Analytics"),
            PremiumToolRouteExpectation(rawValue: "journal", contentID: "premium.reflection", title: "Journal"),
            PremiumToolRouteExpectation(rawValue: "export", contentID: "premium.export_summary", title: "Export"),
        ]

        for route in routes {
            let row = elementByIdentifier("premium.tool.\(route.rawValue)", in: app)
            XCTAssertTrue(scrollToElement(row, in: app), "Unable to find Premium tool \(route.title)")
            row.tap()

            XCTAssertTrue(
                elementByIdentifier(route.contentID, in: app).waitForExistence(timeout: 4),
                "Premium tool \(route.title) did not show its content")
            XCTAssertTrue(
                app.navigationBars[route.title].waitForExistence(timeout: 4),
                "Premium tool \(route.title) did not open its destination")

            let backButton = app.navigationBars.buttons.firstMatch
            XCTAssertTrue(backButton.waitForExistence(timeout: 3))
            backButton.tap()
            XCTAssertTrue(
                elementByIdentifier("premium.surface_picker", in: app).waitForExistence(timeout: 4),
                "Back did not return to Premium Tools after \(route.title)")
        }

        returnToMoreHome(in: app)
    }

    func testIPhonePremiumSpanishShowsLocalizedJourneyAndSupportCopy() {
        let app = makeApp(languageMode: "spanish")
        app.launch()
        ensureOnHomeScreen(app)
        openSurface("More", in: app)
        let supportAndPremium = elementByIdentifier("more.hub.supportAndPremium", in: app)
        XCTAssertTrue(scrollToElement(supportAndPremium, in: app))
        supportAndPremium.tap()
        XCTAssertTrue(elementByIdentifier("premium.surface_picker", in: app).waitForExistence(timeout: 4))

        XCTAssertTrue(app.navigationBars["Soporte y Premium"].waitForExistence(timeout: 4))
        XCTAssertTrue(
            scrollToElement(
                app.staticTexts["Vista previa de Formación estacional guiada"].firstMatch,
                in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.sample_preview", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.restore"].firstMatch, in: app))
    }

    func testIPadPremiumSpanishShowsLocalizedWorkspaceCopy() {
        let app = makeApp(languageMode: "spanish")
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("supportAndPremium", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Apoyo y Premium"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(app.staticTexts["Vista previa de Formación estacional guiada"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.sample_preview", in: app), in: app))
    }

    func testIPadMorePremiumShowsPlansAndLegal() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("supportAndPremium", in: app)

        XCTAssertTrue(scrollToElement(app.staticTexts["Support & Premium"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.plan_choice", in: app), in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.plan_choice_state", in: app), in: app))
        XCTAssertTrue(scrollToElement(app.buttons["premium.restore"].firstMatch, in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.legal.terms", in: app), in: app))
        XCTAssertTrue(scrollToElement(elementByIdentifier("premium.legal.privacy", in: app), in: app))
    }

    func testIPadPremiumPlanChoicePrecedesLegalAndJourney() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)

        openIPadMoreDestination("supportAndPremium", in: app)

        let planChoice = elementByIdentifier("premium.plan_choice", in: app)
        let planState = elementByIdentifier("premium.plan_choice_state", in: app)
        let legal = elementByIdentifier("premium.legal_actions", in: app)
        let journey = elementByIdentifier("premium.sample_preview", in: app)
        XCTAssertTrue(planChoice.waitForExistence(timeout: 4))
        XCTAssertTrue(planState.waitForExistence(timeout: 4), "The plan-choice heading must never be followed by a blank state")
        XCTAssertTrue(legal.waitForExistence(timeout: 4))
        XCTAssertTrue(journey.waitForExistence(timeout: 4))
        XCTAssertLessThan(planChoice.frame.minY, legal.frame.minY)
        XCTAssertLessThan(legal.frame.minY, journey.frame.minY)
    }

    func testPremiumUnavailableStateOffersCatalogRetry() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let retry = app.buttons["premium.catalog.retry"].firstMatch
        XCTAssertTrue(scrollToElement(retry, in: app))
        XCTAssertTrue(retry.isHittable)
    }

    func testIPhonePremiumOfflineStateExplainsThatCurrentAccessIsPreserved() {
        let app = makeApp(premiumCatalogState: "offline")
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        let recovery = elementByIdentifier("premium.catalog.recovery", in: app)
        XCTAssertTrue(scrollToElement(recovery, in: app))
        XCTAssertTrue(recovery.label.localizedCaseInsensitiveContains("offline"))
        XCTAssertTrue(recovery.label.localizedCaseInsensitiveContains("current access"))
    }

    func testIPhonePremiumOfflineStatePreservesAnExistingEntitlement() {
        let app = makeApp(premiumUnlocked: true, premiumCatalogState: "offline")
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)

        XCTAssertTrue(
            app.buttons["premium.open_tools"].firstMatch.waitForExistence(timeout: 4),
            "An offline catalog refresh hid an existing Premium entitlement")
        let status = elementByIdentifier("premium.status", in: app)
        let premiumList = app.collectionViews.firstMatch
        XCTAssertTrue(premiumList.waitForExistence(timeout: 4))
        for _ in 0 ..< 4 where !status.exists {
            premiumList.swipeUp()
        }
        XCTAssertTrue(status.waitForExistence(timeout: 4))
        XCTAssertTrue(
            waitUntil(timeout: 4) {
                status.exists && status.label.localizedCaseInsensitiveContains("current access")
            },
            "The offline state did not confirm that the existing Premium access remains available")
    }

    func testIPadPremiumUnavailableStateOffersCatalogRetry() {
        let app = makeApp()
        app.launch()
        ensureOnHomeScreen(app)
        openIPadMoreDestination("supportAndPremium", in: app)

        let retry = app.buttons["premium.catalog.retry"].firstMatch
        XCTAssertTrue(scrollToElement(retry, in: app))
        XCTAssertTrue(retry.isHittable)
    }
}

private extension CatholicFastingAppUITests {
    func launchStoreKitPremiumScreen() -> XCUIApplication {
        let app = makeApp(includeUITestEnvironment: false)
        app.launch()
        ensureOnHomeScreen(app)
        openMoreDestination("Support & Premium", in: app)
        return app
    }

    func assertStoreKitOffer(
        productID: String,
        expectedPrice: String,
        in app: XCUIApplication)
    {
        let offer = elementByIdentifier("premium.offer.\(productID)", in: app)
        XCTAssertTrue(scrollToElement(offer, in: app), "StoreKit did not load \(productID)")
        let button = app.buttons["premium.offer.unlock.\(productID)"].firstMatch
        XCTAssertTrue(scrollToElement(button, in: app), "StoreKit did not expose \(productID)")
        XCTAssertTrue(
            button.label.contains(expectedPrice),
            "Expected \(productID) to display \(expectedPrice), got: \(button.label)")
    }
}
