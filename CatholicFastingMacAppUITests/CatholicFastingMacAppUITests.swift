import XCTest

final class CatholicFastingMacAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func makeApp(
        resetData: Bool = true,
        skipOnboarding: Bool = true,
        seedMissed: Bool = false,
        seedDeterministic: Bool = true,
        regionProfile: String? = nil,
        languageMode: String? = nil,
        premiumUnlocked: Bool = false) -> XCUIApplication
    {
        let app = XCUIApplication()
        var arguments: [String] = []
        arguments.append(contentsOf: [
            "-ApplePersistenceIgnoreState",
            "YES",
            "-NSQuitAlwaysKeepsWindows",
            "NO",
        ])
        if resetData {
            arguments.append("-uitest-reset")
        }
        if seedDeterministic {
            arguments.append("-uitest-seed-deterministic")
        }
        if seedMissed {
            arguments.append("-uitest-seed-missed")
        }
        if skipOnboarding {
            arguments.append("-uitest-skip-onboarding")
        }
        app.launchArguments = arguments
        app.launchEnvironment["UITEST_MODE"] = "1"
        app.launchEnvironment["DISABLE_APP_GROUP_STORAGE"] = "1"
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
        makeApp(skipOnboarding: false, seedDeterministic: false)
    }

    func identifiedElement(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(identifier: identifier)
            .firstMatch
    }

    func identifiedSwitch(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.switches.matching(identifier: identifier).firstMatch
    }

    func waitForElement(
        _ identifier: String,
        in app: XCUIApplication,
        timeout: TimeInterval = 4) -> Bool
    {
        identifiedElement(identifier, in: app).waitForExistence(timeout: timeout)
    }

    @discardableResult
    func waitForAppState(
        _ app: XCUIApplication,
        _ state: XCUIApplication.State,
        timeout: TimeInterval = 6) -> Bool
    {
        let predicate = NSPredicate(format: "state == %d", state.rawValue)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: app)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    func waitForSurfaceReady(_ surface: CatholicFastingMacSurfaceID, in app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        let identifier = switch surface {
        case .today:
            "mac.surface.today.ready"
        case .calendar:
            "mac.calendar.year"
        case .intermittent:
            "mac.intermittent.target"
        case .premium:
            "mac.surface.premium.ready"
        case .guidance:
            "mac.guidance.rationale"
        }
        return identifiedElement(identifier, in: app).waitForExistence(timeout: timeout)
    }

    func ensureOnDesktopHomeScreen(_ app: XCUIApplication) {
        let finishButton = identifiedElement("mac.onboarding.finish", in: app)
        if finishButton.waitForExistence(timeout: 1) {
            finishButton.tap()
        }

        XCTAssertTrue(identifiedElement("mac.root.ready", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(waitForSurfaceReady(.today, in: app))
    }

    func openSidebarSurface(_ surface: CatholicFastingMacSurfaceID, in app: XCUIApplication) {
        let row = identifiedElement("mac.sidebar.\(surface.rawValue)", in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 4), "Unable to find sidebar item for \(surface.rawValue)")
        row.tap()
        XCTAssertTrue(
            waitForSurfaceReady(surface, in: app, timeout: 4),
            "Surface \(surface.rawValue) did not become ready")
    }

    func openSettings(_ app: XCUIApplication) {
        app.typeKey(",", modifierFlags: .command)
        XCTAssertTrue(identifiedElement("mac.settings.ready", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(identifiedSwitch("mac.settings.profile.dispensation", in: app).waitForExistence(timeout: 5))
    }

    func openSettingsTab(_ tab: CatholicFastingMacSettingsTabID, in app: XCUIApplication) {
        let identified = identifiedElement("mac.settings.tab.\(tab.rawValue)", in: app)
        if identified.waitForExistence(timeout: 2) {
            identified.tap()
        } else {
            let labeled = app.buttons[tab.buttonTitle].firstMatch
            XCTAssertTrue(labeled.waitForExistence(timeout: 2), "Unable to find settings tab \(tab.rawValue)")
            labeled.tap()
        }
        let ready = switch tab {
        case .profile:
            identifiedSwitch("mac.settings.profile.dispensation", in: app).waitForExistence(timeout: 5)
        case .reminders:
            identifiedElement("mac.settings.reminders.support", in: app).waitForExistence(timeout: 5)
        case .privacy:
            identifiedElement("mac.settings.privacy.copy_export", in: app).waitForExistence(timeout: 5)
        }
        XCTAssertTrue(ready)
    }
}

enum CatholicFastingMacSurfaceID: String {
    case today
    case calendar
    case intermittent
    case premium
    case guidance
}

enum CatholicFastingMacSettingsTabID: String {
    case profile
    case reminders
    case privacy

    var buttonTitle: String {
        switch self {
        case .profile:
            "Profile"
        case .reminders:
            "Reminders"
        case .privacy:
            "Privacy"
        }
    }
}
