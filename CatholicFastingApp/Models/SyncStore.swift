@preconcurrency import Foundation

enum SyncStoreKeys {
  static let storageSchemaVersion = "storage_schema_version"
  static let completedObservances = "completed_observances"
  static let observanceStatuses = "observance_statuses"
  static let fridayPenanceNotes = "friday_penance_notes"
  static let lastSyncDate = "last_sync_date"
  static let allowCloudSync = "allow_cloud_sync"
  static let allowDiagnostics = "allow_diagnostics"
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
      NSUbiquitousKeyValueStore.default.removeObject(forKey: SyncStoreKeys.completedObservances)
    }

    if UserDefaults.standard.object(forKey: SyncStoreKeys.allowCloudSync) == nil {
      UserDefaults.standard.set(true, forKey: SyncStoreKeys.allowCloudSync)
    }
    if UserDefaults.standard.object(forKey: SyncStoreKeys.allowDiagnostics) == nil {
      UserDefaults.standard.set(true, forKey: SyncStoreKeys.allowDiagnostics)
    }

    UserDefaults.standard.set(currentVersion, forKey: SyncStoreKeys.storageSchemaVersion)
  }
}

enum SyncedStore {
  static func isCloudSyncEnabled() -> Bool {
    guard UserDefaults.standard.object(forKey: SyncStoreKeys.allowCloudSync) != nil else {
      return true
    }
    return UserDefaults.standard.bool(forKey: SyncStoreKeys.allowCloudSync)
  }

  static func isDiagnosticsEnabled() -> Bool {
    guard UserDefaults.standard.object(forKey: SyncStoreKeys.allowDiagnostics) != nil else {
      return true
    }
    return UserDefaults.standard.bool(forKey: SyncStoreKeys.allowDiagnostics)
  }

  static func mergedStringSet(for key: String) -> Set<String> {
    let local = Set(UserDefaults.standard.array(forKey: key) as? [String] ?? [])
    guard isCloudSyncEnabled() else { return local }
    let cloud = Set(NSUbiquitousKeyValueStore.default.array(forKey: key) as? [String] ?? [])
    return local.union(cloud)
  }

  static func mergedStringDictionary(for key: String) -> [String: String] {
    var merged = UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
    guard isCloudSyncEnabled() else { return merged }
    let cloud = NSUbiquitousKeyValueStore.default.dictionary(forKey: key) as? [String: String] ?? [:]
    for (k, v) in cloud {
      merged[k] = v
    }
    return merged
  }

  static func persist(_ value: Set<String>, for key: String) {
    let arrayValue = Array(value).sorted()
    let existingLocal = UserDefaults.standard.array(forKey: key) as? [String] ?? []
    if existingLocal == arrayValue {
      if isCloudSyncEnabled() {
        let existingCloud = NSUbiquitousKeyValueStore.default.array(forKey: key) as? [String] ?? []
        guard existingCloud != arrayValue else { return }
      } else {
        return
      }
    }

    UserDefaults.standard.set(arrayValue, forKey: key)
    if isCloudSyncEnabled() {
      NSUbiquitousKeyValueStore.default.set(arrayValue, forKey: key)
      NSUbiquitousKeyValueStore.default.synchronize()
    }
    updateLastSyncDate()
  }

  static func persist(_ value: [String: String], for key: String) {
    let existingLocal = UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
    if existingLocal == value {
      if isCloudSyncEnabled() {
        let existingCloud = NSUbiquitousKeyValueStore.default.dictionary(forKey: key) as? [String: String] ?? [:]
        guard existingCloud != value else { return }
      } else {
        return
      }
    }

    UserDefaults.standard.set(value, forKey: key)
    if isCloudSyncEnabled() {
      NSUbiquitousKeyValueStore.default.set(value, forKey: key)
      NSUbiquitousKeyValueStore.default.synchronize()
    }
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
    if isCloudSyncEnabled() {
      NSUbiquitousKeyValueStore.default.set(now, forKey: SyncStoreKeys.lastSyncDate)
    }
  }
}
