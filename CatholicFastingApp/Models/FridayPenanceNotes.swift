@preconcurrency import Foundation
import SwiftUI

struct FridayPenanceRecord: Identifiable, Hashable {
    let id: String
    let date: Date
    let title: String
    let note: String
}

final class FridayPenanceNotes: ObservableObject {
    @Published private(set) var notesByObservanceID: [String: String]

    private let syncKey = SyncStoreKeys.fridayPenanceNotes

    init() {
        StorageSchema.migrateIfNeeded()
        notesByObservanceID = SyncedStore.mergedStringDictionary(for: syncKey)
        SyncedStore.persist(notesByObservanceID, for: syncKey)
    }

    func note(for observanceID: String) -> String {
        notesByObservanceID[observanceID] ?? ""
    }

    func setNote(_ value: String, for observanceID: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            notesByObservanceID.removeValue(forKey: observanceID)
        } else {
            notesByObservanceID[observanceID] = trimmed
        }
        SyncedStore.persist(notesByObservanceID, for: syncKey)
    }

    func records() -> [FridayPenanceRecord] {
        notesByObservanceID.compactMap { entry in
            let trimmed = entry.value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return makeRecord(observanceID: entry.key, note: trimmed)
        }
        .sorted { $0.date > $1.date }
    }

    func clearAll() {
        notesByObservanceID.removeAll()
        SyncedStore.persist(notesByObservanceID, for: syncKey)
    }

    func exportPayload() -> [String: String] {
        notesByObservanceID
    }

    private func makeRecord(observanceID: String, note: String) -> FridayPenanceRecord {
        let pieces = observanceID.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
        let dateString = pieces.indices.contains(0) ? String(pieces[0]) : ""
        let title = pieces.indices.contains(1) ? String(pieces[1]) : "Friday Penance"
        let date = DateFormatter.dayKeyParser.date(from: dateString) ?? Date.distantPast
        return FridayPenanceRecord(id: observanceID, date: date, title: title, note: note)
    }
}

extension FridayPenanceNotes: @unchecked Sendable {}
