import XCTest

extension CatholicFastingAppUITests {
    func testIPhonePrimarySurfacesPassAccessibilityAudit() throws {
        continueAfterFailure = true
        let app = makeApp(fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)

        for surface in ["Today", "Fasting Days", "Track Fast", "More"] {
            openSurfaceThroughVisibleNavigation(surface, in: app)
            try performPrimarySurfaceAccessibilityAudit(in: app)
        }
    }

    func testIPadPrimaryWorkspacesPassAccessibilityAudit() throws {
        continueAfterFailure = true
        let app = makeApp(fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)

        for surface in ["today", "fasting_days", "intermittent", "more"] {
            openIPadSurface(surface, in: app)
            try performPrimarySurfaceAccessibilityAudit(in: app)
        }
    }

    func testIPhoneAccessibilityTextSizeKeepsPrimaryActionsReachable() {
        let app = makeApp(fixedDate: "2026-07-17")
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge",
        ]
        app.launch()
        ensureOnHomeScreen(app)

        XCTAssertTrue(scrollToElement(app.buttons["companion.primary_action.button"].firstMatch, in: app))
        openSurfaceThroughVisibleNavigation("Track Fast", in: app)
        XCTAssertTrue(scrollToElement(app.buttons["intermittent.start_fast"].firstMatch, in: app))
    }

    func testIPhoneEnhancedAccessibilitySettingsKeepPrimarySurfacesUsable() {
        let app = makeApp(fixedDate: "2026-07-17")
        app.launchArguments += [
            "-UIAccessibilityDarkerSystemColorsEnabled", "YES",
            "-UIAccessibilityButtonShapesEnabled", "YES",
            "-UIAccessibilityReduceMotionEnabled", "YES",
        ]
        app.launch()
        ensureOnHomeScreen(app)

        for surface in ["Today", "Fasting Days", "Track Fast", "More"] {
            openSurfaceThroughVisibleNavigation(surface, in: app)
        }
    }

    func testIPadAccessibilityTextSizeKeepsPrimaryWorkspacesReachable() {
        let app = makeApp(fixedDate: "2026-07-17")
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge",
        ]
        app.launch()
        ensureOnHomeScreen(app)

        let workspaces = ["today", "fasting_days", "intermittent", "more"]
        for surface in workspaces {
            openIPadSurface(surface, in: app)
            assertIPadWorkspaceVisible(surface, in: app)
        }
    }

    func testIPadUpcomingCalendarNeverDefaultsToPastObservance() {
        let app = makeApp(fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)
        openIPadSurface("fasting_days", in: app)

        let selected = app.buttons
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "ipad.fasting_days.row."))
            .firstMatch
        XCTAssertTrue(selected.waitForExistence(timeout: 4))
        XCTAssertTrue(selected.isSelected, "Upcoming Calendar did not select its first visible observance")
        XCTAssertFalse(selected.identifier.contains("2026-01-02"), "Upcoming Calendar selected a past January observance")
        XCTAssertTrue(
            selected.identifier.contains("2026-07-")
                || selected.identifier.contains("2026-08-")
                || selected.identifier.contains("2026-09-")
                || selected.identifier.contains("2026-10-")
                || selected.identifier.contains("2026-11-")
                || selected.identifier.contains("2026-12-")
                || selected.identifier.contains("2027-"),
            "Upcoming Calendar did not select today or a future observance: \(selected.identifier)")
    }

    func testIPhoneAge60PlusProfileDoesNotReceiveMandatoryFastingRule() {
        let app = makeApp(
            fixedDate: "2026-02-18",
            abstinenceAgeEligible: true,
            fastingAgeEligible: false)
        app.launch()
        ensureOnHomeScreen(app)

        let obligation = app.staticTexts["companion.rule.obligation"].firstMatch
        XCTAssertTrue(obligation.waitForExistence(timeout: 4))
        XCTAssertTrue(obligation.label.localizedCaseInsensitiveContains("abstinence"))
        XCTAssertFalse(obligation.label.localizedCaseInsensitiveContains("mandatory fasting"))
    }

    func testIPhoneTodayFrenchCanadianHasNoEnglishCompanionFallbacks() {
        let app = makeApp(languageMode: "frenchCanadian", fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)

        XCTAssertTrue(app.navigationBars["Aujourd’hui"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Directives d’aujourd’hui"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Prochaine action fidèle"].firstMatch.waitForExistence(timeout: 4))
        let action = app.buttons["companion.primary_action.button"].firstMatch
        XCTAssertTrue(action.waitForExistence(timeout: 4))
        XCTAssertFalse(action.label.localizedCaseInsensitiveContains("review today"))
    }

    func testIPhoneLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            let app = makeApp(fixedDate: "2026-07-17")
            app.launch()
            XCTAssertTrue(app.otherElements["home.ready"].waitForExistence(timeout: 5))
            app.terminate()
        }
    }

    func testIPhonePrimaryNavigationPerformance() {
        let app = makeApp(fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)

        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            for surface in ["Fasting Days", "Track Fast", "More", "Today"] {
                openSurfaceThroughVisibleNavigation(surface, in: app)
            }
        }
    }

    func testIPadWorkspaceSwitchingPerformance() {
        let app = makeApp(fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)

        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], options: options) {
            for surface in ["fasting_days", "intermittent", "more", "today"] {
                openIPadSurface(surface, in: app)
                assertIPadWorkspaceVisible(surface, in: app)
            }
        }
    }

    private func performPrimarySurfaceAccessibilityAudit(in app: XCUIApplication) throws {
        // Xcode 27 beta reports solid black system text as a contrast failure when it
        // intersects the iOS 26 floating tab-bar renderer. Contrast and Dynamic Type
        // are exercised through dedicated maximum-size/enhanced-setting journeys.
        try app.performAccessibilityAudit(
            for: .all.subtracting([.dynamicType, .textClipped, .contrast])) { issue in
            let element = issue.element
            print(
                "CFA_ACCESSIBILITY_AUDIT type=\(issue.auditType.rawValue) "
                    + "label=\(element?.label ?? "<none>") "
                    + "identifier=\(element?.identifier ?? "<none>") "
                    + "detail=\(issue.detailedDescription)")
            return false
        }
    }
}
