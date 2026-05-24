@testable import CatholicFastingCore
import XCTest

final class IntermittentFastCompanionTests: XCTestCase {
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

    func testEndedFastPersistsIntentionAndNote() throws {
        let tracker = IntermittentFastTracker()
        let start = Date(timeIntervalSince1970: 1_700_700_000)
        let end = start.addingTimeInterval(16 * 3600)

        tracker.startFast(now: start)
        tracker.endFast(now: end, intentionID: "prayer", note: " Offered for a parish intention. ")

        let reloaded = IntermittentFastTracker()
        let session = try XCTUnwrap(reloaded.sessions.first)
        XCTAssertEqual(session.intentionID, "prayer")
        XCTAssertEqual(session.note, "Offered for a parish intention.")
    }

    func testLegacySessionPayloadStillDecodes() throws {
        let start = Date(timeIntervalSince1970: 1_700_800_000)
        let end = start.addingTimeInterval(14 * 3600)
        let legacyPayload = #"{"start":"\#(iso(start))","end":"\#(iso(end))","targetHours":14}"#
        SyncedStore.persist(["legacy": legacyPayload], for: SyncStoreKeys.intermittentFastSessions)

        let tracker = IntermittentFastTracker()
        let session = try XCTUnwrap(tracker.sessions.first)

        XCTAssertEqual(session.id, "legacy")
        XCTAssertEqual(session.targetHours, 14)
        XCTAssertNil(session.intentionID)
        XCTAssertNil(session.note)
    }

    func testFastProgressReportsActiveAndTargetReachedStates() {
        let now = Date(timeIntervalSince1970: 1_700_900_000)
        let active = FastProgressState.current(
            activeStart: now.addingTimeInterval(-2 * 3600),
            targetHours: 16,
            sessions: [],
            now: now)

        XCTAssertTrue(active.isActive)
        XCTAssertEqual(active.stage, .early)

        let targetReached = FastProgressState.current(
            activeStart: now.addingTimeInterval(-18 * 3600),
            targetHours: 16,
            sessions: [],
            now: now)

        XCTAssertTrue(targetReached.isActive)
        XCTAssertEqual(targetReached.stage, .targetReached)
    }

    func testRecapUsesPositiveLanguageForCompletedAndEarlyEnd() {
        let start = Date(timeIntervalSince1970: 1_701_000_000)
        let completed = IntermittentFastSession(
            id: "complete",
            start: start,
            end: start.addingTimeInterval(16 * 3600),
            targetHours: 16)
        let early = IntermittentFastSession(
            id: "early",
            start: start,
            end: start.addingTimeInterval(4 * 3600),
            targetHours: 16)

        let completedRecap = IntermittentFastSessionRecap.make(session: completed)
        let earlyRecap = IntermittentFastSessionRecap.make(session: early)

        XCTAssertTrue(completedRecap.completedTarget)
        XCTAssertFalse(earlyRecap.completedTarget)
        XCTAssertFalse(earlyRecap.encouragement.localizedCaseInsensitiveContains("failed"))
        XCTAssertFalse(earlyRecap.encouragement.localizedCaseInsensitiveContains("shame"))
    }

    private func iso(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }
}
