@preconcurrency import Foundation

struct PremiumReflection: Hashable {
    let title: String
    let body: String
    let action: String
}

enum PremiumReflectionEngine {
    static func reflection(
        for date: Date = Date(),
        season: LiturgicalSeason) -> PremiumReflection
    {
        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let options = reflections(for: season)
        return options[(dayIndex - 1) % options.count]
    }

    private static func reflections(for season: LiturgicalSeason) -> [PremiumReflection] {
        switch season {
        case .advent:
            [
                PremiumReflection(
                    title: "Watch in Hope",
                    body: "Advent fasting prepares the heart by making room for Christ's coming.",
                    action: "Keep one hidden act of restraint today."),
                PremiumReflection(
                    title: "Quiet Expectation",
                    body: "Silence and simplicity sharpen spiritual attention.",
                    action: "Add 10 minutes of silent prayer before your next meal."),
            ]
        case .christmas:
            [
                PremiumReflection(
                    title: "Receive with Gratitude",
                    body: "Feasting and fasting both become holy through thanksgiving.",
                    action: "Pray a short thanksgiving after each meal today."),
                PremiumReflection(
                    title: "Joy with Sobriety",
                    body: "Christian joy does not require excess.",
                    action: "Choose one concrete moderation in food or drink today."),
            ]
        case .lent:
            [
                PremiumReflection(
                    title: "Return to the Lord",
                    body: "Fasting without prayer becomes technique; with prayer it becomes conversion.",
                    action: "Pair your next hunger moment with a brief prayer of repentance."),
                PremiumReflection(
                    title: "Offer the Sacrifice",
                    body: "A faithful small sacrifice is better than a dramatic one you cannot sustain.",
                    action: "Select one realistic discipline to keep through this week."),
            ]
        case .easter:
            [
                PremiumReflection(
                    title: "Persevere in New Life",
                    body: "Easter discipline protects the grace you received in Lent.",
                    action: "Renew your Friday penance plan for this week."),
                PremiumReflection(
                    title: "Witness in Charity",
                    body: "Resurrection joy bears fruit through mercy toward others.",
                    action: "Choose one specific act of mercy today."),
            ]
        case .ordinary:
            [
                PremiumReflection(
                    title: "Sanctify the Ordinary",
                    body: "Ordinary Time is where fidelity becomes character.",
                    action: "Keep your chosen discipline exactly as planned today."),
                PremiumReflection(
                    title: "Small Daily Yes",
                    body: "Steady obedience in little things forms long-term freedom.",
                    action: "End today with a two-minute examen on your fasting intention."),
            ]
        }
    }
}
