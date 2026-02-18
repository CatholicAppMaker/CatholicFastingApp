@preconcurrency import Foundation

enum LiturgicalSeason: String {
  case advent
  case christmas
  case lent
  case easter
  case ordinary

  var label: String {
    switch self {
    case .advent:
      return "Advent"
    case .christmas:
      return "Christmas"
    case .lent:
      return "Lent"
    case .easter:
      return "Easter"
    case .ordinary:
      return "Ordinary Time"
    }
  }
}

enum LiturgicalSeasonThemeEngine {
  static func season(for date: Date, calendar: Calendar = .gregorian) -> LiturgicalSeason {
    let year = calendar.component(.year, from: date)
    let startOfDay = calendar.startOfDay(for: date)

    let easter = easterSunday(year: year, calendar: calendar)
    let ashWednesday = dateByAdding(days: -46, to: easter, calendar: calendar)
    let pentecost = dateByAdding(days: 49, to: easter, calendar: calendar)
    let holySaturday = dateByAdding(days: -1, to: easter, calendar: calendar)

    if startOfDay >= ashWednesday && startOfDay <= holySaturday {
      return .lent
    }
    if startOfDay >= easter && startOfDay <= pentecost {
      return .easter
    }

    if isInChristmasSeason(date: startOfDay, calendar: calendar) {
      return .christmas
    }

    let adventStart = firstSundayOfAdvent(year: year, calendar: calendar)
    let christmasEve = calendar.date(from: DateComponents(year: year, month: 12, day: 24)) ?? startOfDay
    if startOfDay >= adventStart && startOfDay <= christmasEve {
      return .advent
    }

    return .ordinary
  }

  private static func isInChristmasSeason(date: Date, calendar: Calendar) -> Bool {
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)

    if month == 12 {
      let christmas = calendar.date(from: DateComponents(year: year, month: 12, day: 25)) ?? date
      let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) ?? date
      return date >= christmas && date <= endOfYear
    }

    if month == 1 {
      let christmas = calendar.date(from: DateComponents(year: year - 1, month: 12, day: 25)) ?? date
      let baptism = calendar.date(from: DateComponents(year: year, month: 1, day: 13)) ?? date
      return date >= christmas && date <= baptism
    }

    return false
  }

  private static func firstSundayOfAdvent(year: Int, calendar: Calendar) -> Date {
    let nov27 = calendar.date(from: DateComponents(year: year, month: 11, day: 27)) ?? Date()
    var cursor = nov27
    while calendar.component(.weekday, from: cursor) != 1 {
      cursor = dateByAdding(days: 1, to: cursor, calendar: calendar)
    }
    return cursor
  }

  private static func dateByAdding(days: Int, to date: Date, calendar: Calendar) -> Date {
    calendar.date(byAdding: .day, value: days, to: date) ?? date
  }

  private static func easterSunday(year: Int, calendar: Calendar) -> Date {
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
    return calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
  }
}
