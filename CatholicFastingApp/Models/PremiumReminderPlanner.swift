@preconcurrency import Foundation

struct PremiumReminderRecommendation: Hashable {
    let shouldEnableDailySupport: Bool
    let shouldEnableMorning: Bool
    let shouldEnableEvening: Bool
    let summaryLine: String
}

enum PremiumReminderPlanner {
    static func recommendation(
        observances: [Observance],
        statusesByID: [String: CompletionStatus],
        now: Date = Date(),
        calendar: Calendar = .current) -> PremiumReminderRecommendation
    {
        let startOfToday = calendar.startOfDay(for: now)
        let recentWindowStart = calendar.date(byAdding: .day, value: -30, to: startOfToday) ?? startOfToday
        let upcomingWindowEnd = calendar.date(byAdding: .day, value: 14, to: startOfToday) ?? startOfToday

        let recent = observances.filter { item in
            let day = calendar.startOfDay(for: item.date)
            return day >= recentWindowStart && day <= startOfToday && item.obligation != .notApplicable
        }
        let upcomingRequired = observances.filter { item in
            let day = calendar.startOfDay(for: item.date)
            return day >= startOfToday && day <= upcomingWindowEnd && item.obligation == .mandatory
        }

        let completedRecent = recent.count(where: { statusesByID[$0.id]?.countsTowardProgress == true })
        let missedRecent = recent.count(where: { statusesByID[$0.id] == .missed })
        let completionRate =
            recent.isEmpty ? 1.0 : Double(completedRecent) / Double(recent.count)

        if missedRecent >= 2 || completionRate < 0.65 {
            return PremiumReminderRecommendation(
                shouldEnableDailySupport: true,
                shouldEnableMorning: true,
                shouldEnableEvening: true,
                summaryLine: CoreLocalizer.localizedCurrent(
                    "premium.reminder.recovery.summary",
                    default: "Recovery mode: enable both morning and evening reminders for the next 2 weeks."))
        }

        if !upcomingRequired.isEmpty {
            return PremiumReminderRecommendation(
                shouldEnableDailySupport: true,
                shouldEnableMorning: true,
                shouldEnableEvening: false,
                summaryLine: CoreLocalizer.localizedCurrent(
                    "premium.reminder.preparation.summary",
                    default: "Preparation mode: keep morning reminders on for upcoming required observances."))
        }

        return PremiumReminderRecommendation(
            shouldEnableDailySupport: true,
            shouldEnableMorning: false,
            shouldEnableEvening: true,
            summaryLine: CoreLocalizer.localizedCurrent(
                "premium.reminder.maintenance.summary",
                default: "Maintenance mode: evening examen reminders are enough for your current rhythm."))
    }
}

enum PremiumConditionReminderAdvisor {
    static func applyRules(
        _ rules: PremiumConditionRules,
        hasUpcomingRequiredDays: Bool) -> PremiumReminderRecommendation
    {
        if rules.requiredDaysDoubleReminder, hasUpcomingRequiredDays {
            return PremiumReminderRecommendation(
                shouldEnableDailySupport: true,
                shouldEnableMorning: true,
                shouldEnableEvening: true,
                summaryLine: CoreLocalizer.localizedCurrent(
                    "premium.reminder.condition.required_double",
                    default: "Condition rules enabled: required-day double reminders are active."))
        }
        if rules.remindIfUnloggedByNoon {
            return PremiumReminderRecommendation(
                shouldEnableDailySupport: true,
                shouldEnableMorning: true,
                shouldEnableEvening: false,
                summaryLine: CoreLocalizer.localizedCurrent(
                    "premium.reminder.condition.noon_recovery",
                    default: "Condition rules enabled: noon check-in recovery reminders are active."))
        }
        return PremiumReminderRecommendation(
            shouldEnableDailySupport: true,
            shouldEnableMorning: false,
            shouldEnableEvening: true,
            summaryLine: CoreLocalizer.localizedCurrent(
                "premium.reminder.condition.evening_examen",
                default: "Condition rules enabled: evening examen support is active."))
    }
}
