@preconcurrency import Foundation

struct SubscriptionOfferCatalog {
    struct Offer: Hashable, Identifiable {
        let id: String
        let displayTitle: String
        let durationLabel: String
        let billingCadenceLabel: String
        let outcomeSummary: String
        let isPrimaryAnchor: Bool
    }

    struct Pillar: Hashable, Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let outcomes: [String]
        let requiredSurface: PremiumEntitlementSurface
    }

    let title: String
    let subtitle: String
    let pillars: [Pillar]
    let offers: [Offer]

    static let catholicFasting = SubscriptionOfferCatalog(
        title: "Formation Toolkit",
        subtitle: "Premium keeps a guided seasonal journey, reminders, review, and reflection in one steady Catholic workflow.",
        pillars: [
            Pillar(
                id: "planning",
                title: "Guided Journey",
                subtitle: "Follow one weekly seasonal path instead of guessing what to do next.",
                outcomes: [
                    "Move through Lent, Advent, and Ordinary Time with one weekly rhythm",
                    "Keep fasting, prayer, charity, and review tied together in the same plan",
                    "Protect celebration days so personal discipline does not overreach",
                ],
                requiredSurface: .planning),
            Pillar(
                id: "accountability",
                title: "Accountability",
                subtitle: "Recover quickly and keep momentum when discipline slips.",
                outcomes: [
                    "Turn reminders into a steadier rule of life",
                    "Spot slippage early with completion trends and recovery guidance",
                    "Review longer intermittent history with milestone feedback",
                ],
                requiredSurface: .accountability),
            Pillar(
                id: "reflection",
                title: "Reflection",
                subtitle: "Connect fasting to prayer, virtue, and honest review.",
                outcomes: [
                    "Use guided prompts to examine intention, not just completion",
                    "Keep a private local journal with virtue notes",
                    "Export a fasting summary for spiritual direction or personal review",
                ],
                requiredSurface: .reflection),
        ],
        offers: [
            Offer(
                id: "com.kevpierce.catholicfasting.premium.yearly.v3",
                displayTitle: "Premium Yearly",
                durationLabel: "1 year",
                billingCadenceLabel: "Billed once per year",
                outcomeSummary: "Best value for one steady rhythm through the full liturgical year.",
                isPrimaryAnchor: true),
            Offer(
                id: "com.kevpierce.catholicfasting.premium.monthly.v3",
                displayTitle: "Premium Monthly",
                durationLabel: "1 month",
                billingCadenceLabel: "Billed monthly",
                outcomeSummary: "Lower-friction way to begin premium planning and review habits.",
                isPrimaryAnchor: false),
        ])

    var canonicalSubscriptionProductIDs: Set<String> {
        Set(offers.map(\.id))
    }

    func offer(for productID: String) -> Offer? {
        offers.first(where: { $0.id == productID })
    }
}

enum PremiumEntitlementSurface: String, CaseIterable, Identifiable {
    case planning
    case accountability
    case reflection
    case export

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .planning:
            "Planning"
        case .accountability:
            "Accountability"
        case .reflection:
            "Reflection"
        case .export:
            "Export"
        }
    }

    var guidance: String {
        switch self {
        case .planning:
            "Build a realistic discipline plan that respects feast and holy days."
        case .accountability:
            "Stay steady with reminders, trends, and recovery guidance."
        case .reflection:
            "Reflect with guided prompts, journal entries, and virtue notes."
        case .export:
            "Share clean summaries for personal review or spiritual direction."
        }
    }
}

struct LaunchFunnelSnapshot: Codable, Equatable {
    var startedAt: Date
    var completedOnboardingAt: Date?
    var selectedRegionRaw: String
    var selectedReminderTierRaw: String
    var firstActionCompletedAt: Date?
    var paywallSeenAt: Date?
    var paywallViewCount: Int
    var lockedUpgradeTapCount: Int
    var premiumPreviewSeenAt: Date?
    var purchaseStartedAt: Date?
    var premiumUnlockedAt: Date?

    static let `default` = LaunchFunnelSnapshot(
        startedAt: Date(),
        completedOnboardingAt: nil,
        selectedRegionRaw: RuleSettings.RegionProfile.us.rawValue,
        selectedReminderTierRaw: ReminderTier.balanced.rawValue,
        firstActionCompletedAt: nil,
        paywallSeenAt: nil,
        paywallViewCount: 0,
        lockedUpgradeTapCount: 0,
        premiumPreviewSeenAt: nil,
        purchaseStartedAt: nil,
        premiumUnlockedAt: nil)

    var selectedRegion: RuleSettings.RegionProfile {
        RuleSettings.RegionProfile(rawValue: selectedRegionRaw) ?? .us
    }

    var selectedReminderTier: ReminderTier {
        ReminderTier(rawValue: selectedReminderTierRaw) ?? .balanced
    }
}

enum ReminderTier: String, CaseIterable, Identifiable {
    case minimal
    case balanced
    case guided

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .minimal: "Minimal"
        case .balanced: "Balanced"
        case .guided: "Guided"
        }
    }

    var summary: String {
        switch self {
        case .minimal:
            "Required-day reminders only."
        case .balanced:
            "Required days plus one daily support reminder."
        case .guided:
            "Morning + evening support cadence for habit building."
        }
    }

    var morningEnabled: Bool {
        switch self {
        case .minimal: false
        case .balanced, .guided: true
        }
    }

    var eveningEnabled: Bool {
        switch self {
        case .minimal, .balanced: false
        case .guided: true
        }
    }

    var supportEnabled: Bool {
        self != .minimal
    }

    static func infer(
        supportEnabled: Bool,
        morningEnabled: Bool,
        eveningEnabled: Bool) -> ReminderTier
    {
        if supportEnabled, morningEnabled, eveningEnabled {
            return .guided
        }
        if supportEnabled, morningEnabled {
            return .balanced
        }
        return .minimal
    }
}
