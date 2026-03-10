import Darwin
import Dispatch
import XCTest

private let storeLockPath = "/tmp/CatholicFastingCoreTests.store.lock"

private final class StoreIsolationLock: @unchecked Sendable {
    static let shared = StoreIsolationLock()

    private let queue = DispatchQueue(label: "CatholicFastingCoreTests.store.lock")
    private var lockFD: Int32 = -1

    func lock() {
        queue.sync {
            guard lockFD == -1 else { return }
            let fd = open(storeLockPath, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
            precondition(fd >= 0, "Unable to open test store lock at \(storeLockPath)")
            let lockResult = flock(fd, LOCK_EX)
            precondition(lockResult == 0, "Unable to acquire test store lock at \(storeLockPath)")
            lockFD = fd
        }
    }

    func unlock() {
        queue.sync {
            guard lockFD >= 0 else { return }
            _ = flock(lockFD, LOCK_UN)
            _ = close(lockFD)
            lockFD = -1
        }
    }
}

extension XCTestCase {
    var syncResetKeys: [String] {
        [
            "storage_schema_version",
            "completed_observances",
            "observance_statuses",
            "friday_penance_notes",
            "last_sync_date",
            "daily_reminder_support_enabled",
            "morning_reminder_enabled",
            "evening_reminder_enabled",
            "intermittent_fast_sessions",
            "intermittent_fast_meta",
            "accepted_legal_notice",
            "accepted_legal_notice_at",
            "rule_bundle_directory_override",
            "widget_snapshot",
        ]
    }

    func resetStores() {
        for syncResetKey in syncResetKeys {
            UserDefaults.standard.removeObject(forKey: syncResetKey)
        }
    }

    func beginStoreIsolation() {
        StoreIsolationLock.shared.lock()
    }

    func endStoreIsolation() {
        StoreIsolationLock.shared.unlock()
    }
}
