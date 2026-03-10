@testable import CatholicFastingCore
import XCTest

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

    func testSyncedStoreDuplicatePersistSkipsLastSyncUpdate() {
        let payload = ["k": "v"]

        SyncedStore.persist(payload, for: "observance_statuses")
        let sentinelDate = Date(timeIntervalSince1970: 1_000_000)
        UserDefaults.standard.set(sentinelDate, forKey: "last_sync_date")

        SyncedStore.persist(payload, for: "observance_statuses")
        let afterSecondPersist = UserDefaults.standard.object(forKey: "last_sync_date") as? Date

        XCTAssertEqual(afterSecondPersist, sentinelDate)
    }

    func testSyncedStorePersistsOnlyToUserDefaults() {
        let payload = ["privacy": "local-only"]
        SyncedStore.persist(payload, for: "observance_statuses")
        let persisted = UserDefaults.standard.dictionary(forKey: "observance_statuses") as? [String: String]
        XCTAssertEqual(persisted?["privacy"], "local-only")
    }

    func testHouseholdProfileDecodesLegacyBirthYearOnlyPayload() throws {
        let json = """
        [
          {
            "id": "legacy-profile",
            "name": "Legacy",
            "birthYear": 1985,
            "medicalDispensation": true
          }
        ]
        """
        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode([HouseholdProfile].self, from: data)
        let profile = try XCTUnwrap(decoded.first)

        XCTAssertTrue(profile.isAge14OrOlderForAbstinence)
        XCTAssertTrue(profile.isAge18OrOlderForFasting)
        XCTAssertTrue(profile.medicalDispensation)
    }
}
