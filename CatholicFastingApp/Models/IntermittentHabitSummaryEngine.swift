@preconcurrency import Foundation

struct IntermittentHabitSummary: Hashable {
    let currentStreakDays: Int
    let bestStreakDays: Int
    let weeklySessionCount: Int
    let monthlySessionCount: Int
    let targetHitPercent: Int
    let longestDuration: TimeInterval
    let latestSessionRecap: IntermittentFastSessionRecap?
}

enum IntermittentHabitSummaryEngine {
    static func summary(
        sessions: [IntermittentFastSession],
        now: Date = Date(),
        calendar: Calendar = .current) -> IntermittentHabitSummary
    {
        let sortedSessions = sessions.sorted { $0.end > $1.end }
        let weeklyStart = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let monthlyStart = calendar.date(byAdding: .day, value: -30, to: now) ?? now
        let completedTargets = sortedSessions.count(where: \.completedTarget)
        let targetHitPercent =
            sortedSessions.isEmpty
                ? 0
                : Int((Double(completedTargets) / Double(sortedSessions.count) * 100).rounded())

        return IntermittentHabitSummary(
            currentStreakDays: currentStreakDays(for: sortedSessions, calendar: calendar),
            bestStreakDays: bestStreakDays(for: sortedSessions, calendar: calendar),
            weeklySessionCount: sortedSessions.count { $0.end >= weeklyStart && $0.end <= now },
            monthlySessionCount: sortedSessions.count { $0.end >= monthlyStart && $0.end <= now },
            targetHitPercent: targetHitPercent,
            longestDuration: sortedSessions.map(\.duration).max() ?? 0,
            latestSessionRecap: sortedSessions.first.map { IntermittentFastSessionRecap.make(session: $0) })
    }

    private static func currentStreakDays(
        for sessions: [IntermittentFastSession],
        calendar: Calendar) -> Int
    {
        let days = uniqueSessionDays(for: sessions, calendar: calendar).sorted(by: >)
        guard let latest = days.first else { return 0 }

        var streak = 1
        var expectedPreviousDay = calendar.date(byAdding: .day, value: -1, to: latest)
        for day in days.dropFirst() {
            guard let expected = expectedPreviousDay else { break }
            if calendar.isDate(day, inSameDayAs: expected) {
                streak += 1
                expectedPreviousDay = calendar.date(byAdding: .day, value: -1, to: expected)
            } else if day < expected {
                break
            }
        }
        return streak
    }

    private static func bestStreakDays(
        for sessions: [IntermittentFastSession],
        calendar: Calendar) -> Int
    {
        let days = uniqueSessionDays(for: sessions, calendar: calendar).sorted()
        guard !days.isEmpty else { return 0 }

        var best = 1
        var current = 1
        for index in 1 ..< days.count {
            let previous = days[index - 1]
            let expected = calendar.date(byAdding: .day, value: 1, to: previous)
            if let expected, calendar.isDate(days[index], inSameDayAs: expected) {
                current += 1
            } else {
                current = 1
            }
            best = max(best, current)
        }
        return best
    }

    private static func uniqueSessionDays(
        for sessions: [IntermittentFastSession],
        calendar: Calendar) -> [Date]
    {
        Array(Set(sessions.map { calendar.startOfDay(for: $0.end) }))
    }

}
