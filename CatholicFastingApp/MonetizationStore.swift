import SwiftUI
#if canImport(StoreKit)
import StoreKit
#endif
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

#if canImport(StoreKit)
@MainActor
final class MonetizationStore: ObservableObject {
    static let premiumCatalog = SubscriptionOfferCatalog.catholicFasting
    static let premiumMonthlyID = "com.kevpierce.catholicfasting.premium.monthly.v3"
    static let premiumYearlyID = "com.kevpierce.catholicfasting.premium.yearly.v3"
    static let tipSmallID = "com.kevpierce.catholicfasting.tip.small"
    static let tipMediumID = "com.kevpierce.catholicfasting.tip.medium"
    static let tipLargeID = "com.kevpierce.catholicfasting.tip.large"

    static let premiumProductIDs: Set<String> = premiumCatalog.canonicalSubscriptionProductIDs
    static let tipProductIDs: Set<String> = [tipSmallID, tipMediumID, tipLargeID]
    static let allProductIDs: Set<String> = premiumProductIDs.union(tipProductIDs)

    @Published var premiumUnlocked = false
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var statusMessage = ""
    @Published var subscriptionHealthMessage = ""
    @Published var premiumProducts: [Product] = []
    @Published var tipProducts: [Product] = []

    private static let debugPremiumUnlockedKey = "debug_simulator_premium_unlocked"
    private var updatesTask: Task<Void, Never>?
    private var hasStartedTransactionMonitoring = false

    init() {
        if Self.usesLocalDebugPremiumOverride {
            premiumUnlocked = UserDefaults.standard.bool(forKey: Self.debugPremiumUnlockedKey)
            statusMessage = premiumUnlocked ? "Premium unlocked for local UI testing." : ""
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refreshCatalogAndEntitlements() async {
        if Self.usesLocalDebugPremiumOverride {
            premiumUnlocked = UserDefaults.standard.bool(forKey: Self.debugPremiumUnlockedKey)
            premiumProducts = []
            tipProducts = []
            statusMessage = premiumUnlocked ? "Premium unlocked for local UI testing." : ""
            await refreshSubscriptionHealth()
            return
        }

        startTransactionMonitoringIfNeeded()
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: Array(Self.allProductIDs))
            premiumProducts =
                products
                    .filter { Self.premiumProductIDs.contains($0.id) }
                    .sorted { premiumSortIndex(for: $0.id) < premiumSortIndex(for: $1.id) }
            tipProducts =
                products
                    .filter { Self.tipProductIDs.contains($0.id) }
                    .sorted { tipSortIndex(for: $0.id) < tipSortIndex(for: $1.id) }
            await refreshEntitlements()
            await refreshSubscriptionHealth()
        } catch {
            statusMessage = "Unable to load purchases right now."
        }
    }

    func purchase(_ product: Product) async {
        if Self.usesLocalDebugPremiumOverride {
            if Self.premiumProductIDs.contains(product.id) {
                premiumUnlocked = true
                UserDefaults.standard.set(true, forKey: Self.debugPremiumUnlockedKey)
                statusMessage = "Premium unlocked (simulator debug purchase)."
            } else {
                statusMessage = "Thank you for supporting this app (simulator debug tip)."
            }
            await refreshSubscriptionHealth()
            return
        }

        startTransactionMonitoringIfNeeded()
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    statusMessage = "Purchase could not be verified."
                    return
                }
                await transaction.finish()
                await refreshEntitlements()
                await refreshSubscriptionHealth()
                if Self.premiumProductIDs.contains(product.id) {
                    statusMessage = "Premium unlocked."
                } else {
                    statusMessage = "Thank you for supporting this app."
                }
            case .pending:
                statusMessage = "Purchase pending approval."
            case .userCancelled:
                statusMessage = "Purchase cancelled."
            @unknown default:
                statusMessage = "Purchase did not complete."
            }
        } catch {
            statusMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        if Self.usesLocalDebugPremiumOverride {
            premiumUnlocked = UserDefaults.standard.bool(forKey: Self.debugPremiumUnlockedKey)
            await refreshSubscriptionHealth()
            statusMessage =
                premiumUnlocked
                    ? "Simulator debug purchase restored."
                    : "No simulator debug premium purchase found."
            return
        }

        startTransactionMonitoringIfNeeded()
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            await refreshSubscriptionHealth()
            statusMessage = premiumUnlocked ? "Purchases restored." : "No active premium purchase found."
        } catch {
            statusMessage = "Could not restore purchases."
        }
    }

    func openManageSubscriptions() async {
        #if canImport(UIKit)
        guard let scene = Self.activeWindowScene() else {
            if !openManageSubscriptionsFallback() {
                statusMessage = "Unable to open subscription management right now."
            }
            return
        }
        do {
            try await AppStore.showManageSubscriptions(in: scene)
        } catch {
            if !openManageSubscriptionsFallback() {
                statusMessage = "Unable to open subscription settings."
            }
        }
        #elseif canImport(AppKit)
        if Self.openManageSubscriptionsURL() {
            statusMessage = "Opened account subscriptions in the App Store."
        } else {
            statusMessage = "Unable to open subscription settings."
        }
        #else
        statusMessage = "Subscription management is unavailable on this platform."
        #endif
    }

    func resetSimulatorDebugPurchase() async {
        guard Self.usesLocalDebugPremiumOverride else { return }
        UserDefaults.standard.removeObject(forKey: Self.debugPremiumUnlockedKey)
        premiumUnlocked = false
        statusMessage = "Simulator debug premium reset."
        await refreshSubscriptionHealth()
    }

    func startTransactionMonitoringIfNeeded() {
        guard !Self.usesLocalDebugPremiumOverride else { return }
        guard !hasStartedTransactionMonitoring else { return }
        hasStartedTransactionMonitoring = true
        updatesTask = Task { [weak self] in
            await self?.monitorTransactionUpdates()
        }
    }

    private func refreshEntitlements() async {
        if Self.usesLocalDebugPremiumOverride {
            premiumUnlocked = UserDefaults.standard.bool(forKey: Self.debugPremiumUnlockedKey)
            return
        }

        premiumUnlocked = false
        for await verification in Transaction.currentEntitlements {
            guard case .verified(let transaction) = verification else { continue }
            guard Self.premiumProductIDs.contains(transaction.productID) else { continue }
            if transaction.revocationDate != nil { continue }
            if let expiration = transaction.expirationDate, expiration <= Date() { continue }
            premiumUnlocked = true
        }
    }

    private func monitorTransactionUpdates() async {
        if Self.usesLocalDebugPremiumOverride {
            return
        }

        for await verification in Transaction.updates {
            guard case .verified(let transaction) = verification else { continue }
            await transaction.finish()
            await refreshEntitlements()
            await refreshSubscriptionHealth()
        }
    }

    private func refreshSubscriptionHealth() async {
        var states: [PremiumSubscriptionState] = []
        for product in premiumProducts {
            guard let subscription = product.subscription else { continue }
            guard let statuses = try? await subscription.status else { continue }
            for status in statuses {
                switch status.state {
                case .subscribed:
                    states.append(.subscribed)
                case .expired:
                    states.append(.expired)
                case .inGracePeriod:
                    states.append(.inGracePeriod)
                case .inBillingRetryPeriod:
                    states.append(.inBillingRetry)
                case .revoked:
                    states.append(.revoked)
                default:
                    continue
                }
            }
        }
        subscriptionHealthMessage = PremiumSubscriptionHealthEvaluator.message(
            states: states,
            premiumUnlocked: premiumUnlocked)
    }

    #if canImport(UIKit)
    private static func activeWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    private func openManageSubscriptionsFallback() -> Bool {
        UIApplication.shared.open(UIConstants.manageSubscriptionsURL)
        statusMessage = "Opened account subscriptions in App Store."
        return true
    }
    #endif

    #if canImport(AppKit)
    private static func openManageSubscriptionsURL() -> Bool {
        NSWorkspace.shared.open(UIConstants.manageSubscriptionsURL)
    }
    #endif

    private func premiumSortIndex(for productID: String) -> Int {
        Self.premiumCatalog.offers.firstIndex(where: { $0.id == productID }) ?? 99
    }

    private func tipSortIndex(for productID: String) -> Int {
        switch productID {
        case Self.tipSmallID:
            0
        case Self.tipMediumID:
            1
        case Self.tipLargeID:
            2
        default:
            99
        }
    }

    private static var usesSimulatorDebugPurchases: Bool {
        #if DEBUG && targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    private static var usesLocalDebugPremiumOverride: Bool {
        usesSimulatorDebugPurchases || ProcessInfo.processInfo.environment["UITEST_MODE"] == "1"
    }
}
#else
@MainActor
final class MonetizationStore: ObservableObject {
    @Published var premiumUnlocked = false
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var statusMessage = "Purchases unavailable on this platform."
    @Published var subscriptionHealthMessage = ""
    @Published var premiumProducts: [String] = []
    @Published var tipProducts: [String] = []

    func refreshCatalogAndEntitlements() async {}
    func restorePurchases() async {}
    func purchase(_: String) async {}
    func openManageSubscriptions() async {}
    func resetSimulatorDebugPurchase() async {}
}
#endif
