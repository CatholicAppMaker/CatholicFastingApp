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
                fastingIntensity: "Gentle")
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
                fastingIntensity: "Moderate")
        case .christmas:
            return PremiumSeasonPlan(
                titleLine: "Christmas Joy Plan",
                focusLine: "Celebrate with gratitude while keeping sobriety.",
                practices: [
                    "Keep Friday penance with deliberate charity.",
                    "Pray a brief thanksgiving after each meal.",
                    "Avoid unnecessary excess for one chosen category.",
                ],
                fastingIntensity: "Light")
        case .lent:
            return PremiumSeasonPlan(
                titleLine: "Lenten Discipline Plan",
                focusLine: "Repentance, conversion, and generous self-denial.",
                practices: [
                    "Observe all required fast/abstinence days with planning.",
                    "Keep one additional personal fast each week.",
                    "Pair every fast with prayer and almsgiving.",
                ],
                fastingIntensity: "Strong")
        case .easter:
            return PremiumSeasonPlan(
                titleLine: "Easter Fidelity Plan",
                focusLine: "Sustain the fruits of Lent with steady habits.",
                practices: [
                    "Maintain Friday penance without interruption.",
                    "Offer one act of encouragement or mercy weekly.",
                    "Review your rule of life every Sunday evening.",
                ],
                fastingIntensity: "Light")
        case .ordinary:
            return PremiumSeasonPlan(
                titleLine: "Ordinary Time Rule of Life",
                focusLine: "Consistency in ordinary days forms long-term holiness.",
                practices: [
                    "Choose a fixed weekly fasting day.",
                    "Keep Friday penance intentionally.",
                    "Track completion and review each weekend.",
                ],
                fastingIntensity: "Moderate")
        }
    }
}

enum GuidedSeasonalJourneyCategory: String, Hashable {
    case fasting
    case prayer
    case charity
    case review

    var label: String {
        switch self {
        case .fasting: "Fasting focus"
        case .prayer: "Prayer focus"
        case .charity: "Penance / charity"
        case .review: "Weekly checkpoint"
        }
    }
}

struct GuidedSeasonalJourneyAction: Hashable, Identifiable {
    let id: String
    let category: GuidedSeasonalJourneyCategory
    let title: String
    let detail: String
}

struct GuidedSeasonalJourneyWeek: Hashable {
    let season: LiturgicalSeason
    let program: PremiumSeasonProgram
    let weekNumber: Int
    let title: String
    let summary: String
    let actions: [GuidedSeasonalJourneyAction]

    var reviewAction: GuidedSeasonalJourneyAction? {
        actions.first(where: { $0.category == .review })
    }
}

struct GuidedSeasonalJourneyProgress: Hashable {
    let completedCount: Int
    let totalCount: Int
    let nextAction: GuidedSeasonalJourneyAction?
    let completionSummary: String
}

enum GuidedSeasonalJourneyEngine {
    static func week(
        for season: LiturgicalSeason,
        program: PremiumSeasonProgram,
        week: Int) -> GuidedSeasonalJourneyWeek
    {
        let normalizedWeek = max(1, week)

        switch season {
        case .lent:
            return GuidedSeasonalJourneyWeek(
                season: season,
                program: program,
                weekNumber: normalizedWeek,
                title: "Lenten Week \(normalizedWeek)",
                summary: "Keep one sacrificial rhythm, one concrete prayer, and one act of mercy in the same week.",
                actions: [
                    GuidedSeasonalJourneyAction(
                        id: "fasting",
                        category: .fasting,
                        title: "Protect the next required observance",
                        detail: "Plan Ash Wednesday, Friday abstinence, or your next required day before the week gets noisy."),
                    GuidedSeasonalJourneyAction(
                        id: "prayer",
                        category: .prayer,
                        title: "Pair hunger with repentance prayer",
                        detail: "Use one hunger moment each day for a short prayer of repentance or Psalm 51."),
                    GuidedSeasonalJourneyAction(
                        id: "charity",
                        category: .charity,
                        title: "Add one hidden act of mercy",
                        detail: "Choose one charitable or penitential act that costs you something but stays sustainable."),
                    GuidedSeasonalJourneyAction(
                        id: "review",
                        category: .review,
                        title: "Review the week honestly",
                        detail: "Ask what actually helped conversion, not just what looked strict on paper."),
                ])
        case .advent:
            return GuidedSeasonalJourneyWeek(
                season: season,
                program: program,
                weekNumber: normalizedWeek,
                title: "Advent Week \(normalizedWeek)",
                summary: "Build watchfulness through simplicity, quiet prayer, and one restrained work of charity.",
                actions: [
                    GuidedSeasonalJourneyAction(
                        id: "fasting",
                        category: .fasting,
                        title: "Simplify one meal pattern this week",
                        detail: "Choose one modest food sacrifice that creates room for recollection rather than performance."),
                    GuidedSeasonalJourneyAction(
                        id: "prayer",
                        category: .prayer,
                        title: "Keep a short evening watch",
                        detail: "Add a brief Scripture reading or silent prayer before your final meal or before bed."),
                    GuidedSeasonalJourneyAction(
                        id: "charity",
                        category: .charity,
                        title: "Practice hidden generosity",
                        detail: "Choose one concrete act of generosity that prepares your heart for Christ’s coming."),
                    GuidedSeasonalJourneyAction(
                        id: "review",
                        category: .review,
                        title: "Check for noise versus attention",
                        detail: "Review whether your week made you more attentive, more grateful, and less scattered."),
                ])
        case .ordinary, .christmas, .easter:
            return GuidedSeasonalJourneyWeek(
                season: season,
                program: program,
                weekNumber: normalizedWeek,
                title: "\(season.label) Week \(normalizedWeek)",
                summary: "Use one steady rhythm for fasting, prayer, mercy, and review so the season forms habit instead of good intentions only.",
                actions: [
                    GuidedSeasonalJourneyAction(
                        id: "fasting",
                        category: .fasting,
                        title: "Keep one fixed discipline day",
                        detail: "Protect one weekly fasting or penitential day that fits your actual state in life."),
                    GuidedSeasonalJourneyAction(
                        id: "prayer",
                        category: .prayer,
                        title: "Add one anchored prayer cue",
                        detail: "Tie your discipline to a stable cue such as breakfast prayer, the Angelus, or evening examen."),
                    GuidedSeasonalJourneyAction(
                        id: "charity",
                        category: .charity,
                        title: "Choose one practical mercy step",
                        detail: "Make the week concrete with one act of mercy, generosity, or patient self-denial."),
                    GuidedSeasonalJourneyAction(
                        id: "review",
                        category: .review,
                        title: "Close the week with review",
                        detail: "Review what stayed faithful, what slipped, and what one next adjustment should be."),
                ])
        }
    }

    static func actionKey(
        program: PremiumSeasonProgram,
        week: Int,
        actionID: String) -> String
    {
        "\(program.rawValue)-w\(max(1, week))-\(actionID)"
    }

    static func progress(
        for week: GuidedSeasonalJourneyWeek,
        completedActionKeys: [String]) -> GuidedSeasonalJourneyProgress
    {
        let completedKeySet = Set(completedActionKeys)
        let completedActions = week.actions.filter {
            completedKeySet.contains(actionKey(program: week.program, week: week.weekNumber, actionID: $0.id))
        }
        let nextAction = week.actions.first {
            !completedKeySet.contains(actionKey(program: week.program, week: week.weekNumber, actionID: $0.id))
        }
        let totalCount = week.actions.count
        let completedCount = completedActions.count
        let completionSummary = if completedCount == totalCount {
            "This week is complete. Reuse the review prompt and carry the rhythm into the next week."
        } else {
            "\(completedCount) of \(totalCount) journey actions completed this week."
        }

        return GuidedSeasonalJourneyProgress(
            completedCount: completedCount,
            totalCount: totalCount,
            nextAction: nextAction,
            completionSummary: completionSummary)
    }
}

enum PremiumSeasonProgramEngine {
    static func actions(
        for program: PremiumSeasonProgram,
        week: Int) -> [String]
    {
        let normalizedWeek = max(1, week)
        switch program {
        case .liturgicalRhythm:
            return [
                "Pray before first meal each day.",
                "Keep one fixed weekday discipline.",
                "Weekly review checkpoint #\(normalizedWeek).",
            ]
        case .lentDeepen:
            return [
                "Keep all required observances with planning.",
                "Add one hidden sacrifice this week.",
                "Link fasting to almsgiving checkpoint #\(normalizedWeek).",
            ]
        case .adventWatch:
            return [
                "Reduce one comfort item for watchfulness.",
                "Add a short Scripture reading before dinner.",
                "Keep a quiet-night prayer checkpoint #\(normalizedWeek).",
            ]
        case .fridayFidelity:
            return [
                "Plan Friday penance by Thursday evening.",
                "Record one charity action on Friday.",
                "End Friday with a gratitude examen checkpoint #\(normalizedWeek).",
            ]
        }
    }
}
