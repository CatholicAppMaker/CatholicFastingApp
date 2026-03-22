@preconcurrency import Foundation

enum GuidanceScenario: String, CaseIterable, Identifiable {
    case normalDay
    case heavyLabor
    case travel
    case socialMeal
    case medicalRecovery

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .normalDay:
            "Normal Day"
        case .heavyLabor:
            "Heavy Labor"
        case .travel:
            "Travel"
        case .socialMeal:
            "Social Meal"
        case .medicalRecovery:
            "Medical Recovery"
        }
    }
}

enum FoodGuidanceEngine {
    static func snapshot(
        for scenario: GuidanceScenario,
        settings: RuleSettings) -> FoodGuidanceSnapshot
    {
        let sourceLine = switch settings.regionProfile {
        case .us:
            "Sources: USCCB fast/abstinence guidance and universal law."
        case .canada:
            "Sources: CCCB Friday guidance and universal law."
        case .other:
            "Sources: universal law and local pastoral guidance."
        }

        let summaryLine = switch scenario {
        case .medicalRecovery:
            "Health and pastoral guidance come first. If medical recovery is involved, fasting may not bind in the ordinary way."
        case .heavyLabor:
            "Keep the discipline, but adjust prudently if heavy labor would make strict fasting unsafe."
        case .travel:
            "Travel can limit options. Choose the simplest penitential option you can keep faithfully."
        case .socialMeal:
            "Keep charity and discretion at shared meals while still honoring abstinence and fasting norms."
        case .normalDay:
            "Use this section for the practical food questions Catholics actually ask about fasting and abstinence."
        }

        let scenarioCaveat = switch scenario {
        case .medicalRecovery:
            "If health or recovery is involved, follow medical advice and use substitute penance where appropriate."
        case .heavyLabor:
            "If your state in life makes the legal minimum unsafe, reduce rigor and add another penitential act."
        case .travel:
            "When options are limited, the safer and simpler non-meat option is usually best."
        case .socialMeal:
            "When hospitality creates ambiguity, choose the simpler penitential option without turning the meal into a spectacle."
        case .normalDay:
            "Examples here are practical guidance, not a replacement for pastoral judgment."
        }

        return FoodGuidanceSnapshot(
            summaryLine: summaryLine,
            whatCountsAsMeat: FoodGuidanceGroup(
                title: "What counts as meat",
                summary: "Abstinence from meat includes the flesh of land animals and birds.",
                items: [
                    FoodGuidanceExample(title: "Generally avoid", detail: "Beef, pork, chicken, turkey, lamb, bacon, ham, and similar land-animal or bird meats."),
                    FoodGuidanceExample(title: "Chicken counts as meat", detail: "Poultry is included in abstinence from meat."),
                ]),
            generallyPermitted: FoodGuidanceGroup(
                title: "Generally permitted",
                summary: "These are generally permitted on abstinence days.",
                items: [
                    FoodGuidanceExample(title: "Fish and shellfish", detail: "Fish, shellfish, and other seafood are generally permitted."),
                    FoodGuidanceExample(title: "Eggs and dairy", detail: "Eggs, milk, butter, cheese, and similar dairy products are not treated as meat."),
                    FoodGuidanceExample(title: "Plant foods", detail: "Grains, vegetables, legumes, fruit, breads, and oils are generally permitted."),
                ]),
            mealPattern: FoodGuidanceGroup(
                title: "Meal pattern on fasting days",
                summary: "Fasting is distinct from abstinence.",
                items: [
                    FoodGuidanceExample(title: "Core fasting norm", detail: "One full meal and up to two smaller meals that together do not equal a second full meal."),
                    FoodGuidanceExample(title: "What to avoid", detail: "Eating in a way that effectively becomes a second full meal, even if spread out."),
                ]),
            extraGuidance: FoodGuidanceGroup(
                title: "Extra guidance for common questions",
                summary: "These are the gray-area cases people actually ask about.",
                items: [
                    FoodGuidanceExample(title: "Broths, gravies, and sauces", detail: "Meat broths, chicken broth, consommé, or gravies flavored with meat are often understood as technically not forbidden under the strict legal minimum."),
                    FoodGuidanceExample(title: "Animal-fat seasonings", detail: "Condiments or seasonings made from animal fat can fall into the same technically-not-forbidden category."),
                    FoodGuidanceExample(title: "Fish remains permitted", detail: "Fish and shellfish remain permitted, even though they are animal foods."),
                    FoodGuidanceExample(title: "Dairy is generally permitted", detail: "Butter, cheese, milk, and eggs are generally permitted and do not count as meat."),
                ]),
            stricterTraditionalPractice: [
                "Many Catholics and traditional moral theologians choose to avoid meat broths, gravies, and animal-fat products as part of a stricter penitential practice.",
                "If you want the simpler and more penitential option, avoid foods that are strongly meat-derived even when they may not be strictly forbidden.",
            ],
            ifUnsure: [
                "Choose the simpler non-meat option.",
                "Consult your pastor if you need certainty in a disputed or local case.",
                "Follow medical guidance where health is involved.",
            ],
            caveatLine: scenarioCaveat,
            sourceLine: sourceLine)
    }

    static func recommendations(
        for scenario: GuidanceScenario,
        settings: RuleSettings) -> [String]
    {
        let snapshot = snapshot(for: scenario, settings: settings)
        var lines: [String] = [snapshot.summaryLine]
        let medicallyDispensed = settings.hasMedicalDispensation || scenario == .medicalRecovery

        if medicallyDispensed {
            lines.append("Your health comes first. A medical or pastoral dispensation likely applies.")
            lines.append(
                "Choose a substitute penance if possible (prayer, charity, Scripture, or another sacrifice).")
            lines.append("Resume normal fasting only when it is prudent and safe.")
            return lines
        }

        lines.append("Abstinence: avoid meat from land animals and birds, including chicken, beef, pork, turkey, and lamb.")
        lines.append("Generally permitted on abstinence days: fish, shellfish, eggs, dairy, grains, fruit, and vegetables.")
        lines.append("Fasting: one full meal and up to two smaller meals that together are less than a second full meal.")
        lines.append("Extra guidance: broth, gravies, and animal-fat seasonings may be technically permitted, but many Catholics avoid them in stricter practice.")
        lines.append(snapshot.caveatLine)

        return lines
    }
}

struct FoodGuidanceSnapshot {
    let summaryLine: String
    let whatCountsAsMeat: FoodGuidanceGroup
    let generallyPermitted: FoodGuidanceGroup
    let mealPattern: FoodGuidanceGroup
    let extraGuidance: FoodGuidanceGroup
    let stricterTraditionalPractice: [String]
    let ifUnsure: [String]
    let caveatLine: String
    let sourceLine: String
}

struct FoodGuidanceGroup {
    let title: String
    let summary: String
    let items: [FoodGuidanceExample]
}

struct FoodGuidanceExample: Hashable {
    let title: String
    let detail: String
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

enum RequiredDayReminderPlanner {
    static let pendingNotificationLimit = 64
    static let reservedSlotsForNonRequired = 14
    static let absoluteRequiredReminderCap = pendingNotificationLimit - reservedSlotsForNonRequired

    static func maximumRequiredReminders(existingNonRequiredPendingCount: Int) -> Int {
        let nonRequiredCount = max(0, existingNonRequiredPendingCount)
        let remainingQueueCapacity = max(0, pendingNotificationLimit - nonRequiredCount)
        return min(absoluteRequiredReminderCap, remainingQueueCapacity)
    }

    static func additionalRequiredReminderSlots(
        existingRequiredPendingCount: Int,
        existingNonRequiredPendingCount: Int) -> Int
    {
        let requiredCount = max(0, existingRequiredPendingCount)
        let maxRequired = maximumRequiredReminders(
            existingNonRequiredPendingCount: existingNonRequiredPendingCount)
        return max(0, maxRequired - requiredCount)
    }

    static func upcomingMandatoryObservances(
        from observances: [Observance],
        now: Date = Date(),
        calendar: Calendar = .gregorian,
        limit: Int) -> [Observance]
    {
        guard limit > 0 else { return [] }

        let startOfToday = calendar.startOfDay(for: now)
        let sortedCandidates =
            observances
                .filter { observance in
                    observance.obligation == .mandatory
                        && calendar.startOfDay(for: observance.date) >= startOfToday
                }
                .sorted { lhs, rhs in
                    if lhs.date == rhs.date {
                        return lhs.id < rhs.id
                    }
                    return lhs.date < rhs.date
                }

        var seenIDs = Set<String>()
        var planned: [Observance] = []
        planned.reserveCapacity(min(limit, sortedCandidates.count))

        for observance in sortedCandidates {
            guard seenIDs.insert(observance.id).inserted else { continue }
            planned.append(observance)
            if planned.count == limit {
                break
            }
        }

        return planned
    }
}

enum DailyFoodDecisionEngine {
    static func decision(
        for observances: [Observance],
        settings: RuleSettings,
        date: Date = Date(),
        calendar: Calendar = .current) -> DailyFoodDecision
    {
        let generalNormSourceLine = switch settings.regionProfile {
        case .us:
            "Source: USCCB and pastoral guidance."
        case .canada:
            "Source: CCCB Friday guidance and universal law."
        case .other:
            "Source: universal law and local pastoral guidance."
        }
        let fastingNormSourceLine = switch settings.regionProfile {
        case .us:
            "Source: USCCB Fast & Abstinence norms."
        case .canada:
            "Source: universal fast/abstinence law with Canada Friday guidance."
        case .other:
            "Source: universal fast/abstinence law."
        }
        let fridayNormSourceLine = switch settings.regionProfile {
        case .us:
            "Source: USCCB Friday penance norms."
        case .canada:
            "Source: CCCB Friday guidance."
        case .other:
            "Source: local Friday penance guidance."
        }
        let holyDaySourceLine = switch settings.regionProfile {
        case .us:
            "Source: USCCB liturgical norms."
        case .canada:
            "Source: universal law and the Canada national baseline."
        case .other:
            "Source: local liturgical guidance."
        }

        let todayObservances = observances.filter { calendar.isDate($0.date, inSameDayAs: date) }
        let mandatoryToday = todayObservances.filter { $0.obligation == .mandatory }
        let optionalFastOrAbstinenceToday = todayObservances.filter {
            $0.obligation == .optional && ($0.kind == .fastAndAbstinence || $0.kind == .abstinence)
        }

        if settings.hasMedicalDispensation {
            return DailyFoodDecision(
                obligationLine: "Medical/pastoral dispensation is enabled in your profile.",
                allowed: ["Eat what is prudent and medically safe.", "Keep prayer/charity as substitute penance."],
                avoid: ["Avoid self-imposed rigor that harms health."],
                rationale: "Health and pastoral obedience take priority when obligations do not bind.",
                sourceLine: generalNormSourceLine)
        }

        let requiresFasting = mandatoryToday.contains {
            $0.kind == .fastAndAbstinence
        }
        let requiresAbstinence = mandatoryToday.contains {
            $0.kind == .fastAndAbstinence || $0.kind == .abstinence
        }
        let requiresFridayPenance = mandatoryToday.contains {
            $0.kind == .fridayPenance
        }

        if requiresFasting, requiresAbstinence {
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
                sourceLine: fastingNormSourceLine)
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
                sourceLine: fastingNormSourceLine)
        }

        if requiresFridayPenance {
            if settings.regionProfile == .canada {
                if settings.fridayOutsideLentMode == .abstainFromMeat {
                    return DailyFoodDecision(
                        obligationLine: "Today calls for Friday penance through abstinence from meat.",
                        allowed: [
                            "Normal meal quantity is generally permitted.",
                            "Fish, eggs, dairy, grains, fruits, and vegetables are generally permitted.",
                        ],
                        avoid: ["Meat from land animals (beef, pork, poultry)."],
                        rationale: observanceReason(from: mandatoryToday),
                        sourceLine: fridayNormSourceLine)
                }

                return DailyFoodDecision(
                    obligationLine: "Today calls for Friday penance, not mandatory fasting.",
                    allowed: [
                        "Normal meals are generally permitted.",
                        "Choose a penitential act, especially a work of charity or piety.",
                    ],
                    avoid: ["Do not skip Friday penance entirely."],
                    rationale: observanceReason(from: mandatoryToday),
                    sourceLine: fridayNormSourceLine)
            } else if settings.fridayOutsideLentMode == .abstainFromMeat {
                return DailyFoodDecision(
                    obligationLine: "Today requires Friday penance through abstinence from meat.",
                    allowed: [
                        "Normal meal quantity is generally permitted.",
                        "Fish, eggs, dairy, grains, fruits, and vegetables are generally permitted.",
                    ],
                    avoid: ["Meat from land animals (beef, pork, poultry)."],
                    rationale: observanceReason(from: mandatoryToday),
                    sourceLine: fridayNormSourceLine)
            }

            return DailyFoodDecision(
                obligationLine: "Today requires Friday penance, but not mandatory fasting.",
                allowed: [
                    "Normal meals are generally permitted.",
                    "Choose a penitential act (for example prayer, almsgiving, or another sacrifice).",
                ],
                avoid: ["Do not skip Friday penance entirely."],
                rationale: observanceReason(from: mandatoryToday),
                sourceLine: fridayNormSourceLine)
        }

        if !mandatoryToday.isEmpty {
            return DailyFoodDecision(
                obligationLine: "Today has a required observance but no mandatory food restriction.",
                allowed: ["Normal meals are generally permitted.", "Keep the day with prayer and Mass obligations."],
                avoid: [],
                rationale: observanceReason(from: mandatoryToday),
                sourceLine: holyDaySourceLine)
        }

        if !optionalFastOrAbstinenceToday.isEmpty {
            let titles = optionalFastOrAbstinenceToday.map(\.title).joined(separator: ", ")
            let unknownAgeProfile = !settings.isAge14OrOlderForAbstinence && !settings.isAge18OrOlderForFasting
            let obligationLine =
                unknownAgeProfile
                    ? "Today may include fasting/abstinence obligations (profile incomplete)."
                    : "Today includes fasting/abstinence observance in your profile, but not mandatory."
            let rationale =
                unknownAgeProfile
                    ? "Review the age eligibility toggles in Settings so the app can determine whether \(titles) binds you."
                    : "Based on your current profile, \(titles) does not strictly bind today."

            return DailyFoodDecision(
                obligationLine: obligationLine,
                allowed: [
                    "Follow age/health and pastoral guidance for your situation.",
                    "If unsure, observe abstinence and a simpler meal pattern.",
                ],
                avoid: ["Do not assume no obligation without confirming your profile."],
                rationale: rationale,
                sourceLine: fastingNormSourceLine)
        }

        return DailyFoodDecision(
            obligationLine: "No mandatory food restriction today.",
            allowed: ["Normal meals are generally permitted.", "You may choose a voluntary penance."],
            avoid: [],
            rationale: "No mandatory fast/abstinence observance appears for today in your current profile.",
            sourceLine: fastingNormSourceLine)
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
        calendar: Calendar = .current) -> MissedDayRecoveryPlan?
    {
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

        let nextRequiredLine = if let nextRequired {
            "Next required day: \(nextRequired.title) on \(nextRequired.date.formatted(date: .abbreviated, time: .omitted))."
        } else {
            "No future required observances remain in this calendar year."
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
            nextRequiredLine: nextRequiredLine)
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
        calendar: Calendar = .current) -> [Observance]
    {
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
        statusesByID: [String: CompletionStatus]) -> Bool
    {
        switch filter {
        case .all:
            true
        case .requiredOnly:
            observance.obligation == .mandatory
        case .trackedOnly:
            (statusesByID[observance.id] ?? .notStarted) != .notStarted
        }
    }

    private static func matchesWindow(
        _ observance: Observance,
        window: CalendarWindow,
        startOfToday: Date,
        endOfNext30Days: Date?,
        calendar: Calendar) -> Bool
    {
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
            { lhs, rhs in
                lhs.date == rhs.date ? lhs.title < rhs.title : lhs.date < rhs.date
            }
        case .requiredFirst:
            { lhs, rhs in
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
            0
        case .optional:
            1
        case .notApplicable:
            2
        }
    }
}
