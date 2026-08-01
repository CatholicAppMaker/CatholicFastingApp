@preconcurrency import Foundation

enum PremiumDirectionSummaryEngine {
    static func summaryText(
        date: Date = AppClock.now(),
        season: LiturgicalSeason,
        analytics: PremiumAnalyticsSummary,
        reminder: PremiumReminderRecommendation,
        plan: PremiumSeasonPlan,
        latestReflection: PremiumReflection) -> String
    {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = CoreLocalizer.currentLocale()

        let enabledLabel = CoreLocalizer.localizedCurrent("shared.on", default: "On")
        let disabledLabel = CoreLocalizer.localizedCurrent("shared.off", default: "Off")
        let personalFastTargetHitRate = CoreLocalizer.localizedCurrentFormat(
            "premium.summary.metrics.personal_fast",
            default: "Personal fast targets met (recent): %d%%",
            analytics.intermittentTargetHitPercent)
        let dailySupportLabel = CoreLocalizer.localizedCurrentFormat(
            "premium.summary.reminders.daily_support",
            default: "Daily support: %@",
            reminder.shouldEnableDailySupport ? enabledLabel : disabledLabel)
        let morningReminderLabel = CoreLocalizer.localizedCurrentFormat(
            "premium.summary.reminders.morning",
            default: "Morning reminder: %@",
            reminder.shouldEnableMorning ? enabledLabel : disabledLabel)
        let eveningReminderLabel = CoreLocalizer.localizedCurrentFormat(
            "premium.summary.reminders.evening",
            default: "Evening reminder: %@",
            reminder.shouldEnableEvening ? enabledLabel : disabledLabel)
        let lines = [
            CoreLocalizer.localizedCurrent(
                "premium.summary.title",
                default: "Catholic Fasting Premium Summary"),
            CoreLocalizer.localizedCurrentFormat(
                "premium.summary.generated",
                default: "Generated: %@",
                formatter.string(from: date)),
            "",
            CoreLocalizer.localizedCurrent("premium.summary.season.heading", default: "Season"),
            "- \(season.label)",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.plan", default: "Plan: %@", plan.titleLine))",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.focus", default: "Focus: %@", plan.focusLine))",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.intensity", default: "Intensity: %@", plan.fastingIntensity))",
            "",
            CoreLocalizer.localizedCurrent("premium.summary.metrics.heading", default: "Discipline Metrics"),
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.metrics.required", default: "Required completion: %d%%", analytics.requiredCompletionPercent))",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.metrics.overall", default: "Overall completion: %d%%", analytics.overallCompletionPercent))",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.metrics.missed", default: "Missed observances logged: %d", analytics.missedCount))",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.metrics.substituted", default: "Substituted observances logged: %d", analytics.substitutedCount))",
            "- \(personalFastTargetHitRate)",
            "",
            CoreLocalizer.localizedCurrent("premium.summary.reminders.heading", default: "Reminder Strategy"),
            "- \(dailySupportLabel)",
            "- \(morningReminderLabel)",
            "- \(eveningReminderLabel)",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.reminders.guidance", default: "Guidance: %@", reminder.summaryLine))",
            "",
            CoreLocalizer.localizedCurrent("premium.summary.reflection.heading", default: "Reflection"),
            "- \(latestReflection.title)",
            "- \(latestReflection.body)",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.reflection.action", default: "Action: %@", latestReflection.action))",
        ]
        return lines.joined(separator: "\n")
    }
}

enum PremiumMotivationEngine {
    static func line(
        season: LiturgicalSeason,
        streak: Int,
        template: PremiumRuleTemplate) -> String
    {
        let seasonPhrase =
            switch season {
            case .advent:
                CoreLocalizer.localizedCurrent("premium.motivation.advent", default: "Watch with hope")
            case .christmas:
                CoreLocalizer.localizedCurrent("premium.motivation.christmas", default: "Celebrate with gratitude")
            case .lent:
                CoreLocalizer.localizedCurrent("premium.motivation.lent", default: "Repent with discipline")
            case .easter:
                CoreLocalizer.localizedCurrent("premium.motivation.easter", default: "Persevere in new life")
            case .ordinary:
                CoreLocalizer.localizedCurrent("premium.motivation.ordinary", default: "Stay faithful in the ordinary")
            }
        return CoreLocalizer.localizedCurrentFormat(
            "premium.motivation.line",
            default: "%@ • %@ rule • Streak %dd",
            seasonPhrase,
            template.label,
            streak)
    }
}
