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

    func testHabitSummaryReportsEmptyState() {
        let now = Date(timeIntervalSince1970: 1_701_400_000)
        let summary = IntermittentHabitSummaryEngine.summary(sessions: [], now: now, calendar: .gregorian)

        XCTAssertEqual(summary.currentStreakDays, 0)
        XCTAssertEqual(summary.bestStreakDays, 0)
        XCTAssertEqual(summary.weeklySessionCount, 0)
        XCTAssertEqual(summary.monthlySessionCount, 0)
        XCTAssertEqual(summary.targetHitPercent, 0)
        XCTAssertEqual(summary.longestDuration, 0)
        XCTAssertNil(summary.latestSessionRecap)
    }

    func testHabitSummaryCountsStreaksWindowsAndHitRate() throws {
        let calendar = Calendar.gregorian
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 24, hour: 12)))
        let sessions = [
            session(id: "latest", ending: now.addingTimeInterval(-2 * 3600), durationHours: 16, targetHours: 16),
            session(id: "yesterday", ending: now.addingTimeInterval((-1 * 24 - 2) * 3600), durationHours: 14, targetHours: 16),
            session(id: "two-days", ending: now.addingTimeInterval((-2 * 24 - 2) * 3600), durationHours: 18, targetHours: 16),
            session(id: "gap", ending: now.addingTimeInterval((-4 * 24 - 2) * 3600), durationHours: 16, targetHours: 16),
            session(id: "old", ending: now.addingTimeInterval((-40 * 24 - 2) * 3600), durationHours: 12, targetHours: 16),
        ]

        let summary = IntermittentHabitSummaryEngine.summary(
            sessions: sessions,
            now: now,
            calendar: calendar)

        XCTAssertEqual(summary.currentStreakDays, 3)
        XCTAssertEqual(summary.bestStreakDays, 3)
        XCTAssertEqual(summary.weeklySessionCount, 4)
        XCTAssertEqual(summary.monthlySessionCount, 4)
        XCTAssertEqual(summary.targetHitPercent, 60)
        XCTAssertEqual(Int(summary.longestDuration / 3600), 18)
        XCTAssertEqual(summary.latestSessionRecap?.sessionID, "latest")
    }

    func testHabitSummaryFindsBestStreakAfterBrokenCurrentStreak() throws {
        let calendar = Calendar.gregorian
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 24, hour: 12)))
        let sessions = [
            session(id: "latest", ending: now, durationHours: 16, targetHours: 16),
            session(id: "old-1", ending: now.addingTimeInterval(-3 * 24 * 3600), durationHours: 16, targetHours: 16),
            session(id: "old-2", ending: now.addingTimeInterval(-4 * 24 * 3600), durationHours: 16, targetHours: 16),
            session(id: "old-3", ending: now.addingTimeInterval(-5 * 24 * 3600), durationHours: 16, targetHours: 16),
        ]

        let summary = IntermittentHabitSummaryEngine.summary(
            sessions: sessions,
            now: now,
            calendar: calendar)

        XCTAssertEqual(summary.currentStreakDays, 1)
        XCTAssertEqual(summary.bestStreakDays, 3)
    }

    func testIntermittentTargetReminderIdentifierIsStable() {
        let start = Date(timeIntervalSince1970: 1_701_500_123)

        XCTAssertEqual(
            IntermittentTargetReminderPolicy.identifier(start: start),
            "intermittent-target-1701500123")
    }

    private func iso(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }

    private func session(
        id: String,
        ending end: Date,
        durationHours: Int,
        targetHours: Int) -> IntermittentFastSession
    {
        IntermittentFastSession(
            id: id,
            start: end.addingTimeInterval(TimeInterval(-durationHours * 3600)),
            end: end,
            targetHours: targetHours)
    }
}
