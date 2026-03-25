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
                title: "Recovery Stable",
                summary: "No current missed-day alert. Stay proactive this week.",
                steps: [
                    "Review the next required observance date.",
                    "Keep your fixed personal fast day.",
                    "Close today with a one-minute examen.",
                ])
        }

        let seasonalAction =
            switch season {
            case .lent: "Pair recovery with concrete almsgiving."
            case .advent: "Pair recovery with quiet watchfulness prayer."
            case .easter: "Pair recovery with one mercy action."
            case .christmas: "Pair recovery with gratitude prayer after meals."
            case .ordinary: "Pair recovery with faithful Friday penance."
            }

        return PremiumRecoveryCoachPlan(
            title: missedPlan.titleLine,
            summary: "\(missedPlan.summaryLine) \(seasonalAction)",
            steps: missedPlan.steps + [missedPlan.nextRequiredLine])
    }
}
