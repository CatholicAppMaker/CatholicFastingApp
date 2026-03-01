@preconcurrency import Foundation
import SwiftUI

enum CompletionStatus: String, CaseIterable, Identifiable {
  case notStarted
  case completed
  case substituted
  case dispensed
  case missed

  var id: String {
    rawValue
  }

  var label: String {
    switch self {
    case .notStarted:
      return "Not Started"
    case .completed:
      return "Completed"
    case .substituted:
      return "Substituted"
    case .dispensed:
      return "Dispensed"
    case .missed:
      return "Missed"
    }
  }

  var countsTowardProgress: Bool {
    self == .completed || self == .substituted || self == .dispensed
  }
}

final class FastTracker: ObservableObject {
  @Published private(set) var statusesByID: [String: CompletionStatus]

  private let syncKey = SyncStoreKeys.observanceStatuses

  init() {
    StorageSchema.migrateIfNeeded()
    statusesByID = SyncedStore.mergedStatusDictionary(for: syncKey)
    SyncedStore.persist(statusesByID, for: syncKey)
  }

  var completedIDs: Set<String> {
    Set(
      statusesByID.compactMap { id, status in
        status.countsTowardProgress ? id : nil
      }
    )
  }

  func status(for id: String) -> CompletionStatus {
    statusesByID[id] ?? .notStarted
  }

  func isCompleted(_ id: String) -> Bool {
    status(for: id) == .completed
  }

  func setStatus(_ status: CompletionStatus, for id: String) {
    if status == .notStarted {
      statusesByID.removeValue(forKey: id)
    } else {
      statusesByID[id] = status
    }
    SyncedStore.persist(statusesByID, for: syncKey)
  }

  func toggle(_ id: String) {
    let next: CompletionStatus = status(for: id) == .completed ? .notStarted : .completed
    setStatus(next, for: id)
  }

  func clearAll() {
    statusesByID.removeAll()
    SyncedStore.persist(statusesByID, for: syncKey)
  }

  func exportPayload() -> [String] {
    Array(completedIDs).sorted()
  }

  func exportStatusPayload() -> [String: String] {
    statusesByID
      .mapValues(\.rawValue)
  }
}

extension FastTracker: @unchecked Sendable {}
