@testable import CatholicFastingCore
import Foundation
import XCTest

final class WidgetSnapshotStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        beginStoreIsolation()
        resetStores()
        let sharedDefaults = UserDefaults(suiteName: WidgetSnapshotContract.appGroupIdentifier)
        sharedDefaults?.removeObject(forKey: WidgetSnapshotContract.snapshotKey)
        sharedDefaults?.removeObject(forKey: WidgetSnapshotContract.localizationCodeKey)
    }

    override func tearDown() {
        let sharedDefaults = UserDefaults(suiteName: WidgetSnapshotContract.appGroupIdentifier)
        sharedDefaults?.removeObject(forKey: WidgetSnapshotContract.snapshotKey)
        sharedDefaults?.removeObject(forKey: WidgetSnapshotContract.localizationCodeKey)
        resetStores()
        endStoreIsolation()
        super.tearDown()
    }

    func testWidgetSnapshotRoundTrip() {
        let generatedAt = Date(timeIntervalSince1970: 1_726_500_000)
        let nextRequiredDate = Date(timeIntervalSince1970: 1_726_600_000)
        let snapshot = WidgetSnapshot(
            generatedAt: generatedAt,
            todayTitle: "Ash Wednesday",
            todayObligation: "Required",
            nextRequiredTitle: "Good Friday",
            nextRequiredDate: nextRequiredDate,
            completionRate: 0.72,
            hasActiveIntermittentFast: true,
            activeIntermittentFastStart: generatedAt,
            activeIntermittentTargetHours: 16,
            localizationCode: "fr-CA")

        WidgetSnapshotStore.persist(snapshot)
        let loaded = WidgetSnapshotStore.load()

        XCTAssertEqual(loaded, snapshot)
        XCTAssertEqual(WidgetSnapshotStore.fallbackLocalizationCode(), "fr-CA")
    }

    func testWidgetSnapshotOverwritePersistsLatestValue() {
        let initial = WidgetSnapshot(
            generatedAt: Date(timeIntervalSince1970: 1_726_500_000),
            todayTitle: "No observance today",
            todayObligation: "No obligation",
            nextRequiredTitle: "No upcoming required observance",
            nextRequiredDate: nil,
            completionRate: 0,
            hasActiveIntermittentFast: false,
            activeIntermittentFastStart: nil,
            activeIntermittentTargetHours: 16)
        let updated = WidgetSnapshot(
            generatedAt: Date(timeIntervalSince1970: 1_726_700_000),
            todayTitle: "Good Friday",
            todayObligation: "Required",
            nextRequiredTitle: "Holy Saturday",
            nextRequiredDate: Date(timeIntervalSince1970: 1_726_786_400),
            completionRate: 0.95,
            hasActiveIntermittentFast: false,
            activeIntermittentFastStart: nil,
            activeIntermittentTargetHours: 20)

        WidgetSnapshotStore.persist(initial)
        WidgetSnapshotStore.persist(updated)

        XCTAssertEqual(WidgetSnapshotStore.load(), updated)
    }

    func testWidgetSnapshotClearRemovesPersistedValue() {
        let snapshot = WidgetSnapshot(
            generatedAt: Date(timeIntervalSince1970: 1_726_700_000),
            todayTitle: "Friday of Lent",
            todayObligation: "Required",
            nextRequiredTitle: "Good Friday",
            nextRequiredDate: Date(timeIntervalSince1970: 1_726_786_400),
            completionRate: 0.65,
            hasActiveIntermittentFast: false,
            activeIntermittentFastStart: nil,
            activeIntermittentTargetHours: 16)

        WidgetSnapshotStore.persist(snapshot)
        XCTAssertEqual(WidgetSnapshotStore.load(), snapshot)

        WidgetSnapshotStore.clear()
        XCTAssertNil(WidgetSnapshotStore.load())
    }

    func testWidgetSnapshotLoadReturnsNilForCorruptPayload() {
        let sharedDefaults = UserDefaults(suiteName: WidgetSnapshotContract.appGroupIdentifier)
        sharedDefaults?.set("es", forKey: WidgetSnapshotContract.localizationCodeKey)
        sharedDefaults?.set(Data("not-json".utf8), forKey: WidgetSnapshotContract.snapshotKey)

        XCTAssertNil(WidgetSnapshotStore.load())
        XCTAssertEqual(WidgetSnapshotStore.fallbackLocalizationCode(), "es")
    }

    func testLegacyWidgetSnapshotWithoutOptionalFieldsUsesBackwardCompatibleDefaults() throws {
        struct LegacySnapshot: Codable {
            let generatedAt: Date
            let todayTitle: String
            let todayObligation: String
            let nextRequiredTitle: String
            let nextRequiredDate: Date?
            let completionRate: Double
            let hasActiveIntermittentFast: Bool
            let activeIntermittentFastStart: Date?
            let activeIntermittentTargetHours: Int
        }

        let legacy = LegacySnapshot(
            generatedAt: Date(timeIntervalSince1970: 1_726_500_000),
            todayTitle: "Friday",
            todayObligation: "Required",
            nextRequiredTitle: "Good Friday",
            nextRequiredDate: nil,
            completionRate: 0.5,
            hasActiveIntermittentFast: false,
            activeIntermittentFastStart: nil,
            activeIntermittentTargetHours: 16)
        try UserDefaults.standard.set(JSONEncoder().encode(legacy), forKey: "widget_snapshot")

        let loaded = WidgetSnapshotStore.load()
        XCTAssertEqual(loaded?.localizationCode, "en")
        XCTAssertEqual(loaded?.premiumMotivationLine, "Stay faithful in small daily disciplines.")
        XCTAssertEqual(loaded?.todayTitle, legacy.todayTitle)
    }

    func testActiveFastTargetUsesRequestedEvaluationDate() {
        let start = Date(timeIntervalSince1970: 1_726_500_000)
        let snapshot = WidgetSnapshot(
            generatedAt: start,
            todayTitle: "Friday",
            todayObligation: "Optional",
            nextRequiredTitle: "Ash Wednesday",
            nextRequiredDate: nil,
            completionRate: 0,
            hasActiveIntermittentFast: true,
            activeIntermittentFastStart: start,
            activeIntermittentTargetHours: 16)
        let target = start.addingTimeInterval(16 * 3600)

        XCTAssertEqual(snapshot.activeIntermittentTargetDate, target)
        XCTAssertFalse(snapshot.hasReachedActiveIntermittentTarget(at: target.addingTimeInterval(-1)))
        XCTAssertTrue(snapshot.hasReachedActiveIntermittentTarget(at: target))
    }

    func testInactiveFastHasNoTargetDate() {
        let start = Date(timeIntervalSince1970: 1_726_500_000)
        let snapshot = WidgetSnapshot(
            generatedAt: start,
            todayTitle: "Friday",
            todayObligation: "Optional",
            nextRequiredTitle: "Ash Wednesday",
            nextRequiredDate: nil,
            completionRate: 0,
            hasActiveIntermittentFast: false,
            activeIntermittentFastStart: start,
            activeIntermittentTargetHours: 16)

        XCTAssertNil(snapshot.activeIntermittentTargetDate)
        XCTAssertFalse(snapshot.hasReachedActiveIntermittentTarget(at: start.addingTimeInterval(17 * 3600)))
    }

    func testInvalidActiveFastTargetsFailSafely() {
        let start = Date(timeIntervalSince1970: 1_726_500_000)

        XCTAssertNil(WidgetActiveFastTiming.targetDate(isActive: true, start: start, targetHours: 0))
        XCTAssertNil(WidgetActiveFastTiming.targetDate(isActive: true, start: start, targetHours: -1))
        XCTAssertNil(WidgetActiveFastTiming.targetDate(isActive: true, start: start, targetHours: Int.max))
    }

    func testWidgetSnapshotExpiresAtTheLocalDayBoundary() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let generatedAt = Date(timeIntervalSince1970: 1_726_531_200)
        let snapshot = WidgetSnapshot(
            generatedAt: generatedAt,
            todayTitle: "Friday",
            todayObligation: "Required",
            nextRequiredTitle: "Ash Wednesday",
            nextRequiredDate: nil,
            completionRate: 0,
            hasActiveIntermittentFast: false,
            activeIntermittentFastStart: nil,
            activeIntermittentTargetHours: 16)

        XCTAssertTrue(snapshot.isCurrent(at: generatedAt.addingTimeInterval(3600), calendar: calendar))
        XCTAssertFalse(snapshot.isCurrent(at: generatedAt.addingTimeInterval(24 * 3600), calendar: calendar))
    }

    func testTimelineRefreshUsesEarliestFutureBoundary() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let now = Date(timeIntervalSince1970: 1_726_531_200)

        XCTAssertEqual(
            WidgetTimelineSchedule.nextRefreshDate(
                after: now,
                activeFastTargetDate: now.addingTimeInterval(10 * 60),
                calendar: calendar),
            now.addingTimeInterval(10 * 60))
        XCTAssertEqual(
            WidgetTimelineSchedule.nextRefreshDate(
                after: now,
                activeFastTargetDate: now.addingTimeInterval(-1),
                calendar: calendar),
            now.addingTimeInterval(30 * 60))
    }

    func testWidgetLocalizationCandidatesNormalizeSupportedLocaleForms() {
        XCTAssertEqual(WidgetLocalizationCode.candidates(for: "fr_CA"), ["fr-CA", "fr"])
        XCTAssertEqual(WidgetLocalizationCode.candidates(for: "fr"), ["fr-CA", "fr"])
        XCTAssertEqual(WidgetLocalizationCode.candidates(for: "frenchCanadian"), ["fr-CA", "fr"])
        XCTAssertEqual(WidgetLocalizationCode.candidates(for: "es_MX"), ["es-MX", "es"])
        XCTAssertEqual(WidgetLocalizationCode.candidates(for: "spanish"), ["es"])
        XCTAssertEqual(WidgetLocalizationCode.candidates(for: ""), ["en"])
    }

    func testWidgetLocalizationResolvesDateLocaleToSupportedBundle() {
        XCTAssertEqual(WidgetLocalizationCode.resolvedSupportedCode(for: "spanish"), "es")
        XCTAssertEqual(WidgetLocalizationCode.resolvedSupportedCode(for: "es_MX"), "es")
        XCTAssertEqual(WidgetLocalizationCode.resolvedSupportedCode(for: "fr_FR"), "fr-CA")
        XCTAssertEqual(WidgetLocalizationCode.resolvedSupportedCode(for: "frenchCanadian"), "fr-CA")
        XCTAssertEqual(WidgetLocalizationCode.resolvedSupportedCode(for: "de_DE"), "en")
        XCTAssertEqual(WidgetLocalizationCode.resolvedSupportedCode(for: ""), "en")
    }
}
