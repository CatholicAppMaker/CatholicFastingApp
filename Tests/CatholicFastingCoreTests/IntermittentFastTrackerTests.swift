@testable import CatholicFastingCore
import XCTest

final class IntermittentFastTrackerTests: XCTestCase {
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

    func testStartAndEndCreatesSessionAndClearsActiveState() throws {
        let tracker = IntermittentFastTracker()
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let end = start.addingTimeInterval((16 * 3600) + 60)

        tracker.startFast(now: start)
        XCTAssertEqual(tracker.activeStart, start)

        tracker.endFast(now: end)

        XCTAssertNil(tracker.activeStart)
        XCTAssertEqual(tracker.sessions.count, 1)
        let session = try XCTUnwrap(tracker.sessions.first)
        XCTAssertEqual(session.start, start)
        XCTAssertEqual(session.end, end)
        XCTAssertEqual(session.targetHours, 16)
        XCTAssertTrue(session.completedTarget)
    }

    func testCancelClearsActiveFastWithoutCreatingSession() {
        let tracker = IntermittentFastTracker()
        let start = Date(timeIntervalSince1970: 1_700_100_000)

        tracker.startFast(now: start)
        XCTAssertEqual(tracker.activeStart, start)

        tracker.cancelActiveFast()
        XCTAssertNil(tracker.activeStart)
        XCTAssertTrue(tracker.sessions.isEmpty)
    }

    func testPresetHoursAreBounded() {
        let tracker = IntermittentFastTracker()

        tracker.setPresetHours(9)
        XCTAssertEqual(tracker.presetHours, 12)

        tracker.setPresetHours(72)
        XCTAssertEqual(tracker.presetHours, 72)

        tracker.setPresetHours(400)
        XCTAssertEqual(tracker.presetHours, 336)
    }

    func testStatePersistsAcrossInstances() throws {
        let start = Date(timeIntervalSince1970: 1_700_200_000)
        let end = start.addingTimeInterval(7200)

        let tracker = IntermittentFastTracker()
        tracker.setPresetHours(20)
        tracker.startFast(now: start)

        let reloadedDuringActive = IntermittentFastTracker()
        XCTAssertEqual(reloadedDuringActive.presetHours, 20)
        XCTAssertEqual(reloadedDuringActive.activeStart, start)

        reloadedDuringActive.endFast(now: end)
        let reloadedAfterEnd = IntermittentFastTracker()
        XCTAssertNil(reloadedAfterEnd.activeStart)
        XCTAssertEqual(reloadedAfterEnd.sessions.count, 1)
        let session = try XCTUnwrap(reloadedAfterEnd.sessions.first)
        XCTAssertEqual(session.targetHours, 20)
        XCTAssertEqual(session.start, start)
        XCTAssertEqual(session.end, end)
    }

    func testClearAllResetsSessionsAndPreset() {
        let tracker = IntermittentFastTracker()
        let start = Date(timeIntervalSince1970: 1_700_300_000)
        let end = start.addingTimeInterval(3600)
        tracker.setPresetHours(18)
        tracker.startFast(now: start)
        tracker.endFast(now: end)
        XCTAssertEqual(tracker.sessions.count, 1)
        XCTAssertEqual(tracker.presetHours, 18)

        tracker.clearAll()

        XCTAssertTrue(tracker.sessions.isEmpty)
        XCTAssertNil(tracker.activeStart)
        XCTAssertEqual(tracker.presetHours, 16)
    }

    func testSessionHistoryIsCappedAt500() {
        let tracker = IntermittentFastTracker()
        let base = Date(timeIntervalSince1970: 1_700_400_000)

        for offset in 0 ..< 520 {
            let start = base.addingTimeInterval(TimeInterval(offset * 7200))
            let end = start.addingTimeInterval(1800)
            tracker.startFast(now: start)
            tracker.endFast(now: end)
        }

        XCTAssertEqual(tracker.sessions.count, 500)

        let reloaded = IntermittentFastTracker()
        XCTAssertEqual(reloaded.sessions.count, 500)
    }

    func testStartFastClampsFutureStartToCurrentTime() {
        let tracker = IntermittentFastTracker()
        let before = Date()
        let future = before.addingTimeInterval(3600)

        tracker.startFast(now: future)

        let after = Date()
        let actualStart = tracker.activeStart
        XCTAssertNotNil(actualStart)
        XCTAssertLessThanOrEqual(actualStart ?? .distantFuture, after)
        XCTAssertGreaterThanOrEqual(actualStart ?? .distantPast, before.addingTimeInterval(-1))
    }

    func testUpdateActiveStartPersistsWhileFastIsRunning() {
        let tracker = IntermittentFastTracker()
        let originalStart = Date(timeIntervalSince1970: 1_700_500_000)
        let editedStart = originalStart.addingTimeInterval(-1800)

        tracker.startFast(now: originalStart)
        tracker.updateActiveStart(to: editedStart, now: originalStart)

        XCTAssertEqual(tracker.activeStart, editedStart)

        let reloaded = IntermittentFastTracker()
        XCTAssertEqual(reloaded.activeStart, editedStart)
    }

    func testUpdateActiveStartClampsFutureValues() {
        let tracker = IntermittentFastTracker()
        let originalStart = Date(timeIntervalSince1970: 1_700_600_000)
        let now = originalStart.addingTimeInterval(300)
        let future = now.addingTimeInterval(3600)

        tracker.startFast(now: originalStart)
        tracker.updateActiveStart(to: future, now: now)

        XCTAssertEqual(tracker.activeStart, now)
    }
}
