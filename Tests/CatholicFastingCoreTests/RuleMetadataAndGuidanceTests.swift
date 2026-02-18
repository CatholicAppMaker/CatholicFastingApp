import XCTest
@testable import CatholicFastingCore

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
      encoding: .utf8
    )
    try """
    {"key_id":"release-2026-q1","algorithm":"ed25519","signature":"AAAA"}
    """.write(
      to: tempDirectory.appendingPathComponent("rule-bundle.sig"),
      atomically: true,
      encoding: .utf8
    )

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

  func testDiagnosticsCanBeDisabled() {
    UserDefaults.standard.set(false, forKey: "allow_diagnostics")
    let snapshot = SyncDiagnostics.snapshot()
    XCTAssertEqual(snapshot.completedObservancesCount, 0)
    XCTAssertTrue(snapshot.warnings.contains { $0.localizedCaseInsensitiveContains("disabled") })
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

  func testMissedDayRecoveryPlanIsNilWithoutMissedStatus() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let plan = MissedDayRecoveryEngine.plan(
      observances: observances,
      statusesByID: [:],
      today: fixedDate(year: 2026, month: 3, day: 1),
      calendar: fixedCalendar
    )

    XCTAssertNil(plan)
  }

  func testMissedDayRecoveryPlanUsesMostRecentMissedAndNextRequired() throws {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let ashWednesday = try XCTUnwrap(observances.first(where: { $0.title == "Ash Wednesday" }))

    let plan = MissedDayRecoveryEngine.plan(
      observances: observances,
      statusesByID: [ashWednesday.id: .missed],
      today: fixedDate(year: 2026, month: 3, day: 1),
      calendar: fixedCalendar
    )

    XCTAssertNotNil(plan)
    XCTAssertTrue(plan?.titleLine.localizedCaseInsensitiveContains("ash wednesday") ?? false)
    XCTAssertFalse(plan?.steps.isEmpty ?? true)
    XCTAssertTrue(plan?.nextRequiredLine.localizedCaseInsensitiveContains("required") ?? false)
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
