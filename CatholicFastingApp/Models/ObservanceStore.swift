@preconcurrency import Foundation

enum LocalAnalyticsEvent: String, CaseIterable {
  case appLaunch = "app_launch"
  case onboardingCompleted = "onboarding_completed"
  case openedCalendarFocus = "opened_calendar_focus"
  case reminderPermissionRequested = "reminder_permission_requested"
  case requiredRemindersScheduled = "required_reminders_scheduled"
  case supportRemindersScheduled = "support_reminders_scheduled"
  case recoverySubstituteLogged = "recovery_substitute_logged"
  case intermittentFastStarted = "intermittent_fast_started"
}

struct LocalAnalyticsSnapshot {
  let isEnabled: Bool
  let countsByEvent: [String: Int]
  let totalEvents: Int

  func count(for event: LocalAnalyticsEvent) -> Int {
    countsByEvent[event.rawValue] ?? 0
  }
}

enum LocalAnalyticsStore {
  static let enabledKey = "allow_local_analytics"
  private static let countsKey = "local_analytics_counts"

  static func setEnabled(_ enabled: Bool) {
    UserDefaults.standard.set(enabled, forKey: enabledKey)
    if !enabled {
      UserDefaults.standard.removeObject(forKey: countsKey)
    }
  }

  static func isEnabled() -> Bool {
    UserDefaults.standard.bool(forKey: enabledKey)
  }

  static func track(_ event: LocalAnalyticsEvent) {
    guard isEnabled() else { return }
    var counts = storedCounts()
    counts[event.rawValue, default: 0] += 1
    UserDefaults.standard.set(counts, forKey: countsKey)
  }

  static func snapshot() -> LocalAnalyticsSnapshot {
    let counts = storedCounts()
    return LocalAnalyticsSnapshot(
      isEnabled: isEnabled(),
      countsByEvent: counts,
      totalEvents: counts.values.reduce(0, +)
    )
  }

  static func reset() {
    UserDefaults.standard.removeObject(forKey: countsKey)
  }

  private static func storedCounts() -> [String: Int] {
    guard let raw = UserDefaults.standard.dictionary(forKey: countsKey) else { return [:] }
    var result: [String: Int] = [:]
    for (key, value) in raw {
      if let intValue = value as? Int {
        result[key] = intValue
      } else if let numberValue = value as? NSNumber {
        result[key] = numberValue.intValue
      }
    }
    return result
  }
}
