@testable import CatholicFastingCore
import XCTest

@MainActor
final class AppLaunchExecutionStateTests: XCTestCase {
    func testOneShotLaunchGatesOnlyBeginOnce() {
        let state = AppLaunchExecutionState()

        XCTAssertTrue(state.beginLocalPreparation())
        XCTAssertFalse(state.beginLocalPreparation())
        XCTAssertTrue(state.beginUITestInitialNavigation())
        XCTAssertFalse(state.beginUITestInitialNavigation())
        XCTAssertTrue(state.beginDeferredStartup())
        XCTAssertFalse(state.beginDeferredStartup())
        XCTAssertTrue(state.hasRunDeferredStartup)
    }

    func testTipConfigurationIsMarkedExplicitlyAfterAttempt() {
        let state = AppLaunchExecutionState()

        XCTAssertFalse(state.hasConfiguredTips)
        state.markTipsConfigured()
        XCTAssertTrue(state.hasConfiguredTips)
    }

    func testForcedStoreRefreshBypassesOneShotGate() {
        let state = AppLaunchExecutionState()

        XCTAssertTrue(state.beginStoreCatalogRefresh(force: false))
        XCTAssertFalse(state.beginStoreCatalogRefresh(force: false))
        XCTAssertTrue(state.beginStoreCatalogRefresh(force: true))
        XCTAssertTrue(state.beginStoreCatalogRefresh(force: true))
    }
}
