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
        case .normalDay: "Normal Day"
        case .heavyLabor: "Heavy Labor"
        case .travel: "Travel"
        case .socialMeal: "Social Meal"
        case .medicalRecovery: "Medical Recovery"
        }
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

enum AppSemanticTone: Hashable {
    case primary
    case success
    case warning
    case information
    case danger
}

struct DailyFoodDecision {
    enum Category: CaseIterable, Hashable {
        case medicalDispensation
        case fastAndAbstinence
        case abstinence
        case fridayPenance
        case requiredNoFoodRestriction
        case optionalFastOrAbstinence
        case unrestricted
    }

    let category: Category
    let obligationLine: String
    let allowed: [String]
    let avoid: [String]
    let rationale: String
    let sourceLine: String
}

struct DailyFoodDecisionPresentation: Hashable {
    let symbolName: String
    let tone: AppSemanticTone
    let nextActionLocalizationKey: String
    let nextActionDefaultValue: String

    static func presentation(for category: DailyFoodDecision.Category) -> DailyFoodDecisionPresentation {
        switch category {
        case .medicalDispensation:
            DailyFoodDecisionPresentation(
                symbolName: "cross.case.fill",
                tone: .information,
                nextActionLocalizationKey: "today.decision.next_action.dispensation",
                nextActionDefaultValue: "Follow health and pastoral guidance, then choose a prudent prayer or charity substitute.")
        case .fastAndAbstinence, .abstinence:
            DailyFoodDecisionPresentation(
                symbolName: "exclamationmark.circle.fill",
                tone: .danger,
                nextActionLocalizationKey: "today.decision.next_action.required",
                nextActionDefaultValue: "Review the food guidance below, then keep the day with prayer, fasting, and charity.")
        case .fridayPenance:
            DailyFoodDecisionPresentation(
                symbolName: "hand.raised.fill",
                tone: .warning,
                nextActionLocalizationKey: "today.decision.next_action.friday",
                nextActionDefaultValue: "Choose today's penance now so Friday does not become an afterthought.")
        case .requiredNoFoodRestriction:
            DailyFoodDecisionPresentation(
                symbolName: "calendar.badge.exclamationmark",
                tone: .information,
                nextActionLocalizationKey: "today.decision.next_action.required_no_food_restriction",
                nextActionDefaultValue: "Keep today's required observance through prayer and Mass; no food restriction is required.")
        case .optionalFastOrAbstinence:
            DailyFoodDecisionPresentation(
                symbolName: "info.circle.fill",
                tone: .information,
                nextActionLocalizationKey: "today.decision.next_action.optional",
                nextActionDefaultValue: "Review your profile and pastoral guidance before choosing an optional fasting practice.")
        case .unrestricted:
            DailyFoodDecisionPresentation(
                symbolName: "checkmark.circle.fill",
                tone: .success,
                nextActionLocalizationKey: "today.decision.next_action.clear",
                nextActionDefaultValue: "Normal meals are generally permitted. Keep the next required day visible and choose voluntary penance only if prudent.")
        }
    }
}

struct MissedDayRecoveryPlan {
    let titleLine: String
    let summaryLine: String
    let steps: [String]
    let nextRequiredLine: String
}
