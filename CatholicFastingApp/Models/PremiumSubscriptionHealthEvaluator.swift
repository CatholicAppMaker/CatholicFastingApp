@preconcurrency import Foundation

enum PremiumSubscriptionState: String, CaseIterable, Hashable {
    case subscribed
    case expired
    case inGracePeriod
    case inBillingRetry
    case revoked
}

enum PremiumCatalogLoadState: Equatable {
    case idle
    case loading
    case loaded
    case offline
    case failed
}

struct PremiumCatalogRefreshResolution: Equatable {
    let premiumUnlocked: Bool
    let catalogState: PremiumCatalogLoadState
    let clearsCatalog: Bool
}

enum PremiumCatalogRefreshPolicy {
    static func catalogResult(
        entitlementUnlocked: Bool,
        hasPlans: Bool) -> PremiumCatalogRefreshResolution
    {
        PremiumCatalogRefreshResolution(
            premiumUnlocked: entitlementUnlocked,
            catalogState: hasPlans ? .loaded : .failed,
            clearsCatalog: !hasPlans)
    }

    static func failure(
        entitlementUnlocked: Bool,
        isOffline: Bool) -> PremiumCatalogRefreshResolution
    {
        PremiumCatalogRefreshResolution(
            premiumUnlocked: entitlementUnlocked,
            catalogState: isOffline ? .offline : .failed,
            clearsCatalog: true)
    }
}

enum PremiumSubscriptionHealthEvaluator {
    static func message(
        states: [PremiumSubscriptionState],
        premiumUnlocked: Bool) -> String
    {
        // StoreKit can return statuses for individual and Family Sharing
        // subscriptions at the same time. Any active subscription wins over
        // stale expired or revoked statuses from another source.
        if states.contains(.subscribed) {
            return "Premium subscription is active."
        }
        if states.contains(.inGracePeriod) {
            return "You are in billing grace period. Premium remains active for now."
        }
        if states.contains(.inBillingRetry) {
            return "Billing issue detected. Update your payment method to keep Premium."
        }
        if premiumUnlocked {
            return "Premium subscription is active."
        }
        if states.contains(.revoked) {
            return "Subscription was revoked. Restore or update your account."
        }
        if states.contains(.expired) {
            return "Premium subscription expired."
        }
        return ""
    }
}
