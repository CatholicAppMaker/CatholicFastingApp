@preconcurrency import Foundation

enum ObservanceQueryEngine {
    static func filter(
        observances: [Observance],
        query: String,
        filter: ObservanceFilter,
        window: CalendarWindow,
        sortOrder: ObservanceSortOrder,
        statusesByID: [String: CompletionStatus],
        now: Date,
        calendar: Calendar = .current) -> [Observance]
    {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let startOfToday = calendar.startOfDay(for: now)
        let endOfNext30Days = calendar.date(byAdding: .day, value: 30, to: startOfToday)
        let filtered = observances.filter { observance in
            guard matchesFilter(observance, filter: filter, statusesByID: statusesByID) else {
                return false
            }
            guard
                matchesWindow(
                    observance, window: window, startOfToday: startOfToday, endOfNext30Days: endOfNext30Days,
                    calendar: calendar)
            else { return false }
            guard matchesQuery(observance, query: normalizedQuery) else { return false }
            return true
        }
        return filtered.sorted(by: sortPredicate(order: sortOrder))
    }

    private static func matchesFilter(
        _ observance: Observance,
        filter: ObservanceFilter,
        statusesByID: [String: CompletionStatus]) -> Bool
    {
        switch filter {
        case .all:
            true
        case .requiredOnly:
            observance.obligation == .mandatory
        case .trackedOnly:
            (statusesByID[observance.id] ?? .notStarted) != .notStarted
        }
    }

    private static func matchesWindow(
        _ observance: Observance,
        window: CalendarWindow,
        startOfToday: Date,
        endOfNext30Days: Date?,
        calendar: Calendar) -> Bool
    {
        switch window {
        case .allYear:
            return true
        case .thisMonth:
            return calendar.isDate(observance.date, equalTo: startOfToday, toGranularity: .month)
                && calendar.isDate(observance.date, equalTo: startOfToday, toGranularity: .year)
        case .next30Days:
            guard let endOfNext30Days else { return false }
            let day = calendar.startOfDay(for: observance.date)
            return day >= startOfToday && day <= endOfNext30Days
        }
    }

    private static func matchesQuery(_ observance: Observance, query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return observance.title.localizedCaseInsensitiveContains(query)
            || observance.kind.label.localizedCaseInsensitiveContains(query)
            || observance.obligation.label.localizedCaseInsensitiveContains(query)
            || (observance.detail?.localizedCaseInsensitiveContains(query) ?? false)
    }

    private static func sortPredicate(order: ObservanceSortOrder) -> (Observance, Observance) -> Bool {
        switch order {
        case .chronological:
            { lhs, rhs in
                lhs.date == rhs.date ? lhs.title < rhs.title : lhs.date < rhs.date
            }
        case .requiredFirst:
            { lhs, rhs in
                let lhsRank = obligationRank(lhs.obligation)
                let rhsRank = obligationRank(rhs.obligation)
                if lhsRank == rhsRank {
                    return lhs.date == rhs.date ? lhs.title < rhs.title : lhs.date < rhs.date
                }
                return lhsRank < rhsRank
            }
        }
    }

    private static func obligationRank(_ obligation: Observance.Obligation) -> Int {
        switch obligation {
        case .mandatory:
            0
        case .optional:
            1
        case .notApplicable:
            2
        }
    }
}
