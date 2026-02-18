import XCTest
@testable import CatholicFastingCore

final class StorageAndSyncTests: XCTestCase {
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

  func testFastTrackerToggleAndExport() {
    let tracker = FastTracker()
    let id = "2026-03-01|Sample|mandatory"

    XCTAssertFalse(tracker.isCompleted(id))
    tracker.toggle(id)
    XCTAssertTrue(tracker.isCompleted(id))
    XCTAssertEqual(tracker.status(for: id), .completed)
    XCTAssertEqual(tracker.exportPayload(), [id])

    tracker.toggle(id)
    XCTAssertFalse(tracker.isCompleted(id))
    XCTAssertEqual(tracker.status(for: id), .notStarted)
  }

  func testFastTrackerClearAll() {
    let tracker = FastTracker()
    tracker.setStatus(.completed, for: "2026-03-01|A|mandatory")
    tracker.setStatus(.substituted, for: "2026-03-02|B|mandatory")

    XCTAssertEqual(tracker.exportPayload().count, 2)
    tracker.clearAll()
    XCTAssertTrue(tracker.exportPayload().isEmpty)
  }

  func testFastTrackerStatusPayload() {
    let tracker = FastTracker()
    tracker.setStatus(.dispensed, for: "2026-03-05|C|mandatory")
    tracker.setStatus(.missed, for: "2026-03-06|D|mandatory")

    let payload = tracker.exportStatusPayload()
    XCTAssertEqual(payload["2026-03-05|C|mandatory"], "dispensed")
    XCTAssertEqual(payload["2026-03-06|D|mandatory"], "missed")
  }

  func testFridayNotesTrimsWhitespaceAndExports() {
    let notes = FridayPenanceNotes()
    let id = "2026-05-01|Friday Penance (Outside Lent)|fridayPenance"

    notes.setNote("   extra prayer and almsgiving   ", for: id)
    XCTAssertEqual(notes.note(for: id), "extra prayer and almsgiving")

    let exported = notes.exportPayload()
    XCTAssertEqual(exported[id], "extra prayer and almsgiving")
  }

  func testFridayNotesClearAll() {
    let notes = FridayPenanceNotes()
    notes.setNote("Rosary", for: "2026-05-01|Friday Penance (Outside Lent)|fridayPenance")
    notes.setNote("Adoration", for: "2026-05-08|Friday Penance (Outside Lent)|fridayPenance")

    XCTAssertEqual(notes.records().count, 2)
    notes.clearAll()
    XCTAssertTrue(notes.records().isEmpty)
  }

  func testFridayNotesRecordParsesDateAndTitle() {
    let notes = FridayPenanceNotes()
    let id = "2026-05-01|Friday Penance (Outside Lent)|fridayPenance"
    notes.setNote("Rosary", for: id)

    let record = notes.records().first
    XCTAssertEqual(record?.title, "Friday Penance (Outside Lent)")
    XCTAssertEqual(record?.note, "Rosary")
    XCTAssertNotNil(record?.date)
  }

  func testSyncDiagnosticsReportsCounts() {
    let tracker = FastTracker()
    let notes = FridayPenanceNotes()

    tracker.setStatus(.completed, for: "2026-03-01|A|mandatory")
    tracker.setStatus(.substituted, for: "2026-03-02|B|mandatory")
    notes.setNote("Rosary", for: "2026-05-01|Friday Penance (Outside Lent)|fridayPenance")

    let snapshot = SyncDiagnostics.snapshot()
    XCTAssertGreaterThanOrEqual(snapshot.completedObservancesCount, 2)
    XCTAssertGreaterThanOrEqual(snapshot.fridayNotesCount, 1)
    XCTAssertNotNil(snapshot.lastSyncDate)
  }

  func testSchemaMigrationPromotesLegacyData() {
    UserDefaults.standard.set(["legacy-id"], forKey: "completed_observances")
    UserDefaults.standard.set(["legacy-note-id": "legacy note"], forKey: "friday_penance_notes")
    UserDefaults.standard.set(0, forKey: "storage_schema_version")

    _ = FastTracker()
    let notes = FridayPenanceNotes()

    XCTAssertEqual(UserDefaults.standard.integer(forKey: "storage_schema_version"), 3)
    XCTAssertEqual(notes.note(for: "legacy-note-id"), "legacy note")
  }

  func testCloudSyncToggleCanDisableICloudWrites() {
    UserDefaults.standard.set(false, forKey: "allow_cloud_sync")
    let tracker = FastTracker()
    let id = "2026-03-10|NoCloud|mandatory"
    tracker.setStatus(.completed, for: id)

    let cloudValue = NSUbiquitousKeyValueStore.default.dictionary(forKey: "observance_statuses") as? [String: String]
    XCTAssertFalse((cloudValue ?? [:]).keys.contains(id))
  }

  func testSetNotStartedRemovesStatusEntry() {
    let tracker = FastTracker()
    let id = "2026-03-10|Reset|mandatory"
    tracker.setStatus(.completed, for: id)
    XCTAssertEqual(tracker.status(for: id), .completed)

    tracker.setStatus(.notStarted, for: id)
    XCTAssertEqual(tracker.status(for: id), .notStarted)
    XCTAssertNil(tracker.exportStatusPayload()[id])
  }

  func testExportStatusPayloadContainsRawValues() {
    let tracker = FastTracker()
    tracker.setStatus(.completed, for: "a")
    tracker.setStatus(.substituted, for: "b")
    tracker.setStatus(.dispensed, for: "c")
    tracker.setStatus(.missed, for: "d")

    let payload = tracker.exportStatusPayload()
    XCTAssertEqual(payload["a"], "completed")
    XCTAssertEqual(payload["b"], "substituted")
    XCTAssertEqual(payload["c"], "dispensed")
    XCTAssertEqual(payload["d"], "missed")
  }

  func testFridayNotesEmptyTrimmedInputRemovesEntry() {
    let notes = FridayPenanceNotes()
    let id = "2026-05-01|Friday Penance (Outside Lent)|fridayPenance"

    notes.setNote("Rosary", for: id)
    XCTAssertEqual(notes.note(for: id), "Rosary")

    notes.setNote("   ", for: id)
    XCTAssertEqual(notes.note(for: id), "")
    XCTAssertNil(notes.exportPayload()[id])
  }

  func testSyncedStoreDiagnosticsDefaultEnabledWhenUnset() {
    UserDefaults.standard.removeObject(forKey: "allow_diagnostics")
    XCTAssertTrue(SyncedStore.isDiagnosticsEnabled())
  }

  func testSyncedStoreDuplicatePersistSkipsLastSyncUpdate() {
    UserDefaults.standard.set(false, forKey: "allow_cloud_sync")
    let payload = ["k": "v"]

    SyncedStore.persist(payload, for: "observance_statuses")
    let sentinelDate = Date(timeIntervalSince1970: 1_000_000)
    UserDefaults.standard.set(sentinelDate, forKey: "last_sync_date")

    SyncedStore.persist(payload, for: "observance_statuses")
    let afterSecondPersist = UserDefaults.standard.object(forKey: "last_sync_date") as? Date

    XCTAssertEqual(afterSecondPersist, sentinelDate)
  }

  func testLocalAnalyticsTracksOnlyWhenEnabled() {
    LocalAnalyticsStore.setEnabled(false)
    LocalAnalyticsStore.track(.appLaunch)
    XCTAssertEqual(LocalAnalyticsStore.snapshot().totalEvents, 0)

    LocalAnalyticsStore.setEnabled(true)
    LocalAnalyticsStore.track(.appLaunch)
    LocalAnalyticsStore.track(.appLaunch)
    LocalAnalyticsStore.track(.supportRemindersScheduled)

    let snapshot = LocalAnalyticsStore.snapshot()
    XCTAssertTrue(snapshot.isEnabled)
    XCTAssertEqual(snapshot.count(for: .appLaunch), 2)
    XCTAssertEqual(snapshot.count(for: .supportRemindersScheduled), 1)
    XCTAssertEqual(snapshot.totalEvents, 3)
  }

  func testLocalAnalyticsDisablingClearsStoredCounts() {
    LocalAnalyticsStore.setEnabled(true)
    LocalAnalyticsStore.track(.onboardingCompleted)
    XCTAssertGreaterThan(LocalAnalyticsStore.snapshot().totalEvents, 0)

    LocalAnalyticsStore.setEnabled(false)
    let snapshot = LocalAnalyticsStore.snapshot()
    XCTAssertFalse(snapshot.isEnabled)
    XCTAssertEqual(snapshot.totalEvents, 0)
  }

}
