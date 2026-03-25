@preconcurrency import Foundation

extension ObservanceCalculator {
    enum LiturgicalObligationAgeStatus {
        case underSeven
        case sevenOrOlder
        case unknown
    }

    static func isBirthYearKnown(settings: RuleSettings) -> Bool {
        settings.birthYear >= minimumSupportedBirthYear
    }

    static func isFullBirthDateKnown(settings: RuleSettings) -> Bool {
        guard isBirthYearKnown(settings: settings) else { return false }
        guard settings.hasFullBirthDate else { return false }
        return true
    }

    static func isFastRequired(on _: Date, settings: RuleSettings) -> Bool {
        guard !settings.hasMedicalDispensation else { return false }
        return settings.isAge18OrOlderForFasting
    }

    static func isAbstinenceRequired(on _: Date, settings: RuleSettings) -> Bool {
        guard !settings.hasMedicalDispensation else { return false }
        return settings.isAge14OrOlderForAbstinence
    }

    static func liturgicalObligationAgeStatus(on date: Date, settings: RuleSettings) -> LiturgicalObligationAgeStatus {
        if isBirthYearKnown(settings: settings) {
            return age(on: date, settings: settings) >= 7 ? .sevenOrOlder : .underSeven
        }

        if settings.isAge14OrOlderForAbstinence || settings.isAge18OrOlderForFasting {
            return .sevenOrOlder
        }

        return .unknown
    }

    static func age(on date: Date, settings: RuleSettings) -> Int {
        let calendar = Calendar.gregorian
        let year = calendar.component(.year, from: date)
        guard isBirthYearKnown(settings: settings) else { return 0 }

        guard isFullBirthDateKnown(settings: settings) else {
            return max(0, year - settings.birthYear)
        }

        guard
            let birthDate = canonicalDate(
                year: settings.birthYear,
                month: settings.birthMonth,
                day: settings.birthDay)
        else {
            return max(0, year - settings.birthYear)
        }

        var age = year - settings.birthYear
        if let anniversary = calendar.date(byAdding: .year, value: age, to: birthDate) {
            let day = calendar.startOfDay(for: date)
            let anniversaryDay = calendar.startOfDay(for: anniversary)
            if day < anniversaryDay {
                age -= 1
            }
        }
        return max(0, age)
    }

    static func lentFridays(from start: Date, through end: Date) -> [Date] {
        var dates: [Date] = []
        var current = start

        while current <= end {
            if Calendar.gregorian.component(.weekday, from: current) == 6 {
                dates.append(current)
            }
            current = dateByAdding(days: 1, to: current)
        }

        return dates
    }

    static func fridaysOutsideLent(for year: Int, lentStart: Date, lentEnd: Date) -> [Date] {
        guard
            let yearStart = canonicalDate(year: year, month: 1, day: 1),
            let yearEnd = canonicalDate(year: year, month: 12, day: 31)
        else {
            return []
        }

        var dates: [Date] = []
        var current = yearStart

        while current <= yearEnd {
            let weekday = Calendar.gregorian.component(.weekday, from: current)
            let inLent = current >= lentStart && current <= lentEnd
            if weekday == 6, !inLent {
                dates.append(current)
            }
            current = dateByAdding(days: 1, to: current)
        }

        return dates
    }

    static func emberDays(for year: Int, ashWednesday: Date, pentecost: Date) -> [Date] {
        var dates: [Date] = []

        let firstSundayOfLent = nextWeekday(onOrAfter: dateByAdding(days: 1, to: ashWednesday), weekday: 1)
        dates.append(contentsOf: [3, 5, 6].map { dateByAdding(days: $0, to: firstSundayOfLent) })

        dates.append(contentsOf: [3, 5, 6].map { dateByAdding(days: $0, to: pentecost) })

        if let sep14 = canonicalDate(year: year, month: 9, day: 14) {
            dates.append(nextWeekday(after: sep14, weekday: 4))
            dates.append(nextWeekday(after: sep14, weekday: 6))
            dates.append(nextWeekday(after: sep14, weekday: 7))
        }

        if let dec13 = canonicalDate(year: year, month: 12, day: 13) {
            dates.append(nextWeekday(after: dec13, weekday: 4))
            dates.append(nextWeekday(after: dec13, weekday: 6))
            dates.append(nextWeekday(after: dec13, weekday: 7))
        }

        return Array(Set(dates)).sorted()
    }

    static func nextWeekday(onOrAfter date: Date, weekday target: Int) -> Date {
        var cursor = date
        while Calendar.gregorian.component(.weekday, from: cursor) != target {
            cursor = dateByAdding(days: 1, to: cursor)
        }
        return cursor
    }

    static func nextWeekday(after date: Date, weekday target: Int) -> Date {
        nextWeekday(onOrAfter: dateByAdding(days: 1, to: date), weekday: target)
    }

    static func dateByAdding(days: Int, to date: Date) -> Date {
        Calendar.gregorian.date(byAdding: .day, value: days, to: date) ?? date
    }

    static func epiphanySunday(for year: Int) -> Date? {
        for day in 2 ... 8 {
            guard let date = canonicalDate(year: year, month: 1, day: day) else { continue }
            if Calendar.gregorian.component(.weekday, from: date) == 1 {
                return date
            }
        }
        return canonicalDate(year: year, month: 1, day: 6)
    }

    static func firstSundayOfAdvent(year: Int) -> Date {
        let nov27 = canonicalDate(year: year, month: 11, day: 27) ?? Date()
        var cursor = nov27
        while Calendar.gregorian.component(.weekday, from: cursor) != 1 {
            cursor = dateByAdding(days: 1, to: cursor)
        }
        return cursor
    }

    static func holyFamilyDate(for year: Int) -> Date? {
        for day in 26 ... 31 {
            guard let date = canonicalDate(year: year, month: 12, day: day) else { continue }
            if Calendar.gregorian.component(.weekday, from: date) == 1 {
                return date
            }
        }
        return canonicalDate(year: year, month: 12, day: 30)
    }

    static func easterSunday(year: Int) -> Date {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1

        return canonicalDate(year: year, month: month, day: day) ?? Date()
    }

    static func canonicalDate(year: Int, month: Int, day: Int) -> Date? {
        Calendar.gregorian.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
    }
}
