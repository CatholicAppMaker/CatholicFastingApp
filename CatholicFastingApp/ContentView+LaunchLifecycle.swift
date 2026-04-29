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
        guard appLaunchPolicy.shouldPrepareLocalLaunchState else {
            return
        }
        guard !didPrepareLaunchState else {
            return
        }

        didPrepareLaunchState = true
        if launchFunnelSnapshot.completedOnboardingAt == nil {
            launchFunnelSnapshot.startedAt = Date()
        }
        launchFunnelSnapshot.selectedRegionRaw = regionProfileRaw
        launchFunnelSnapshot.selectedReminderTierRaw = reminderTierRaw
        persistWidgetSnapshot()
        ensureActiveHouseholdProfileSelection()
    }

    @MainActor
    func runDeferredPlatformStartupIfNeeded() async {
        let policy = appLaunchPolicy
        guard policy.shouldRunDeferredPlatformStartup else {
            return
        }
        guard !didRunDeferredStartup else {
            return
        }

        didRunDeferredStartup = true

        if policy.shouldDelayInitialPlatformStartup {
            try? await Task.sleep(for: .milliseconds(750))
        }

        #if canImport(TipKit)
        if policy.shouldConfigureTips, !didConfigureTips {
            try? Tips.configure([
                .displayFrequency(.daily),
            ])
            didConfigureTips = true
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
        guard force || !didRefreshStoreCatalog else {
            return
        }

        didRefreshStoreCatalog = true
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
