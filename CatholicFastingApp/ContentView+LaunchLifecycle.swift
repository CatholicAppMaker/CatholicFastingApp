import SwiftUI
#if canImport(TipKit)
import TipKit
#endif

extension ContentView {
    var appLaunchPolicy: AppLaunchPolicy {
        AppLaunchPolicy(
            didCompleteOnboarding: didCompleteOnboarding,
            acceptedLegalNotice: acceptedLegalNotice)
    }

    func prepareLocalLaunchStateIfNeeded() {
        migrateFastingAgeEligibilityIfNeeded()
        guard appLaunchPolicy.shouldPrepareLocalLaunchState else {
            return
        }
        guard launchExecutionState.beginLocalPreparation() else { return }
        if launchFunnelSnapshot.completedOnboardingAt == nil {
            launchFunnelSnapshot.startedAt = Date()
        }
        launchFunnelSnapshot.selectedRegionRaw = regionProfileRaw
        launchFunnelSnapshot.selectedReminderTierRaw = reminderTierRaw
        persistWidgetSnapshot()
        ensureActiveHouseholdProfileSelection()
    }

    private func migrateFastingAgeEligibilityIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.integer(forKey: StorageKeys.fastingAgeEligibilityContractVersion) < 2 else {
            return
        }

        // The former question meant “18 or older” and could not distinguish people 60+.
        // Reset only that ambiguous answer so every user explicitly confirms the canonical 18–59 band.
        age18OrOlderForFasting = false
        defaults.set(2, forKey: StorageKeys.fastingAgeEligibilityContractVersion)
    }

    func applyUITestInitialNavigationIfNeeded() {
        guard ProcessInfo.processInfo.environment["UITEST_MODE"] == "1" else {
            return
        }
        guard let rawDestination = ProcessInfo.processInfo.environment["UITEST_INITIAL_MORE_DESTINATION"],
              let destination = MoreHubDestination(rawValue: rawDestination)
        else {
            return
        }

        guard launchExecutionState.beginUITestInitialNavigation() else { return }
        navigateToMoreDestination(destination)
    }

    @MainActor
    func runDeferredPlatformStartupIfNeeded() async {
        let policy = appLaunchPolicy
        guard policy.shouldRunDeferredPlatformStartup else {
            return
        }
        guard launchExecutionState.beginDeferredStartup() else { return }

        if policy.shouldDelayInitialPlatformStartup {
            try? await Task.sleep(for: .milliseconds(750))
        }

        #if canImport(TipKit)
        if policy.shouldConfigureTips, !launchExecutionState.hasConfiguredTips {
            try? Tips.configure([
                .displayFrequency(.daily),
            ])
            launchExecutionState.markTipsConfigured()
        }
        #endif

        monetizationStore.startTransactionMonitoringIfNeeded()
        await refreshStoreCatalogIfNeeded()
        await refreshReminderIntegrationsIfNeeded()
    }

    @MainActor
    func refreshStoreCatalogIfNeeded(force: Bool = false) async {
        guard force || appLaunchPolicy.shouldRefreshStoreCatalog else {
            return
        }
        guard launchExecutionState.beginStoreCatalogRefresh(force: force) else { return }
        await monetizationStore.refreshCatalogAndEntitlements()
    }

    @MainActor
    func refreshReminderIntegrationsIfNeeded() async {
        guard appLaunchPolicy.shouldRefreshReminderIntegrations else {
            return
        }
        _ = await ReminderScheduler.topUpRequiredReminders(observances: rollingUpcomingObservances)
        await refreshDailyQuoteReminderIfNeeded()
        notificationStatus = await ReminderScheduler.notificationSummary()
    }
}
