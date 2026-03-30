@preconcurrency import Foundation

enum PremiumDirectionSummaryEngine {
    static func summaryText(
        date: Date = Date(),
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
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.metrics.intermittent", default: "Intermittent target hit rate (recent): %d%%", analytics.intermittentTargetHitPercent))",
            "",
            CoreLocalizer.localizedCurrent("premium.summary.reminders.heading", default: "Reminder Strategy"),
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.reminders.daily_support", default: "Daily support: %@", reminder.shouldEnableDailySupport ? CoreLocalizer.localizedCurrent("shared.on", default: "On") : CoreLocalizer.localizedCurrent("shared.off", default: "Off")))",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.reminders.morning", default: "Morning reminder: %@", reminder.shouldEnableMorning ? CoreLocalizer.localizedCurrent("shared.on", default: "On") : CoreLocalizer.localizedCurrent("shared.off", default: "Off")))",
            "- \(CoreLocalizer.localizedCurrentFormat("premium.summary.reminders.evening", default: "Evening reminder: %@", reminder.shouldEnableEvening ? CoreLocalizer.localizedCurrent("shared.on", default: "On") : CoreLocalizer.localizedCurrent("shared.off", default: "Off")))",
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

enum PremiumFastPrepGuidanceEngine {
    static func prepAndRefeed(
        targetHours: Int,
        hasMedicalDispensation: Bool) -> [String]
    {
        if hasMedicalDispensation {
            return [
                CoreLocalizer.localizedCurrent(
                    "premium.fastprep.medical.prep",
                    default: "Prep: choose medically safe meals and hydration."),
                CoreLocalizer.localizedCurrent(
                    "premium.fastprep.medical.during",
                    default: "During: prioritize stability and avoid unsafe restriction."),
                CoreLocalizer.localizedCurrent(
                    "premium.fastprep.medical.refeed",
                    default: "Refeed: return to normal meals gradually as advised."),
            ]
        }

        if targetHours <= 18 {
            return [
                CoreLocalizer.localizedCurrent(
                    "premium.fastprep.short.prep",
                    default: "Prep: hydrate and simplify your final meal."),
                CoreLocalizer.localizedCurrent(
                    "premium.fastprep.short.during",
                    default: "During: keep prayer cues tied to hunger moments."),
                CoreLocalizer.localizedCurrent(
                    "premium.fastprep.short.refeed",
                    default: "Refeed: break with moderate portions and protein/fiber."),
            ]
        }

        if targetHours <= 36 {
            return [
                CoreLocalizer.localizedCurrent(
                    "premium.fastprep.medium.prep",
                    default: "Prep: increase hydration the day before."),
                CoreLocalizer.localizedCurrent(
                    "premium.fastprep.medium.during",
                    default: "During: keep intensity moderate and avoid overexertion."),
                CoreLocalizer.localizedCurrent(
                    "premium.fastprep.medium.refeed",
                    default: "Refeed: start light, then full meal after 30-60 minutes."),
            ]
        }

        return [
            CoreLocalizer.localizedCurrent(
                "premium.fastprep.long.prep",
                default: "Prep: plan schedule, hydration, and pastoral prudence."),
            CoreLocalizer.localizedCurrent(
                "premium.fastprep.long.during",
                default: "During: monitor energy and stop if health concerns arise."),
            CoreLocalizer.localizedCurrent(
                "premium.fastprep.long.refeed",
                default: "Refeed: start very gently, then normalize in stages."),
        ]
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
