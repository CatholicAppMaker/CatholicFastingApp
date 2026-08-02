import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

extension ReminderScheduler {
    private static let requiredReminderPrefix = "required-day-"
    private static let requiredReminderCategory = "habit-reminder"

    private static var requiredNotificationsNotEnabledStatus: String {
        localized(
            "reminder.status.notifications_not_enabled",
            default: "Notifications are not enabled. Request permission first.")
    }

    private static var requiredNotificationQueueFullStatus: String {
        localized(
            "reminder.status.queue_full",
            default: "Notification queue is full. Clear other reminders and try again.")
    }

    static func schedule(observances: [Observance]) async -> String {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let liturgicalCalendar = Calendar.gregorian
        let status = await authorizationStatus(center)
        guard isAuthorizedStatus(status) else {
            return requiredNotificationsNotEnabledStatus
        }
        configureReminderActions(center)
        let existing = await pendingRequests(center)
        let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(requiredReminderPrefix) }
        if !toRemove.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }

        let now = AppClock.now()
        let existingNonRequiredPendingCount = existing.reduce(into: 0) { count, request in
            if !request.identifier.hasPrefix(requiredReminderPrefix) {
                count += 1
            }
        }
        let maxRequiredReminders = RequiredDayReminderPlanner.maximumRequiredReminders(
            existingNonRequiredPendingCount: existingNonRequiredPendingCount)

        guard maxRequiredReminders > 0 else {
            return requiredNotificationQueueFullStatus
        }

        let totalUpcomingMandatoryCount = RequiredDayReminderPlanner.upcomingMandatoryObservances(
            from: observances,
            now: now,
            calendar: liturgicalCalendar,
            limit: .max).count
        let plannedMandatoryObservances = RequiredDayReminderPlanner.upcomingMandatoryObservances(
            from: observances,
            now: now,
            calendar: liturgicalCalendar,
            limit: maxRequiredReminders)

        guard !plannedMandatoryObservances.isEmpty else {
            return localized(
                "reminder.status.no_upcoming_required",
                default: "No upcoming required observances to schedule")
        }

        var scheduled = 0
        for observance in plannedMandatoryObservances {
            let identifier = "required-day-\(observance.id)"
            var dateComponents = liturgicalCalendar.dateComponents(
                [.year, .month, .day], from: observance.date)
            dateComponents.hour = 7
            dateComponents.minute = 0

            guard
                let reminderDate = liturgicalCalendar.date(from: dateComponents),
                reminderDate > now
            else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = ObservanceContentLocalizer.localizedCurrentTitle(observance.title)
            content.body = localized(
                "reminder.notification.required.body",
                default: "Required observance today. Open Catholic Fasting to mark completion.")
            content.sound = .default
            content.categoryIdentifier = requiredReminderCategory

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            do {
                try await center.add(request)
                scheduled += 1
            } catch {
                return schedulingErrorStatus(error)
            }
        }

        guard scheduled > 0 else {
            return localized(
                "reminder.status.no_future_required",
                default: "No future required-day reminders to schedule")
        }
        if totalUpcomingMandatoryCount > plannedMandatoryObservances.count {
            return localizedFormat(
                "reminder.status.required_scheduled_refill_format",
                default: "Scheduled %d upcoming reminder(s) for the earliest required days. The app will auto-refill future required reminders.",
                scheduled)
        }
        return localizedFormat(
            "reminder.status.required_scheduled_format",
            default: "Scheduled %d upcoming reminder(s)",
            scheduled)
        #else
        return localized(
            "reminder.status.unavailable",
            default: "Notifications unavailable on this platform")
        #endif
    }

    static func topUpRequiredReminders(observances: [Observance]) async -> String? {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let liturgicalCalendar = Calendar.gregorian
        let status = await authorizationStatus(center)
        guard isAuthorizedStatus(status) else { return nil }

        configureReminderActions(center)
        let existing = await pendingRequests(center)

        let existingRequiredIDs = Set(
            existing
                .map(\.identifier)
                .filter { $0.hasPrefix(requiredReminderPrefix) })
        let existingRequiredPendingCount = existingRequiredIDs.count
        let existingNonRequiredPendingCount = existing.count - existingRequiredPendingCount
        let additionalSlots = RequiredDayReminderPlanner.additionalRequiredReminderSlots(
            existingRequiredPendingCount: existingRequiredPendingCount,
            existingNonRequiredPendingCount: existingNonRequiredPendingCount)
        guard additionalSlots > 0 else { return nil }

        let now = AppClock.now()
        let candidates = RequiredDayReminderPlanner.upcomingMandatoryObservances(
            from: observances,
            now: now,
            calendar: liturgicalCalendar,
            limit: .max)

        var scheduled = 0
        for observance in candidates {
            if scheduled >= additionalSlots {
                break
            }
            let identifier = "\(requiredReminderPrefix)\(observance.id)"
            guard !existingRequiredIDs.contains(identifier) else { continue }

            var dateComponents = liturgicalCalendar.dateComponents(
                [.year, .month, .day], from: observance.date)
            dateComponents.hour = 7
            dateComponents.minute = 0

            guard
                let reminderDate = liturgicalCalendar.date(from: dateComponents),
                reminderDate > now
            else {
                continue
            }

            let content = UNMutableNotificationContent()
            content.title = ObservanceContentLocalizer.localizedCurrentTitle(observance.title)
            content.body = localized(
                "reminder.notification.required.body",
                default: "Required observance today. Open Catholic Fasting to mark completion.")
            content.sound = .default
            content.categoryIdentifier = requiredReminderCategory

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            do {
                try await center.add(request)
                scheduled += 1
            } catch {
                return localizedFormat(
                    "reminder.status.auto_refill_failed_format",
                    default: "Auto-refill failed: %@",
                    error.localizedDescription)
            }
        }

        guard scheduled > 0 else { return nil }
        return localizedFormat(
            "reminder.status.auto_refilled_format",
            default: "Auto-refilled %d required-day reminder(s)",
            scheduled)
        #else
        return nil
        #endif
    }
}
