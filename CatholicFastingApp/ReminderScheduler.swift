import Foundation
#if canImport(UserNotifications)
    import UserNotifications
#endif

enum ReminderScheduler {
    private static let reminderPrefix = "required-day-"
    private static let supportReminderPrefix = "habit-support-"
    private static let intermittentSchedulePrefix = "intermittent-schedule-"
    private static let reminderCategory = "habit-reminder"

    static func requestPermission() async -> String {
        #if canImport(UserNotifications)
            let center = UNUserNotificationCenter.current()
            let existingStatus = await authorizationStatus(center)
            if isAuthorizedStatus(existingStatus) {
                configureReminderActions(center)
                return "Permission already granted"
            }
            if existingStatus == .denied {
                return "Notifications denied. Enable them in iOS Settings."
            }
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                configureReminderActions(center)
                return granted ? "Permission granted" : "Permission denied"
            } catch {
                return "Permission error: \(error.localizedDescription)"
            }
        #else
            return "Notifications unavailable on this platform"
        #endif
    }

    static func schedule(observances: [Observance]) async -> String {
        #if canImport(UserNotifications)
            let center = UNUserNotificationCenter.current()
            let liturgicalCalendar = Calendar.gregorian
            let status = await authorizationStatus(center)
            guard isAuthorizedStatus(status) else {
                return "Notifications are not enabled. Request permission first."
            }
            configureReminderActions(center)
            let existing = await pendingRequests(center)
            let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(reminderPrefix) }
            if !toRemove.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: toRemove)
            }

            let now = Date()
            let existingNonRequiredPendingCount = existing.reduce(into: 0) { count, request in
                if !request.identifier.hasPrefix(reminderPrefix) {
                    count += 1
                }
            }
            let maxRequiredReminders = RequiredDayReminderPlanner.maximumRequiredReminders(
                existingNonRequiredPendingCount: existingNonRequiredPendingCount
            )

            guard maxRequiredReminders > 0 else {
                return "Notification queue is full. Clear other reminders and try again."
            }

            let totalUpcomingMandatoryCount = RequiredDayReminderPlanner.upcomingMandatoryObservances(
                from: observances,
                now: now,
                calendar: liturgicalCalendar,
                limit: .max
            ).count
            let plannedMandatoryObservances = RequiredDayReminderPlanner.upcomingMandatoryObservances(
                from: observances,
                now: now,
                calendar: liturgicalCalendar,
                limit: maxRequiredReminders
            )

            guard !plannedMandatoryObservances.isEmpty else {
                return "No upcoming required observances to schedule"
            }

            var scheduled = 0
            for observance in plannedMandatoryObservances {
                let identifier = "required-day-\(observance.id)"
                var dateComponents = liturgicalCalendar.dateComponents(
                    [.year, .month, .day], from: observance.date
                )
                dateComponents.hour = 7
                dateComponents.minute = 0

                guard
                    let reminderDate = liturgicalCalendar.date(from: dateComponents),
                    reminderDate > now
                else {
                    continue
                }

                let content = UNMutableNotificationContent()
                content.title = observance.title
                content.body = "Required observance today. Open Catholic Fasting to mark completion."
                content.sound = .default
                content.categoryIdentifier = reminderCategory

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                do {
                    try await center.add(request)
                    scheduled += 1
                } catch {
                    return "Scheduling error: \(error.localizedDescription)"
                }
            }

            guard scheduled > 0 else {
                return "No future required-day reminders to schedule"
            }
            if totalUpcomingMandatoryCount > plannedMandatoryObservances.count {
                return
                    "Scheduled \(scheduled) upcoming reminder(s) for the earliest required days. The app will auto-refill future required reminders."
            }
            return "Scheduled \(scheduled) upcoming reminder(s)"
        #else
            return "Notifications unavailable on this platform"
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
                    .filter { $0.hasPrefix(reminderPrefix) }
            )
            let existingRequiredPendingCount = existingRequiredIDs.count
            let existingNonRequiredPendingCount = existing.count - existingRequiredPendingCount
            let additionalSlots = RequiredDayReminderPlanner.additionalRequiredReminderSlots(
                existingRequiredPendingCount: existingRequiredPendingCount,
                existingNonRequiredPendingCount: existingNonRequiredPendingCount
            )
            guard additionalSlots > 0 else { return nil }

            let now = Date()
            let candidates = RequiredDayReminderPlanner.upcomingMandatoryObservances(
                from: observances,
                now: now,
                calendar: liturgicalCalendar,
                limit: .max
            )

            var scheduled = 0
            for observance in candidates {
                if scheduled >= additionalSlots { break }
                let identifier = "\(reminderPrefix)\(observance.id)"
                guard !existingRequiredIDs.contains(identifier) else { continue }

                var dateComponents = liturgicalCalendar.dateComponents(
                    [.year, .month, .day], from: observance.date
                )
                dateComponents.hour = 7
                dateComponents.minute = 0

                guard
                    let reminderDate = liturgicalCalendar.date(from: dateComponents),
                    reminderDate > now
                else {
                    continue
                }

                let content = UNMutableNotificationContent()
                content.title = observance.title
                content.body = "Required observance today. Open Catholic Fasting to mark completion."
                content.sound = .default
                content.categoryIdentifier = reminderCategory

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                do {
                    try await center.add(request)
                    scheduled += 1
                } catch {
                    return "Auto-refill failed: \(error.localizedDescription)"
                }
            }

            guard scheduled > 0 else { return nil }
            return "Auto-refilled \(scheduled) required-day reminder(s)"
        #else
            return nil
        #endif
    }

    static func scheduleHabitSupport(morning: Bool, evening: Bool) async -> String {
        #if canImport(UserNotifications)
            let center = UNUserNotificationCenter.current()
            let status = await authorizationStatus(center)
            guard isAuthorizedStatus(status) else {
                return "Notifications are not enabled. Request permission first."
            }
            configureReminderActions(center)
            let existing = await pendingRequests(center)
            let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(supportReminderPrefix) }
            if !toRemove.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: toRemove)
            }

            guard morning || evening else {
                return "Select morning or evening support first"
            }

            var scheduled = 0

            if morning {
                if await addHabitSupportReminder(
                    center: center,
                    identifier: "\(supportReminderPrefix)morning",
                    title: "Morning fasting check",
                    body: "Review today’s observance plan before your first meal.",
                    hour: 7,
                    minute: 0
                ) {
                    scheduled += 1
                }
            }

            if evening {
                if await addHabitSupportReminder(
                    center: center,
                    identifier: "\(supportReminderPrefix)evening",
                    title: "Evening examen",
                    body: "Mark progress and prepare for tomorrow’s observance.",
                    hour: 20,
                    minute: 0
                ) {
                    scheduled += 1
                }
            }

            return scheduled > 0 ? "Scheduled \(scheduled) daily support reminder(s)" : "No support reminders selected"
        #else
            return "Notifications unavailable on this platform"
        #endif
    }

    static func scheduleIntermittentPlan(_ plan: IntermittentSchedulePlan) async -> String {
        #if canImport(UserNotifications)
            let center = UNUserNotificationCenter.current()
            let status = await authorizationStatus(center)
            guard isAuthorizedStatus(status) else {
                return "Applied \(plan.name), but notifications are not enabled. Request permission first."
            }
            configureReminderActions(center)

            let existing = await pendingRequests(center)
            let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(intermittentSchedulePrefix) }
            if !toRemove.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: toRemove)
            }

            let weekdays = Array(Set(plan.weekdays)).sorted().filter { (1 ... 7).contains($0) }
            guard !weekdays.isEmpty else {
                return "Applied \(plan.name), but no weekdays were selected."
            }

            var scheduled = 0
            for weekday in weekdays {
                var dateComponents = DateComponents()
                dateComponents.weekday = weekday
                dateComponents.hour = min(max(plan.startHour, 0), 23)
                dateComponents.minute = 0

                let content = UNMutableNotificationContent()
                content.title = "Intermittent fast start"
                content.body = "\(plan.name): begin your \(plan.targetHours)h fast."
                content.sound = .default
                content.categoryIdentifier = reminderCategory

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let identifier = "\(intermittentSchedulePrefix)\(plan.id)-\(weekday)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                do {
                    try await center.add(request)
                    scheduled += 1
                } catch {
                    return "Applied \(plan.name), but reminder scheduling failed: \(error.localizedDescription)"
                }
            }

            return "Applied \(plan.name): \(scheduled) weekly start reminder(s) at \(String(format: "%02d:00", min(max(plan.startHour, 0), 23)))."
        #else
            return "Applied \(plan.name). Notifications unavailable on this platform."
        #endif
    }

    static func notificationSummary() async -> String {
        #if canImport(UserNotifications)
            let center = UNUserNotificationCenter.current()
            let status = await authorizationStatus(center)
            if status == .notDetermined {
                return "Permission not requested"
            }
            if status == .denied {
                return "Notifications denied in iOS Settings"
            }

            let requests = await pendingRequests(center)
            let requiredCount = requests.map(\.identifier).filter { $0.hasPrefix(reminderPrefix) }.count
            let supportCount = requests.map(\.identifier).filter { $0.hasPrefix(supportReminderPrefix) }.count
            let intermittentCount = requests.map(\.identifier).filter { $0.hasPrefix(intermittentSchedulePrefix) }
                .count
            if requiredCount == 0, supportCount == 0, intermittentCount == 0 {
                return "No reminders queued"
            }
            if requiredCount > 0, supportCount > 0, intermittentCount > 0 {
                return "\(requiredCount) required-day, \(supportCount) support, and \(intermittentCount) intermittent reminder(s) queued"
            }
            if requiredCount > 0, supportCount > 0 {
                return "\(requiredCount) required-day and \(supportCount) support reminder(s) queued"
            }
            if requiredCount > 0, intermittentCount > 0 {
                return "\(requiredCount) required-day and \(intermittentCount) intermittent reminder(s) queued"
            }
            if supportCount > 0, intermittentCount > 0 {
                return "\(supportCount) support and \(intermittentCount) intermittent reminder(s) queued"
            }
            if requiredCount > 0 {
                return "\(requiredCount) required-day reminder(s) queued"
            }
            if supportCount > 0 {
                return "\(supportCount) support reminder(s) queued"
            }
            return "\(intermittentCount) intermittent reminder(s) queued"
        #else
            return "Notifications unavailable on this platform"
        #endif
    }

    #if canImport(UserNotifications)
        private static func configureReminderActions(_ center: UNUserNotificationCenter) {
            let reviewAction = UNNotificationAction(
                identifier: "review_today",
                title: "Review Today",
                options: [.foreground]
            )
            let recoveryAction = UNNotificationAction(
                identifier: "open_recovery",
                title: "Recovery Plan",
                options: [.foreground]
            )
            let category = UNNotificationCategory(
                identifier: reminderCategory,
                actions: [reviewAction, recoveryAction],
                intentIdentifiers: [],
                options: []
            )
            center.setNotificationCategories([category])
        }

        private static func addHabitSupportReminder(
            center: UNUserNotificationCenter,
            identifier: String,
            title: String,
            body: String,
            hour: Int,
            minute: Int
        ) async -> Bool {
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

        private static func pendingRequests(_ center: UNUserNotificationCenter) async -> [UNNotificationRequest] {
            await withCheckedContinuation { continuation in
                center.getPendingNotificationRequests { requests in
                    continuation.resume(returning: requests)
                }
            }
        }

        private static func authorizationStatus(_ center: UNUserNotificationCenter) async
            -> UNAuthorizationStatus
        {
            await withCheckedContinuation { continuation in
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
    #endif
}
