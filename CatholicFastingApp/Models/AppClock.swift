import Foundation

enum AppClock {
    static func now(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        arguments: [String] = ProcessInfo.processInfo.arguments) -> Date
    {
        let value = environment["CFA_FIXED_DATE"]
            ?? environment["UITEST_FIXED_DATE"]
            ?? argumentValue(named: "-fixed-date", in: arguments)
        guard let value, let fixedDate = parse(value) else {
            return Date()
        }
        return fixedDate
    }

    static func parse(_ value: String) -> Date? {
        if let precise = ISO8601DateFormatter().date(from: value) {
            return precise
        }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let startOfDay = formatter.date(from: value) else { return nil }
        return startOfDay.addingTimeInterval(12 * 3600)
    }

    private static func argumentValue(named name: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: name), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }
}
