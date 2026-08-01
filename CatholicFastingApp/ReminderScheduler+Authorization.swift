import Foundation
#if canImport(UserNotifications)
import UserNotifications

private struct PendingNotificationRequests: @unchecked Sendable {
    let value: [UNNotificationRequest]
}
#endif

extension ReminderScheduler {
    private static let summaryRequiredReminderPrefix = "required-day-"
    private static let summarySupportReminderPrefix = "habit-support-"
    private static let summaryQuoteReminderPrefix = "daily-quote-"
    private static let summaryIntermittentSchedulePrefix = "intermittent-schedule-"
    private static let summaryIntermittentTargetPrefix = IntermittentTargetReminderPolicy.identifierPrefix
    private static let authorizationReminderCategory = "habit-reminder"

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
        let requiredCount = requests.map(\.identifier).count(where: { $0.hasPrefix(summaryRequiredReminderPrefix) })
        let supportCount = requests.map(\.identifier).count(where: { $0.hasPrefix(summarySupportReminderPrefix) })
        let quoteCount = requests.map(\.identifier).count(where: { $0.hasPrefix(summaryQuoteReminderPrefix) })
        let intermittentCount = requests.map(\.identifier).count(where: { $0.hasPrefix(summaryIntermittentSchedulePrefix) })
        let targetCount = requests.map(\.identifier).count(where: { $0.hasPrefix(summaryIntermittentTargetPrefix) })

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
    static func configureReminderActions(_ center: UNUserNotificationCenter) {
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
            identifier: authorizationReminderCategory,
            actions: [reviewAction, recoveryAction],
            intentIdentifiers: [],
            options: [])
        center.setNotificationCategories([category])
    }

    static func pendingRequests(_ center: UNUserNotificationCenter) async -> [UNNotificationRequest] {
        let wrapped = await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: PendingNotificationRequests(value: requests))
            }
        }
        return wrapped.value
    }

    static func authorizationStatus(_ center: UNUserNotificationCenter) async
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

    static func isAuthorizedStatus(_ status: UNAuthorizationStatus) -> Bool {
        switch status {
        case .authorized, .provisional, .ephemeral:
            true
        default:
            false
        }
    }
    #endif

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
}
