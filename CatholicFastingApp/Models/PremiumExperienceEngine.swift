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

        let lines = [
            "Catholic Fasting Premium Summary",
            "Generated: \(formatter.string(from: date))",
            "",
            "Season",
            "- \(season.label)",
            "- Plan: \(plan.titleLine)",
            "- Focus: \(plan.focusLine)",
            "- Intensity: \(plan.fastingIntensity)",
            "",
            "Discipline Metrics",
            "- Required completion: \(analytics.requiredCompletionPercent)%",
            "- Overall completion: \(analytics.overallCompletionPercent)%",
            "- Missed observances logged: \(analytics.missedCount)",
            "- Substituted observances logged: \(analytics.substitutedCount)",
            "- Intermittent target hit rate (recent): \(analytics.intermittentTargetHitPercent)%",
            "",
            "Reminder Strategy",
            "- Daily support: \(reminder.shouldEnableDailySupport ? "On" : "Off")",
            "- Morning reminder: \(reminder.shouldEnableMorning ? "On" : "Off")",
            "- Evening reminder: \(reminder.shouldEnableEvening ? "On" : "Off")",
            "- Guidance: \(reminder.summaryLine)",
            "",
            "Reflection",
            "- \(latestReflection.title)",
            "- \(latestReflection.body)",
            "- Action: \(latestReflection.action)",
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
                "Prep: choose medically safe meals and hydration.",
                "During: prioritize stability and avoid unsafe restriction.",
                "Refeed: return to normal meals gradually as advised.",
            ]
        }

        if targetHours <= 18 {
            return [
                "Prep: hydrate and simplify your final meal.",
                "During: keep prayer cues tied to hunger moments.",
                "Refeed: break with moderate portions and protein/fiber.",
            ]
        }

        if targetHours <= 36 {
            return [
                "Prep: increase hydration the day before.",
                "During: keep intensity moderate and avoid overexertion.",
                "Refeed: start light, then full meal after 30-60 minutes.",
            ]
        }

        return [
            "Prep: plan schedule, hydration, and pastoral prudence.",
            "During: monitor energy and stop if health concerns arise.",
            "Refeed: start very gently, then normalize in stages.",
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
            case .advent: "Watch with hope"
            case .christmas: "Celebrate with gratitude"
            case .lent: "Repent with discipline"
            case .easter: "Persevere in new life"
            case .ordinary: "Stay faithful in the ordinary"
            }
        return "\(seasonPhrase) • \(template.label) rule • Streak \(streak)d"
    }
}
