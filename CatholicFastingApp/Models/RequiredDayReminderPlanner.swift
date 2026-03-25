@preconcurrency import Foundation

enum RequiredDayReminderPlanner {
    static let pendingNotificationLimit = 64
    static let reservedSlotsForNonRequired = 14
    static let absoluteRequiredReminderCap = pendingNotificationLimit - reservedSlotsForNonRequired

    static func maximumRequiredReminders(existingNonRequiredPendingCount: Int) -> Int {
        let nonRequiredCount = max(0, existingNonRequiredPendingCount)
        let remainingQueueCapacity = max(0, pendingNotificationLimit - nonRequiredCount)
        return min(absoluteRequiredReminderCap, remainingQueueCapacity)
    }

    static func additionalRequiredReminderSlots(
        existingRequiredPendingCount: Int,
        existingNonRequiredPendingCount: Int) -> Int
    {
        let requiredCount = max(0, existingRequiredPendingCount)
        let maxRequired = maximumRequiredReminders(
            existingNonRequiredPendingCount: existingNonRequiredPendingCount)
        return max(0, maxRequired - requiredCount)
    }

    static func upcomingMandatoryObservances(
        from observances: [Observance],
        now: Date = Date(),
        calendar: Calendar = .gregorian,
        limit: Int) -> [Observance]
    {
        guard limit > 0 else { return [] }

        let startOfToday = calendar.startOfDay(for: now)
        let sortedCandidates =
            observances
                .filter { observance in
                    observance.obligation == .mandatory
                        && calendar.startOfDay(for: observance.date) >= startOfToday
                }
                .sorted { lhs, rhs in
                    if lhs.date == rhs.date {
                        return lhs.id < rhs.id
                    }
                    return lhs.date < rhs.date
                }

        var seenIDs = Set<String>()
        var planned: [Observance] = []
        planned.reserveCapacity(min(limit, sortedCandidates.count))

        for observance in sortedCandidates {
            guard seenIDs.insert(observance.id).inserted else { continue }
            planned.append(observance)
            if planned.count == limit {
                break
            }
        }

        return planned
    }
}
