@preconcurrency import Foundation

struct PremiumSeasonPlan: Hashable {
  let titleLine: String
  let focusLine: String
  let practices: [String]
  let fastingIntensity: String
}

enum PremiumSeasonPlanEngine {
  static func plan(for season: LiturgicalSeason, settings: RuleSettings) -> PremiumSeasonPlan {
    if settings.hasMedicalDispensation {
      return PremiumSeasonPlan(
        titleLine: "Medical/Pastoral Plan",
        focusLine: "Use a moderated discipline with your pastor's guidance.",
        practices: [
          "Keep a fixed morning and evening prayer rhythm.",
          "Choose one charitable act each week.",
          "Use food discipline only as health allows.",
        ],
        fastingIntensity: "Gentle"
      )
    }

    switch season {
    case .advent:
      return PremiumSeasonPlan(
        titleLine: "Advent Preparation Plan",
        focusLine: "Watchfulness, restraint, and expectation of the Lord.",
        practices: [
          "Fast lightly on Wednesdays and Fridays.",
          "Add one weekday Mass when possible.",
          "Set one concrete almsgiving commitment.",
        ],
        fastingIntensity: "Moderate"
      )
    case .christmas:
      return PremiumSeasonPlan(
        titleLine: "Christmas Joy Plan",
        focusLine: "Celebrate with gratitude while keeping sobriety.",
        practices: [
          "Keep Friday penance with deliberate charity.",
          "Pray a brief thanksgiving after each meal.",
          "Avoid unnecessary excess for one chosen category.",
        ],
        fastingIntensity: "Light"
      )
    case .lent:
      return PremiumSeasonPlan(
        titleLine: "Lenten Discipline Plan",
        focusLine: "Repentance, conversion, and generous self-denial.",
        practices: [
          "Observe all required fast/abstinence days with planning.",
          "Keep one additional personal fast each week.",
          "Pair every fast with prayer and almsgiving.",
        ],
        fastingIntensity: "Strong"
      )
    case .easter:
      return PremiumSeasonPlan(
        titleLine: "Easter Fidelity Plan",
        focusLine: "Sustain the fruits of Lent with steady habits.",
        practices: [
          "Maintain Friday penance without interruption.",
          "Offer one act of encouragement or mercy weekly.",
          "Review your rule of life every Sunday evening.",
        ],
        fastingIntensity: "Light"
      )
    case .ordinary:
      return PremiumSeasonPlan(
        titleLine: "Ordinary Time Rule of Life",
        focusLine: "Consistency in ordinary days forms long-term holiness.",
        practices: [
          "Choose a fixed weekly fasting day.",
          "Keep Friday penance intentionally.",
          "Track completion and review each weekend.",
        ],
        fastingIntensity: "Moderate"
      )
    }
  }
}

struct PremiumReminderRecommendation: Hashable {
  let shouldEnableDailySupport: Bool
  let shouldEnableMorning: Bool
  let shouldEnableEvening: Bool
  let summaryLine: String
}

enum PremiumReminderPlanner {
  static func recommendation(
    observances: [Observance],
    statusesByID: [String: CompletionStatus],
    now: Date = Date(),
    calendar: Calendar = .current
  ) -> PremiumReminderRecommendation {
    let startOfToday = calendar.startOfDay(for: now)
    let recentWindowStart = calendar.date(byAdding: .day, value: -30, to: startOfToday) ?? startOfToday
    let upcomingWindowEnd = calendar.date(byAdding: .day, value: 14, to: startOfToday) ?? startOfToday

    let recent = observances.filter { item in
      let day = calendar.startOfDay(for: item.date)
      return day >= recentWindowStart && day <= startOfToday && item.obligation != .notApplicable
    }
    let upcomingRequired = observances.filter { item in
      let day = calendar.startOfDay(for: item.date)
      return day >= startOfToday && day <= upcomingWindowEnd && item.obligation == .mandatory
    }

    let completedRecent = recent.filter { statusesByID[$0.id]?.countsTowardProgress == true }.count
    let missedRecent = recent.filter { statusesByID[$0.id] == .missed }.count
    let completionRate =
      recent.isEmpty ? 1.0 : Double(completedRecent) / Double(recent.count)

    if missedRecent >= 2 || completionRate < 0.65 {
      return PremiumReminderRecommendation(
        shouldEnableDailySupport: true,
        shouldEnableMorning: true,
        shouldEnableEvening: true,
        summaryLine:
          "Recovery mode: enable both morning and evening reminders for the next 2 weeks."
      )
    }

    if !upcomingRequired.isEmpty {
      return PremiumReminderRecommendation(
        shouldEnableDailySupport: true,
        shouldEnableMorning: true,
        shouldEnableEvening: false,
        summaryLine:
          "Preparation mode: keep morning reminders on for upcoming required observances."
      )
    }

    return PremiumReminderRecommendation(
      shouldEnableDailySupport: true,
      shouldEnableMorning: false,
      shouldEnableEvening: true,
      summaryLine: "Maintenance mode: evening examen reminders are enough for your current rhythm."
    )
  }
}

struct PremiumSeasonCompletionRow: Hashable, Identifiable {
  let id: String
  let season: LiturgicalSeason
  let completedCount: Int
  let totalCount: Int

  var completionPercent: Int {
    guard totalCount > 0 else { return 0 }
    let rate = (Double(completedCount) / Double(totalCount)) * 100
    return Int(rate.rounded())
  }
}

struct PremiumAnalyticsSummary: Hashable {
  let requiredCompletionPercent: Int
  let overallCompletionPercent: Int
  let missedCount: Int
  let substitutedCount: Int
  let intermittentTargetHitPercent: Int
  let seasonRows: [PremiumSeasonCompletionRow]
}

enum PremiumAnalyticsEngine {
  static func summary(
    observances: [Observance],
    statusesByID: [String: CompletionStatus],
    sessions: [IntermittentFastSession]
  ) -> PremiumAnalyticsSummary {
    let required = observances.filter { $0.obligation == .mandatory }
    let actionable = observances.filter { $0.obligation != .notApplicable }

    let requiredCompleted = required.filter { statusesByID[$0.id]?.countsTowardProgress == true }.count
    let actionableCompleted = actionable.filter { statusesByID[$0.id]?.countsTowardProgress == true }.count
    let missedCount = statusesByID.values.filter { $0 == .missed }.count
    let substitutedCount = statusesByID.values.filter { $0 == .substituted }.count

    let recentSessions = sessions.prefix(30)
    let hitTarget = recentSessions.filter(\.completedTarget).count
    let intermittentHitPercent =
      recentSessions.isEmpty ? 0 : Int((Double(hitTarget) / Double(recentSessions.count) * 100).rounded())

    var seasonalTotals: [LiturgicalSeason: (done: Int, total: Int)] = [:]
    for item in actionable {
      let season = LiturgicalSeasonThemeEngine.season(for: item.date)
      var entry = seasonalTotals[season] ?? (done: 0, total: 0)
      entry.total += 1
      if statusesByID[item.id]?.countsTowardProgress == true {
        entry.done += 1
      }
      seasonalTotals[season] = entry
    }

    let orderedSeasons: [LiturgicalSeason] = [.advent, .christmas, .lent, .easter, .ordinary]
    let rows = orderedSeasons.compactMap { season -> PremiumSeasonCompletionRow? in
      guard let data = seasonalTotals[season] else { return nil }
      return PremiumSeasonCompletionRow(
        id: season.rawValue,
        season: season,
        completedCount: data.done,
        totalCount: data.total
      )
    }

    return PremiumAnalyticsSummary(
      requiredCompletionPercent: percent(done: requiredCompleted, total: required.count),
      overallCompletionPercent: percent(done: actionableCompleted, total: actionable.count),
      missedCount: missedCount,
      substitutedCount: substitutedCount,
      intermittentTargetHitPercent: intermittentHitPercent,
      seasonRows: rows
    )
  }

  private static func percent(done: Int, total: Int) -> Int {
    guard total > 0 else { return 0 }
    return Int((Double(done) / Double(total) * 100).rounded())
  }
}

struct PremiumReflection: Hashable {
  let title: String
  let body: String
  let action: String
}

enum PremiumReflectionEngine {
  static func reflection(
    for date: Date = Date(),
    season: LiturgicalSeason
  ) -> PremiumReflection {
    let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    let options = reflections(for: season)
    let reflection = options[(dayIndex - 1) % options.count]
    return reflection
  }

  private static func reflections(for season: LiturgicalSeason) -> [PremiumReflection] {
    switch season {
    case .advent:
      return [
        PremiumReflection(
          title: "Watch in Hope",
          body: "Advent fasting prepares the heart by making room for Christ's coming.",
          action: "Keep one hidden act of restraint today."
        ),
        PremiumReflection(
          title: "Quiet Expectation",
          body: "Silence and simplicity sharpen spiritual attention.",
          action: "Add 10 minutes of silent prayer before your next meal."
        ),
      ]
    case .christmas:
      return [
        PremiumReflection(
          title: "Receive with Gratitude",
          body: "Feasting and fasting both become holy through thanksgiving.",
          action: "Pray a short thanksgiving after each meal today."
        ),
        PremiumReflection(
          title: "Joy with Sobriety",
          body: "Christian joy does not require excess.",
          action: "Choose one concrete moderation in food or drink today."
        ),
      ]
    case .lent:
      return [
        PremiumReflection(
          title: "Return to the Lord",
          body: "Fasting without prayer becomes technique; with prayer it becomes conversion.",
          action: "Pair your next hunger moment with a brief prayer of repentance."
        ),
        PremiumReflection(
          title: "Offer the Sacrifice",
          body: "A faithful small sacrifice is better than a dramatic one you cannot sustain.",
          action: "Select one realistic discipline to keep through this week."
        ),
      ]
    case .easter:
      return [
        PremiumReflection(
          title: "Persevere in New Life",
          body: "Easter discipline protects the grace you received in Lent.",
          action: "Renew your Friday penance plan for this week."
        ),
        PremiumReflection(
          title: "Witness in Charity",
          body: "Resurrection joy bears fruit through mercy toward others.",
          action: "Choose one specific act of mercy today."
        ),
      ]
    case .ordinary:
      return [
        PremiumReflection(
          title: "Sanctify the Ordinary",
          body: "Ordinary Time is where fidelity becomes character.",
          action: "Keep your chosen discipline exactly as planned today."
        ),
        PremiumReflection(
          title: "Small Daily Yes",
          body: "Steady obedience in little things forms long-term freedom.",
          action: "End today with a two-minute examen on your fasting intention."
        ),
      ]
    }
  }
}

enum PremiumDirectionSummaryEngine {
  static func summaryText(
    date: Date = Date(),
    season: LiturgicalSeason,
    analytics: PremiumAnalyticsSummary,
    reminder: PremiumReminderRecommendation,
    plan: PremiumSeasonPlan,
    latestReflection: PremiumReflection
  ) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short

    let lines = [
      "Catholic Fasting Premium Summary",
      "Generated: \(formatter.string(from: date))",
      "",
      "Season",
      "- \(season.label)",
      "- Plan: \(plan.titleLine)",
      "- Focus: \(plan.focusLine)",
      "- Intensity: \(plan.fastingIntensity)",
      "",
      "Discipline Metrics",
      "- Required completion: \(analytics.requiredCompletionPercent)%",
      "- Overall completion: \(analytics.overallCompletionPercent)%",
      "- Missed observances logged: \(analytics.missedCount)",
      "- Substituted observances logged: \(analytics.substitutedCount)",
      "- Intermittent target hit rate (recent): \(analytics.intermittentTargetHitPercent)%",
      "",
      "Reminder Strategy",
      "- Daily support: \(reminder.shouldEnableDailySupport ? "On" : "Off")",
      "- Morning reminder: \(reminder.shouldEnableMorning ? "On" : "Off")",
      "- Evening reminder: \(reminder.shouldEnableEvening ? "On" : "Off")",
      "- Guidance: \(reminder.summaryLine)",
      "",
      "Reflection",
      "- \(latestReflection.title)",
      "- \(latestReflection.body)",
      "- Action: \(latestReflection.action)",
    ]
    return lines.joined(separator: "\n")
  }
}

enum PremiumSubscriptionState: String, CaseIterable, Hashable {
  case subscribed
  case expired
  case inGracePeriod
  case inBillingRetry
  case revoked
}

enum PremiumSubscriptionHealthEvaluator {
  static func message(
    states: [PremiumSubscriptionState],
    premiumUnlocked: Bool
  ) -> String {
    if states.contains(.revoked) {
      return "Subscription was revoked. Restore or update your account."
    }
    if states.contains(.inBillingRetry) {
      return "Billing issue detected. Update your payment method to keep Premium."
    }
    if states.contains(.inGracePeriod) {
      return "You are in billing grace period. Premium remains active for now."
    }
    if states.contains(.expired) {
      return "Premium subscription expired."
    }
    if states.contains(.subscribed) || premiumUnlocked {
      return "Premium subscription is active."
    }
    return ""
  }
}
