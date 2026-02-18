@preconcurrency import Foundation

enum GuidanceScenario: String, CaseIterable, Identifiable {
  case normalDay
  case heavyLabor
  case travel
  case socialMeal
  case medicalRecovery

  var id: String { rawValue }

  var label: String {
    switch self {
    case .normalDay:
      return "Normal Day"
    case .heavyLabor:
      return "Heavy Labor"
    case .travel:
      return "Travel"
    case .socialMeal:
      return "Social Meal"
    case .medicalRecovery:
      return "Medical Recovery"
    }
  }
}

enum FoodGuidanceEngine {
  static func recommendations(
    for scenario: GuidanceScenario,
    settings: RuleSettings
  ) -> [String] {
    var lines: [String] = []
    let medicallyDispensed = settings.hasMedicalDispensation || scenario == .medicalRecovery

    if medicallyDispensed {
      lines.append("Your health comes first. A medical or pastoral dispensation likely applies.")
      lines.append(
        "Choose a substitute penance if possible (prayer, charity, Scripture, or another sacrifice)."
      )
      lines.append("Resume normal fasting only when it is prudent and safe.")
      return lines
    }

    lines.append("Abstinence: avoid meat from land animals; fish is usually permitted.")
    lines.append(
      "Fasting: one full meal and up to two smaller meals that together are less than a second full meal."
    )
    lines.append("Keep prayer and charity with the fast, not just food restriction.")

    switch scenario {
    case .normalDay:
      lines.append("Plan meals early so you can keep the discipline calmly and consistently.")
    case .heavyLabor:
      lines.append(
        "If heavy labor makes strict fasting unsafe, reduce food discipline and add another penance."
      )
      lines.append("Discuss a steady plan with your pastor if this is frequent.")
    case .travel:
      lines.append(
        "Travel days can limit options. Choose the best realistic penitential option available.")
      lines.append("If needed, simplify meals and add prayer or almsgiving as substitute penance.")
    case .socialMeal:
      lines.append(
        "Keep charity and discretion at shared meals; avoid drawing attention to yourself.")
      lines.append(
        "If a host menu is limited, choose the most prudent option and keep penitential intent.")
    case .medicalRecovery:
      break
    }

    return lines
  }
}

struct DailyFoodDecision {
  let obligationLine: String
  let allowed: [String]
  let avoid: [String]
  let rationale: String
  let sourceLine: String
}

struct MissedDayRecoveryPlan {
  let titleLine: String
  let summaryLine: String
  let steps: [String]
  let nextRequiredLine: String
}

enum DailyFoodDecisionEngine {
  static func decision(
    for observances: [Observance],
    settings: RuleSettings,
    date: Date = Date(),
    calendar: Calendar = .current
  ) -> DailyFoodDecision {
    let todayObservances = observances.filter { calendar.isDate($0.date, inSameDayAs: date) }
    let mandatoryToday = todayObservances.filter { $0.obligation == .mandatory }

    if settings.hasMedicalDispensation {
      return DailyFoodDecision(
        obligationLine: "Medical/pastoral dispensation is enabled in your profile.",
        allowed: ["Eat what is prudent and medically safe.", "Keep prayer/charity as substitute penance."],
        avoid: ["Avoid self-imposed rigor that harms health."],
        rationale: "Health and pastoral obedience take priority when obligations do not bind.",
        sourceLine: "Source: USCCB and pastoral guidance."
      )
    }

    let requiresFasting = mandatoryToday.contains {
      $0.kind == .fastAndAbstinence
    }
    let requiresAbstinence = mandatoryToday.contains {
      $0.kind == .fastAndAbstinence || $0.kind == .abstinence
    }

    if requiresFasting && requiresAbstinence {
      return DailyFoodDecision(
        obligationLine: "Today requires fasting and abstinence.",
        allowed: [
          "One full meal with up to two smaller meals.",
          "Fish, eggs, dairy, grains, fruits, and vegetables are generally permitted.",
        ],
        avoid: [
          "Meat from land animals (beef, pork, poultry).",
          "Eating patterns that effectively become a second full meal.",
        ],
        rationale: observanceReason(from: mandatoryToday),
        sourceLine: "Source: USCCB Fast & Abstinence norms."
      )
    }

    if requiresAbstinence {
      return DailyFoodDecision(
        obligationLine: "Today requires abstinence from meat.",
        allowed: [
          "Normal meal quantity is generally permitted.",
          "Fish, eggs, dairy, grains, fruits, and vegetables are generally permitted.",
        ],
        avoid: ["Meat from land animals (beef, pork, poultry)."],
        rationale: observanceReason(from: mandatoryToday),
        sourceLine: "Source: USCCB Fast & Abstinence norms."
      )
    }

    if !mandatoryToday.isEmpty {
      return DailyFoodDecision(
        obligationLine: "Today has a required observance but no mandatory food restriction.",
        allowed: ["Normal meals are generally permitted.", "Keep the day with prayer and Mass obligations."],
        avoid: [],
        rationale: observanceReason(from: mandatoryToday),
        sourceLine: "Source: USCCB liturgical norms."
      )
    }

    return DailyFoodDecision(
      obligationLine: "No mandatory food restriction today.",
      allowed: ["Normal meals are generally permitted.", "You may choose a voluntary penance."],
      avoid: [],
      rationale: "No mandatory fast/abstinence observance appears for today in your current profile.",
      sourceLine: "Source: USCCB Fast & Abstinence norms."
    )
  }

  private static func observanceReason(from observances: [Observance]) -> String {
    let titles = observances.map(\.title)
    if titles.isEmpty {
      return "No specific mandatory observance was detected."
    }
    if titles.count == 1 {
      return "This is based on \(titles[0])."
    }
    return "This is based on \(titles.joined(separator: ", "))."
  }
}

enum MissedDayRecoveryEngine {
  static func plan(
    observances: [Observance],
    statusesByID: [String: CompletionStatus],
    today: Date = Date(),
    calendar: Calendar = .current
  ) -> MissedDayRecoveryPlan? {
    let startOfToday = calendar.startOfDay(for: today)
    let missedObservances = observances.filter { observance in
      statusesByID[observance.id] == .missed
        && calendar.startOfDay(for: observance.date) <= startOfToday
    }

    guard let lastMissed = missedObservances.max(by: { $0.date < $1.date }) else {
      return nil
    }

    let nextRequired = observances.first { observance in
      observance.obligation == .mandatory
        && calendar.startOfDay(for: observance.date) > startOfToday
    }

    let nextRequiredLine: String
    if let nextRequired {
      nextRequiredLine =
        "Next required day: \(nextRequired.title) on \(nextRequired.date.formatted(date: .abbreviated, time: .omitted))."
    } else {
      nextRequiredLine = "No future required observances remain in this calendar year."
    }

    return MissedDayRecoveryPlan(
      titleLine:
        "Recent missed observance: \(lastMissed.title) (\(lastMissed.date.formatted(date: .abbreviated, time: .omitted))).",
      summaryLine:
        "Missing a day does not end your discipline. Recover with a practical next step today.",
      steps: [
        "Offer a short prayer of repentance and renew your intention.",
        "Choose one concrete recovery act today (charity, Scripture, Rosary, or a simplified meal).",
        "Plan the next required day now so it is easier to keep.",
      ],
      nextRequiredLine: nextRequiredLine
    )
  }
}

enum ObservanceQueryEngine {
  static func filter(
    observances: [Observance],
    query: String,
    filter: ObservanceFilter,
    window: CalendarWindow,
    sortOrder: ObservanceSortOrder,
    statusesByID: [String: CompletionStatus],
    now: Date,
    calendar: Calendar = .current
  ) -> [Observance] {
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    let startOfToday = calendar.startOfDay(for: now)
    let endOfNext30Days = calendar.date(byAdding: .day, value: 30, to: startOfToday)
    let filtered = observances.filter { observance in
      guard matchesFilter(observance, filter: filter, statusesByID: statusesByID) else {
        return false
      }
      guard
        matchesWindow(
          observance, window: window, startOfToday: startOfToday, endOfNext30Days: endOfNext30Days,
          calendar: calendar)
      else { return false }
      guard matchesQuery(observance, query: normalizedQuery) else { return false }
      return true
    }
    return filtered.sorted(by: sortPredicate(order: sortOrder))
  }

  private static func matchesFilter(
    _ observance: Observance,
    filter: ObservanceFilter,
    statusesByID: [String: CompletionStatus]
  ) -> Bool {
    switch filter {
    case .all:
      return true
    case .requiredOnly:
      return observance.obligation == .mandatory
    case .trackedOnly:
      return (statusesByID[observance.id] ?? .notStarted) != .notStarted
    }
  }

  private static func matchesWindow(
    _ observance: Observance,
    window: CalendarWindow,
    startOfToday: Date,
    endOfNext30Days: Date?,
    calendar: Calendar
  ) -> Bool {
    switch window {
    case .allYear:
      return true
    case .thisMonth:
      return calendar.isDate(observance.date, equalTo: startOfToday, toGranularity: .month)
        && calendar.isDate(observance.date, equalTo: startOfToday, toGranularity: .year)
    case .next30Days:
      guard let endOfNext30Days else { return false }
      let day = calendar.startOfDay(for: observance.date)
      return day >= startOfToday && day <= endOfNext30Days
    }
  }

  private static func matchesQuery(_ observance: Observance, query: String) -> Bool {
    guard !query.isEmpty else { return true }
    return observance.title.localizedCaseInsensitiveContains(query)
      || observance.kind.label.localizedCaseInsensitiveContains(query)
      || observance.obligation.label.localizedCaseInsensitiveContains(query)
      || (observance.detail?.localizedCaseInsensitiveContains(query) ?? false)
  }

  private static func sortPredicate(order: ObservanceSortOrder) -> (Observance, Observance) -> Bool {
    switch order {
    case .chronological:
      return { lhs, rhs in
        lhs.date == rhs.date ? lhs.title < rhs.title : lhs.date < rhs.date
      }
    case .requiredFirst:
      return { lhs, rhs in
        let lhsRank = obligationRank(lhs.obligation)
        let rhsRank = obligationRank(rhs.obligation)
        if lhsRank == rhsRank {
          return lhs.date == rhs.date ? lhs.title < rhs.title : lhs.date < rhs.date
        }
        return lhsRank < rhsRank
      }
    }
  }

  private static func obligationRank(_ obligation: Observance.Obligation) -> Int {
    switch obligation {
    case .mandatory:
      return 0
    case .optional:
      return 1
    case .notApplicable:
      return 2
    }
  }
}
