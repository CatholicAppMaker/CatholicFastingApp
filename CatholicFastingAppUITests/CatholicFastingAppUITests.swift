import Foundation
import UIKit
import XCTest

final class CatholicFastingAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        if name.contains("IPad"), UIDevice.current.userInterfaceIdiom != .pad {
            throw XCTSkip("iPad-specific UI test is skipped on non-iPad destinations.")
        }
        if name.contains("IPhone"), UIDevice.current.userInterfaceIdiom == .pad {
            throw XCTSkip("iPhone-specific UI test is skipped on iPad destinations.")
        }
    }

    func makeApp(
        skipOnboarding: Bool = true,
        seedMissed: Bool = false,
        seedActiveFast: Bool = false,
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
        if seedActiveFast {
            args.append("-uitest-seed-active-fast")
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
        if tapUITestSurfaceSwitcher(label, in: app) {
            waitForSurfaceReady(label, in: app)
            return
        }

        if tapTodayQuickSurfaceAction(label, in: app) {
            XCTAssertTrue(
                waitUntil(timeout: 3, condition: { visibleSurfaceNavigationTitle(for: label, in: app) }),
                "Unable to select tab \(label)")
            waitForSurfaceReady(label, in: app)
            return
        }

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 3))

        tapTab(label, in: app)
        if !waitUntil(timeout: 1, condition: { visibleSurfaceNavigationTitle(for: label, in: app) }) {
            tapTab(label, in: app)
        }
        XCTAssertTrue(
            waitUntil(timeout: 3, condition: { visibleSurfaceNavigationTitle(for: label, in: app) }),
            "Unable to select tab \(label)")
        waitForSurfaceReady(label, in: app)
    }

    func tapUITestSurfaceSwitcher(_ label: String, in app: XCUIApplication) -> Bool {
        guard let rawValue = surfaceRawValue(for: label) else {
            return false
        }

        let button = app.buttons["uitest.surface.\(rawValue)"].firstMatch
        guard button.exists || button.waitForExistence(timeout: 1) else {
            return false
        }
        button.tap()
        return true
    }

    func surfaceRawValue(for label: String) -> String? {
        switch label {
        case "Today":
            "today"
        case "Fasting Days":
            "fastingDays"
        case "Track Fast":
            "intermittent"
        case "More":
            "more"
        default:
            nil
        }
    }

    func tapTodayQuickSurfaceAction(_ label: String, in app: XCUIApplication) -> Bool {
        guard let identifier = todayQuickSurfaceActionIdentifier(for: label),
              visibleSurfaceNavigationTitle(for: "Today", in: app)
        else {
            return false
        }

        let button = app.buttons[identifier].firstMatch
        guard button.exists || scrollToElementPresence(button, in: app, maxSwipes: 8) else {
            return false
        }
        guard scrollToElement(button, in: app, maxSwipes: 8) else {
            return false
        }
        button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        return true
    }

    func todayQuickSurfaceActionIdentifier(for label: String) -> String? {
        switch label {
        case "Fasting Days":
            "today.quick.fasting_days"
        case "Track Fast":
            "today.quick.intermittent"
        case "More":
            "today.quick.more"
        default:
            nil
        }
    }

    func tabButton(for label: String, in app: XCUIApplication) -> XCUIElement {
        let tabBar = app.tabBars.firstMatch
        if let index = tabIndex(for: label) {
            let indexedButton = tabBar.buttons.element(boundBy: index)
            if indexedButton.exists {
                return indexedButton
            }
        }
        for candidate in tabLabels(for: label) {
            let button = tabBar.buttons[candidate].firstMatch
            if button.exists {
                return button
            }
        }
        return tabBar.buttons[label].firstMatch
    }

    func tabIndex(for label: String) -> Int? {
        switch label {
        case "Today":
            0
        case "Fasting Days":
            1
        case "Track Fast":
            2
        case "More":
            3
        default:
            nil
        }
    }

    func tapTab(_ label: String, in app: XCUIApplication) {
        guard let index = tabIndex(for: label) else {
            let tab = tabButton(for: label, in: app)
            XCTAssertTrue(tab.waitForExistence(timeout: 3), "Unable to find tab \(label)")
            tab.tap()
            return
        }

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 3))
        let tabCenterX = (Double(index) + 0.5) / 4.0
        tabBar.coordinate(withNormalizedOffset: CGVector(dx: tabCenterX, dy: 0.5)).tap()
    }

    func visibleSurfaceNavigationTitle(for label: String, in app: XCUIApplication) -> Bool {
        tabLabels(for: label).contains { candidate in
            let navigationBar = app.navigationBars[candidate].firstMatch
            return elementIsVisible(navigationBar, in: app)
        }
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
        if let rawValue = moreDestinationRawValue(for: title),
           tapUITestMoreDestination(rawValue, in: app)
        {
            assertMoreDestinationOpened(rawValue, title: title, in: app)
            return
        }

        openSurface("More", in: app)

        if let rawValue = moreDestinationRawValue(for: title) {
            let identifiedDestination = elementByIdentifier("more.hub.\(rawValue)", in: app)
            if identifiedDestination.exists || identifiedDestination.waitForExistence(timeout: 1) {
                XCTAssertTrue(scrollToElement(identifiedDestination, in: app), "Unable to find More destination \(title)")
                identifiedDestination.tap()
                assertMoreDestinationOpened(rawValue, title: title, in: app)
                return
            }
        }

        let destinationButton = app.buttons[title].firstMatch
        if destinationButton.exists || destinationButton.waitForExistence(timeout: 1) {
            XCTAssertTrue(scrollToElement(destinationButton, in: app))
            destinationButton.tap()
            if let rawValue = moreDestinationRawValue(for: title) {
                assertMoreDestinationOpened(rawValue, title: title, in: app)
            } else {
                XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4))
            }
            return
        }

        let destinationText = app.staticTexts[title].firstMatch
        XCTAssertTrue(scrollToElement(destinationText, in: app), "Unable to find More destination \(title)")
        destinationText.tap()
        if let rawValue = moreDestinationRawValue(for: title) {
            assertMoreDestinationOpened(rawValue, title: title, in: app)
        } else {
            XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 4))
        }
    }

    func tapUITestMoreDestination(_ rawValue: String, in app: XCUIApplication) -> Bool {
        let button = app.buttons["uitest.more.destination.\(rawValue)"].firstMatch
        guard button.exists || button.waitForExistence(timeout: 1) else {
            return false
        }
        button.tap()
        return true
    }

    func assertMoreDestinationOpened(_ rawValue: String, title: String, in app: XCUIApplication) {
        let hero = elementByIdentifier("more.\(rawValue).hero", in: app)
        XCTAssertTrue(
            hero.waitForExistence(timeout: 4)
                || app.navigationBars[title].waitForExistence(timeout: 2)
                || scrollToElement(hero, in: app),
            "Unable to open More destination \(title)")
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
            XCTAssertTrue(scrollToElement(elementByIdentifier("settings.region_picker", in: app), in: app))
        case "profileAndNorms":
            XCTAssertTrue(scrollToElement(elementByIdentifier("settings.region_picker", in: app), in: app))
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

    func scrollToElement(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 6)
        -> Bool
    {
        if elementIsVisible(element, in: app) {
            return true
        }

        for _ in 0 ..< maxSwipes {
            swipePageUp(in: app)
            if elementIsVisible(element, in: app) {
                return true
            }
        }

        for _ in 0 ..< maxSwipes {
            swipePageDown(in: app)
            if elementIsVisible(element, in: app) {
                return true
            }
        }

        return elementIsVisible(element, in: app)
    }

    func scrollToElementPresence(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 6)
        -> Bool
    {
        if element.exists {
            return true
        }

        for _ in 0 ..< maxSwipes {
            swipePageUp(in: app)
            if element.exists {
                return true
            }
        }

        for _ in 0 ..< maxSwipes {
            swipePageDown(in: app)
            if element.exists {
                return true
            }
        }

        return element.exists
    }

    func scrollToElementInApp(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 6)
        -> Bool
    {
        if elementIsVisible(element, in: app) {
            return true
        }

        for _ in 0 ..< maxSwipes {
            swipePageUp(in: app)
            if elementIsVisible(element, in: app) {
                return true
            }
        }

        for _ in 0 ..< maxSwipes {
            swipePageDown(in: app)
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

    func swipePageUp(in app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.24))
        start.press(forDuration: 0.01, thenDragTo: end)
    }

    func swipePageDown(in app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.24))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82))
        start.press(forDuration: 0.01, thenDragTo: end)
    }

    func elementByIdentifier(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    func optionalElementByIdentifier(_ identifier: String, in app: XCUIApplication) -> XCUIElement? {
        let element = elementByIdentifier(identifier, in: app)
        return element.exists || element.waitForExistence(timeout: 1) ? element : nil
    }

    func expandDisclosureGroup(_ label: String, in app: XCUIApplication) {
        if label == "Reminder Actions",
           elementByIdentifier("settings.quick.reminder_status", in: app).exists
        {
            return
        }

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
        if let boolValue = element.value as? Bool {
            return boolValue
        }
        if let intValue = element.value as? Int {
            return intValue != 0
        }
        let rawValue = String(describing: element.value ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return rawValue == "1"
            || rawValue == "on"
            || rawValue == "true"
            || rawValue == "yes"
    }

    func tapSwitch(_ element: XCUIElement, in app: XCUIApplication) {
        XCTAssertTrue(scrollToElement(element, in: app), "Unable to find switch \(element)")
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.5)).tap()
    }

    func setSwitch(_ element: XCUIElement, to targetValue: Bool, in app: XCUIApplication) {
        XCTAssertTrue(scrollToElement(element, in: app), "Unable to find switch \(element)")
        if switchIsOn(element) == targetValue {
            return
        }

        tapSwitch(element, in: app)
        XCTAssertTrue(
            waitUntil(timeout: 3) {
                let refreshed = app.switches[element.identifier].firstMatch
                return refreshed.exists && switchIsOn(refreshed) == targetValue
            },
            "Expected switch \(element.identifier) to become \(targetValue ? "on" : "off")")
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
