@preconcurrency import Foundation

extension Calendar {
    static var gregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = .current
        return calendar
    }
}

extension DateFormatter {
    static let dayKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .gregorian
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let dayKeyParser = dayKey
}
