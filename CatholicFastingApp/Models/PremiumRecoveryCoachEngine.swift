@preconcurrency import Foundation

struct PremiumRecoveryCoachPlan: Hashable {
    let title: String
    let summary: String
    let steps: [String]
}

enum PremiumRecoveryCoachEngine {
    static func plan(
        missedPlan: MissedDayRecoveryPlan?,
        season: LiturgicalSeason) -> PremiumRecoveryCoachPlan
    {
        guard let missedPlan else {
            return PremiumRecoveryCoachPlan(
                title: CoreLocalizer.localizedCurrent("premium.recovery.stable.title", default: "Recovery Stable"),
                summary: CoreLocalizer.localizedCurrent(
                    "premium.recovery.stable.summary",
                    default: "No current missed-day alert. Stay proactive this week."),
                steps: [
                    CoreLocalizer.localizedCurrent(
                        "premium.recovery.stable.step1",
                        default: "Review the next required observance date."),
                    CoreLocalizer.localizedCurrent(
                        "premium.recovery.stable.step2",
                        default: "Keep your fixed personal fast day."),
                    CoreLocalizer.localizedCurrent(
                        "premium.recovery.stable.step3",
                        default: "Close today with a one-minute examen."),
                ])
        }

        let seasonalAction =
            switch season {
            case .lent:
                CoreLocalizer.localizedCurrent(
                    "premium.recovery.seasonal.lent",
                    default: "Pair recovery with concrete almsgiving.")
            case .advent:
                CoreLocalizer.localizedCurrent(
                    "premium.recovery.seasonal.advent",
                    default: "Pair recovery with quiet watchfulness prayer.")
            case .easter:
                CoreLocalizer.localizedCurrent(
                    "premium.recovery.seasonal.easter",
                    default: "Pair recovery with one mercy action.")
            case .christmas:
                CoreLocalizer.localizedCurrent(
                    "premium.recovery.seasonal.christmas",
                    default: "Pair recovery with gratitude prayer after meals.")
            case .ordinary:
                CoreLocalizer.localizedCurrent(
                    "premium.recovery.seasonal.ordinary",
                    default: "Pair recovery with faithful Friday penance.")
            }

        return PremiumRecoveryCoachPlan(
            title: missedPlan.titleLine,
            summary: "\(missedPlan.summaryLine) \(seasonalAction)",
            steps: missedPlan.steps + [missedPlan.nextRequiredLine])
    }
}
