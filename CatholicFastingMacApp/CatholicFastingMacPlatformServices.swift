import AppKit
import Foundation

@MainActor
protocol ReminderPlatformServicing {
    func requestPermission() async -> String
    func topUpRequiredReminders(observances: [Observance]) async -> String?
    func notificationSummary() async -> String
    func scheduleHabitSupport(morning: Bool, evening: Bool) async -> String
    func scheduleDailyQuoteReminder(
        enabled: Bool,
        hour: Int,
        minute: Int,
        languageMode: LanguageMode) async -> String
    func scheduleIntermittentPlan(_ plan: IntermittentSchedulePlan) async -> String
    func notificationsAuthorizedForScheduling() async -> Bool
    func pendingDailyQuoteReminderCount() async -> Int
}

struct SystemReminderPlatformService: ReminderPlatformServicing {
    func requestPermission() async -> String {
        await ReminderScheduler.requestPermission()
    }

    func topUpRequiredReminders(observances: [Observance]) async -> String? {
        await ReminderScheduler.topUpRequiredReminders(observances: observances)
    }

    func notificationSummary() async -> String {
        await ReminderScheduler.notificationSummary()
    }

    func scheduleHabitSupport(morning: Bool, evening: Bool) async -> String {
        await ReminderScheduler.scheduleHabitSupport(morning: morning, evening: evening)
    }

    func scheduleDailyQuoteReminder(
        enabled: Bool,
        hour: Int,
        minute: Int,
        languageMode: LanguageMode) async -> String
    {
        await ReminderScheduler.scheduleDailyQuoteReminder(
            enabled: enabled,
            hour: hour,
            minute: minute,
            languageMode: languageMode)
    }

    func scheduleIntermittentPlan(_ plan: IntermittentSchedulePlan) async -> String {
        await ReminderScheduler.scheduleIntermittentPlan(plan)
    }

    func notificationsAuthorizedForScheduling() async -> Bool {
        await ReminderScheduler.notificationsAuthorizedForScheduling()
    }

    func pendingDailyQuoteReminderCount() async -> Int {
        await ReminderScheduler.pendingDailyQuoteReminderCount()
    }
}

@MainActor
protocol SharePayloadPlatformServicing {
    func copy(_ text: String)
}

struct MacSharePayloadService: SharePayloadPlatformServicing {
    func copy(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

@MainActor
protocol ActiveFastStatusSurfaceServicing {
    func menuBarTitle(for tracker: IntermittentFastTracker) -> String
    func menuBarSubtitle(for tracker: IntermittentFastTracker, locale: Locale) -> String
}

struct DefaultActiveFastStatusSurfaceService: ActiveFastStatusSurfaceServicing {
    func menuBarTitle(for tracker: IntermittentFastTracker) -> String {
        if tracker.activeStart != nil {
            return "Fast Active"
        }
        return "Catholic Fasting"
    }

    func menuBarSubtitle(for tracker: IntermittentFastTracker, locale: Locale) -> String {
        guard let activeStart = tracker.activeStart else {
            return "No active intermittent fast"
        }
        let elapsed = Date().timeIntervalSince(activeStart)
        let hours = max(0, Int(elapsed / 3600))
        let minutes = max(0, Int((elapsed.truncatingRemainder(dividingBy: 3600)) / 60))
        return "\(hours)h \(minutes)m of \(tracker.presetHours)h goal"
    }
}

@MainActor
protocol SeasonalAppearancePlatformServicing {
    func handleSceneDidBecomeActive() async
}

struct MacSeasonalAppearancePlatformService: SeasonalAppearancePlatformServicing {
    func handleSceneDidBecomeActive() async {}
}

@MainActor
struct CatholicFastingMacPlatformServices {
    let reminders: ReminderPlatformServicing
    let sharing: SharePayloadPlatformServicing
    let activeFastStatus: ActiveFastStatusSurfaceServicing
    let seasonalAppearance: SeasonalAppearancePlatformServicing

    static let live = CatholicFastingMacPlatformServices(
        reminders: SystemReminderPlatformService(),
        sharing: MacSharePayloadService(),
        activeFastStatus: DefaultActiveFastStatusSurfaceService(),
        seasonalAppearance: MacSeasonalAppearancePlatformService())
}
