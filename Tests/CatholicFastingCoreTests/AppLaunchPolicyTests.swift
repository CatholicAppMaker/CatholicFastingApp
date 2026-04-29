@testable import CatholicFastingCore
import XCTest

final class AppLaunchPolicyTests: XCTestCase {
    func testFreshInstallDoesNotRunDeferredPlatformStartup() {
        let policy = AppLaunchPolicy(
            didCompleteOnboarding: false,
            acceptedLegalNotice: false)

        XCTAssertTrue(policy.shouldPrepareLocalLaunchState)
        XCTAssertFalse(policy.shouldRunDeferredPlatformStartup)
        XCTAssertFalse(policy.shouldRefreshStoreCatalog)
        XCTAssertFalse(policy.shouldConfigureTips)
        XCTAssertFalse(policy.shouldRefreshReminderIntegrations)
    }

    func testCompletedOnboardingAllowsStoreStartupButNotReminderSchedulingBeforeLegalNotice() {
        let policy = AppLaunchPolicy(
            didCompleteOnboarding: true,
            acceptedLegalNotice: false)

        XCTAssertTrue(policy.shouldRunDeferredPlatformStartup)
        XCTAssertTrue(policy.shouldRefreshStoreCatalog)
        XCTAssertTrue(policy.shouldConfigureTips)
        XCTAssertFalse(policy.shouldRefreshReminderIntegrations)
    }

    func testCompletedSetupAllowsReminderIntegrationRefresh() {
        let policy = AppLaunchPolicy(
            didCompleteOnboarding: true,
            acceptedLegalNotice: true)

        XCTAssertTrue(policy.shouldRefreshReminderIntegrations)
    }
}
