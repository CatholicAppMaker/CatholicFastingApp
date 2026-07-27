import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

enum ReminderScheduler {
    private struct PendingNotificationRequests: @unchecked Sendable {
        let value: [UNNotificationRequest]
    }

    private static let reminderPrefix = "required-day-"
    private static let supportReminderPrefix = "habit-support-"
    private static let quoteReminderPrefix = "daily-quote-"
    private static let intermittentSchedulePrefix = "intermittent-schedule-"
    private static let intermittentTargetPrefix = IntermittentTargetReminderPolicy.identifierPrefix
    private static let reminderCategory = "habit-reminder"
    private static let dailyQuoteSchedulingHorizon = 21

    private static func localized(_ key: String, default defaultValue: String) -> String {
        CoreLocalizer.localizedCurrent(key, default: defaultValue)
    }

    private static func localizedFormat(
        _ key: String,
        default defaultValue: String,
        _ arguments: CVarArg...) -> String
    {
        let format = CoreLocalizer.localizedCurrent(key, default: defaultValue)
        return String(format: format, locale: CoreLocalizer.currentLocale(), arguments: arguments)
    }

    private static var notificationsNotEnabledStatus: String {
        localized(
            "reminder.status.notifications_not_enabled",
            default: "Notifications are not enabled. Request permission first.")
    }

    private static var notificationQueueFullStatus: String {
        localized(
            "reminder.status.queue_full",
            default: "Notification queue is full. Clear other reminders and try again.")
    }

    private static var targetReminderClearedStatus: String {
        localized(
            "reminder.status.target_cleared",
            default: "Target reminder cleared")
    }

    private static func schedulingErrorStatus(_ error: Error) -> String {
        localizedFormat(
            "reminder.status.scheduling_error_format",
            default: "Scheduling error: %@",
            error.localizedDescription)
    }

    private static var notificationSettingsNoun: String {
        #if os(macOS)
        localized("reminder.settings.system", default: "System Settings")
        #else
        localized("reminder.settings.app", default: "Settings")
        #endif
    }

    static func requestPermission() async -> String {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let existingStatus = await authorizationStatus(center)
        if isAuthorizedStatus(existingStatus) {
            configureReminderActions(center)
            return localized("reminder.status.permission_already_granted", default: "Permission already granted")
        }
        if existingStatus == .denied {
            return localizedFormat(
                "reminder.status.notifications_denied_settings_format",
                default: "Notifications denied. Enable them in %@.",
                notificationSettingsNoun)
        }
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            configureReminderActions(center)
            return granted
                ? localized("reminder.status.permission_granted", default: "Permission granted")
                : localized("reminder.status.permission_denied", default: "Permission denied")
        } catch {
            return localizedFormat(
                "reminder.status.permission_error_format",
                default: "Permission error: %@",
                error.localizedDescription)
        }
        #else
        return localized(
            "reminder.status.unavailable",
            default: "Notifications unavailable on this platform")
        #endif
    }

    static func schedule(observances: [Observance]) async -> String {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let liturgicalCalendar = Calendar.gregorian
        let status = await authorizationStatus(center)
        guard isAuthorizedStatus(status) else {
            return notificationsNotEnabledStatus
        }
        configureReminderActions(center)
        let existing = await pendingRequests(center)
        let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(reminderPrefix) }
        if !toRemove.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: toRemove)
        }

        let now = AppClock.now()
        let existingNonRequiredPendingCount = existing.reduce(into: 0) { count, request in
            if !request.identifier.hasPrefix(reminderPrefix) {
                count += 1
            }
        }
        let maxRequiredReminders = RequiredDayReminderPlanner.maximumRequiredReminders(
            existingNonRequiredPendingCount: existingNonRequiredPendingCount)

        guard maxRequiredReminders > 0 else {
            return notificationQueueFullStatus
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
            content.categoryIdentifier = reminderCategory

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
                .filter { $0.hasPrefix(reminderPrefix) })
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
            if scheduled >= additionalSlots { break }
            let identifier = "\(reminderPrefix)\(observance.id)"
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
            content.categoryIdentifier = reminderCategory

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

    static func scheduleHabitSupport(morning: Bool, evening: Bool) async -> String {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let status = await authorizationStatus(center)
        guard isAuthorizedStatus(status) else {
            return notificationsNotEnabledStatus
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
            return notificationsNotEnabledStatus
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
            return notificationQueueFullStatus
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
            content.categoryIdentifier = reminderCategory

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
            content.categoryIdentifier = reminderCategory

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
        content.categoryIdentifier = reminderCategory

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

    static func notificationSummary() async -> String {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let status = await authorizationStatus(center)
        if status == .notDetermined {
            return localized(
                "reminder.status.permission_not_requested",
                default: "Permission not requested")
        }
        if status == .denied {
            return localizedFormat(
                "reminder.status.notifications_denied_in_format",
                default: "Notifications denied in %@",
                notificationSettingsNoun)
        }

        let requests = await pendingRequests(center)
        let requiredCount = requests.map(\.identifier).count(where: { $0.hasPrefix(reminderPrefix) })
        let supportCount = requests.map(\.identifier).count(where: { $0.hasPrefix(supportReminderPrefix) })
        let quoteCount = requests.map(\.identifier).count(where: { $0.hasPrefix(quoteReminderPrefix) })
        let intermittentCount = requests.map(\.identifier).count(where: { $0.hasPrefix(intermittentSchedulePrefix) })
        let targetCount = requests.map(\.identifier).count(where: { $0.hasPrefix(intermittentTargetPrefix) })

        let summaryParts = [
            summaryPart(
                count: requiredCount,
                labelKey: "reminder.summary.required_day",
                defaultLabel: "required-day"),
            summaryPart(
                count: supportCount,
                labelKey: "reminder.summary.support",
                defaultLabel: "support"),
            summaryPart(
                count: quoteCount,
                labelKey: "reminder.summary.quote",
                defaultLabel: "quote"),
            summaryPart(
                count: intermittentCount,
                labelKey: "reminder.summary.personal_fast",
                defaultLabel: "personal-fast"),
            summaryPart(
                count: targetCount,
                labelKey: "reminder.summary.target",
                defaultLabel: "target"),
        ].compactMap(\.self)

        if summaryParts.isEmpty {
            return localized(
                "reminder.status.no_reminders_queued",
                default: "No reminders queued")
        }

        if summaryParts.count == 1, let only = summaryParts.first {
            return localizedFormat(
                "reminder.status.summary_single_format",
                default: "%@ queued",
                only)
        }

        if summaryParts.count == 2 {
            return localizedFormat(
                "reminder.status.summary_two_format",
                default: "%@ and %@ queued",
                summaryParts[0],
                summaryParts[1])
        }

        let leading = summaryParts.dropLast().joined(separator: ", ")
        return localizedFormat(
            "reminder.status.summary_many_format",
            default: "%@, and %@ queued",
            leading,
            summaryParts[summaryParts.count - 1])
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

    static func notificationsAuthorizedForScheduling() async -> Bool {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        let status = await authorizationStatus(center)
        return isAuthorizedStatus(status)
        #else
        return false
        #endif
    }

    #if canImport(UserNotifications)
    private static func configureReminderActions(_ center: UNUserNotificationCenter) {
        let reviewAction = UNNotificationAction(
            identifier: "review_today",
            title: localized(
                "reminder.action.review_today",
                default: "Review Today"),
            options: [.foreground])
        let recoveryAction = UNNotificationAction(
            identifier: "open_recovery",
            title: localized(
                "reminder.action.recovery_plan",
                default: "Recovery Plan"),
            options: [.foreground])
        let category = UNNotificationCategory(
            identifier: reminderCategory,
            actions: [reviewAction, recoveryAction],
            intentIdentifiers: [],
            options: [])
        center.setNotificationCategories([category])
    }

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
        content.categoryIdentifier = reminderCategory

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        do {
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }

    private static func clearIntermittentTargetReminders(_ center: UNUserNotificationCenter) async {
        let identifiers = await pendingRequests(center)
            .map(\.identifier)
            .filter { $0.hasPrefix(intermittentTargetPrefix) }
        if !identifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    private static func pendingRequests(_ center: UNUserNotificationCenter) async -> [UNNotificationRequest] {
        let wrapped = await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: PendingNotificationRequests(value: requests))
            }
        }
        return wrapped.value
    }

    private static func authorizationStatus(_ center: UNUserNotificationCenter) async
        -> UNAuthorizationStatus
    {
        let environment = ProcessInfo.processInfo.environment
        if environment["UITEST_MODE"] == "1",
           let override = environment["UITEST_NOTIFICATION_AUTHORIZATION"]
        {
            switch override {
            case "authorized":
                return .authorized
            case "denied":
                return .denied
            case "notDetermined":
                return .notDetermined
            default:
                break
            }
        }

        return await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings.authorizationStatus)
            }
        }
    }

    private static func isAuthorizedStatus(_ status: UNAuthorizationStatus) -> Bool {
        switch status {
        case .authorized, .provisional, .ephemeral:
            true
        default:
            false
        }
    }

    private static func localizedQuoteReminderTitle(languageMode: LanguageMode) -> String {
        AppLocalizer.localized(
            "reminder.quote.title",
            default: "Daily fasting reflection",
            languageCode: languageMode.rawValue)
    }

    private static func summaryPart(
        count: Int,
        labelKey: String,
        defaultLabel: String) -> String?
    {
        guard count > 0 else { return nil }
        let label = localized(labelKey, default: defaultLabel)
        if count == 1 {
            return localizedFormat(
                "reminder.summary.part_singular_format",
                default: "%d %@ reminder",
                count,
                label)
        }
        return localizedFormat(
            "reminder.summary.part_plural_format",
            default: "%d %@ reminders",
            count,
            label)
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
