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
protocol MonetizationPurchaseClient {
    func purchase(_ product: Product) async throws -> Product.PurchaseResult
}

@MainActor
struct LiveMonetizationPurchaseClient: MonetizationPurchaseClient {
    func purchase(_ product: Product) async throws -> Product.PurchaseResult {
        try await product.purchase()
    }
}

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
    @Published private(set) var catalogLoadState: PremiumCatalogLoadState = .idle

    private static let debugPremiumUnlockedKey = "debug_simulator_premium_unlocked"
    private let purchaseClient: any MonetizationPurchaseClient
    private var updatesTask: Task<Void, Never>?
    private var hasStartedTransactionMonitoring = false

    init(purchaseClient: (any MonetizationPurchaseClient)? = nil) {
        self.purchaseClient = purchaseClient ?? LiveMonetizationPurchaseClient()
        if Self.usesLocalDebugPremiumOverride {
            premiumUnlocked = Self.localDebugPremiumUnlocked
            statusMessage = premiumUnlocked
                ? localized(
                    "premium.store.debug.unlocked",
                    default: "Premium unlocked for local UI testing.")
                : ""
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refreshCatalogAndEntitlements() async {
        if Self.usesLocalDebugPremiumOverride {
            premiumUnlocked = Self.localDebugPremiumUnlocked
            premiumProducts = []
            tipProducts = []
            isLoading = false
            switch Self.uiTestCatalogState {
            case .loading:
                isLoading = true
                catalogLoadState = .loading
                statusMessage = ""
            case .offline:
                catalogLoadState = .offline
                statusMessage = localized(
                    "premium.catalog.offline",
                    default: "You appear to be offline. Premium plans need an App Store connection; your current access remains unchanged.")
            case .idle, .loaded, .failed, nil:
                catalogLoadState = .failed
                statusMessage = premiumUnlocked
                    ? localized(
                        "premium.store.debug.unlocked",
                        default: "Premium unlocked for local UI testing.")
                    : ""
            }
            await refreshSubscriptionHealth()
            return
        }

        startTransactionMonitoringIfNeeded()
        isLoading = true
        catalogLoadState = .loading
        defer { isLoading = false }

        // StoreKit entitlements are available independently of the product catalog.
        // Refresh them first so a catalog/network outage can never hide access that
        // the App Store still reports as active.
        await refreshEntitlements()
        await refreshSubscriptionHealth()

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
            let resolution = PremiumCatalogRefreshPolicy.catalogResult(
                entitlementUnlocked: premiumUnlocked,
                hasPlans: !premiumProducts.isEmpty)
            premiumUnlocked = resolution.premiumUnlocked
            catalogLoadState = resolution.catalogState
            if resolution.clearsCatalog {
                premiumProducts = []
                tipProducts = []
            }
            if premiumProducts.isEmpty {
                statusMessage = localized(
                    "premium.store.catalog.unavailable",
                    default: "Premium plans are temporarily unavailable.")
            }
            await refreshSubscriptionHealth()
        } catch {
            let resolution = PremiumCatalogRefreshPolicy.failure(
                entitlementUnlocked: premiumUnlocked,
                isOffline: Self.isNetworkFailure(error))
            premiumUnlocked = resolution.premiumUnlocked
            if resolution.clearsCatalog {
                premiumProducts = []
                tipProducts = []
            }
            catalogLoadState = resolution.catalogState
            statusMessage = localized(
                "premium.store.catalog.load_failed",
                default: "Unable to load purchases right now.")
            await refreshSubscriptionHealth()
        }
    }

    func purchase(_ product: Product) async {
        if Self.usesLocalDebugPremiumOverride {
            if Self.premiumProductIDs.contains(product.id) {
                premiumUnlocked = true
                UserDefaults.standard.set(true, forKey: Self.debugPremiumUnlockedKey)
                statusMessage = localized(
                    "premium.store.debug.purchase_unlocked",
                    default: "Premium unlocked for simulator testing.")
            } else {
                statusMessage = localized(
                    "premium.store.debug.tip_received",
                    default: "Test support purchase completed.")
            }
            await refreshSubscriptionHealth()
            return
        }

        startTransactionMonitoringIfNeeded()
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await purchaseClient.purchase(product)
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    statusMessage = localized(
                        "premium.store.purchase.unverified",
                        default: "The App Store could not verify this purchase.")
                    return
                }
                await transaction.finish()
                await refreshEntitlements()
                await refreshSubscriptionHealth()
                if Self.premiumProductIDs.contains(product.id) {
                    statusMessage = localized(
                        "premium.store.purchase.unlocked",
                        default: "Premium is now active.")
                } else {
                    statusMessage = localized(
                        "premium.store.purchase.thanks",
                        default: "Thank you for supporting this app.")
                }
            case .pending:
                statusMessage = localized(
                    "premium.store.purchase.pending",
                    default: "This purchase is awaiting approval.")
            case .userCancelled:
                statusMessage = localized(
                    "premium.store.purchase.cancelled",
                    default: "Purchase cancelled.")
            @unknown default:
                statusMessage = localized(
                    "premium.store.purchase.incomplete",
                    default: "The purchase did not complete.")
            }
        } catch {
            statusMessage = localizedFormat(
                "premium.store.purchase.failed_format",
                default: "Purchase failed: %@",
                error.localizedDescription)
        }
    }

    func restorePurchases() async {
        if Self.usesLocalDebugPremiumOverride {
            premiumUnlocked = Self.localDebugPremiumUnlocked
            await refreshSubscriptionHealth()
            statusMessage =
                premiumUnlocked
                    ? localized(
                        "premium.store.debug.restore_found",
                        default: "Simulator test access restored.")
                    : localized(
                        "premium.store.debug.restore_missing",
                        default: "No simulator test purchase was found.")
            return
        }

        startTransactionMonitoringIfNeeded()
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            await refreshSubscriptionHealth()
            statusMessage = premiumUnlocked
                ? localized(
                    "premium.store.restore.succeeded",
                    default: "Purchases restored.")
                : localized(
                    "premium.store.restore.none_found",
                    default: "No active Premium purchase was found.")
        } catch {
            statusMessage = localized(
                "premium.store.restore.failed",
                default: "Purchases could not be restored. Please try again.")
        }
    }

    func openManageSubscriptions() async {
        #if canImport(UIKit)
        guard let scene = Self.activeWindowScene() else {
            if !openManageSubscriptionsFallback() {
                statusMessage = localized(
                    "premium.store.manage.unavailable",
                    default: "Subscription management could not be opened.")
            }
            return
        }
        do {
            try await AppStore.showManageSubscriptions(in: scene)
        } catch {
            if !openManageSubscriptionsFallback() {
                statusMessage = localized(
                    "premium.store.manage.unavailable",
                    default: "Subscription management could not be opened.")
            }
        }
        #elseif canImport(AppKit)
        if Self.openManageSubscriptionsURL() {
            statusMessage = localized(
                "premium.store.manage.opened",
                default: "Account subscriptions opened in the App Store.")
        } else {
            statusMessage = localized(
                "premium.store.manage.unavailable",
                default: "Subscription management could not be opened.")
        }
        #else
        statusMessage = localized(
            "premium.store.manage.unsupported",
            default: "Subscription management is unavailable on this device.")
        #endif
    }

    func resetSimulatorDebugPurchase() async {
        guard Self.usesLocalDebugPremiumOverride else { return }
        UserDefaults.standard.removeObject(forKey: Self.debugPremiumUnlockedKey)
        premiumUnlocked = false
        statusMessage = localized(
            "premium.store.debug.reset",
            default: "Simulator test access reset.")
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
            premiumUnlocked = Self.localDebugPremiumUnlocked
            return
        }

        premiumUnlocked = false
        for await verification in Transaction.currentEntitlements {
            guard case .verified(let transaction) = verification else { continue }
            guard Self.premiumProductIDs.contains(transaction.productID) else { continue }
            // `currentEntitlements` already applies StoreKit's expiration,
            // revocation, renewal, and billing-grace rules. Rechecking the
            // normal expiration date here would incorrectly lock subscribers
            // who still have access during billing grace.
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

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localizedCurrent(key, default: defaultValue)
    }

    private func localizedFormat(
        _ key: String,
        default defaultValue: String,
        _ arguments: CVarArg...) -> String
    {
        let format = localized(key, default: defaultValue)
        return String(format: format, locale: AppLocalizer.currentLocale(), arguments: arguments)
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
        statusMessage = localized(
            "premium.store.manage.opened",
            default: "Account subscriptions opened in the App Store.")
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

    private static var usesLocalDebugPremiumOverride: Bool {
        ProcessInfo.processInfo.environment["UITEST_MODE"] == "1"
            || explicitPremiumUnlockOverride != nil
    }

    private static var localDebugPremiumUnlocked: Bool {
        explicitPremiumUnlockOverride
            ?? UserDefaults.standard.bool(forKey: debugPremiumUnlockedKey)
    }

    private static var explicitPremiumUnlockOverride: Bool? {
        guard let rawValue = ProcessInfo.processInfo.environment["UITEST_PREMIUM_UNLOCKED"] else {
            return nil
        }
        switch rawValue.lowercased() {
        case "1", "true", "yes":
            return true
        case "0", "false", "no":
            return false
        default:
            return nil
        }
    }

    private static var uiTestCatalogState: PremiumCatalogLoadState? {
        uiTestCatalogStateOverride(environment: ProcessInfo.processInfo.environment)
    }

    static func uiTestCatalogStateOverride(environment: [String: String]) -> PremiumCatalogLoadState? {
        guard environment["UITEST_MODE"] == "1" else {
            return nil
        }
        switch environment["UITEST_PREMIUM_CATALOG_STATE"] {
        case "loading":
            return .loading
        case "offline":
            return .offline
        case "failed":
            return .failed
        default:
            return nil
        }
    }

    private static func isNetworkFailure(_ error: Error) -> Bool {
        if let storeKitError = error as? StoreKitError,
           case .networkError = storeKitError
        {
            return true
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return true
        }
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error,
           (underlying as NSError) !== nsError
        {
            return isNetworkFailure(underlying)
        }
        return false
    }
}
#else
@MainActor
final class MonetizationStore: ObservableObject {
    @Published var premiumUnlocked = false
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var statusMessage = AppLocalizer.localizedCurrent(
        "premium.store.unsupported",
        default: "Purchases are unavailable on this device.")
    @Published var subscriptionHealthMessage = ""
    @Published var premiumProducts: [String] = []
    @Published var tipProducts: [String] = []
    @Published private(set) var catalogLoadState: PremiumCatalogLoadState = .failed

    func refreshCatalogAndEntitlements() async {}
    func restorePurchases() async {}
    func purchase(_: String) async {}
    func openManageSubscriptions() async {}
    func resetSimulatorDebugPurchase() async {}
}
#endif
