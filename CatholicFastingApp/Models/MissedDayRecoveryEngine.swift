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
            CoreLocalizer.localizedCurrentFormat(
                "premium.recovery.next_required.format",
                default: "Next required day: %@ on %@.",
                nextRequired.title,
                nextRequired.date.formatted(date: .abbreviated, time: .omitted))
        } else {
            CoreLocalizer.localizedCurrent(
                "premium.recovery.next_required.none",
                default: "No future required observances remain in this calendar year.")
        }

        return MissedDayRecoveryPlan(
            titleLine:
            CoreLocalizer.localizedCurrentFormat(
                "premium.recovery.recent_missed.format",
                default: "Recent missed observance: %@ (%@).",
                lastMissed.title,
                lastMissed.date.formatted(date: .abbreviated, time: .omitted)),
            summaryLine:
            CoreLocalizer.localizedCurrent(
                "premium.recovery.missed.summary",
                default: "Missing a day does not end your discipline. Recover with a practical next step today."),
            steps: [
                CoreLocalizer.localizedCurrent(
                    "premium.recovery.missed.step1",
                    default: "Offer a short prayer of repentance and renew your intention."),
                CoreLocalizer.localizedCurrent(
                    "premium.recovery.missed.step2",
                    default: "Choose one concrete recovery act today (charity, Scripture, Rosary, or a simplified meal)."),
                CoreLocalizer.localizedCurrent(
                    "premium.recovery.missed.step3",
                    default: "Plan the next required day now so it is easier to keep."),
            ],
            nextRequiredLine: nextRequiredLine)
    }
}
