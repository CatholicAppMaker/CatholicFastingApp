@preconcurrency import Foundation

struct PremiumAdaptiveRulePlan: Hashable {
    let title: String
    let summary: String
    let weeklyActions: [String]
    let caution: String
}

enum PremiumAdaptiveRulePlanner {
    static func plan(
        season: LiturgicalSeason,
        settings: RuleSettings,
        template: PremiumRuleTemplate,
        optionalDisciplinesPerWeek: Int,
        fixedFastWeekday: Int,
        protectFeastDays: Bool) -> PremiumAdaptiveRulePlan
    {
        let weekday = weekdayName(for: fixedFastWeekday)
        let baseSeasonLine =
            switch season {
            case .advent:
                "Advent emphasis: watchfulness and simplicity."
            case .christmas:
                "Christmas emphasis: grateful moderation."
            case .lent:
                "Lent emphasis: repentance and sustained sacrifice."
            case .easter:
                "Easter emphasis: preserve gains from Lent."
            case .ordinary:
                "Ordinary Time emphasis: steady fidelity."
            }

        if settings.hasMedicalDispensation {
            return PremiumAdaptiveRulePlan(
                title: "Moderated Rule of Life",
                summary: "\(baseSeasonLine) Keep food discipline medically safe and pastorally guided.",
                weeklyActions: [
                    "Anchor one stable prayer block daily.",
                    "Choose one practical charity act each week.",
                    "Use non-food substitute penance when needed.",
                ],
                caution: "Health and pastoral guidance take priority over rigor.")
        }

        let intensity = max(0, min(optionalDisciplinesPerWeek, 7))
        let templateLine = "\(template.label) template with \(intensity) optional discipline(s)/week."
        let feastLine =
            protectFeastDays
                ? "Feast/holy days switch to celebration mode automatically."
                : "Feast/holy days are shown, but your personal disciplines remain user-controlled."

        return PremiumAdaptiveRulePlan(
            title: "\(template.label) Rule Plan",
            summary: "\(baseSeasonLine) \(templateLine)",
            weeklyActions: [
                "Primary personal fast day: \(weekday).",
                "Optional disciplines this week: \(intensity).",
                "Review completion each Sunday evening and adjust the next week.",
            ],
            caution: feastLine)
    }

    private static func weekdayName(for value: Int) -> String {
        let symbols = Calendar.current.weekdaySymbols
        let index = max(1, min(7, value)) - 1
        if index < symbols.count {
            return symbols[index]
        }
        return "Friday"
    }
}
