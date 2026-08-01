import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

extension ReminderScheduler {
    private static let supportReminderPrefix = "habit-support-"
    private static let quoteReminderPrefix = "daily-quote-"
    private static let habitReminderCategory = "habit-reminder"
    private static let dailyQuoteSchedulingHorizon = 21

    private static var habitNotificationsNotEnabledStatus: String {
        localized(
            "reminder.status.notifications_not_enabled",
            default: "Notifications are not enabled. Request permission first.")
    }

    private static var habitNotificationQueueFullStatus: String {
        localized(
            "reminder.status.queue_full",
            default: "Notification queue is full. Clear other reminders and try again.")
    }

    static func scheduleHabitSupport(morning: Bool, evening: Bool) async -> String {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let status = await authorizationStatus(center)
        guard isAuthorizedStatus(status) else {
            return habitNotificationsNotEnabledStatus
        }
        configureReminderActions(center)
        let existing = await pendingRequests(center)
        let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(supportReminderPrefix) }
        if !toRemove.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }

        guard morning || evening else {
            return localized(
                "reminder.status.select_support_time",
                default: "Select morning or evening support first")
        }

        var scheduled = 0

        if morning {
            if await addHabitSupportReminder(
                center: center,
                identifier: "\(supportReminderPrefix)morning",
                title: localized(
                    "reminder.notification.morning.title",
                    default: "Morning fasting check"),
                body: localized(
                    "reminder.notification.morning.body",
                    default: "Review today’s observance plan before your first meal."),
                hour: 7,
                minute: 0)
            {
                scheduled += 1
            }
        }

        if evening {
            if await addHabitSupportReminder(
                center: center,
                identifier: "\(supportReminderPrefix)evening",
                title: localized(
                    "reminder.notification.evening.title",
                    default: "Evening examen"),
                body: localized(
                    "reminder.notification.evening.body",
                    default: "Mark today and prepare for tomorrow’s observance."),
                hour: 20,
                minute: 0)
            {
                scheduled += 1
            }
        }

        return scheduled > 0
            ? localizedFormat(
                "reminder.status.support_scheduled_format",
                default: "Scheduled %d daily support reminder(s)",
                scheduled)
            : localized(
                "reminder.status.no_support_selected",
                default: "No support reminders selected")
        #else
        return localized(
            "reminder.status.unavailable",
            default: "Notifications unavailable on this platform")
        #endif
    }

    static func scheduleDailyQuoteReminder(
        enabled: Bool,
        hour: Int,
        minute: Int,
        languageMode: LanguageMode,
        referenceDate: Date = AppClock.now()) async -> String
    {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let status = await authorizationStatus(center)
        guard isAuthorizedStatus(status) else {
            return habitNotificationsNotEnabledStatus
        }
        configureReminderActions(center)

        let existing = await pendingRequests(center)
        let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(quoteReminderPrefix) }
        if !toRemove.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }

        guard enabled else {
            return localized(
                "reminder.status.quote_cleared",
                default: "Daily quote reminder cleared")
        }

        let remainingPendingCount = existing.count - toRemove.count
        let availableSlots = max(0, 64 - remainingPendingCount)
        let scheduleCount = min(dailyQuoteSchedulingHorizon, availableSlots)
        guard scheduleCount > 0 else {
            return habitNotificationQueueFullStatus
        }

        let calendar = Calendar.gregorian
        let normalizedHour = min(max(hour, 0), 23)
        let normalizedMinute = min(max(minute, 0), 59)
        let title = localizedQuoteReminderTitle(languageMode: languageMode)
        let scheduledDates = upcomingQuoteDates(
            from: referenceDate,
            count: scheduleCount,
            hour: normalizedHour,
            minute: normalizedMinute,
            calendar: calendar)

        var scheduled = 0
        for reminderDate in scheduledDates {
            let contentModel = DailyQuoteReminderContentProvider.content(
                title: title,
                for: reminderDate,
                locale: languageMode.contentLocale,
                calendar: calendar)

            let content = UNMutableNotificationContent()
            content.title = contentModel.title
            content.body = contentModel.body
            content.sound = .default
            content.categoryIdentifier = habitReminderCategory

            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier = "\(quoteReminderPrefix)\(quoteReminderDateIdentifier(for: reminderDate, calendar: calendar))"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger)
            do {
                try await center.add(request)
                scheduled += 1
            } catch {
                return schedulingErrorStatus(error)
            }
        }

        return localizedFormat(
            "reminder.status.quote_scheduled_format",
            default: "Scheduled %d daily quote reminder(s)",
            scheduled)
        #else
        return localized(
            "reminder.status.unavailable",
            default: "Notifications unavailable on this platform")
        #endif
    }

    static func pendingDailyQuoteReminderCount() async -> Int {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let requests = await pendingRequests(center)
        return requests.map(\.identifier).count(where: { $0.hasPrefix(quoteReminderPrefix) })
        #else
        return 0
        #endif
    }

    #if canImport(UserNotifications)
    private static func addHabitSupportReminder(
        center: UNUserNotificationCenter,
        identifier: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int) async -> Bool
    {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = habitReminderCategory

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        do {
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }

    private static func localizedQuoteReminderTitle(languageMode: LanguageMode) -> String {
        AppLocalizer.localized(
            "reminder.quote.title",
            default: "Daily fasting reflection",
            languageCode: languageMode.rawValue)
    }

    private static func upcomingQuoteDates(
        from referenceDate: Date,
        count: Int,
        hour: Int,
        minute: Int,
        calendar: Calendar) -> [Date]
    {
        guard count > 0 else { return [] }

        let startOfDay = calendar.startOfDay(for: referenceDate)
        var dates: [Date] = []

        for dayOffset in 0 ..< (count + 1) {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfDay) else { continue }
            let candidate = calendar.date(
                bySettingHour: hour,
                minute: minute,
                second: 0,
                of: day) ?? day
            if candidate > referenceDate {
                dates.append(candidate)
            }
            if dates.count == count {
                break
            }
        }

        return dates
    }

    private static func quoteReminderDateIdentifier(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d%02d%02d", year, month, day)
    }
    #endif
}
