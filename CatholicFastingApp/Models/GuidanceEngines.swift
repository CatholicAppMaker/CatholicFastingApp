@preconcurrency import Foundation

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
                    FoodGuidanceExample(
                        title: "Broths, gravies, and sauces",
                        detail: """
                        Meat broths, chicken broth, consommé, or gravies flavored with meat are often understood as technically not forbidden under the strict legal minimum.
                        """),
                    FoodGuidanceExample(
                        title: "Animal-fat seasonings",
                        detail: "Condiments or seasonings made from animal fat can fall into the same technically-not-forbidden category."),
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
