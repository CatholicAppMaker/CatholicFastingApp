import Foundation
#if canImport(UserNotifications)
import UserNotifications
#endif

enum ReminderScheduler {
    static func localized(_ key: String, default defaultValue: String) -> String {
        CoreLocalizer.localizedCurrent(key, default: defaultValue)
    }

    static func localizedFormat(
        _ key: String,
        default defaultValue: String,
        _ arguments: CVarArg...) -> String
    {
        let format = CoreLocalizer.localizedCurrent(key, default: defaultValue)
        return String(format: format, locale: CoreLocalizer.currentLocale(), arguments: arguments)
    }

    static func schedulingErrorStatus(_ error: Error) -> String {
        localizedFormat(
            "reminder.status.scheduling_error_format",
            default: "Scheduling error: %@",
            error.localizedDescription)
    }
}
