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
        if ProcessInfo.processInfo.environment["UITEST_COMPANION_ACTION"] == "journal" {
            guard launchExecutionState.beginUITestInitialNavigation() else { return }
            performCompanionAction(
                CompanionNextAction(
                    id: "uitest-journal",
                    title: "Journal",
                    detail: "Open Journal",
                    destination: .journal,
                    priority: .high,
                    requiresPremium: true))
            return
        }
        if let rawURL = ProcessInfo.processInfo.environment["UITEST_DEEP_LINK_URL"],
           let url = URL(string: rawURL)
        {
            guard launchExecutionState.beginUITestInitialNavigation() else { return }
            handleDeepLink(url)
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
        feedback.notificationStatus = await ReminderScheduler.notificationSummary()
    }

    func applyCoreLifecycleHandlers(to content: some View) -> some View {
        let routedContent = applyRoutingAndOnboardingHandlers(to: content)
        let navigatedContent = applyNavigationLifecycleHandlers(to: routedContent)
        let monetizedContent = applyMonetizationLifecycleHandlers(to: navigatedContent)
        return applySceneLifecycleHandlers(to: monetizedContent)
    }

    private func applyRoutingAndOnboardingHandlers(to content: some View) -> some View {
        content
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .onChange(of: acceptedLegalNotice) { _, newValue in
                acceptedLegalNoticeAt = newValue ? UIConstants.exportISO8601.string(from: Date()) : ""
                Task {
                    await refreshDailyQuoteReminderIfNeeded()
                    feedback.notificationStatus = await ReminderScheduler.notificationSummary()
                }
            }
            .task {
                prepareLocalLaunchStateIfNeeded()
                applyUITestInitialNavigationIfNeeded()
            }
            .onChange(of: didCompleteOnboarding) { _, completed in
                guard completed else { return }
                Task {
                    await runDeferredPlatformStartupIfNeeded()
                }
            }
    }

    private func applyNavigationLifecycleHandlers(to content: some View) -> some View {
        content
            .onChange(of: navigationState.homeSurface) { _, newValue in
                if newValue == .fastingDays, launchFunnelSnapshot.firstActionCompletedAt == nil {
                    launchFunnelSnapshot.firstActionCompletedAt = Date()
                }
                if newValue == .more {
                    let hasPendingPhoneNavigation = !navigationState.pendingPhoneNavigationPath.isEmpty
                    openPendingPhoneMoreDestinationIfNeeded()
                    if !appLayoutProfile.usesSplitViewShell,
                       !hasPendingPhoneNavigation,
                       !navigationState.morePath.isEmpty
                    {
                        navigationState.morePath = []
                    }
                }
                if newValue == .more, navigationState.selectedMoreDestination == .supportAndPremium {
                    Task {
                        await refreshStoreCatalogIfNeeded()
                    }
                }
            }
            .onChange(of: navigationState.selectedMoreDestination) { _, newValue in
                guard navigationState.homeSurface == .more, newValue == .supportAndPremium else { return }
                Task {
                    await refreshStoreCatalogIfNeeded()
                }
            }
    }

    private func applyMonetizationLifecycleHandlers(to content: some View) -> some View {
        content
            .onChange(of: supportPremiumSurfaceRaw) { _, newValue in
                if newValue == SupportPremiumSurface.upgrade.rawValue {
                    if launchFunnelSnapshot.paywallSeenAt == nil {
                        launchFunnelSnapshot.paywallSeenAt = Date()
                    }
                    launchFunnelSnapshot.paywallViewCount += 1
                    Task {
                        await refreshStoreCatalogIfNeeded()
                    }
                }
            }
            .onChange(of: monetizationStore.isPurchasing) { _, isPurchasing in
                if isPurchasing, launchFunnelSnapshot.purchaseStartedAt == nil {
                    launchFunnelSnapshot.purchaseStartedAt = Date()
                }
            }
            .onChange(of: monetizationStore.premiumUnlocked) { _, unlocked in
                if unlocked, launchFunnelSnapshot.premiumUnlockedAt == nil {
                    launchFunnelSnapshot.premiumUnlockedAt = Date()
                }
            }
    }

    private func applySceneLifecycleHandlers(to content: some View) -> some View {
        content
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .active {
                    Task {
                        prepareLocalLaunchStateIfNeeded()
                        await runDeferredPlatformStartupIfNeeded()
                        if launchExecutionState.hasRunDeferredStartup {
                            await refreshReminderIntegrationsIfNeeded()
                        }
                    }
                } else if newValue == .background {
                    saveAdvancedState()
                }
            }
    }

    var onboardingLaunchRoot: some View {
        OnboardingView(
            age14OrOlderForAbstinence: $age14OrOlderForAbstinence,
            age18OrOlderForFasting: $age18OrOlderForFasting,
            medicalDispensation: $medicalDispensation,
            languageModeRaw: $languageModeRaw,
            regionProfileRaw: $regionProfileRaw,
            fridayModeRaw: $fridayModeRaw,
            reminderTierRaw: $reminderTierRaw,
            dailyReminderSupportEnabled: $dailyReminderSupportEnabled,
            morningReminderEnabled: $morningReminderEnabled,
            eveningReminderEnabled: $eveningReminderEnabled,
            dailyQuoteReminderEnabled: $dailyQuoteReminderEnabled,
            dailyQuoteReminderHour: $dailyQuoteReminderHour,
            dailyQuoteReminderMinute: $dailyQuoteReminderMinute,
            intermittentIntentionRaw: $intermittentIntentionRaw,
            acceptedLegalNotice: $acceptedLegalNotice)
        {
            didCompleteOnboarding = true
            launchFunnelSnapshot.completedOnboardingAt = Date()
            Task {
                await runDeferredPlatformStartupIfNeeded()
            }
        }
        .appRootBackground()
        .task {
            prepareLocalLaunchStateIfNeeded()
        }
    }

    func applyLaunchPersistenceHandlers(to content: some View) -> some View {
        content
            .onChange(of: regionProfileRaw) { _, newValue in
                launchFunnelSnapshot.selectedRegionRaw = newValue
            }
            .onChange(of: reminderTierRaw) { _, newValue in
                launchFunnelSnapshot.selectedReminderTierRaw = newValue
            }
            .onChange(of: dailyReminderSupportEnabled) { _, _ in
                syncReminderTierFromCurrentToggleState()
            }
            .onChange(of: morningReminderEnabled) { _, _ in
                syncReminderTierFromCurrentToggleState()
            }
            .onChange(of: eveningReminderEnabled) { _, _ in
                syncReminderTierFromCurrentToggleState()
            }
            .onChange(of: dailyQuoteReminderEnabled) { _, _ in
                Task {
                    await scheduleDailyQuoteReminderFromCurrentSettings()
                }
            }
            .onChange(of: dailyQuoteReminderHour) { _, _ in
                guard acceptedLegalNotice, dailyQuoteReminderEnabled else { return }
                Task {
                    await scheduleDailyQuoteReminderFromCurrentSettings()
                }
            }
            .onChange(of: dailyQuoteReminderMinute) { _, _ in
                guard acceptedLegalNotice, dailyQuoteReminderEnabled else { return }
                Task {
                    await scheduleDailyQuoteReminderFromCurrentSettings()
                }
            }
            .onChange(of: languageModeRaw) { _, _ in
                guard acceptedLegalNotice, dailyQuoteReminderEnabled else { return }
                Task {
                    await scheduleDailyQuoteReminderFromCurrentSettings()
                }
            }
    }

    func applyStateSavePersistenceHandlers(to content: some View) -> some View {
        let planningContent = applyPlanningPersistenceHandlers(to: content)
        let profileContent = applyProfilePersistenceHandlers(to: planningContent)
        let premiumContent = applyPremiumPersistenceHandlers(to: profileContent)
        return applyFunnelPersistenceHandlers(to: premiumContent)
    }

    private func applyPlanningPersistenceHandlers(to content: some View) -> some View {
        content
            .onChange(of: planningSession.data) { _, newValue in
                LocalFeatureStore.savePlanningData(newValue)
            }
            .onChange(of: planningSession.schedules) { _, newValue in
                LocalFeatureStore.saveSchedules(newValue)
            }
            .onChange(of: planningSession.activeScheduleID) { _, newValue in
                LocalFeatureStore.saveActiveScheduleID(newValue)
            }
    }

    private func applyProfilePersistenceHandlers(to content: some View) -> some View {
        content
            .onChange(of: profileSession.householdProfiles) { _, newValue in
                LocalFeatureStore.saveProfiles(newValue)
            }
            .onChange(of: profileSession.activeHouseholdProfileID) { _, newValue in
                LocalFeatureStore.saveActiveProfileID(newValue)
            }
            .onChange(of: profileSession.devotionalFavorites) { _, newValue in
                LocalFeatureStore.saveDevotionalFavorites(newValue)
            }
    }

    private func applyPremiumPersistenceHandlers(to content: some View) -> some View {
        content
            .onChange(of: premiumSession.reflections) { _, newValue in
                LocalFeatureStore.saveReflections(newValue)
            }
            .onChange(of: premiumSession.checklist) { _, newValue in
                LocalFeatureStore.saveChecklist(newValue)
            }
            .onChange(of: premiumSession.companion) { _, newValue in
                LocalFeatureStore.savePremiumCompanionState(newValue)
            }
    }

    private func applyFunnelPersistenceHandlers(to content: some View) -> some View {
        content
            .onChange(of: launchFunnelSnapshot) { _, newValue in
                LocalFeatureStore.saveLaunchFunnelSnapshot(newValue)
            }
            .onDisappear {
                saveAdvancedState()
            }
    }

    func saveAdvancedState() {
        LocalFeatureStore.savePlanningData(planningSession.data)
        LocalFeatureStore.saveSchedules(planningSession.schedules)
        LocalFeatureStore.saveActiveScheduleID(planningSession.activeScheduleID)
        LocalFeatureStore.saveProfiles(profileSession.householdProfiles)
        LocalFeatureStore.saveActiveProfileID(profileSession.activeHouseholdProfileID)
        LocalFeatureStore.saveDevotionalFavorites(profileSession.devotionalFavorites)
        LocalFeatureStore.saveReflections(premiumSession.reflections)
        LocalFeatureStore.saveChecklist(premiumSession.checklist)
        LocalFeatureStore.savePremiumCompanionState(premiumSession.companion)
        LocalFeatureStore.saveLaunchFunnelSnapshot(launchFunnelSnapshot)
    }
}
