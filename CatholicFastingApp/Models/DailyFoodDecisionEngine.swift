@preconcurrency import Foundation

enum DailyFoodDecisionEngine {
    struct DecisionSources {
        let generalNorm: String
        let fastingNorm: String
        let fridayNorm: String
        let holyDayNorm: String
    }

    static func decision(
        for observances: [Observance],
        settings: RuleSettings,
        date: Date = Date(),
        calendar: Calendar = .current) -> DailyFoodDecision
    {
        let sources = sourceLines(for: settings.regionProfile)

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
                sourceLine: sources.generalNorm)
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
                sourceLine: sources.fastingNorm)
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
                sourceLine: sources.fastingNorm)
        }

        if requiresFridayPenance {
            return fridayDecision(
                settings: settings,
                mandatoryToday: mandatoryToday,
                sourceLine: sources.fridayNorm)
        }

        if !mandatoryToday.isEmpty {
            return DailyFoodDecision(
                obligationLine: "Today has a required observance but no mandatory food restriction.",
                allowed: ["Normal meals are generally permitted.", "Keep the day with prayer and Mass obligations."],
                avoid: [],
                rationale: observanceReason(from: mandatoryToday),
                sourceLine: sources.holyDayNorm)
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
                sourceLine: sources.fastingNorm)
        }

        return DailyFoodDecision(
            obligationLine: "No mandatory food restriction today.",
            allowed: ["Normal meals are generally permitted.", "You may choose a voluntary penance."],
            avoid: [],
            rationale: "No mandatory fast/abstinence observance appears for today in your current profile.",
            sourceLine: sources.fastingNorm)
    }

    private static func sourceLines(for profile: RuleSettings.RegionProfile) -> DecisionSources {
        switch profile {
        case .us:
            DecisionSources(
                generalNorm: "Source: USCCB and pastoral guidance.",
                fastingNorm: "Source: USCCB Fast & Abstinence norms.",
                fridayNorm: "Source: USCCB Friday penance norms.",
                holyDayNorm: "Source: USCCB liturgical norms.")
        case .canada:
            DecisionSources(
                generalNorm: "Source: CCCB Friday guidance and universal law.",
                fastingNorm: "Source: universal fast/abstinence law with Canada Friday guidance.",
                fridayNorm: "Source: CCCB Friday guidance.",
                holyDayNorm: "Source: universal law and the Canada national baseline.")
        case .other:
            DecisionSources(
                generalNorm: "Source: universal law and local pastoral guidance.",
                fastingNorm: "Source: universal fast/abstinence law.",
                fridayNorm: "Source: local Friday penance guidance.",
                holyDayNorm: "Source: local liturgical guidance.")
        }
    }

    private static func fridayDecision(
        settings: RuleSettings,
        mandatoryToday: [Observance],
        sourceLine: String) -> DailyFoodDecision
    {
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
                    sourceLine: sourceLine)
            }

            return DailyFoodDecision(
                obligationLine: "Today calls for Friday penance, not mandatory fasting.",
                allowed: [
                    "Normal meals are generally permitted.",
                    "Choose a penitential act, especially a work of charity or piety.",
                ],
                avoid: ["Do not skip Friday penance entirely."],
                rationale: observanceReason(from: mandatoryToday),
                sourceLine: sourceLine)
        }

        if settings.fridayOutsideLentMode == .abstainFromMeat {
            return DailyFoodDecision(
                obligationLine: "Today requires Friday penance through abstinence from meat.",
                allowed: [
                    "Normal meal quantity is generally permitted.",
                    "Fish, eggs, dairy, grains, fruits, and vegetables are generally permitted.",
                ],
                avoid: ["Meat from land animals (beef, pork, poultry)."],
                rationale: observanceReason(from: mandatoryToday),
                sourceLine: sourceLine)
        }

        return DailyFoodDecision(
            obligationLine: "Today requires Friday penance, but not mandatory fasting.",
            allowed: [
                "Normal meals are generally permitted.",
                "Choose a penitential act (for example prayer, almsgiving, or another sacrifice).",
            ],
            avoid: ["Do not skip Friday penance entirely."],
            rationale: observanceReason(from: mandatoryToday),
            sourceLine: sourceLine)
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
