@preconcurrency import Foundation

enum PremiumSubscriptionState: String, CaseIterable, Hashable {
    case subscribed
    case expired
    case inGracePeriod
    case inBillingRetry
    case revoked
}

enum PremiumSubscriptionHealthEvaluator {
    static func message(
        states: [PremiumSubscriptionState],
        premiumUnlocked: Bool) -> String
    {
        if states.contains(.revoked) {
            return "Subscription was revoked. Restore or update your account."
        }
        if states.contains(.inBillingRetry) {
            return "Billing issue detected. Update your payment method to keep Premium."
        }
        if states.contains(.inGracePeriod) {
            return "You are in billing grace period. Premium remains active for now."
        }
        if states.contains(.expired) {
            return "Premium subscription expired."
        }
        if states.contains(.subscribed) || premiumUnlocked {
            return "Premium subscription is active."
        }
        return ""
    }
}
