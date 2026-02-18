@preconcurrency import Foundation
import SwiftUI

enum ObservanceCalculator {
  private static let minimumSupportedBirthYear = 1900
  private static let cacheLock = NSLock()
  nonisolated(unsafe) private static var calendarCache: [CalendarCacheKey: [Observance]] = [:]

  private struct CalendarCacheKey: Hashable {
    let year: Int
    let settings: RuleSettings
  }

  private struct LiturgicalDates {
    let easter: Date
    let ashWednesday: Date
    let goodFriday: Date
    let easterVigil: Date
    let pentecost: Date
    let ascension: Date
  }

  static func ruleBundleMetadata() -> RuleBundleMetadata {
    RuleBundleRepository.snapshot().metadata
  }

  static func ruleBundleChanges() -> [RuleBundleChange] {
    RuleBundleRepository.snapshot().changes
  }

  static func ruleBundleAudit() -> RuleBundleAudit {
    RuleBundleRepository.snapshot().audit
  }

  static func makeCalendar(for year: Int, settings: RuleSettings) -> [Observance] {
    let cacheKey = CalendarCacheKey(year: year, settings: settings)
    if let cached = cachedCalendar(for: cacheKey) {
      return cached
    }

    var items: [Observance] = []
    let dates = liturgicalDates(for: year, settings: settings)

    items.append(fastAndAbstinenceObservance(title: "Ash Wednesday", date: dates.ashWednesday, settings: settings))
    items.append(fastAndAbstinenceObservance(title: "Good Friday", date: dates.goodFriday, settings: settings))

    for friday in lentFridays(from: dates.ashWednesday, through: dates.easterVigil) {
      if Calendar.gregorian.isDate(friday, inSameDayAs: dates.goodFriday) {
        continue
      }
      let unknownAgeProfile = !isBirthYearKnown(settings: settings)
      let required = isAbstinenceRequired(on: friday, settings: settings)
      items.append(
        makeObservance(
          "Friday of Lent",
          friday,
          .abstinence,
          unknownAgeProfile ? .optional : (required ? .mandatory : .notApplicable),
          required ? "No meat from mammals or poultry." : ageDispensationDetail(settings: settings)
        ))
    }

    for friday in fridaysOutsideLent(for: year, lentStart: dates.ashWednesday, lentEnd: dates.easterVigil) {
      let unknownAgeProfile = !isBirthYearKnown(settings: settings)
      let required = isAbstinenceRequired(on: friday, settings: settings)
      let detail = fridayPenanceDetail(mode: settings.fridayOutsideLentMode)
      items.append(
        makeObservance(
          "Friday Penance (Outside Lent)",
          friday,
          .fridayPenance,
          unknownAgeProfile ? .optional : (required ? .mandatory : .notApplicable),
          required ? detail : ageDispensationDetail(settings: settings)
        ))
    }

    for holyDay in holyDaysOfObligation(for: year, ascension: dates.ascension) {
      let obligation = holyDayObligation(title: holyDay.title, date: holyDay.date, settings: settings)
      items.append(makeObservance(holyDay.title, holyDay.date, .holyDay, obligation, holyDay.detail))
    }

    items.append(makeObservance("Easter Sunday", dates.easter, .feastDay, .optional, nil))
    items.append(makeObservance("Pentecost", dates.pentecost, .feastDay, .optional, nil))

    let emberDetail: String
    if settings.calendarMode == .traditional1962 {
      emberDetail = "Traditional calendar mode: Ember day of prayer, fasting, and abstinence."
    } else {
      emberDetail = "Optional observance in U.S. profile mode."
    }
    for emberDate in emberDays(for: year, ashWednesday: dates.ashWednesday, pentecost: dates.pentecost) {
      items.append(makeObservance("Ember Day", emberDate, .optionalEmber, .optional, emberDetail))
    }

    let generated = items.sorted { $0.date < $1.date }
    storeCalendar(generated, for: cacheKey)
    return generated
  }

  private static func cachedCalendar(for key: CalendarCacheKey) -> [Observance]? {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    return calendarCache[key]
  }

  private static func storeCalendar(_ observances: [Observance], for key: CalendarCacheKey) {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    calendarCache[key] = observances
  }

  private static func holyDaysOfObligation(for year: Int, ascension: Date) -> [(title: String, date: Date, detail: String?)] {
    var holyDays: [(String, Date, String?)] = []

    let fixed: [(String, Int, Int)] = [
      ("Mary, Mother of God", 1, 1),
      ("Assumption of the Blessed Virgin Mary", 8, 15),
      ("All Saints", 11, 1),
      ("Christmas", 12, 25),
    ]

    for item in fixed {
      if let date = Calendar.gregorian.date(from: DateComponents(year: year, month: item.1, day: item.2)) {
        let detail = holyDayDetail(title: item.0, date: date, transferred: false)
        holyDays.append((item.0, date, detail))
      }
    }

    if let dec8 = Calendar.gregorian.date(from: DateComponents(year: year, month: 12, day: 8)) {
      if Calendar.gregorian.component(.weekday, from: dec8) == 1 {
        let dec9 = dateByAdding(days: 1, to: dec8)
        holyDays.append(("Immaculate Conception (Transferred)", dec9, holyDayDetail(title: "Immaculate Conception", date: dec9, transferred: true)))
      } else {
        holyDays.append(("Immaculate Conception", dec8, holyDayDetail(title: "Immaculate Conception", date: dec8, transferred: false)))
      }
    }

    holyDays.append(("Ascension", ascension, "Observed on Thursday or transferred to Sunday by province; obligation depends on local observance rules."))

    return holyDays
  }

  private static func liturgicalDates(for year: Int, settings: RuleSettings) -> LiturgicalDates {
    let easter = easterSunday(year: year)
    let ashWednesday = dateByAdding(days: -46, to: easter)
    let goodFriday = dateByAdding(days: -2, to: easter)
    let easterVigil = dateByAdding(days: -1, to: easter)
    let pentecost = dateByAdding(days: 49, to: easter)
    let ascension = settings.ascensionObservance == .sunday ? dateByAdding(days: 42, to: easter) : dateByAdding(days: 39, to: easter)
    return LiturgicalDates(
      easter: easter,
      ashWednesday: ashWednesday,
      goodFriday: goodFriday,
      easterVigil: easterVigil,
      pentecost: pentecost,
      ascension: ascension
    )
  }

  private static func fastAndAbstinenceObservance(title: String, date: Date, settings: RuleSettings) -> Observance {
    if !isBirthYearKnown(settings: settings) {
      return makeObservance(
        title,
        date,
        .fastAndAbstinence,
        .optional,
        ageDispensationDetail(settings: settings)
      )
    }

    let fastRequired = isFastRequired(on: date, settings: settings)
    let abstinenceRequired = isAbstinenceRequired(on: date, settings: settings)
    return makeObservance(
      title,
      date,
      .fastAndAbstinence,
      (fastRequired && abstinenceRequired) ? .mandatory : .notApplicable,
      fastDetail(settings: settings)
    )
  }

  private static func holyDayDetail(title: String, date: Date, transferred: Bool) -> String {
    let weekday = Calendar.gregorian.component(.weekday, from: date)
    let isSaturdayOrMonday = (weekday == 7 || weekday == 2)

    switch title {
    case "Mary, Mother of God", "Assumption of the Blessed Virgin Mary", "All Saints":
      if isSaturdayOrMonday {
        return "In U.S. norms, obligation may be abrogated this year because this holy day falls on Saturday or Monday."
      }
      return "Holy Day of Obligation in the U.S., subject to local episcopal conference directives."
    case "Immaculate Conception":
      if transferred {
        return "Transferred from Sunday, December 8. In many U.S. provinces this remains obligatory; confirm local directives."
      }
      return "Holy Day of Obligation in the U.S."
    case "Christmas":
      return "Holy Day of Obligation in the U.S."
    default:
      return "Holy Day of Obligation in the U.S., subject to local episcopal conference directives."
    }
  }

  private static func holyDayObligation(title: String, date: Date, settings: RuleSettings) -> Observance.Obligation {
    guard isBirthYearKnown(settings: settings) else {
      return .optional
    }
    let age = age(on: date, birthYear: settings.birthYear)
    guard age >= 7 else { return .notApplicable }

    let weekday = Calendar.gregorian.component(.weekday, from: date)
    let isSaturdayOrMonday = (weekday == 7 || weekday == 2)

    if title == "Mary, Mother of God" || title == "Assumption of the Blessed Virgin Mary" || title == "All Saints" {
      return isSaturdayOrMonday ? .optional : .mandatory
    }

    if title.contains("Immaculate Conception") || title == "Christmas" || title == "Ascension" {
      return .mandatory
    }

    return .optional
  }

  private static func makeObservance(
    _ title: String,
    _ date: Date,
    _ kind: Observance.Kind,
    _ obligation: Observance.Obligation,
    _ detail: String?
  ) -> Observance {
    let dayKey = DateFormatter.dayKey.string(from: date)
    let citations = defaultCitations(for: title, kind: kind)
    let rationale = defaultRationale(for: title, kind: kind, obligation: obligation)
    return Observance(
      id: "\(dayKey)|\(title)|\(kind.rawValue)",
      title: title,
      date: date,
      kind: kind,
      obligation: obligation,
      detail: detail,
      rationale: rationale,
      citations: citations,
      ruleVersion: ruleBundleMetadata().version
    )
  }

  private static func defaultRationale(
    for title: String,
    kind: Observance.Kind,
    obligation: Observance.Obligation
  ) -> String {
    switch kind {
    case .fastAndAbstinence:
      return obligation == .mandatory
        ? "\(title) is a universal fast/abstinence day for the Latin Church in this profile."
        : "\(title) is listed, but your profile indicates the obligation does not strictly bind."
    case .abstinence:
      return "Fridays in Lent are days of abstinence for those bound by age and health norms."
    case .fridayPenance:
      return "Outside Lent Friday penance follows your selected U.S. profile mode."
    case .holyDay:
      return "Holy day obligation may vary by universal, national, and local norms."
    case .feastDay:
      return "Feast day included for liturgical awareness and devotional planning."
    case .optionalEmber:
      return "Ember days are optional in this mode and offered as devotional practice."
    }
  }

  private static func defaultCitations(for title: String, kind: Observance.Kind) -> [RuleCitation] {
    switch kind {
    case .fastAndAbstinence, .abstinence:
      return [
        RuleCitation(authority: .universalLaw, title: "Code of Canon Law", shortReference: "Can. 1249-1253"),
        RuleCitation(authority: .usccb, title: "Pastoral Statement on Penance and Abstinence", shortReference: "USCCB 1966"),
      ]
    case .fridayPenance:
      return [
        RuleCitation(authority: .usccb, title: "Penance and Abstinence Guidance", shortReference: "USCCB Norms"),
        RuleCitation(authority: .pastoral, title: "Pastoral Direction", shortReference: "Consult pastor for substitutions"),
      ]
    case .holyDay:
      var citations = [
        RuleCitation(authority: .universalLaw, title: "Code of Canon Law", shortReference: "Can. 1246-1248"),
        RuleCitation(authority: .usccb, title: "U.S. Holy Days", shortReference: "USCCB Liturgical Norms"),
      ]
      if title.contains("Ascension") || title.contains("Immaculate") {
        citations.append(RuleCitation(authority: .pastoral, title: "Particular Law", shortReference: "Province dependent"))
      }
      return citations
    case .feastDay:
      return [
        RuleCitation(authority: .pastoral, title: "Liturgical Calendar", shortReference: "Devotional observance")
      ]
    case .optionalEmber:
      return [
        RuleCitation(authority: .pastoral, title: "Traditional Ember Practice", shortReference: "Optional in U.S. usage")
      ]
    }
  }

  private static func fastDetail(settings: RuleSettings) -> String {
    if settings.hasMedicalDispensation {
      return "Dispensation enabled in your profile. Follow your pastor and medical guidance."
    }
    return "For ages 18-59: one full meal and two smaller meals (not equal to a second full meal)."
  }

  private static func fridayPenanceDetail(mode: RuleSettings.FridayOutsideLentMode) -> String {
    switch mode {
    case .abstainFromMeat:
      return "Outside Lent: abstain from meat as your Friday penance."
    case .substitutePenance:
      return "Outside Lent: choose a penitential act (e.g., extra prayer, charity, or another sacrifice)."
    }
  }

  private static func ageDispensationDetail(settings: RuleSettings) -> String {
    if !isBirthYearKnown(settings: settings) {
      return "Set birth year in Profile & Rules to determine age-based obligations."
    }
    if settings.hasMedicalDispensation {
      return "Not required due to medical dispensation setting."
    }
    return "Not required for your profile age setting."
  }

  private static func isBirthYearKnown(settings: RuleSettings) -> Bool {
    settings.birthYear >= minimumSupportedBirthYear
  }

  private static func isFastRequired(on date: Date, settings: RuleSettings) -> Bool {
    guard isBirthYearKnown(settings: settings) else { return false }
    let age = age(on: date, birthYear: settings.birthYear)
    return (18...59).contains(age) && !settings.hasMedicalDispensation
  }

  private static func isAbstinenceRequired(on date: Date, settings: RuleSettings) -> Bool {
    guard isBirthYearKnown(settings: settings) else { return false }
    let age = age(on: date, birthYear: settings.birthYear)
    return age >= 14 && !settings.hasMedicalDispensation
  }

  private static func age(on date: Date, birthYear: Int) -> Int {
    let year = Calendar.gregorian.component(.year, from: date)
    return max(0, year - birthYear)
  }

  private static func lentFridays(from start: Date, through end: Date) -> [Date] {
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

  private static func fridaysOutsideLent(for year: Int, lentStart: Date, lentEnd: Date) -> [Date] {
    guard
      let yearStart = Calendar.gregorian.date(from: DateComponents(year: year, month: 1, day: 1)),
      let yearEnd = Calendar.gregorian.date(from: DateComponents(year: year, month: 12, day: 31))
    else {
      return []
    }

    var dates: [Date] = []
    var current = yearStart

    while current <= yearEnd {
      let weekday = Calendar.gregorian.component(.weekday, from: current)
      let inLent = current >= lentStart && current <= lentEnd
      if weekday == 6 && !inLent {
        dates.append(current)
      }
      current = dateByAdding(days: 1, to: current)
    }

    return dates
  }

  private static func emberDays(for year: Int, ashWednesday: Date, pentecost: Date) -> [Date] {
    var dates: [Date] = []

    let firstSundayOfLent = nextWeekday(onOrAfter: dateByAdding(days: 1, to: ashWednesday), weekday: 1)
    dates.append(contentsOf: [3, 5, 6].map { dateByAdding(days: $0, to: firstSundayOfLent) })

    dates.append(contentsOf: [3, 5, 6].map { dateByAdding(days: $0, to: pentecost) })

    if let sep14 = Calendar.gregorian.date(from: DateComponents(year: year, month: 9, day: 14)) {
      dates.append(nextWeekday(after: sep14, weekday: 4))
      dates.append(nextWeekday(after: sep14, weekday: 6))
      dates.append(nextWeekday(after: sep14, weekday: 7))
    }

    if let dec13 = Calendar.gregorian.date(from: DateComponents(year: year, month: 12, day: 13)) {
      dates.append(nextWeekday(after: dec13, weekday: 4))
      dates.append(nextWeekday(after: dec13, weekday: 6))
      dates.append(nextWeekday(after: dec13, weekday: 7))
    }

    return Array(Set(dates)).sorted()
  }

  private static func nextWeekday(onOrAfter date: Date, weekday target: Int) -> Date {
    var cursor = date
    while Calendar.gregorian.component(.weekday, from: cursor) != target {
      cursor = dateByAdding(days: 1, to: cursor)
    }
    return cursor
  }

  private static func nextWeekday(after date: Date, weekday target: Int) -> Date {
    nextWeekday(onOrAfter: dateByAdding(days: 1, to: date), weekday: target)
  }

  private static func dateByAdding(days: Int, to date: Date) -> Date {
    Calendar.gregorian.date(byAdding: .day, value: days, to: date) ?? date
  }

  private static func easterSunday(year: Int) -> Date {
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

    return Calendar.gregorian.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
  }
}
