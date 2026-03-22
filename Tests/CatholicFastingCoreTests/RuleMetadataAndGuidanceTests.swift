@testable import CatholicFastingCore
import XCTest

final class RuleMetadataAndGuidanceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        beginStoreIsolation()
        resetStores()
    }

    override func tearDown() {
        resetStores()
        endStoreIsolation()
        super.tearDown()
    }

    func testRuleBundleMetadataHasVersionAndDates() {
        let metadata = ObservanceCalculator.ruleBundleMetadata()
        XCTAssertFalse(metadata.version.isEmpty)
        XCTAssertLessThanOrEqual(metadata.effectiveDate, metadata.reviewedDate)
        let audit = ObservanceCalculator.ruleBundleAudit()
        XCTAssertTrue(audit.isVerified || !audit.warnings.isEmpty)
    }

    func testBundledRuleBundleSignatureVerifies() {
        let audit = ObservanceCalculator.ruleBundleAudit()
        XCTAssertTrue(audit.isVerified, "Expected bundled signature verification to pass. Warnings: \(audit.warnings)")
    }

    func testInvalidLocalRuleBundleFallsBackToBundled() throws {
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        let localBundle = """
        {
          "metadata": {
            "id": "local-test",
            "displayName": "Local Test",
            "version": "1.0.0",
            "effectiveDate": "2026-01-01",
            "reviewedDate": "2026-02-11"
          },
          "changes": [],
          "signing": {
            "key_id": "release-2026-q1",
            "algorithm": "ed25519",
            "signature": "AAAA"
          }
        }
        """
        try localBundle.write(
            to: tempDirectory.appendingPathComponent("rule-bundle.json"),
            atomically: true,
            encoding: .utf8)
        try """
        {"key_id":"release-2026-q1","algorithm":"ed25519","signature":"AAAA"}
        """.write(
            to: tempDirectory.appendingPathComponent("rule-bundle.sig"),
            atomically: true,
            encoding: .utf8)

        UserDefaults.standard.set(tempDirectory.path, forKey: "rule_bundle_directory_override")
        defer {
            UserDefaults.standard.removeObject(forKey: "rule_bundle_directory_override")
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let audit = ObservanceCalculator.ruleBundleAudit()
        XCTAssertEqual(audit.source, "bundled")
        XCTAssertTrue(audit.warnings.contains { $0.localizedCaseInsensitiveContains("local rule bundle signature check failed") })
    }

    func testObservancesCarryRationaleAndCitations() throws {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)

        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let ashWednesday = try XCTUnwrap(observances.first { $0.title == "Ash Wednesday" })
        XCTAssertFalse(ashWednesday.rationale.isEmpty)
        XCTAssertFalse(ashWednesday.citations.isEmpty)
        XCTAssertEqual(ashWednesday.ruleVersion, ObservanceCalculator.ruleBundleMetadata().version)
    }

    func testFoodGuidanceMedicalScenarioLeansDispensation() {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)

        let recommendations = FoodGuidanceEngine.recommendations(for: .medicalRecovery, settings: settings)
        XCTAssertTrue(recommendations.contains { $0.localizedCaseInsensitiveContains("dispensation") })
    }

    func testSyncWarningsAppearForNotesWithoutCompletions() {
        let tracker = FastTracker()
        let notes = FridayPenanceNotes()

        tracker.clearAll()
        notes.clearAll()
        notes.setNote("Rosary", for: "2026-05-01|Friday Penance (Outside Lent)|fridayPenance")

        let snapshot = SyncDiagnostics.snapshot()
        XCTAssertTrue(snapshot.completedObservancesCount == 0)
        XCTAssertFalse(snapshot.warnings.isEmpty)
    }

    func testDataProtectionEncryptDecryptRoundTrip() {
        let plaintext = "{ \"hello\": \"world\" }"
        let passphrase = "abc123"

        let encrypted = DataProtectionEngine.encrypt(plaintext: plaintext, passphrase: passphrase)
        XCTAssertNotNil(encrypted)

        let decrypted = DataProtectionEngine.decrypt(base64Ciphertext: encrypted ?? "", passphrase: passphrase)
        XCTAssertEqual(decrypted, plaintext)
    }

    func testDataProtectionDecryptFailsWithWrongPassphrase() {
        let plaintext = "sensitive export"
        let encrypted = DataProtectionEngine.encrypt(plaintext: plaintext, passphrase: "correct-passphrase")
        XCTAssertNotNil(encrypted)

        let decrypted = DataProtectionEngine.decrypt(base64Ciphertext: encrypted ?? "", passphrase: "wrong-passphrase")
        XCTAssertNil(decrypted)
    }

    func testFoodGuidanceHeavyLaborMentionsAdjustment() {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)

        let recommendations = FoodGuidanceEngine.recommendations(for: .heavyLabor, settings: settings)
        XCTAssertTrue(recommendations.contains { $0.localizedCaseInsensitiveContains("heavy labor") || $0.localizedCaseInsensitiveContains("pastor") })
    }

    func testFoodGuidanceIncludesCoreDisciplineOnNormalDay() {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)

        let recommendations = FoodGuidanceEngine.recommendations(for: .normalDay, settings: settings)
        XCTAssertTrue(recommendations.contains { $0.localizedCaseInsensitiveContains("abstinence") || $0.localizedCaseInsensitiveContains("avoid meat") })
        XCTAssertTrue(recommendations.contains { $0.localizedCaseInsensitiveContains("one full meal") })
    }

    func testFoodGuidanceSnapshotPlacesChickenInMeatAndDairyInPermitted() {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)

        let snapshot = FoodGuidanceEngine.snapshot(for: .normalDay, settings: settings)

        XCTAssertTrue(snapshot.whatCountsAsMeat.items.contains { $0.detail.localizedCaseInsensitiveContains("chicken") })
        XCTAssertTrue(snapshot.generallyPermitted.items.contains { $0.detail.localizedCaseInsensitiveContains("eggs") })
        XCTAssertTrue(snapshot.generallyPermitted.items.contains { $0.detail.localizedCaseInsensitiveContains("cheese") })
        XCTAssertTrue(snapshot.generallyPermitted.items.contains { $0.detail.localizedCaseInsensitiveContains("fish") })
    }

    func testFoodGuidanceSnapshotKeepsBrothInExtraGuidance() {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)

        let snapshot = FoodGuidanceEngine.snapshot(for: .normalDay, settings: settings)

        XCTAssertTrue(snapshot.extraGuidance.items.contains { $0.detail.localizedCaseInsensitiveContains("broth") })
        XCTAssertFalse(snapshot.whatCountsAsMeat.items.contains { $0.detail.localizedCaseInsensitiveContains("broth") })
    }

    func testFoodGuidanceSnapshotUsesCanadaSourceLine() {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb,
            regionProfile: .canada)

        let snapshot = FoodGuidanceEngine.snapshot(for: .normalDay, settings: settings)

        XCTAssertTrue(snapshot.sourceLine.localizedCaseInsensitiveContains("cccb"))
        XCTAssertTrue(snapshot.sourceLine.localizedCaseInsensitiveContains("universal law"))
        XCTAssertFalse(snapshot.sourceLine.localizedCaseInsensitiveContains("u.s.-first"))
    }

    func testMissedDayRecoveryPlanIsNilWithoutMissedStatus() {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)
        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let plan = MissedDayRecoveryEngine.plan(
            observances: observances,
            statusesByID: [:],
            today: fixedDate(year: 2026, month: 3, day: 1),
            calendar: fixedCalendar)

        XCTAssertNil(plan)
    }

    func testMissedDayRecoveryPlanUsesMostRecentMissedAndNextRequired() throws {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)
        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let ashWednesday = try XCTUnwrap(observances.first(where: { $0.title == "Ash Wednesday" }))

        let plan = MissedDayRecoveryEngine.plan(
            observances: observances,
            statusesByID: [ashWednesday.id: .missed],
            today: fixedDate(year: 2026, month: 3, day: 1),
            calendar: fixedCalendar)

        XCTAssertNotNil(plan)
        XCTAssertTrue(plan?.titleLine.localizedCaseInsensitiveContains("ash wednesday") ?? false)
        XCTAssertFalse(plan?.steps.isEmpty ?? true)
        XCTAssertTrue(plan?.nextRequiredLine.localizedCaseInsensitiveContains("required") ?? false)
    }

    func testDailyFoodDecisionMarksAshWednesdayMandatoryOnLocalEvening() throws {
        let originalTimeZone = NSTimeZone.default
        let testTimeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        NSTimeZone.default = testTimeZone
        defer {
            NSTimeZone.default = originalTimeZone
        }

        ObservanceCalculator.resetCacheForTesting()
        let settings = RuleSettings(
            birthYear: 1988,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .abstainFromMeat,
            calendarMode: .usccb)

        var localCalendar = Calendar(identifier: .gregorian)
        localCalendar.timeZone = testTimeZone

        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let localEveningAshWednesday =
            localCalendar.date(from: DateComponents(year: 2026, month: 2, day: 18, hour: 20, minute: 30))
                ?? .distantPast

        let decision = DailyFoodDecisionEngine.decision(
            for: observances,
            settings: settings,
            date: localEveningAshWednesday,
            calendar: localCalendar)

        XCTAssertTrue(decision.obligationLine.localizedCaseInsensitiveContains("fasting and abstinence"))
        XCTAssertTrue(decision.rationale.localizedCaseInsensitiveContains("ash wednesday"))
    }

    func testDailyFoodDecisionForFridayOutsideLentAbstainModeShowsAbstinence() {
        let settings = RuleSettings(
            birthYear: 1988,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .abstainFromMeat,
            calendarMode: .usccb)

        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let decision = DailyFoodDecisionEngine.decision(
            for: observances,
            settings: settings,
            date: fixedDate(year: 2026, month: 5, day: 1),
            calendar: fixedCalendar)

        XCTAssertTrue(decision.obligationLine.localizedCaseInsensitiveContains("friday penance"))
        XCTAssertTrue(decision.obligationLine.localizedCaseInsensitiveContains("abstinence"))
        XCTAssertTrue(decision.avoid.joined(separator: " ").localizedCaseInsensitiveContains("meat"))
    }

    func testDailyFoodDecisionForFridayOutsideLentSubstituteModeShowsNoMandatoryFasting() {
        let settings = RuleSettings(
            birthYear: 1988,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)

        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let decision = DailyFoodDecisionEngine.decision(
            for: observances,
            settings: settings,
            date: fixedDate(year: 2026, month: 5, day: 1),
            calendar: fixedCalendar)

        XCTAssertTrue(decision.obligationLine.localizedCaseInsensitiveContains("friday penance"))
        XCTAssertTrue(decision.obligationLine.localizedCaseInsensitiveContains("not mandatory fasting"))
        XCTAssertTrue(decision.allowed.joined(separator: " ").localizedCaseInsensitiveContains("penitential act"))
    }

    func testCanadaFridayDecisionUsesCCCBSourceLine() {
        let settings = RuleSettings(
            birthYear: 1988,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb,
            regionProfile: .canada)

        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let decision = DailyFoodDecisionEngine.decision(
            for: observances,
            settings: settings,
            date: fixedDate(year: 2026, month: 5, day: 1),
            calendar: fixedCalendar)

        XCTAssertTrue(decision.obligationLine.localizedCaseInsensitiveContains("friday penance"))
        XCTAssertTrue(decision.allowed.joined(separator: " ").localizedCaseInsensitiveContains("charity"))
        XCTAssertTrue(decision.sourceLine.localizedCaseInsensitiveContains("cccb"))
    }

    func testCanadaNormalDayGuidanceUsesCCCBGeneralSource() {
        let settings = RuleSettings(
            birthYear: 1988,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb,
            regionProfile: .canada)

        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let decision = DailyFoodDecisionEngine.decision(
            for: observances,
            settings: settings,
            date: fixedDate(year: 2026, month: 5, day: 2),
            calendar: fixedCalendar)

        XCTAssertTrue(decision.obligationLine.localizedCaseInsensitiveContains("no mandatory"))
        XCTAssertTrue(decision.sourceLine.localizedCaseInsensitiveContains("canada friday guidance"))
    }

    func testRegionalGuidanceContextFactoryUsesCCCBForCanadaFridayPenance() throws {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb,
            regionProfile: .canada)

        let observance = try XCTUnwrap(
            ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
                .first(where: { $0.kind == .fridayPenance }))

        let context = RegionalGuidanceContextFactory.context(for: observance, settings: settings)

        XCTAssertEqual(context.regionProfile, .canada)
        XCTAssertEqual(context.supportLevel, .full)
        XCTAssertEqual(context.classificationLabel, "Canada guidance")
        XCTAssertEqual(context.sourceURL?.absoluteString, "https://www.cccb.ca/document/keeping-friday/")
        XCTAssertTrue(context.authorityLabel.localizedCaseInsensitiveContains("cccb"))
    }

    func testRegionalGuidanceContextFactoryUsesCanadaBaselineForHolyDays() throws {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb,
            regionProfile: .canada)

        let holyDay = try XCTUnwrap(
            ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
                .first(where: { $0.title == "Christmas" && $0.kind == .holyDay }))

        let context = RegionalGuidanceContextFactory.context(for: holyDay, settings: settings)

        XCTAssertEqual(context.supportLevel, .full)
        XCTAssertEqual(context.classificationLabel, "Canada baseline")
        XCTAssertTrue(context.authorityLabel.localizedCaseInsensitiveContains("canada national baseline"))
        XCTAssertTrue(context.disclosureText.localizedCaseInsensitiveContains("canada-wide obligations"))
    }

    func testRegionalGuidanceGeneralContextTreatsCanadaAsModeledBaseline() {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb,
            regionProfile: .canada)

        let context = RegionalGuidanceContextFactory.generalContext(for: settings)

        XCTAssertEqual(context.supportLevel, .full)
        XCTAssertEqual(context.classificationLabel, "Canada baseline")
        XCTAssertTrue(context.disclosureText.localizedCaseInsensitiveContains("national baseline"))
        XCTAssertTrue(context.citations.contains { $0.authority == .cccb })
    }

    private var fixedCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func fixedDate(year: Int, month: Int, day: Int) -> Date {
        fixedCalendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }
}
