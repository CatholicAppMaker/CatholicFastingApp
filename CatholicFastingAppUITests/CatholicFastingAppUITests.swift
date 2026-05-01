import Foundation
import UIKit
import XCTest

final class CatholicFastingAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        if name.contains("testIPad"), UIDevice.current.userInterfaceIdiom != .pad {
            throw XCTSkip("iPad-specific UI test is skipped on non-iPad destinations.")
        }
        if name.contains("testIPhone"), UIDevice.current.userInterfaceIdiom == .pad {
            throw XCTSkip("iPhone-specific UI test is skipped on iPad destinations.")
        }
    }

    func makeApp(
        skipOnboarding: Bool = true,
        seedMissed: Bool = false,
        seedDeterministic: Bool = true,
        disableAnimations: Bool = true,
        includeUITestEnvironment: Bool = true,
        regionProfile: String? = nil,
        languageMode: String? = nil,
        premiumUnlocked: Bool = false) -> XCUIApplication
    {
        let app = XCUIApplication()
        var args = ["-uitest-reset"]
        if seedDeterministic {
            args.append("-uitest-seed-deterministic")
        }
        if disableAnimations {
            args.append("-uitest-disable-animations")
        }
        if skipOnboarding {
            args.append("-uitest-skip-onboarding")
        }
        if seedMissed {
            args.append("-uitest-seed-missed")
        }
        app.launchArguments = args
        if includeUITestEnvironment {
            app.launchEnvironment["UITEST_MODE"] = "1"
        }
        if let regionProfile {
            app.launchEnvironment["UITEST_REGION_PROFILE"] = regionProfile
        }
        if let languageMode {
            app.launchEnvironment["UITEST_LANGUAGE_MODE"] = languageMode
        }
        if premiumUnlocked {
            app.launchEnvironment["UITEST_PREMIUM_UNLOCKED"] = "1"
        }
        return app
    }

    func makeFreshLaunchApp() -> XCUIApplication {
        makeApp(
            skipOnboarding: false,
            seedDeterministic: false,
            disableAnimations: true,
            includeUITestEnvironment: false)
    }

    func ensureOnHomeScreen(_ app: XCUIApplication) {
        let continueButton = app.buttons["onboarding.continue"]
        if continueButton.waitForExistence(timeout: 1) {
            continueButton.tap()
        }
        XCTAssertTrue(app.otherElements["home.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["surface.today.ready"].waitForExistence(timeout: 4))
    }

    func openSurface(_ label: String, in app: XCUIApplication) {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 3))

        let tab = tabButton(for: label, in: app)
        XCTAssertTrue(tab.waitForExistence(timeout: 3), "Unable to find tab \(label)")
        tab.tap()
        waitForSurfaceReady(label, in: app)
    }

    func tabButton(for label: String, in app: XCUIApplication) -> XCUIElement {
        let tabBar = app.tabBars.firstMatch
        for candidate in tabLabels(for: label) {
            let button = tabBar.buttons[candidate].firstMatch
            if button.exists {
                return button
            }
        }
        return tabBar.buttons[label].firstMatch
    }

    func tabLabels(for label: String) -> [String] {
        switch label {
        case "Today":
            ["Today", "Hoy", "Aujourd’hui"]
        case "Fasting Days":
            ["Fasting Days", "Días de ayuno", "Jours de jeûne"]
        case "Track Fast":
            ["Track Fast", "Registrar ayuno", "Suivi du jeûne"]
        case "More":
            ["More", "Más", "Plus"]
        default:
            [label]
        }
    }

    func openMoreDestination(_ title: String, in app: XCUIApplication) {
        openSurface("More", in: app)

        if let rawValue = moreDestinationRawValue(for: title) {
            let identifiedDestination = elementByIdentifier("more.hub.\(rawValue)", in: app)
            if identifiedDestination.exists || identifiedDestination.waitForExistence(timeout: 1) {
                XCTAssertTrue(scrollToElement(identifiedDestination, in: app), "Unable to find More destination \(title)")
                identifiedDestination.tap()
                XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4))
                return
            }
        }

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

    func moreDestinationRawValue(for title: String) -> String? {
        switch title {
        case "Support & Premium":
            "supportAndPremium"
        case "Setup & Reminders":
            "setupAndReminders"
        case "Profile & Norms":
            "profileAndNorms"
        case "Guidance & Rules":
            "guidanceAndRules"
        case "History of Fasting":
            "historyOfFasting"
        case "Privacy & Data":
            "privacyAndData"
        default:
            nil
        }
    }

    func moreDestinationTitle(for rawValue: String) -> String? {
        switch rawValue {
        case "supportAndPremium":
            "Support & Premium"
        case "setupAndReminders":
            "Setup & Reminders"
        case "profileAndNorms":
            "Profile & Norms"
        case "guidanceAndRules":
            "Guidance & Rules"
        case "historyOfFasting":
            "History of Fasting"
        case "privacyAndData":
            "Privacy & Data"
        default:
            nil
        }
    }

    func openIPadSurface(_ rawValue: String, in app: XCUIApplication) {
        let button = app.buttons["ipad.sidebar.\(rawValue)"].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 4), "Unable to find iPad sidebar surface \(rawValue)")
        button.tap()
    }

    func openIPadMoreDestination(_ rawValue: String, in app: XCUIApplication) {
        openIPadSurface("more", in: app)
        let regularMoreReady = app.otherElements["surface.more.ready"].firstMatch.waitForExistence(timeout: 4)
        let workspaceReady = app.otherElements["ipad.more.workspace"].firstMatch.waitForExistence(timeout: 2)
            || app.otherElements["ipad.more.premium"].firstMatch.waitForExistence(timeout: 2)

        if regularMoreReady, !workspaceReady, let title = moreDestinationTitle(for: rawValue) {
            if let identifiedDestination = optionalElementByIdentifier("more.hub.\(rawValue)", in: app) {
                XCTAssertTrue(
                    scrollToElementInApp(identifiedDestination, in: app, maxSwipes: 10)
                        || scrollToElement(identifiedDestination, in: app, maxSwipes: 10),
                    "Unable to find compact iPad More destination \(title)")
                identifiedDestination.tap()
                if rawValue != "supportAndPremium" {
                    XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4))
                }
                return
            }

            let destinationButton = app.buttons[title].firstMatch
            if destinationButton.exists || destinationButton.waitForExistence(timeout: 1) {
                XCTAssertTrue(
                    scrollToElementInApp(destinationButton, in: app, maxSwipes: 10)
                        || scrollToElement(destinationButton, in: app, maxSwipes: 10),
                    "Unable to find compact iPad More destination \(title)")
                destinationButton.tap()
                if rawValue != "supportAndPremium" {
                    XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4))
                }
                return
            }

            let destinationCell = app.descendants(matching: .cell)
                .matching(NSPredicate(format: "label CONTAINS %@", title))
                .firstMatch
            if destinationCell.exists || destinationCell.waitForExistence(timeout: 1) {
                XCTAssertTrue(
                    scrollToElementInApp(destinationCell, in: app, maxSwipes: 10)
                        || scrollToElement(destinationCell, in: app, maxSwipes: 10),
                    "Unable to find compact iPad More destination row \(title)")
                destinationCell.tap()
                if rawValue != "supportAndPremium" {
                    XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4))
                }
                return
            }

            let destinationText = app.staticTexts[title].firstMatch
            XCTAssertTrue(
                scrollToElementInApp(destinationText, in: app, maxSwipes: 10)
                    || scrollToElement(destinationText, in: app, maxSwipes: 10),
                "Unable to find compact iPad More destination \(title)")
            destinationText.tap()
            if rawValue != "supportAndPremium" {
                XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4))
            }
            return
        }

        XCTAssertTrue(workspaceReady || regularMoreReady, "Unable to reach iPad More workspace")

        let destination = elementByIdentifier("ipad.more.destination.\(rawValue)", in: app)
        let compactDestination = elementByIdentifier("ipad.more.compact.\(rawValue)", in: app)
        if rawValue == "supportAndPremium" {
            if destination.exists || destination.waitForExistence(timeout: 1) {
                XCTAssertTrue(scrollToElement(destination, in: app))
                destination.tap()
                return
            }
            if compactDestination.exists || compactDestination.waitForExistence(timeout: 1) {
                XCTAssertTrue(scrollToElementInApp(compactDestination, in: app))
                compactDestination.tap()
                return
            }
            XCTAssertTrue(app.otherElements["ipad.more.workspace"].waitForExistence(timeout: 4))
            return
        }

        let target = destination.waitForExistence(timeout: 1) ? destination : compactDestination
        if target.exists || target.waitForExistence(timeout: 1) {
            let found = target == compactDestination
                ? scrollToElementInApp(target, in: app)
                : scrollToElement(target, in: app)
            XCTAssertTrue(found, "Unable to bring iPad More destination \(rawValue) into view")
            target.tap()
            return
        }

        XCTAssertTrue(
            scrollToElementInApp(compactDestination, in: app, maxSwipes: 10)
                || scrollToElementInApp(destination, in: app, maxSwipes: 10),
            "Unable to find iPad More destination \(rawValue)")

        let fallback = compactDestination.exists ? compactDestination : destination
        XCTAssertTrue(fallback.exists, "Unable to find iPad More destination \(rawValue)")
        fallback.tap()
    }

    func assertIPadMoreDestinationContent(_ rawValue: String, in app: XCUIApplication) {
        switch rawValue {
        case "supportAndPremium":
            XCTAssertTrue(scrollToElement(elementByIdentifier("premium.subscription_store", in: app), in: app))
        case "setupAndReminders":
            XCTAssertTrue(scrollToElement(app.pickers["settings.region_picker"].firstMatch, in: app))
        case "profileAndNorms":
            XCTAssertTrue(scrollToElement(app.pickers["settings.region_picker"].firstMatch, in: app))
        case "guidanceAndRules":
            XCTAssertTrue(scrollToElement(app.otherElements["guidance.food.section"].firstMatch, in: app))
        case "historyOfFasting":
            XCTAssertTrue(scrollToElement(app.buttons["history.article.earlyChurch"].firstMatch, in: app))
        case "privacyAndData":
            XCTAssertTrue(app.navigationBars["Privacy & Data"].firstMatch.waitForExistence(timeout: 4))
            XCTAssertTrue(app.buttons["launch.export_data"].firstMatch.waitForExistence(timeout: 4))
        default:
            XCTFail("Unhandled iPad More destination \(rawValue)")
        }
    }

    func assertIPhoneMoreDestinationContent(_ rawValue: String, in app: XCUIApplication) {
        let hero = elementByIdentifier("more.\(rawValue).hero", in: app)
        XCTAssertTrue(
            hero.waitForExistence(timeout: 4) || scrollToElement(hero, in: app),
            "More destination \(rawValue) opened without its destination hero")

        switch rawValue {
        case "supportAndPremium":
            XCTAssertTrue(scrollToElement(app.staticTexts["Premium Upgrade"].firstMatch, in: app))
        case "setupAndReminders":
            XCTAssertTrue(scrollToElementPresence(elementByIdentifier("settings.quick.language", in: app), in: app))
            XCTAssertTrue(scrollToElementPresence(elementByIdentifier("settings.quick.reminder_actions", in: app), in: app))
        case "profileAndNorms":
            XCTAssertTrue(scrollToElementPresence(elementByIdentifier("settings.region_picker", in: app), in: app))
        case "guidanceAndRules":
            XCTAssertTrue(scrollToElementPresence(elementByIdentifier("guidance.sacred_gallery", in: app), in: app))
        case "historyOfFasting":
            XCTAssertTrue(scrollToElement(app.buttons["history.article.earlyChurch"].firstMatch, in: app))
        case "privacyAndData":
            XCTAssertTrue(scrollToElementPresence(elementByIdentifier("launch.export_data", in: app), in: app))
        default:
            XCTFail("Unhandled iPhone More destination \(rawValue)")
        }
    }

    func waitForSurfaceReady(_ label: String, in app: XCUIApplication) {
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

    func scrollToElement(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 3)
        -> Bool
    {
        if elementIsVisible(element, in: app) {
            return true
        }

        for scrollContainer in scrollCandidates(in: app) {
            for _ in 0 ..< maxSwipes {
                scrollContainer.swipeUp()
                if elementIsVisible(element, in: app) {
                    return true
                }
            }

            for _ in 0 ..< maxSwipes {
                scrollContainer.swipeDown()
                if elementIsVisible(element, in: app) {
                    return true
                }
            }
        }

        return elementIsVisible(element, in: app)
    }

    func scrollToElementPresence(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 3)
        -> Bool
    {
        if element.exists {
            return true
        }

        for scrollContainer in scrollCandidates(in: app) {
            for _ in 0 ..< maxSwipes {
                scrollContainer.swipeUp()
                if element.exists {
                    return true
                }
            }

            for _ in 0 ..< maxSwipes {
                scrollContainer.swipeDown()
                if element.exists {
                    return true
                }
            }
        }

        return element.exists
    }

    func scrollCandidates(in app: XCUIApplication) -> [XCUIElement] {
        [app.collectionViews.firstMatch]
    }

    func scrollToElementInApp(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 3)
        -> Bool
    {
        if elementIsVisible(element, in: app) {
            return true
        }

        for _ in 0 ..< maxSwipes {
            app.swipeUp()
            if elementIsVisible(element, in: app) {
                return true
            }
        }

        for _ in 0 ..< maxSwipes {
            app.swipeDown()
            if elementIsVisible(element, in: app) {
                return true
            }
        }

        return elementIsVisible(element, in: app)
    }

    func elementIsVisible(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        guard element.exists, !element.frame.isEmpty else {
            return false
        }
        return app.frame.intersects(element.frame)
    }

    func elementByIdentifier(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    func optionalElementByIdentifier(_ identifier: String, in app: XCUIApplication) -> XCUIElement? {
        let element = elementByIdentifier(identifier, in: app)
        return element.exists || element.waitForExistence(timeout: 1) ? element : nil
    }

    func expandDisclosureGroup(_ label: String, in app: XCUIApplication) {
        if let identifier = disclosureIdentifier(for: label) {
            let identified = elementByIdentifier(identifier, in: app)
            if scrollToElement(identified, in: app) {
                identified.tap()
                return
            }
        }

        let button = app.buttons[label].firstMatch
        if scrollToElement(button, in: app) {
            button.tap()
            return
        }

        for candidate in disclosureLabels(for: label) {
            let candidateButton = app.buttons[candidate].firstMatch
            if scrollToElement(candidateButton, in: app) {
                candidateButton.tap()
                return
            }

            let candidateText = app.staticTexts[candidate].firstMatch
            if scrollToElement(candidateText, in: app) {
                candidateText.tap()
                return
            }
        }

        XCTFail("Unable to find disclosure group \(label)")
    }

    func disclosureIdentifier(for label: String) -> String? {
        switch label {
        case "Customize List":
            "fasting_days.filters.customize"
        case "Reminder Actions":
            "settings.quick.reminder_actions"
        default:
            nil
        }
    }

    func disclosureLabels(for label: String) -> [String] {
        switch label {
        case "Customize List":
            ["Customize List", "Personalizar lista", "Personnaliser la liste"]
        case "Reminder Actions":
            ["Reminder Actions", "Acciones de recordatorios", "Actions de rappels"]
        default:
            [label]
        }
    }

    func selectMenuPicker(_ picker: XCUIElement, option: String, in app: XCUIApplication) {
        XCTAssertTrue(scrollToElement(picker, in: app), "Unable to find picker \(picker)")
        picker.tap()

        let optionButton = app.buttons[option].firstMatch
        XCTAssertTrue(optionButton.waitForExistence(timeout: 4), "Unable to find picker option \(option)")
        optionButton.tap()
    }

    func returnToMoreHome(in app: XCUIApplication) {
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
        XCTAssertTrue(app.otherElements["surface.more.ready"].waitForExistence(timeout: 4))
        XCTAssertTrue(
            app.navigationBars["More"].firstMatch.waitForExistence(timeout: 4)
                || app.staticTexts["More"].firstMatch.waitForExistence(timeout: 4))
    }

    func switchIsOn(_ element: XCUIElement) -> Bool {
        let rawValue = element.value as? String
        return rawValue == "1" || rawValue == "On"
    }

    func progressCount(from label: String) -> Int? {
        guard let range = label.range(of: #"\d+/\d+"#, options: .regularExpression) else {
            return nil
        }
        let token = label[range]
        guard let numerator = token.split(separator: "/").first else {
            return nil
        }
        return Int(numerator)
    }

    func waitUntil(
        timeout: TimeInterval,
        pollInterval: TimeInterval = 0.1,
        condition: () -> Bool) -> Bool
    {
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
