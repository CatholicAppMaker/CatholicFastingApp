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
                titleLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.medical.title",
                    default: "Medical/Pastoral Plan"),
                focusLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.medical.focus",
                    default: "Use a moderated discipline with your pastor's guidance."),
                practices: [
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.medical.practice1",
                        default: "Keep a fixed morning and evening prayer rhythm."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.medical.practice2",
                        default: "Choose one charitable act each week."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.medical.practice3",
                        default: "Use food discipline only as health allows."),
                ],
                fastingIntensity: CoreLocalizer.localizedCurrent(
                    "premium.plan.intensity.gentle",
                    default: "Gentle"))
        }

        switch season {
        case .advent:
            return PremiumSeasonPlan(
                titleLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.advent.title",
                    default: "Advent Preparation Plan"),
                focusLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.advent.focus",
                    default: "Watchfulness, restraint, and expectation of the Lord."),
                practices: [
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.advent.practice1",
                        default: "Fast lightly on Wednesdays and Fridays."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.advent.practice2",
                        default: "Add one weekday Mass when possible."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.advent.practice3",
                        default: "Set one concrete almsgiving commitment."),
                ],
                fastingIntensity: CoreLocalizer.localizedCurrent(
                    "premium.plan.intensity.moderate",
                    default: "Moderate"))
        case .christmas:
            return PremiumSeasonPlan(
                titleLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.christmas.title",
                    default: "Christmas Joy Plan"),
                focusLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.christmas.focus",
                    default: "Celebrate with gratitude while keeping sobriety."),
                practices: [
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.christmas.practice1",
                        default: "Keep Friday penance with deliberate charity."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.christmas.practice2",
                        default: "Pray a brief thanksgiving after each meal."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.christmas.practice3",
                        default: "Avoid unnecessary excess for one chosen category."),
                ],
                fastingIntensity: CoreLocalizer.localizedCurrent(
                    "premium.plan.intensity.light",
                    default: "Light"))
        case .lent:
            return PremiumSeasonPlan(
                titleLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.lent.title",
                    default: "Lenten Discipline Plan"),
                focusLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.lent.focus",
                    default: "Repentance, conversion, and generous self-denial."),
                practices: [
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.lent.practice1",
                        default: "Observe all required fast/abstinence days with planning."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.lent.practice2",
                        default: "Keep one additional personal fast each week."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.lent.practice3",
                        default: "Pair every fast with prayer and almsgiving."),
                ],
                fastingIntensity: CoreLocalizer.localizedCurrent(
                    "premium.plan.intensity.strong",
                    default: "Strong"))
        case .easter:
            return PremiumSeasonPlan(
                titleLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.easter.title",
                    default: "Easter Fidelity Plan"),
                focusLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.easter.focus",
                    default: "Sustain the fruits of Lent with steady habits."),
                practices: [
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.easter.practice1",
                        default: "Maintain Friday penance without interruption."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.easter.practice2",
                        default: "Offer one act of encouragement or mercy weekly."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.easter.practice3",
                        default: "Review your rule of life every Sunday evening."),
                ],
                fastingIntensity: CoreLocalizer.localizedCurrent(
                    "premium.plan.intensity.light",
                    default: "Light"))
        case .ordinary:
            return PremiumSeasonPlan(
                titleLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.ordinary.title",
                    default: "Ordinary Time Rule of Life"),
                focusLine: CoreLocalizer.localizedCurrent(
                    "premium.plan.ordinary.focus",
                    default: "Consistency in ordinary days forms long-term holiness."),
                practices: [
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.ordinary.practice1",
                        default: "Choose a fixed weekly fasting day."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.ordinary.practice2",
                        default: "Keep Friday penance intentionally."),
                    CoreLocalizer.localizedCurrent(
                        "premium.plan.ordinary.practice3",
                        default: "Track completion and review each weekend."),
                ],
                fastingIntensity: CoreLocalizer.localizedCurrent(
                    "premium.plan.intensity.moderate",
                    default: "Moderate"))
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
        case .fasting:
            CoreLocalizer.localizedCurrent("premium.journey.category.fasting", default: "Fasting focus")
        case .prayer:
            CoreLocalizer.localizedCurrent("premium.journey.category.prayer", default: "Prayer focus")
        case .charity:
            CoreLocalizer.localizedCurrent("premium.journey.category.charity", default: "Penance / charity")
        case .review:
            CoreLocalizer.localizedCurrent("premium.journey.category.review", default: "Weekly checkpoint")
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
                title: CoreLocalizer.localizedCurrentFormat(
                    "premium.journey.week.lent.title",
                    default: "Lenten Week %d",
                    normalizedWeek),
                summary: CoreLocalizer.localizedCurrent(
                    "premium.journey.week.lent.summary",
                    default: "Keep one sacrificial rhythm, one concrete prayer, and one act of mercy in the same week."),
                actions: [
                    GuidedSeasonalJourneyAction(
                        id: "fasting",
                        category: .fasting,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.lent.fasting.title",
                            default: "Protect the next required observance"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.lent.fasting.detail",
                            default: "Plan Ash Wednesday, Friday abstinence, or your next required day before the week gets noisy.")),
                    GuidedSeasonalJourneyAction(
                        id: "prayer",
                        category: .prayer,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.lent.prayer.title",
                            default: "Pair hunger with repentance prayer"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.lent.prayer.detail",
                            default: "Use one hunger moment each day for a short prayer of repentance or Psalm 51.")),
                    GuidedSeasonalJourneyAction(
                        id: "charity",
                        category: .charity,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.lent.charity.title",
                            default: "Add one hidden act of mercy"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.lent.charity.detail",
                            default: "Choose one charitable or penitential act that costs you something but stays sustainable.")),
                    GuidedSeasonalJourneyAction(
                        id: "review",
                        category: .review,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.lent.review.title",
                            default: "Review the week honestly"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.lent.review.detail",
                            default: "Ask what actually helped conversion, not just what looked strict on paper.")),
                ])
        case .advent:
            return GuidedSeasonalJourneyWeek(
                season: season,
                program: program,
                weekNumber: normalizedWeek,
                title: CoreLocalizer.localizedCurrentFormat(
                    "premium.journey.week.advent.title",
                    default: "Advent Week %d",
                    normalizedWeek),
                summary: CoreLocalizer.localizedCurrent(
                    "premium.journey.week.advent.summary",
                    default: "Build watchfulness through simplicity, quiet prayer, and one restrained work of charity."),
                actions: [
                    GuidedSeasonalJourneyAction(
                        id: "fasting",
                        category: .fasting,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.advent.fasting.title",
                            default: "Simplify one meal pattern this week"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.advent.fasting.detail",
                            default: "Choose one modest food sacrifice that creates room for recollection rather than performance.")),
                    GuidedSeasonalJourneyAction(
                        id: "prayer",
                        category: .prayer,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.advent.prayer.title",
                            default: "Keep a short evening watch"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.advent.prayer.detail",
                            default: "Add a brief Scripture reading or silent prayer before your final meal or before bed.")),
                    GuidedSeasonalJourneyAction(
                        id: "charity",
                        category: .charity,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.advent.charity.title",
                            default: "Practice hidden generosity"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.advent.charity.detail",
                            default: "Choose one concrete act of generosity that prepares your heart for Christ’s coming.")),
                    GuidedSeasonalJourneyAction(
                        id: "review",
                        category: .review,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.advent.review.title",
                            default: "Check for noise versus attention"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.advent.review.detail",
                            default: "Review whether your week made you more attentive, more grateful, and less scattered.")),
                ])
        case .ordinary, .christmas, .easter:
            return GuidedSeasonalJourneyWeek(
                season: season,
                program: program,
                weekNumber: normalizedWeek,
                title: CoreLocalizer.localizedCurrentFormat(
                    "premium.journey.week.generic.title",
                    default: "%@ Week %d",
                    season.label,
                    normalizedWeek),
                summary: CoreLocalizer.localizedCurrent(
                    "premium.journey.week.generic.summary",
                    default: "Use one steady rhythm for fasting, prayer, mercy, and review so the season forms habit instead of good intentions only."),
                actions: [
                    GuidedSeasonalJourneyAction(
                        id: "fasting",
                        category: .fasting,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.generic.fasting.title",
                            default: "Keep one fixed discipline day"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.generic.fasting.detail",
                            default: "Protect one weekly fasting or penitential day that fits your actual state in life.")),
                    GuidedSeasonalJourneyAction(
                        id: "prayer",
                        category: .prayer,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.generic.prayer.title",
                            default: "Add one anchored prayer cue"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.generic.prayer.detail",
                            default: "Tie your discipline to a stable cue such as breakfast prayer, the Angelus, or evening examen.")),
                    GuidedSeasonalJourneyAction(
                        id: "charity",
                        category: .charity,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.generic.charity.title",
                            default: "Choose one practical mercy step"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.generic.charity.detail",
                            default: "Make the week concrete with one act of mercy, generosity, or patient self-denial.")),
                    GuidedSeasonalJourneyAction(
                        id: "review",
                        category: .review,
                        title: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.generic.review.title",
                            default: "Close the week with review"),
                        detail: CoreLocalizer.localizedCurrent(
                            "premium.journey.week.generic.review.detail",
                            default: "Review what stayed faithful, what slipped, and what one next adjustment should be.")),
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
            CoreLocalizer.localizedCurrent(
                "premium.journey.progress.complete",
                default: "This week is complete. Reuse the review prompt and carry the rhythm into the next week.")
        } else {
            CoreLocalizer.localizedCurrentFormat(
                "premium.journey.progress.partial",
                default: "%d of %d journey actions completed this week.",
                completedCount,
                totalCount)
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
                CoreLocalizer.localizedCurrent(
                    "premium.program.liturgicalRhythm.action1",
                    default: "Pray before first meal each day."),
                CoreLocalizer.localizedCurrent(
                    "premium.program.liturgicalRhythm.action2",
                    default: "Keep one fixed weekday discipline."),
                CoreLocalizer.localizedCurrentFormat(
                    "premium.program.liturgicalRhythm.action3",
                    default: "Weekly review checkpoint #%d.",
                    normalizedWeek),
            ]
        case .lentDeepen:
            return [
                CoreLocalizer.localizedCurrent(
                    "premium.program.lentDeepen.action1",
                    default: "Keep all required observances with planning."),
                CoreLocalizer.localizedCurrent(
                    "premium.program.lentDeepen.action2",
                    default: "Add one hidden sacrifice this week."),
                CoreLocalizer.localizedCurrentFormat(
                    "premium.program.lentDeepen.action3",
                    default: "Link fasting to almsgiving checkpoint #%d.",
                    normalizedWeek),
            ]
        case .adventWatch:
            return [
                CoreLocalizer.localizedCurrent(
                    "premium.program.adventWatch.action1",
                    default: "Reduce one comfort item for watchfulness."),
                CoreLocalizer.localizedCurrent(
                    "premium.program.adventWatch.action2",
                    default: "Add a short Scripture reading before dinner."),
                CoreLocalizer.localizedCurrentFormat(
                    "premium.program.adventWatch.action3",
                    default: "Keep a quiet-night prayer checkpoint #%d.",
                    normalizedWeek),
            ]
        case .fridayFidelity:
            return [
                CoreLocalizer.localizedCurrent(
                    "premium.program.fridayFidelity.action1",
                    default: "Plan Friday penance by Thursday evening."),
                CoreLocalizer.localizedCurrent(
                    "premium.program.fridayFidelity.action2",
                    default: "Record one charity action on Friday."),
                CoreLocalizer.localizedCurrentFormat(
                    "premium.program.fridayFidelity.action3",
                    default: "End Friday with a gratitude examen checkpoint #%d.",
                    normalizedWeek),
            ]
        }
    }
}
