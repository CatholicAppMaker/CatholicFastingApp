@preconcurrency import Foundation
import SwiftUI

enum ObservanceCalculator {
  private static let minimumSupportedBirthYear = 1900
  private static let cacheLock = NSLock()
  private nonisolated(unsafe) static var calendarCache: [CalendarCacheKey: [Observance]] = [:]

  private struct CalendarCacheKey: Hashable {
    let year: Int
    let settings: RuleSettings
    let timeZoneIdentifier: String
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
    let cacheKey = CalendarCacheKey(
      year: year,
      settings: settings,
      timeZoneIdentifier: Calendar.gregorian.timeZone.identifier
    )
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
      let required = isAbstinenceRequired(on: friday, settings: settings)
      items.append(
        makeObservance(
          "Friday of Lent",
          friday,
          .abstinence,
          required ? .mandatory : .notApplicable,
          required ? "No meat from mammals or poultry." : ageDispensationDetail(settings: settings)
        )
      )
    }

    for friday in fridaysOutsideLent(for: year, lentStart: dates.ashWednesday, lentEnd: dates.easterVigil) {
      let required = isAbstinenceRequired(on: friday, settings: settings)
      let detail = fridayPenanceDetail(mode: settings.fridayOutsideLentMode)
      items.append(
        makeObservance(
          "Friday Penance (Outside Lent)",
          friday,
          .fridayPenance,
          required ? .mandatory : .notApplicable,
          required ? detail : ageDispensationDetail(settings: settings)
        )
      )
    }

    for holyDay in holyDaysOfObligation(for: year, ascension: dates.ascension) {
      let obligation = holyDayObligation(title: holyDay.title, date: holyDay.date, settings: settings)
      items.append(makeObservance(holyDay.title, holyDay.date, .holyDay, obligation, holyDay.detail))
    }

    for feast in feastAndSolemnityDays(for: year, dates: dates) {
      items.append(makeObservance(feast.title, feast.date, .feastDay, .notApplicable, feast.detail))
    }
    for memorial in memorialDays(for: year, dates: dates) {
      items.append(makeObservance(memorial.title, memorial.date, .memorialDay, .notApplicable, memorial.detail))
    }

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

  static func resetCacheForTesting() {
    cacheLock.lock()
    defer { cacheLock.unlock() }
    calendarCache.removeAll()
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
      if let date = canonicalDate(year: year, month: item.1, day: item.2) {
        let detail = holyDayDetail(title: item.0, date: date, transferred: false)
        holyDays.append((item.0, date, detail))
      }
    }

    if let dec8 = canonicalDate(year: year, month: 12, day: 8) {
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

    if fastRequired && abstinenceRequired {
      return makeObservance(
        title,
        date,
        .fastAndAbstinence,
        .mandatory,
        fastDetail(settings: settings)
      )
    }

    if abstinenceRequired {
      return makeObservance(
        title,
        date,
        .abstinence,
        .mandatory,
        "Abstinence from meat is required. Fasting does not bind for your age profile."
      )
    }

    return makeObservance(
      title,
      date,
      .fastAndAbstinence,
      .notApplicable,
      ageDispensationDetail(settings: settings)
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
        return "Transferred from Sunday, December 8. In U.S. usage, the Mass obligation does not transfer to Monday."
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
    let age = age(on: date, settings: settings)
    guard age >= 7 else { return .notApplicable }

    let weekday = Calendar.gregorian.component(.weekday, from: date)
    let isSaturdayOrMonday = (weekday == 7 || weekday == 2)

    if title == "Mary, Mother of God" || title == "Assumption of the Blessed Virgin Mary" || title == "All Saints" {
      return isSaturdayOrMonday ? .optional : .mandatory
    }

    if title.contains("Immaculate Conception") {
      return title.contains("(Transferred)") ? .optional : .mandatory
    }

    if title == "Christmas" || title == "Ascension" {
      return .mandatory
    }

    return .optional
  }

  private static func feastAndSolemnityDays(
    for year: Int,
    dates: LiturgicalDates
  ) -> [(title: String, date: Date, detail: String?)] {
    var entries: [(String, Date, String?)] = []

    func append(_ title: String, _ date: Date, detail: String? = nil) {
      entries.append((title, date, detail ?? "Included from the U.S. liturgical calendar for devotional planning."))
    }

    if let epiphany = epiphanySunday(for: year) {
      append("Epiphany of the Lord", epiphany)
      append("The Baptism of the Lord", nextWeekday(after: epiphany, weekday: 1))
    }

    if let presentation = canonicalDate(year: year, month: 2, day: 2) {
      append("The Presentation of the Lord", presentation)
    }
    if let joseph = canonicalDate(year: year, month: 3, day: 19) {
      append("Saint Joseph, Spouse of the Blessed Virgin Mary", joseph)
    }
    if let annunciation = canonicalDate(year: year, month: 3, day: 25) {
      append("The Annunciation of the Lord", annunciation)
    }

    append("Palm Sunday of the Passion of the Lord", dateByAdding(days: -7, to: dates.easter))
    append("Holy Thursday (Evening Mass of the Lord's Supper)", dateByAdding(days: -3, to: dates.easter))
    append("Easter Sunday", dates.easter)
    append("Pentecost", dates.pentecost)

    let trinity = dateByAdding(days: 56, to: dates.easter)
    append("The Most Holy Trinity", trinity)
    append("The Most Holy Body and Blood of Christ", dateByAdding(days: 63, to: dates.easter))
    append("The Most Sacred Heart of Jesus", dateByAdding(days: 68, to: dates.easter))

    if let john = canonicalDate(year: year, month: 6, day: 24) {
      append("The Nativity of Saint John the Baptist", john)
    }
    if let peterPaul = canonicalDate(year: year, month: 6, day: 29) {
      append("Saints Peter and Paul, Apostles", peterPaul)
    }
    if let transfiguration = canonicalDate(year: year, month: 8, day: 6) {
      append("The Transfiguration of the Lord", transfiguration)
    }
    if let exaltation = canonicalDate(year: year, month: 9, day: 14) {
      append("The Exaltation of the Holy Cross", exaltation)
    }
    if let guadalupe = canonicalDate(year: year, month: 12, day: 12) {
      append("Our Lady of Guadalupe", guadalupe)
    }

    append("Our Lord Jesus Christ, King of the Universe", dateByAdding(days: -7, to: firstSundayOfAdvent(year: year)))
    if let holyFamily = holyFamilyDate(for: year) {
      append("The Holy Family of Jesus, Mary, and Joseph", holyFamily)
    }

    for dataEntry in USCCBYearlyCalendarData.entries(for: year) where dataEntry.kind == .feastDay {
      if let date = canonicalDate(year: year, month: dataEntry.month, day: dataEntry.day) {
        append(dataEntry.title, date, detail: dataEntry.detail)
      }
    }

    // Ensure stable output without accidental duplicates.
    var seen = Set<String>()
    return entries.filter { entry in
      let key = "\(DateFormatter.dayKey.string(from: entry.1))|\(entry.0)"
      if seen.contains(key) {
        return false
      }
      seen.insert(key)
      return true
    }
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
      if title == "Ash Wednesday" || title == "Good Friday" {
        return "\(title) requires abstinence for those bound by age and health norms."
      }
      return "Fridays in Lent are days of abstinence for those bound by age and health norms."
    case .fridayPenance:
      return "Outside Lent Friday penance follows your selected U.S. profile mode."
    case .holyDay:
      return "Holy day obligation may vary by universal, national, and local norms."
    case .feastDay:
      return "Celebrate this feast day; it is not a fasting obligation."
    case .memorialDay:
      return "Celebrate this memorial day; it is not a fasting obligation."
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
    case .memorialDay:
      return [
        RuleCitation(authority: .pastoral, title: "Liturgical Calendar", shortReference: "Memorial observance")
      ]
    case .optionalEmber:
      return [
        RuleCitation(authority: .pastoral, title: "Traditional Ember Practice", shortReference: "Optional in U.S. usage")
      ]
    }
  }

  private static func memorialDays(
    for year: Int,
    dates: LiturgicalDates
  ) -> [(title: String, date: Date, detail: String?)] {
    var items: [(String, Date, String?)] = []
    let defaultDetail = "Memorial included for liturgical awareness in the U.S. calendar profile."

    for entry in USCCBMemorialCatalog.fixed {
      if let date = canonicalDate(year: year, month: entry.month, day: entry.day) {
        items.append((entry.title, date, defaultDetail))
      }
    }

    let motherChurch = dateByAdding(days: 50, to: dates.easter)
    items.append(("Blessed Virgin Mary, Mother of the Church", motherChurch, defaultDetail))
    let immaculateHeart = dateByAdding(days: 69, to: dates.easter)
    items.append(("The Immaculate Heart of the Blessed Virgin Mary", immaculateHeart, defaultDetail))

    for dataEntry in USCCBYearlyCalendarData.entries(for: year) where dataEntry.kind == .memorialDay {
      if let date = canonicalDate(year: year, month: dataEntry.month, day: dataEntry.day) {
        items.append((dataEntry.title, date, dataEntry.detail))
      }
    }

    var seen = Set<String>()
    return items.filter { item in
      let key = "\(DateFormatter.dayKey.string(from: item.1))|\(item.0)"
      if seen.contains(key) {
        return false
      }
      seen.insert(key)
      return true
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
    if settings.hasMedicalDispensation {
      return "Not required due to medical dispensation setting."
    }
    return "Not required for your age eligibility toggle settings."
  }

  private static func isBirthYearKnown(settings: RuleSettings) -> Bool {
    settings.birthYear >= minimumSupportedBirthYear
  }

  private static func isFullBirthDateKnown(settings: RuleSettings) -> Bool {
    guard isBirthYearKnown(settings: settings) else { return false }
    guard settings.hasFullBirthDate else { return false }
    return true
  }

  private static func isFastRequired(on _: Date, settings: RuleSettings) -> Bool {
    guard !settings.hasMedicalDispensation else { return false }
    return settings.isAge18OrOlderForFasting
  }

  private static func isAbstinenceRequired(on _: Date, settings: RuleSettings) -> Bool {
    guard !settings.hasMedicalDispensation else { return false }
    return settings.isAge14OrOlderForAbstinence
  }

  private static func age(on date: Date, settings: RuleSettings) -> Int {
    let calendar = Calendar.gregorian
    let year = calendar.component(.year, from: date)
    guard isBirthYearKnown(settings: settings) else { return 0 }

    // Legacy profiles may only have a birth year. Keep behavior stable in that case.
    guard isFullBirthDateKnown(settings: settings) else {
      return max(0, year - settings.birthYear)
    }

    guard
      let birthDate = canonicalDate(
        year: settings.birthYear, month: settings.birthMonth, day: settings.birthDay
      )
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

  private static func emberDays(for year: Int, ashWednesday: Date, pentecost: Date) -> [Date] {
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

  private static func epiphanySunday(for year: Int) -> Date? {
    for day in 2...8 {
      guard let date = canonicalDate(year: year, month: 1, day: day) else { continue }
      if Calendar.gregorian.component(.weekday, from: date) == 1 {
        return date
      }
    }
    return canonicalDate(year: year, month: 1, day: 6)
  }

  private static func firstSundayOfAdvent(year: Int) -> Date {
    let nov27 = canonicalDate(year: year, month: 11, day: 27) ?? Date()
    var cursor = nov27
    while Calendar.gregorian.component(.weekday, from: cursor) != 1 {
      cursor = dateByAdding(days: 1, to: cursor)
    }
    return cursor
  }

  private static func holyFamilyDate(for year: Int) -> Date? {
    for day in 26...31 {
      guard let date = canonicalDate(year: year, month: 12, day: day) else { continue }
      if Calendar.gregorian.component(.weekday, from: date) == 1 {
        return date
      }
    }
    return canonicalDate(year: year, month: 12, day: 30)
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

    return canonicalDate(year: year, month: month, day: day) ?? Date()
  }

  private static func canonicalDate(year: Int, month: Int, day: Int) -> Date? {
    Calendar.gregorian.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
  }
}
