@preconcurrency import Foundation

struct SyncSnapshot {
  let iCloudAvailable: Bool
  let lastSyncDate: Date?
  let completedObservancesCount: Int
  let fridayNotesCount: Int
  let warnings: [String]
}

enum SyncDiagnostics {
  static func snapshot() -> SyncSnapshot {
    let diagnosticsEnabled = SyncedStore.isDiagnosticsEnabled()
    let bundleAuditWarnings = RuleBundleRepository.snapshot().audit.warnings

    guard diagnosticsEnabled else {
      return SyncSnapshot(
        iCloudAvailable: SyncedStore.isCloudSyncEnabled()
          && FileManager.default.ubiquityIdentityToken != nil,
        lastSyncDate: UserDefaults.standard.object(forKey: SyncStoreKeys.lastSyncDate) as? Date,
        completedObservancesCount: 0,
        fridayNotesCount: 0,
        warnings: ["Diagnostics disabled by user preference."] + bundleAuditWarnings
      )
    }

    let completedCount = SyncedStore.mergedStatusDictionary(for: SyncStoreKeys.observanceStatuses)
      .values
      .filter(\.countsTowardProgress)
      .count
    let notesCount = SyncedStore.mergedStringDictionary(for: SyncStoreKeys.fridayPenanceNotes)
      .values
      .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .count

    let warnings =
      consistencyWarnings(
        completionCount: completedCount,
        notesCount: notesCount
      ) + bundleAuditWarnings

    return SyncSnapshot(
      iCloudAvailable: SyncedStore.isCloudSyncEnabled()
        && FileManager.default.ubiquityIdentityToken != nil,
      lastSyncDate: UserDefaults.standard.object(forKey: SyncStoreKeys.lastSyncDate) as? Date,
      completedObservancesCount: completedCount,
      fridayNotesCount: notesCount,
      warnings: warnings
    )
  }

  private static func consistencyWarnings(completionCount: Int, notesCount: Int) -> [String] {
    var warnings: [String] = []
    if completionCount == 0 && notesCount > 0 {
      warnings.append("You have notes but no completed observances.")
    }
    if completionCount > 200 {
      warnings.append("High completion count detected; review exports for duplicates.")
    }
    return warnings
  }
}
