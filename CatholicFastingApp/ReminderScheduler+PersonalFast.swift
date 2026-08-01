import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

extension ReminderScheduler {
    private static let intermittentSchedulePrefix = "intermittent-schedule-"
    private static let intermittentTargetPrefix = IntermittentTargetReminderPolicy.identifierPrefix
    private static let personalFastReminderCategory = "habit-reminder"

    private static var targetReminderClearedStatus: String {
        localized(
            "reminder.status.target_cleared",
            default: "Target reminder cleared")
    }

    static func scheduleIntermittentPlan(_ plan: IntermittentSchedulePlan) async -> String {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let status = await authorizationStatus(center)
        guard isAuthorizedStatus(status) else {
            return localizedFormat(
                "reminder.status.plan_applied_notifications_disabled_format",
                default: "Applied %@, but notifications are not enabled. Request permission first.",
                plan.name)
        }
        configureReminderActions(center)

        let existing = await pendingRequests(center)
        let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(intermittentSchedulePrefix) }
        if !toRemove.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }

        let weekdays = Array(Set(plan.weekdays)).sorted().filter { (1 ... 7).contains($0) }
        guard !weekdays.isEmpty else {
            return localizedFormat(
                "reminder.status.plan_applied_no_days_format",
                default: "Applied %@, but no weekdays were selected.",
                plan.name)
        }

        var scheduled = 0
        for weekday in weekdays {
            var dateComponents = DateComponents()
            dateComponents.weekday = weekday
            dateComponents.hour = min(max(plan.startHour, 0), 23)
            dateComponents.minute = 0

            let content = UNMutableNotificationContent()
            content.title = localized(
                "reminder.notification.personal_fast_start.title",
                default: "Personal fast begins")
            content.body = localizedFormat(
                "reminder.notification.personal_fast_start.body_format",
                default: "%@: begin your %d-hour fast.",
                plan.name,
                plan.targetHours)
            content.sound = .default
            content.categoryIdentifier = personalFastReminderCategory

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let identifier = "\(intermittentSchedulePrefix)\(plan.id)-\(weekday)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            do {
                try await center.add(request)
                scheduled += 1
            } catch {
                return localizedFormat(
                    "reminder.status.plan_scheduling_failed_format",
                    default: "Applied %@, but reminder scheduling failed: %@",
                    plan.name,
                    error.localizedDescription)
            }
        }

        return localizedFormat(
            "reminder.status.plan_applied_format",
            default: "Applied %@: %d weekly start reminder(s) at %@.",
            plan.name,
            scheduled,
            String(format: "%02d:00", min(max(plan.startHour, 0), 23)))
        #else
        return localizedFormat(
            "reminder.status.plan_applied_unavailable_format",
            default: "Applied %@. Notifications unavailable on this platform.",
            plan.name)
        #endif
    }

    static func intermittentTargetReminderIdentifier(start: Date) -> String {
        IntermittentTargetReminderPolicy.identifier(start: start)
    }

    static func scheduleIntermittentTargetReminder(
        enabled: Bool,
        start: Date?,
        targetHours: Int,
        now: Date = AppClock.now()) async -> String
    {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        await clearIntermittentTargetReminders(center)

        guard enabled else {
            return targetReminderClearedStatus
        }
        guard let start else {
            return localized(
                "reminder.status.no_active_fast",
                default: "No active fast for target reminder")
        }

        let status = await authorizationStatus(center)
        guard isAuthorizedStatus(status) else {
            return localized(
                "reminder.status.target_selected_notifications_disabled",
                default: "Target reminder selected. Enable notifications to receive it.")
        }
        configureReminderActions(center)

        let targetDate = start.addingTimeInterval(TimeInterval(max(1, targetHours) * 3600))
        guard targetDate > now else {
            return localized(
                "reminder.status.target_already_reached",
                default: "Target already reached")
        }

        let content = UNMutableNotificationContent()
        content.title = localized(
            "reminder.notification.target.title",
            default: "Fast target reached")
        content.body = localized(
            "reminder.notification.target.body",
            default: "Your planned fast target is complete. Review it when ready.")
        content.sound = .default
        content.categoryIdentifier = personalFastReminderCategory

        let components = Calendar.gregorian.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: targetDate)
        let request = UNNotificationRequest(
            identifier: intermittentTargetReminderIdentifier(start: start),
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
        do {
            try await center.add(request)
            return localized(
                "reminder.status.target_scheduled",
                default: "Target reminder scheduled")
        } catch {
            return localizedFormat(
                "reminder.status.target_failed_format",
                default: "Target reminder failed: %@",
                error.localizedDescription)
        }
        #else
        return localized(
            "reminder.status.unavailable",
            default: "Notifications unavailable on this platform")
        #endif
    }

    static func clearIntermittentTargetReminders() async -> String {
        #if canImport(UserNotifications)
        await clearIntermittentTargetReminders(UNUserNotificationCenter.current())
        return targetReminderClearedStatus
        #else
        return localized(
            "reminder.status.unavailable",
            default: "Notifications unavailable on this platform")
        #endif
    }

    #if canImport(UserNotifications)
    private static func clearIntermittentTargetReminders(_ center: UNUserNotificationCenter) async {
        let identifiers = await pendingRequests(center)
            .map(\.identifier)
            .filter { $0.hasPrefix(intermittentTargetPrefix) }
        if !identifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    #endif
}
