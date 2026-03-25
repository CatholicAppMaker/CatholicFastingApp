@preconcurrency import Foundation

struct PremiumSeasonCompletionRow: Hashable, Identifiable {
    let id: String
    let season: LiturgicalSeason
    let completedCount: Int
    let totalCount: Int

    var completionPercent: Int {
        guard totalCount > 0 else { return 0 }
        let rate = (Double(completedCount) / Double(totalCount)) * 100
        return Int(rate.rounded())
    }
}

struct PremiumAnalyticsSummary: Hashable {
    let requiredCompletionPercent: Int
    let overallCompletionPercent: Int
    let missedCount: Int
    let substitutedCount: Int
    let intermittentTargetHitPercent: Int
    let seasonRows: [PremiumSeasonCompletionRow]
}

enum PremiumAnalyticsEngine {
    static func summary(
        observances: [Observance],
        statusesByID: [String: CompletionStatus],
        sessions: [IntermittentFastSession]) -> PremiumAnalyticsSummary
    {
        let required = observances.filter { $0.obligation == .mandatory }
        let actionable = observances.filter { $0.obligation != .notApplicable }

        let requiredCompleted = required.count(where: { statusesByID[$0.id]?.countsTowardProgress == true })
        let actionableCompleted = actionable.count(where: { statusesByID[$0.id]?.countsTowardProgress == true })
        let missedCount = statusesByID.values.count(where: { $0 == .missed })
        let substitutedCount = statusesByID.values.count(where: { $0 == .substituted })

        let recentSessions = sessions.prefix(30)
        let hitTarget = recentSessions.filter(\.completedTarget).count
        let intermittentHitPercent =
            recentSessions.isEmpty ? 0 : Int((Double(hitTarget) / Double(recentSessions.count) * 100).rounded())

        var seasonalTotals: [LiturgicalSeason: (done: Int, total: Int)] = [:]
        for item in actionable {
            let season = LiturgicalSeasonThemeEngine.season(for: item.date)
            var entry = seasonalTotals[season] ?? (done: 0, total: 0)
            entry.total += 1
            if statusesByID[item.id]?.countsTowardProgress == true {
                entry.done += 1
            }
            seasonalTotals[season] = entry
        }

        let orderedSeasons: [LiturgicalSeason] = [.advent, .christmas, .lent, .easter, .ordinary]
        let rows = orderedSeasons.compactMap { season -> PremiumSeasonCompletionRow? in
            guard let data = seasonalTotals[season] else { return nil }
            return PremiumSeasonCompletionRow(
                id: season.rawValue,
                season: season,
                completedCount: data.done,
                totalCount: data.total)
        }

        return PremiumAnalyticsSummary(
            requiredCompletionPercent: percent(done: requiredCompleted, total: required.count),
            overallCompletionPercent: percent(done: actionableCompleted, total: actionable.count),
            missedCount: missedCount,
            substitutedCount: substitutedCount,
            intermittentTargetHitPercent: intermittentHitPercent,
            seasonRows: rows)
    }

    private static func percent(done: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(done) / Double(total) * 100).rounded())
    }
}
