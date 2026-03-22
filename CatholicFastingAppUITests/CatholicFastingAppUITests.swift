import Foundation
import XCTest

final class CatholicFastingAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func makeApp(
        skipOnboarding: Bool = true,
        seedMissed: Bool = false,
        regionProfile: String? = nil,
        languageMode: String? = nil,
        premiumUnlocked: Bool = false) -> XCUIApplication
    {
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
        if premiumUnlocked {
            app.launchEnvironment["UITEST_PREMIUM_UNLOCKED"] = "1"
        }
        return app
    }

    func ensureOnHomeScreen(_ app: XCUIApplication) {
        let continueButton = app.buttons["onboarding.continue"]
        if continueButton.waitForExistence(timeout: 1) {
            continueButton.tap()
        }
        XCTAssertTrue(app.navigationBars["Catholic Fasting"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["home.ready"].waitForExistence(timeout: 4))
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

    func openMoreDestination(_ title: String, in app: XCUIApplication) {
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

    func openIPadSurface(_ rawValue: String, in app: XCUIApplication) {
        let button = app.buttons["ipad.sidebar.\(rawValue)"].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 4), "Unable to find iPad sidebar surface \(rawValue)")
        button.tap()
    }

    func openIPadMoreDestination(_ rawValue: String, in app: XCUIApplication) {
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

    func assertIPadMoreDestinationContent(_ rawValue: String, in app: XCUIApplication) {
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

    func scrollToElement(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 12)
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

    func elementByIdentifier(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    func expandDisclosureGroup(_ label: String, in app: XCUIApplication) {
        let button = app.buttons[label].firstMatch
        if scrollToElement(button, in: app) {
            button.tap()
            return
        }

        let text = app.staticTexts[label].firstMatch
        XCTAssertTrue(scrollToElement(text, in: app), "Unable to find disclosure group \(label)")
        text.tap()
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
        XCTAssertTrue(app.navigationBars["Catholic Fasting"].waitForExistence(timeout: 4))
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
