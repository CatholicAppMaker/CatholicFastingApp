@preconcurrency import Foundation

enum SyncStoreKeys {
  static let storageSchemaVersion = "storage_schema_version"
  static let completedObservances = "completed_observances"
  static let observanceStatuses = "observance_statuses"
  static let fridayPenanceNotes = "friday_penance_notes"
  static let lastSyncDate = "last_sync_date"
  static let ruleBundleDirectoryOverride = "rule_bundle_directory_override"
  static let intermittentFastSessions = "intermittent_fast_sessions"
  static let intermittentFastMeta = "intermittent_fast_meta"
}

enum StorageSchema {
  static let currentVersion = 3

  static func migrateIfNeeded() {
    let existingVersion = UserDefaults.standard.integer(forKey: SyncStoreKeys.storageSchemaVersion)
    guard existingVersion < currentVersion else { return }

    if existingVersion == 0 {
      let legacyCompleted = UserDefaults.standard.array(forKey: SyncStoreKeys.completedObservances) as? [String] ?? []
      let legacyNotes = UserDefaults.standard.dictionary(forKey: SyncStoreKeys.fridayPenanceNotes) as? [String: String] ?? [:]
      SyncedStore.persist(Set(legacyCompleted), for: SyncStoreKeys.completedObservances)
      SyncedStore.persist(legacyNotes, for: SyncStoreKeys.fridayPenanceNotes)
    }

    if existingVersion <= 1 {
      let legacyCompleted = SyncedStore.mergedStringSet(for: SyncStoreKeys.completedObservances)
      let migratedStatuses = Dictionary(uniqueKeysWithValues: legacyCompleted.map { ($0, CompletionStatus.completed) })
      SyncedStore.persist(migratedStatuses, for: SyncStoreKeys.observanceStatuses)
      UserDefaults.standard.removeObject(forKey: SyncStoreKeys.completedObservances)
    }

    UserDefaults.standard.set(currentVersion, forKey: SyncStoreKeys.storageSchemaVersion)
  }
}

enum SyncedStore {
  static func mergedStringSet(for key: String) -> Set<String> {
    Set(UserDefaults.standard.array(forKey: key) as? [String] ?? [])
  }

  static func mergedStringDictionary(for key: String) -> [String: String] {
    UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
  }

  static func persist(_ value: Set<String>, for key: String) {
    let arrayValue = Array(value).sorted()
    let existingLocal = UserDefaults.standard.array(forKey: key) as? [String] ?? []
    guard existingLocal != arrayValue else { return }

    UserDefaults.standard.set(arrayValue, forKey: key)
    updateLastSyncDate()
  }

  static func persist(_ value: [String: String], for key: String) {
    let existingLocal = UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
    guard existingLocal != value else { return }

    UserDefaults.standard.set(value, forKey: key)
    updateLastSyncDate()
  }

  static func mergedStatusDictionary(for key: String) -> [String: CompletionStatus] {
    let mergedRaw = mergedStringDictionary(for: key)
    var typed: [String: CompletionStatus] = [:]
    for (id, rawStatus) in mergedRaw {
      typed[id] = CompletionStatus(rawValue: rawStatus) ?? .notStarted
    }
    return typed
  }

  static func persist(_ value: [String: CompletionStatus], for key: String) {
    let raw = value.mapValues(\.rawValue)
    persist(raw, for: key)
  }

  private static func updateLastSyncDate() {
    let now = Date()
    UserDefaults.standard.set(now, forKey: SyncStoreKeys.lastSyncDate)
  }
}
