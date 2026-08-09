@testable import CatholicFastingApp
import Foundation
import StoreKit
import StoreKitTest
import XCTest

@MainActor
final class MonetizationStoreStoreKitTests: XCTestCase {
    private let monthlyProductID = MonetizationStore.premiumMonthlyID
    private let yearlyProductID = MonetizationStore.premiumYearlyID

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testFixtureLoadsSubscriptionCatalogAndPrices() async throws {
        let session = try makeSession()
        defer { reset(session) }

        let products = try await Product.products(for: MonetizationStore.allProductIDs)
        let productsByID = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })

        XCTAssertEqual(productsByID[monthlyProductID]?.displayPrice, "$3.99")
        XCTAssertEqual(productsByID[yearlyProductID]?.displayPrice, "$19.99")
        XCTAssertEqual(
            Set(productsByID.keys),
            MonetizationStore.allProductIDs,
            "The local fixture and app product catalog must remain in lockstep")
    }

    func testMonthlyPurchaseUnlocksAndPersistsAfterRelaunchEquivalentRefresh() async throws {
        let session = try makeSession()
        defer { reset(session) }

        let product = try await loadProduct(withID: monthlyProductID)

        let store = MonetizationStore()
        await store.purchase(product)

        XCTAssertTrue(store.premiumUnlocked)
        XCTAssertTrue(store.statusMessage.localizedCaseInsensitiveContains("active"))
        XCTAssertFalse(store.isPurchasing)

        let relaunchStore = MonetizationStore()
        await relaunchStore.refreshCatalogAndEntitlements()

        XCTAssertTrue(
            relaunchStore.premiumUnlocked,
            "A new store instance must recover the active monthly StoreKit entitlement")
        XCTAssertEqual(relaunchStore.catalogLoadState, .loaded)
    }

    func testYearlyPurchaseUnlocksAndPersistsAfterRelaunchEquivalentRefresh() async throws {
        let session = try makeSession()
        defer { reset(session) }

        let product = try await loadProduct(withID: yearlyProductID)

        let store = MonetizationStore()
        await store.purchase(product)

        XCTAssertTrue(store.premiumUnlocked)
        XCTAssertTrue(store.statusMessage.localizedCaseInsensitiveContains("active"))
        XCTAssertFalse(store.isPurchasing)

        let relaunchStore = MonetizationStore()
        await relaunchStore.refreshCatalogAndEntitlements()

        XCTAssertTrue(
            relaunchStore.premiumUnlocked,
            "A new store instance must recover the active yearly StoreKit entitlement")
        XCTAssertEqual(relaunchStore.catalogLoadState, .loaded)
    }

    func testRestoreWithActiveTransactionReportsSuccess() async throws {
        let session = try makeSession()
        defer { reset(session) }

        let product = try await loadProduct(withID: yearlyProductID)
        let purchaseStore = MonetizationStore()
        await purchaseStore.purchase(product)
        XCTAssertTrue(purchaseStore.premiumUnlocked)

        let store = MonetizationStore()
        await store.restorePurchases()

        XCTAssertTrue(store.premiumUnlocked)
        XCTAssertTrue(store.statusMessage.localizedCaseInsensitiveContains("restored"))
    }

    func testRestoreWithNoTransactionsReportsEmptyState() async throws {
        let session = try makeSession()
        defer { reset(session) }

        let store = MonetizationStore()
        await store.restorePurchases()

        XCTAssertFalse(store.premiumUnlocked)
        XCTAssertTrue(store.statusMessage.localizedCaseInsensitiveContains("no active"))
    }

    func testCatalogFailurePreservesExistingEntitlement() async throws {
        let session = try makeSession()
        defer { reset(session) }

        let product = try await loadProduct(withID: monthlyProductID)
        let purchaseStore = MonetizationStore()
        await purchaseStore.purchase(product)
        XCTAssertTrue(purchaseStore.premiumUnlocked)

        try await session.setSimulatedError(
            .generic(.networkError(URLError(.notConnectedToInternet))),
            forAPI: .loadProducts)

        let store = MonetizationStore()
        await store.refreshCatalogAndEntitlements()

        XCTAssertTrue(
            store.premiumUnlocked,
            "A catalog outage must not revoke an entitlement already reported by StoreKit")
        XCTAssertEqual(store.catalogLoadState, .offline)
    }

    func testUITestCatalogOverridesKeepLoadingOfflineAndFailureDistinct() {
        func environment(_ state: String) -> [String: String] {
            [
                "UITEST_MODE": "1",
                "UITEST_PREMIUM_CATALOG_STATE": state,
            ]
        }

        XCTAssertEqual(
            MonetizationStore.uiTestCatalogStateOverride(environment: environment("loading")),
            .loading)
        XCTAssertEqual(
            MonetizationStore.uiTestCatalogStateOverride(environment: environment("offline")),
            .offline)
        XCTAssertEqual(
            MonetizationStore.uiTestCatalogStateOverride(environment: environment("failed")),
            .failed)
        XCTAssertNil(
            MonetizationStore.uiTestCatalogStateOverride(
                environment: ["UITEST_PREMIUM_CATALOG_STATE": "loading"]),
            "Catalog overrides must remain unavailable outside UI-test mode")
    }

    func testPendingPurchaseMapsToPendingStatusWithoutStoreKitDialog() async throws {
        let session = try makeSession()
        defer { reset(session) }

        let products = try await Product.products(for: [monthlyProductID])
        let product = try XCTUnwrap(
            products.first,
            "The monthly fixture product must be available")
        let store = MonetizationStore(
            purchaseClient: StubPurchaseClient(result: .pending))

        await store.purchase(product)

        XCTAssertFalse(store.premiumUnlocked)
        XCTAssertTrue(store.statusMessage.localizedCaseInsensitiveContains("awaiting approval"))
        XCTAssertFalse(store.isPurchasing)
    }

    func testCancelledPurchaseMapsToCancelledStatusWithoutStoreKitDialog() async throws {
        let session = try makeSession()
        defer { reset(session) }

        let products = try await Product.products(for: [monthlyProductID])
        let product = try XCTUnwrap(
            products.first,
            "The monthly fixture product must be available")
        let store = MonetizationStore(
            purchaseClient: StubPurchaseClient(result: .userCancelled))

        await store.purchase(product)

        XCTAssertFalse(store.premiumUnlocked)
        XCTAssertTrue(store.statusMessage.localizedCaseInsensitiveContains("cancel"))
        XCTAssertFalse(store.isPurchasing)
    }
}

@MainActor
private final class StubPurchaseClient: MonetizationPurchaseClient {
    private let result: Product.PurchaseResult

    init(result: Product.PurchaseResult) {
        self.result = result
    }

    func purchase(_: Product) async throws -> Product.PurchaseResult {
        result
    }
}

@MainActor
private extension MonetizationStoreStoreKitTests {
    func loadProduct(withID productID: String) async throws -> Product {
        let products = try await Product.products(for: [productID])
        return try XCTUnwrap(
            products.first(where: { $0.id == productID }),
            "The fixture product \(productID) must be available")
    }

    func makeSession() throws -> SKTestSession {
        let session = try SKTestSession(configurationFileNamed: "Premium.storekit")
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        session.locale = Locale(identifier: "en_US")
        session.storefront = "USA"
        return session
    }

    func reset(_ session: SKTestSession) {
        session.resetToDefaultState()
        session.clearTransactions()
    }
}
