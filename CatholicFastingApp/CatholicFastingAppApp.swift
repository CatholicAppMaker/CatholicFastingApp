import SwiftUI
#if canImport(UIKit)
  import UIKit
#endif
import os

@main
struct CatholicFastingAppApp: App {
  @Environment(\.scenePhase) private var scenePhase

  init() {
    UITestBootstrap.applyLaunchOverridesIfNeeded()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .preferredColorScheme(.light)
        .task {
          SeasonalIconManager.applyForCurrentSeasonIfNeeded()
        }
    }
    .onChange(of: scenePhase) { _, newPhase in
      guard newPhase == .active else { return }
      SeasonalIconManager.applyForCurrentSeasonIfNeeded()
    }
  }
}

private enum SeasonalIconManager {
  private static let logger = Logger(subsystem: "com.kevpierce.CatholicFastingApp", category: "Icon")

  static func applyForCurrentSeasonIfNeeded() {
    #if canImport(UIKit)
      guard ProcessInfo.processInfo.environment["UITEST_MODE"] != "1" else { return }
      guard UIApplication.shared.supportsAlternateIcons else { return }

      let seasonModeEnabled =
        UserDefaults.standard.object(forKey: StorageKeys.liturgicalSeasonColorsEnabled) == nil
        ? true
        : UserDefaults.standard.bool(forKey: StorageKeys.liturgicalSeasonColorsEnabled)
      let season = LiturgicalSeasonThemeEngine.season(for: Date())
      let target = iconName(for: seasonModeEnabled ? season : .ordinary)
      guard UIApplication.shared.alternateIconName != target else { return }

      UIApplication.shared.setAlternateIconName(target) { error in
        if let error {
          logger.error("Seasonal icon update failed: \(error.localizedDescription)")
        }
      }
    #endif
  }

  static func iconName(for season: LiturgicalSeason) -> String? {
    switch season {
    case .ordinary:
      return nil
    case .advent:
      return "AppIconAdvent"
    case .christmas:
      return "AppIconChristmas"
    case .lent:
      return "AppIconLent"
    case .easter:
      return "AppIconEaster"
    }
  }
}

private enum UITestBootstrap {
  static func applyLaunchOverridesIfNeeded() {
    let arguments = ProcessInfo.processInfo.arguments
    let environment = ProcessInfo.processInfo.environment
    let isUITestMode =
      arguments.contains("-uitest-reset")
      || arguments.contains("-uitest-skip-onboarding")
      || arguments.contains("-uitest-seed-deterministic")
      || arguments.contains("-uitest-seed-missed")
      || arguments.contains("-uitest-disable-animations")
      || environment["UITEST_MODE"] == "1"

    guard isUITestMode else {
      return
    }

    let defaults = UserDefaults.standard
    if arguments.contains("-uitest-reset") {
      [
        "birth_year",
        "birth_month",
        "birth_day",
        "age_14_or_older_for_abstinence",
        "age_18_or_older_for_fasting",
        "medical_dispensation",
        "ascension_observance",
        "friday_outside_lent_mode",
        "us_province_preset",
        "calendar_mode",
        "language_mode",
        "did_complete_onboarding",
        "accepted_legal_notice",
        "accepted_legal_notice_at",
        "liturgical_season_colors_enabled",
        "daily_reminder_support_enabled",
        "morning_reminder_enabled",
        "evening_reminder_enabled",
        "intermittent_fast_sessions",
        "intermittent_fast_meta",
        "rule_bundle_directory_override",
        "storage_schema_version",
        "completed_observances",
        "observance_statuses",
        "friday_penance_notes",
        "last_sync_date",
      ].forEach { key in
        defaults.removeObject(forKey: key)
      }
    }

    if arguments.contains("-uitest-seed-deterministic") {
      defaults.set(0, forKey: "birth_year")
      defaults.set(0, forKey: "birth_month")
      defaults.set(0, forKey: "birth_day")
      defaults.set(true, forKey: "age_14_or_older_for_abstinence")
      defaults.set(true, forKey: "age_18_or_older_for_fasting")
      defaults.set(false, forKey: "medical_dispensation")
      defaults.set("sunday", forKey: "ascension_observance")
      defaults.set("substitutePenance", forKey: "friday_outside_lent_mode")
      defaults.set("otherUSProvince", forKey: "us_province_preset")
      defaults.set("usccb", forKey: "calendar_mode")
      defaults.set("english", forKey: "language_mode")
      defaults.set(false, forKey: "accepted_legal_notice")
      defaults.set("", forKey: "accepted_legal_notice_at")
      defaults.set(true, forKey: "liturgical_season_colors_enabled")
      defaults.set(true, forKey: "daily_reminder_support_enabled")
      defaults.set(true, forKey: "morning_reminder_enabled")
      defaults.set(false, forKey: "evening_reminder_enabled")
      defaults.set([String: String](), forKey: "intermittent_fast_sessions")
      defaults.set(["preset_hours": "16"], forKey: "intermittent_fast_meta")
      defaults.set(3, forKey: "storage_schema_version")
    }

    if arguments.contains("-uitest-seed-missed") {
      let settings = RuleSettings(
        birthYear: 0,
        birthMonth: 0,
        birthDay: 0,
        isAge14OrOlderForAbstinence: true,
        isAge18OrOlderForFasting: true,
        hasMedicalDispensation: false,
        ascensionObservance: .sunday,
        fridayOutsideLentMode: .substitutePenance,
        calendarMode: .usccb
      )
      let year = Calendar.current.component(.year, from: Date())
      let observances = ObservanceCalculator.makeCalendar(for: year, settings: settings)
      let today = Calendar.current.startOfDay(for: Date())
      let missedTarget =
        observances.last(where: {
          $0.obligation == .mandatory
            && Calendar.current.startOfDay(for: $0.date) <= today
        })
        ?? observances.first(where: { $0.obligation == .mandatory })

      if let missedTarget {
        defaults.set([missedTarget.id: CompletionStatus.missed.rawValue], forKey: "observance_statuses")
      }
    }

    if arguments.contains("-uitest-skip-onboarding") {
      defaults.set(true, forKey: "did_complete_onboarding")
    } else if arguments.contains("-uitest-seed-deterministic") {
      defaults.set(false, forKey: "did_complete_onboarding")
    }

    if arguments.contains("-uitest-disable-animations") {
      #if canImport(UIKit)
        UIView.setAnimationsEnabled(false)
      #endif
    }
  }
}
