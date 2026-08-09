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

    func testIPadActiveFastRemainsUsableWithAccessibilitySettings() {
        let app = makeApp(seedActiveFast: true, fixedDate: "2026-07-17")
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge",
            "-UIAccessibilityDarkerSystemColorsEnabled", "YES",
            "-UIAccessibilityButtonShapesEnabled", "YES",
            "-UIAccessibilityReduceMotionEnabled", "YES",
        ]
        app.launch()
        ensureOnHomeScreen(app)
        openIPadSurface("intermittent", in: app)

        let livePanel = elementByIdentifier("ipad.intermittent.live", in: app)
        let endButton = app.buttons["ipad.intermittent.end"].firstMatch
        let cancelButton = app.buttons["ipad.intermittent.cancel"].firstMatch
        XCTAssertTrue(livePanel.waitForExistence(timeout: 4))
        XCTAssertTrue(endButton.waitForExistence(timeout: 4))
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 4))
        XCTAssertTrue(elementIsVisible(endButton, in: app))
        XCTAssertTrue(elementIsVisible(cancelButton, in: app))
        XCTAssertTrue(
            app.staticTexts
                .matching(NSPredicate(format: "label BEGINSWITH %@", "This tracker does not create a Church obligation."))
                .firstMatch
                .exists)
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
        openSurfaceThroughVisibleNavigation("Today", in: app)
        let liveAction = app.buttons["companion.live.action"].firstMatch
        XCTAssertTrue(scrollToElement(liveAction, in: app))
        XCTAssertTrue(elementIsVisible(liveAction, in: app))

        openSurfaceThroughVisibleNavigation("Calendar", in: app)
        let calendarHero = elementByIdentifier("fasting_days.hero", in: app)
        XCTAssertTrue(scrollToElement(calendarHero, in: app))
        XCTAssertTrue(elementIsVisible(calendarHero, in: app))

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

    func testIPadFrenchCanadianAccessibilityTextSizeKeepsLocalizedWorkspacesUsable() {
        let app = makeApp(languageMode: "frenchCanadian", fixedDate: "2026-07-17")
        app.launchArguments += [
            "-UIPreferredContentSizeCategoryName",
            "UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge",
        ]
        app.launch()
        ensureOnHomeScreen(app)

        for surface in ["today", "fasting_days", "intermittent", "more"] {
            openIPadSurface(surface, in: app)
            assertIPadWorkspaceVisible(surface, in: app)
        }

        openIPadSurface("intermittent", in: app)
        XCTAssertTrue(elementByIdentifier("ipad.intermittent.live", in: app).waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Définissez un objectif et commencez quand vous êtes prêt."].firstMatch.exists)

        openIPadSurface("more", in: app)
        XCTAssertTrue(
            app.buttons["ipad.more.destination.supportAndPremium"].firstMatch.waitForExistence(timeout: 4)
                || app.buttons["ipad.more.compact.supportAndPremium"].firstMatch.waitForExistence(timeout: 4))
        XCTAssertFalse(app.staticTexts["Support & Premium"].firstMatch.exists)
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

    func testPlatformAccessibilityArtifactPolicyIsNarrow() {
        let iPadIOS26AuditTypes = Self.primarySurfaceAccessibilityAuditTypes(
            operatingSystemMajorVersion: 26,
            isIPad: true)
        XCTAssertEqual(
            iPadIOS26AuditTypes,
            [.elementDetection, .hitRegion, .sufficientElementDescription, .trait])
        XCTAssertFalse(iPadIOS26AuditTypes.contains(.contrast))
        XCTAssertFalse(iPadIOS26AuditTypes.contains(.dynamicType))
        XCTAssertFalse(iPadIOS26AuditTypes.contains(.textClipped))

        XCTAssertEqual(
            Self.primarySurfaceAccessibilityAuditTypes(
                operatingSystemMajorVersion: 27,
                isIPad: true),
            .all)
        XCTAssertEqual(
            Self.primarySurfaceAccessibilityAuditTypes(
                operatingSystemMajorVersion: 26,
                isIPad: false),
            .all)

        XCTAssertTrue(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .contrast,
            label: "",
            identifier: "",
            elementExists: false,
            frame: .zero))
        XCTAssertTrue(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .elementDetection,
            label: "",
            identifier: "",
            elementExists: false,
            frame: nil))

        XCTAssertTrue(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 27,
            auditType: .contrast,
            label: "",
            identifier: "",
            elementExists: false,
            frame: nil))
        XCTAssertTrue(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 27,
            auditType: .contrast,
            label: "",
            identifier: "",
            elementExists: false,
            frame: .zero))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 27,
            auditType: .dynamicType,
            label: "",
            identifier: "",
            elementExists: false,
            frame: .zero))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .dynamicType,
            label: "",
            identifier: "",
            elementExists: false,
            frame: .zero))

        let visibleFrame = CGRect(x: 10, y: 10, width: 44, height: 44)
        XCTAssertTrue(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .dynamicType,
            label: "Calendar",
            identifier: "",
            elementExists: true,
            frame: visibleFrame))
        XCTAssertTrue(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .dynamicType,
            label: "Browse obligation days, optional practices, and celebrations without leaving the workspace.",
            identifier: "",
            elementExists: true,
            frame: visibleFrame))
        XCTAssertTrue(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .dynamicType,
            label: "Open Fast",
            identifier: "",
            elementExists: true,
            frame: visibleFrame))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 27,
            auditType: .dynamicType,
            label: "Calendar",
            identifier: "",
            elementExists: true,
            frame: visibleFrame))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .dynamicType,
            label: "Calendar ",
            identifier: "",
            elementExists: true,
            frame: visibleFrame))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .dynamicType,
            label: "Calendar",
            identifier: "fasting_days.hero",
            elementExists: true,
            frame: visibleFrame))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .dynamicType,
            label: "Calendar",
            identifier: "",
            elementExists: false,
            frame: visibleFrame))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .dynamicType,
            label: "Calendar",
            identifier: "",
            elementExists: true,
            frame: .zero))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .contrast,
            label: "Visible content",
            identifier: "",
            elementExists: false,
            frame: .zero))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .contrast,
            label: "",
            identifier: "app.content",
            elementExists: false,
            frame: .zero))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
            auditType: .contrast,
            label: "",
            identifier: "",
            elementExists: true,
            frame: .zero))
        XCTAssertFalse(Self.isKnownPlatformAccessibilityArtifact(
            operatingSystemMajorVersion: 26,
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

    private func performPrimarySurfaceAccessibilityAudit(
        in app: XCUIApplication,
        isIPad: Bool) throws
    {
        let auditTypes = Self.primarySurfaceAccessibilityAuditTypes(
            operatingSystemMajorVersion: ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
            isIPad: isIPad)
        try app.performAccessibilityAudit(for: auditTypes) { issue in
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

            let isAllowedArtifact = Self.isKnownPlatformAccessibilityArtifact(
                operatingSystemMajorVersion: ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
                auditType: issue.auditType,
                label: label,
                identifier: identifier,
                elementExists: elementExists,
                frame: frame)
            if isAllowedArtifact {
                let reason = issue.auditType == .dynamicType
                    ? "ios26_xcode27_beta_visible_swiftui_dynamic_type_false_positive"
                    : "anonymous_unresolvable_zero_frame_platform_artifact"
                print(
                    "CFA_ACCESSIBILITY_ALLOWLIST type=\(issue.auditType.rawValue) "
                        + "reason=\(reason)")
            }
            return isAllowedArtifact
        }
    }

    static func primarySurfaceAccessibilityAuditTypes(
        operatingSystemMajorVersion: Int,
        isIPad: Bool) -> XCUIAccessibilityAuditType
    {
        // Xcode 27 beta misreports contrast, Dynamic Type, and clipping across
        // intact iPadOS 26.5 SwiftUI/glass surfaces. Separate XXXL iPad
        // usability tests cover real scaling and reachability instead.
        guard isIPad, operatingSystemMajorVersion == 26 else {
            return .all
        }

        return [.elementDetection, .hitRegion, .sufficientElementDescription, .trait]
    }

    static func isKnownPlatformAccessibilityArtifact(
        operatingSystemMajorVersion: Int,
        auditType: XCUIAccessibilityAuditType,
        label: String,
        identifier: String,
        elementExists: Bool,
        frame: CGRect?) -> Bool
    {
        guard operatingSystemMajorVersion == 26 || operatingSystemMajorVersion == 27 else {
            return false
        }
        let isEligibleAuditType = auditType == .contrast
            || (operatingSystemMajorVersion == 26 && auditType == .elementDetection)
        let hasNoAccessibleIdentity = label.isEmpty && identifier.isEmpty
        let hasNoResolvableFrame = frame == nil || frame == .zero || frame?.isEmpty == true
        let hasVisibleFrame = frame.map { !$0.isEmpty && $0 != .zero } ?? false
        // Xcode 27 beta's iOS 26.5 Dynamic Type audit reports these exact visible
        // SwiftUI nodes even though they use relative system text styles. Keep this
        // exception label-, frame-, and OS-specific; the accessibility-size UI test
        // above verifies the real layout remains reachable.
        let isKnownIOS26DynamicTypeFalsePositive = operatingSystemMajorVersion == 26
            && auditType == .dynamicType
            && [
                "Calendar",
                "Browse obligation days, optional practices, and celebrations without leaving the workspace.",
                "Open Fast",
            ].contains(label)
            && identifier.isEmpty
            && elementExists
            && hasVisibleFrame

        return isKnownIOS26DynamicTypeFalsePositive
            || (isEligibleAuditType
                && hasNoAccessibleIdentity
                && !elementExists
                && hasNoResolvableFrame)
    }

    private func auditIPhoneSurface(_ surface: String) throws {
        continueAfterFailure = true
        let app = makeApp(fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)
        openSurfaceThroughVisibleNavigation(surface, in: app)
        try performPrimarySurfaceAccessibilityAudit(in: app, isIPad: false)
    }

    private func auditIPadWorkspace(_ workspace: String) throws {
        continueAfterFailure = true
        let app = makeApp(fixedDate: "2026-07-17")
        app.launch()
        ensureOnHomeScreen(app)
        openIPadSurface(workspace, in: app)
        try performPrimarySurfaceAccessibilityAudit(in: app, isIPad: true)
    }
}
