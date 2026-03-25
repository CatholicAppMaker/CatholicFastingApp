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
