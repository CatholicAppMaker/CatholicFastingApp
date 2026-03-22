@preconcurrency import Foundation

struct SyncSnapshot {
    let lastSyncDate: Date?
    let completedObservancesCount: Int
    let fridayNotesCount: Int
    let warnings: [String]
}

enum SyncDiagnostics {
    static func snapshot() -> SyncSnapshot {
        let bundleAuditWarnings = RuleBundleRepository.snapshot().audit.warnings

        let completedCount = SyncedStore.mergedStatusDictionary(for: SyncStoreKeys.observanceStatuses)
            .values
            .filter(\.countsTowardProgress)
            .count
        let notesCount = SyncedStore.mergedStringDictionary(for: SyncStoreKeys.fridayPenanceNotes)
            .values
            .count(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })

        let warnings =
            consistencyWarnings(
                completionCount: completedCount,
                notesCount: notesCount) + bundleAuditWarnings

        return SyncSnapshot(
            lastSyncDate: UserDefaults.standard.object(forKey: SyncStoreKeys.lastSyncDate) as? Date,
            completedObservancesCount: completedCount,
            fridayNotesCount: notesCount,
            warnings: warnings)
    }

    private static func consistencyWarnings(completionCount: Int, notesCount: Int) -> [String] {
        var warnings: [String] = []
        if completionCount == 0, notesCount > 0 {
            warnings.append("You have notes but no completed observances.")
        }
        if completionCount > 200 {
            warnings.append("High completion count detected; review exports for duplicates.")
        }
        return warnings
    }
}
