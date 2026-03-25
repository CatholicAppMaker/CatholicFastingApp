@preconcurrency import Foundation

enum MissedDayRecoveryEngine {
    static func plan(
        observances: [Observance],
        statusesByID: [String: CompletionStatus],
        today: Date = Date(),
        calendar: Calendar = .current) -> MissedDayRecoveryPlan?
    {
        let startOfToday = calendar.startOfDay(for: today)
        let missedObservances = observances.filter { observance in
            statusesByID[observance.id] == .missed
                && calendar.startOfDay(for: observance.date) <= startOfToday
        }

        guard let lastMissed = missedObservances.max(by: { $0.date < $1.date }) else {
            return nil
        }

        let nextRequired = observances.first { observance in
            observance.obligation == .mandatory
                && calendar.startOfDay(for: observance.date) > startOfToday
        }

        let nextRequiredLine = if let nextRequired {
            "Next required day: \(nextRequired.title) on \(nextRequired.date.formatted(date: .abbreviated, time: .omitted))."
        } else {
            "No future required observances remain in this calendar year."
        }

        return MissedDayRecoveryPlan(
            titleLine:
            "Recent missed observance: \(lastMissed.title) (\(lastMissed.date.formatted(date: .abbreviated, time: .omitted))).",
            summaryLine:
            "Missing a day does not end your discipline. Recover with a practical next step today.",
            steps: [
                "Offer a short prayer of repentance and renew your intention.",
                "Choose one concrete recovery act today (charity, Scripture, Rosary, or a simplified meal).",
                "Plan the next required day now so it is easier to keep.",
            ],
            nextRequiredLine: nextRequiredLine)
    }
}
