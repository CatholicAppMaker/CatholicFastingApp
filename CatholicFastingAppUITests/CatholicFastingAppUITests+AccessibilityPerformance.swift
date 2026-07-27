import XCTest

extension CatholicFastingAppUITests {
    func testIPhoneTodayPassesAccessibilityAudit() throws {
        try auditIPhoneSurface("Today")
    }

    func testIPhoneCalendarPassesAccessibilityAudit() throws {
        try auditIPhoneSurface("Calendar")
    }

    func testIPhoneFastPassesAccessibilityAudit() throws {
        try auditIPhoneSurface("Fast")
    }

    func testIPhoneMorePassesAccessibilityAudit() throws {
        try auditIPhoneSurface("More")
    }

    func testIPadTodayPassesAccessibilityAudit() throws {
        try auditIPadWorkspace("today")
    }

    func testIPadCalendarPassesAccessibilityAudit() throws {
        try auditIPadWorkspace("fasting_days")
    }

    func testIPadFastPassesAccessibilityAudit() throws {
        try auditIPadWorkspace("intermittent")
    }

    func testIPadMorePassesAccessibilityAudit() throws {
        try auditIPadWorkspace("more")
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
        openSurfaceThroughVisibleNavigation("Fast", in: app)
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

        for surface in ["Today", "Calendar", "Fast", "More"] {
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

    func testIOS26AccessibilityArtifactPolicyIsNarrow() {
        XCTAssertTrue(Self.isKnownIOS26AccessibilityArtifact(
            auditType: .contrast,
            label: "",
            identifier: "",
            elementExists: false,
            frame: .zero))
        XCTAssertTrue(Self.isKnownIOS26AccessibilityArtifact(
            auditType: .elementDetection,
            label: "",
            identifier: "",
            elementExists: false,
            frame: nil))

        XCTAssertFalse(Self.isKnownIOS26AccessibilityArtifact(
            auditType: .dynamicType,
            label: "",
            identifier: "",
            elementExists: false,
            frame: .zero))
        XCTAssertFalse(Self.isKnownIOS26AccessibilityArtifact(
            auditType: .contrast,
            label: "Visible content",
            identifier: "",
            elementExists: false,
            frame: .zero))
        XCTAssertFalse(Self.isKnownIOS26AccessibilityArtifact(
            auditType: .contrast,
            label: "",
            identifier: "app.content",
            elementExists: false,
            frame: .zero))
        XCTAssertFalse(Self.isKnownIOS26AccessibilityArtifact(
            auditType: .contrast,
            label: "",
            identifier: "",
            elementExists: true,
            frame: .zero))
        XCTAssertFalse(Self.isKnownIOS26AccessibilityArtifact(
            auditType: .elementDetection,
            label: "",
            identifier: "",
            elementExists: false,
            frame: CGRect(x: 10, y: 10, width: 44, height: 44)))
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
            for surface in ["Calendar", "Fast", "More", "Today"] {
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
        try app.performAccessibilityAudit(for: .all) { issue in
            let element = issue.element
            let label = element?.label ?? ""
            let identifier = element?.identifier ?? ""
            let elementExists = element?.exists ?? false
            let frame = element.map(\.frame)
            print(
                "CFA_ACCESSIBILITY_AUDIT type=\(issue.auditType.rawValue) "
                    + "label=\(label.isEmpty ? "<none>" : label) "
                    + "identifier=\(identifier.isEmpty ? "<none>" : identifier) "
                    + "detail=\(issue.detailedDescription)")

            let isAllowedArtifact = Self.isKnownIOS26AccessibilityArtifact(
                auditType: issue.auditType,
                label: label,
                identifier: identifier,
                elementExists: elementExists,
                frame: frame)
            if isAllowedArtifact {
                // iOS 26 can leave transient anonymous SwiftUI/system nodes behind
                // after floating-tab layout. Only unresolvable zero-frame contrast
                // or text-detection nodes qualify; visible or labeled content does not.
                print(
                    "CFA_ACCESSIBILITY_ALLOWLIST type=\(issue.auditType.rawValue) "
                        + "reason=anonymous_unresolvable_zero_frame_ios26_artifact")
            }
            return isAllowedArtifact
        }
    }

    static func isKnownIOS26AccessibilityArtifact(
        auditType: XCUIAccessibilityAuditType,
        label: String,
        identifier: String,
        elementExists: Bool,
        frame: CGRect?) -> Bool
    {
        let isEligibleAuditType = auditType == .contrast || auditType == .elementDetection
        let hasNoAccessibleIdentity = label.isEmpty && identifier.isEmpty
        let hasNoResolvableFrame = frame == nil || frame == .zero || frame?.isEmpty == true

        return isEligibleAuditType
            && hasNoAccessibleIdentity
            && !elementExists
            && hasNoResolvableFrame
    }

    private func auditIPhoneSurface(_ surface: String) throws {
        continueAfterFailure = true
        let app = makeApp(fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)
        openSurfaceThroughVisibleNavigation(surface, in: app)
        try performPrimarySurfaceAccessibilityAudit(in: app)
    }

    private func auditIPadWorkspace(_ workspace: String) throws {
        continueAfterFailure = true
        let app = makeApp(fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)
        openIPadSurface(workspace, in: app)
        try performPrimarySurfaceAccessibilityAudit(in: app)
    }
}
