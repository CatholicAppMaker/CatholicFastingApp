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
                    title: CoreLocalizer.localizedCurrent("premium.reflection.advent.1.title", default: "Watch in Hope"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.advent.1.body",
                        default: "Advent fasting prepares the heart by making room for Christ's coming."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.advent.1.action",
                        default: "Keep one hidden act of restraint today.")),
                PremiumReflection(
                    title: CoreLocalizer.localizedCurrent("premium.reflection.advent.2.title", default: "Quiet Expectation"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.advent.2.body",
                        default: "Silence and simplicity sharpen spiritual attention."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.advent.2.action",
                        default: "Add 10 minutes of silent prayer before your next meal.")),
            ]
        case .christmas:
            [
                PremiumReflection(
                    title: CoreLocalizer.localizedCurrent(
                        "premium.reflection.christmas.1.title",
                        default: "Receive with Gratitude"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.christmas.1.body",
                        default: "Feasting and fasting both become holy through thanksgiving."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.christmas.1.action",
                        default: "Pray a short thanksgiving after each meal today.")),
                PremiumReflection(
                    title: CoreLocalizer.localizedCurrent(
                        "premium.reflection.christmas.2.title",
                        default: "Joy with Sobriety"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.christmas.2.body",
                        default: "Christian joy does not require excess."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.christmas.2.action",
                        default: "Choose one concrete moderation in food or drink today.")),
            ]
        case .lent:
            [
                PremiumReflection(
                    title: CoreLocalizer.localizedCurrent("premium.reflection.lent.1.title", default: "Return to the Lord"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.lent.1.body",
                        default: "Fasting without prayer becomes technique; with prayer it becomes conversion."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.lent.1.action",
                        default: "Pair your next hunger moment with a brief prayer of repentance.")),
                PremiumReflection(
                    title: CoreLocalizer.localizedCurrent(
                        "premium.reflection.lent.2.title",
                        default: "Offer the Sacrifice"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.lent.2.body",
                        default: "A faithful small sacrifice is better than a dramatic one you cannot sustain."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.lent.2.action",
                        default: "Select one realistic discipline to keep through this week.")),
            ]
        case .easter:
            [
                PremiumReflection(
                    title: CoreLocalizer.localizedCurrent(
                        "premium.reflection.easter.1.title",
                        default: "Persevere in New Life"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.easter.1.body",
                        default: "Easter discipline protects the grace you received in Lent."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.easter.1.action",
                        default: "Renew your Friday penance plan for this week.")),
                PremiumReflection(
                    title: CoreLocalizer.localizedCurrent(
                        "premium.reflection.easter.2.title",
                        default: "Witness in Charity"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.easter.2.body",
                        default: "Resurrection joy bears fruit through mercy toward others."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.easter.2.action",
                        default: "Choose one specific act of mercy today.")),
            ]
        case .ordinary:
            [
                PremiumReflection(
                    title: CoreLocalizer.localizedCurrent(
                        "premium.reflection.ordinary.1.title",
                        default: "Sanctify the Ordinary"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.ordinary.1.body",
                        default: "Ordinary Time is where fidelity becomes character."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.ordinary.1.action",
                        default: "Keep your chosen discipline exactly as planned today.")),
                PremiumReflection(
                    title: CoreLocalizer.localizedCurrent(
                        "premium.reflection.ordinary.2.title",
                        default: "Small Daily Yes"),
                    body: CoreLocalizer.localizedCurrent(
                        "premium.reflection.ordinary.2.body",
                        default: "Steady obedience in little things forms long-term freedom."),
                    action: CoreLocalizer.localizedCurrent(
                        "premium.reflection.ordinary.2.action",
                        default: "End today with a two-minute examen on your fasting intention.")),
            ]
        }
    }
}
