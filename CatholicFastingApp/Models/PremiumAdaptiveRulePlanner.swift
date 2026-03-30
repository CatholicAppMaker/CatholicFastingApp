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
                CoreLocalizer.localizedCurrent(
                    "premium.adaptive.season.advent",
                    default: "Advent emphasis: watchfulness and simplicity.")
            case .christmas:
                CoreLocalizer.localizedCurrent(
                    "premium.adaptive.season.christmas",
                    default: "Christmas emphasis: grateful moderation.")
            case .lent:
                CoreLocalizer.localizedCurrent(
                    "premium.adaptive.season.lent",
                    default: "Lent emphasis: repentance and sustained sacrifice.")
            case .easter:
                CoreLocalizer.localizedCurrent(
                    "premium.adaptive.season.easter",
                    default: "Easter emphasis: preserve gains from Lent.")
            case .ordinary:
                CoreLocalizer.localizedCurrent(
                    "premium.adaptive.season.ordinary",
                    default: "Ordinary Time emphasis: steady fidelity.")
            }

        if settings.hasMedicalDispensation {
            return PremiumAdaptiveRulePlan(
                title: CoreLocalizer.localizedCurrent(
                    "premium.adaptive.moderated.title",
                    default: "Moderated Rule of Life"),
                summary: CoreLocalizer.localizedCurrentFormat(
                    "premium.adaptive.moderated.summary",
                    default: "%@ Keep food discipline medically safe and pastorally guided.",
                    baseSeasonLine),
                weeklyActions: [
                    CoreLocalizer.localizedCurrent(
                        "premium.adaptive.moderated.step1",
                        default: "Anchor one stable prayer block daily."),
                    CoreLocalizer.localizedCurrent(
                        "premium.adaptive.moderated.step2",
                        default: "Choose one practical charity act each week."),
                    CoreLocalizer.localizedCurrent(
                        "premium.adaptive.moderated.step3",
                        default: "Use non-food substitute penance when needed."),
                ],
                caution: CoreLocalizer.localizedCurrent(
                    "premium.adaptive.moderated.caution",
                    default: "Health and pastoral guidance take priority over rigor."))
        }

        let intensity = max(0, min(optionalDisciplinesPerWeek, 7))
        let templateLine = CoreLocalizer.localizedCurrentFormat(
            "premium.adaptive.template_line",
            default: "%@ template with %d optional discipline(s)/week.",
            template.label,
            intensity)
        let feastLine =
            protectFeastDays
                ? CoreLocalizer.localizedCurrent(
                    "premium.adaptive.feast.protected",
                    default: "Feast/holy days switch to celebration mode automatically.")
                : CoreLocalizer.localizedCurrent(
                    "premium.adaptive.feast.unprotected",
                    default: "Feast/holy days are shown, but your personal disciplines remain user-controlled.")

        return PremiumAdaptiveRulePlan(
            title: CoreLocalizer.localizedCurrentFormat(
                "premium.adaptive.plan.title",
                default: "%@ Rule Plan",
                template.label),
            summary: "\(baseSeasonLine) \(templateLine)",
            weeklyActions: [
                CoreLocalizer.localizedCurrentFormat(
                    "premium.adaptive.plan.step1",
                    default: "Primary personal fast day: %@.",
                    weekday),
                CoreLocalizer.localizedCurrentFormat(
                    "premium.adaptive.plan.step2",
                    default: "Optional disciplines this week: %d.",
                    intensity),
                CoreLocalizer.localizedCurrent(
                    "premium.adaptive.plan.step3",
                    default: "Review completion each Sunday evening and adjust the next week."),
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
