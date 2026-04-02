import SwiftUI

extension ContentView {
    func localizedMoreHubHeroTitle() -> String {
        localized("more.hub.hero.title", default: "More")
    }

    func localizedMoreHubHeroSubtitle() -> String {
        localized(
            "more.hub.hero.subtitle",
            default: "One calm place for setup, guidance, privacy, and premium support.")
    }

    func localizedMoreHubLeadTitle() -> String {
        localized("more.hub.lead.title", default: "Choose one focused page")
    }

    func localizedMoreHubLeadDetail() -> String {
        localized(
            "more.hub.lead.detail",
            default: "Setup, guidance, privacy, and premium support stay grouped here instead of one long settings screen.")
    }

    func localizedHomeSurfaceLabel(_ surface: HomeSurface) -> String {
        switch surface {
        case .today:
            localized("home.surface.today", default: HomeSurface.today.label)
        case .fastingDays:
            localized("home.surface.fasting_days", default: HomeSurface.fastingDays.label)
        case .intermittent:
            localized("home.surface.intermittent", default: HomeSurface.intermittent.label)
        case .more:
            localized("home.surface.more", default: HomeSurface.more.label)
        }
    }

    func localizedSupportPremiumSurfaceLabel(_ surface: SupportPremiumSurface) -> String {
        switch surface {
        case .upgrade:
            localized("premium.surface.upgrade", default: surface.label)
        case .tools:
            localized("premium.surface.tools", default: surface.label)
        }
    }

    func localizedPremiumToolTitle(_ destination: PremiumToolDestination) -> String {
        switch destination {
        case .planner:
            localized("premium.tool.planner.title", default: destination.title)
        case .reminders:
            localized("premium.tool.reminders.title", default: destination.title)
        case .analytics:
            localized("premium.tool.analytics.title", default: destination.title)
        case .journal:
            localized("premium.tool.journal.title", default: destination.title)
        case .export:
            localized("premium.tool.export.title", default: destination.title)
        }
    }

    func localizedPremiumToolSubtitle(_ destination: PremiumToolDestination) -> String {
        switch destination {
        case .planner:
            localized("premium.tool.planner.subtitle", default: destination.subtitle)
        case .reminders:
            localized("premium.tool.reminders.subtitle", default: destination.subtitle)
        case .analytics:
            localized("premium.tool.analytics.subtitle", default: destination.subtitle)
        case .journal:
            localized("premium.tool.journal.subtitle", default: destination.subtitle)
        case .export:
            localized("premium.tool.export.subtitle", default: destination.subtitle)
        }
    }

    func localizedMoreDestinationTitle(_ destination: MoreHubDestination) -> String {
        switch destination {
        case .supportAndPremium:
            localized("more.destination.support.title", default: destination.title)
        case .setupAndReminders:
            localized("more.destination.setup.title", default: destination.title)
        case .profileAndNorms:
            localized("more.destination.profile.title", default: destination.title)
        case .guidanceAndRules:
            localized("more.destination.guidance.title", default: destination.title)
        case .privacyAndData:
            localized("more.destination.privacy.title", default: destination.title)
        }
    }

    func localizedMoreDestinationSubtitle(_ destination: MoreHubDestination) -> String {
        switch destination {
        case .supportAndPremium:
            localized("more.destination.support.subtitle", default: destination.subtitle)
        case .setupAndReminders:
            localized("more.destination.setup.subtitle", default: destination.subtitle)
        case .profileAndNorms:
            localized("more.destination.profile.subtitle", default: destination.subtitle)
        case .guidanceAndRules:
            localized("more.destination.guidance.subtitle", default: destination.subtitle)
        case .privacyAndData:
            localized("more.destination.privacy.subtitle", default: destination.subtitle)
        }
    }

    var tabRootView: AnyView {
        AnyView(
            TabView(selection: $homeSurface) {
                tabSurface(for: .today)
                    .tabItem {
                        Label(localizedHomeSurfaceLabel(.today), systemImage: HomeSurface.today.iconName)
                    }
                    .tag(HomeSurface.today)
                    .accessibilityIdentifier("tab.today")
                tabSurface(for: .fastingDays)
                    .tabItem {
                        Label(localizedHomeSurfaceLabel(.fastingDays), systemImage: HomeSurface.fastingDays.iconName)
                    }
                    .tag(HomeSurface.fastingDays)
                    .accessibilityIdentifier("tab.fasting_days")
                tabSurface(for: .intermittent)
                    .tabItem {
                        Label(localizedHomeSurfaceLabel(.intermittent), systemImage: HomeSurface.intermittent.iconName)
                    }
                    .tag(HomeSurface.intermittent)
                    .accessibilityIdentifier("tab.intermittent")
                tabSurface(for: .more)
                    .tabItem {
                        Label(localizedHomeSurfaceLabel(.more), systemImage: HomeSurface.more.iconName)
                    }
                    .tag(HomeSurface.more)
                    .accessibilityIdentifier("tab.more")
            })
    }

    var body: some View {
        applyRootLifecycleHandlers(
            to: Group {
                if appLayoutProfile.usesSplitViewShell {
                    ipadRootScaffold
                } else {
                    NavigationStack {
                        tabRootScaffold
                    }
                }
            })
    }

    var tabRootScaffold: AnyView {
        AnyView(
            tabRootView
                .appRootBackground()
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(CatholicTheme.parchment.opacity(0.88), for: .tabBar)
                .overlay(alignment: .topLeading) {
                    readinessMarkers
                }
                .navigationTitle(localizedHomeSurfaceLabel(homeSurface))
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        seasonBadge
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
                .tint(CatholicTheme.primary))
    }

    func applyRootLifecycleHandlers(to content: some View) -> some View {
        applyPersistenceHandlers(to: applyCoreLifecycleHandlers(to: content))
    }

    func applyCoreLifecycleHandlers(to content: some View) -> some View {
        content
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .onChange(of: acceptedLegalNotice) { _, newValue in
                acceptedLegalNoticeAt = newValue ? UIConstants.exportISO8601.string(from: Date()) : ""
                Task {
                    await refreshDailyQuoteReminderIfNeeded()
                    notificationStatus = await ReminderScheduler.notificationSummary()
                }
            }
            .sheet(isPresented: onboardingBinding) {
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
                    dailyQuoteReminderMinute: $dailyQuoteReminderMinute)
                {
                    didCompleteOnboarding = true
                    launchFunnelSnapshot.completedOnboardingAt = Date()
                }
            }
            .task {
                await performInitialStartupTasks()
            }
            .onChange(of: homeSurface) { _, newValue in
                if newValue == .fastingDays, launchFunnelSnapshot.firstActionCompletedAt == nil {
                    launchFunnelSnapshot.firstActionCompletedAt = Date()
                }
            }
            .onChange(of: supportPremiumSurfaceRaw) { _, newValue in
                if newValue == SupportPremiumSurface.upgrade.rawValue {
                    if launchFunnelSnapshot.paywallSeenAt == nil {
                        launchFunnelSnapshot.paywallSeenAt = Date()
                    }
                    launchFunnelSnapshot.paywallViewCount += 1
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
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .active {
                    Task {
                        _ = await ReminderScheduler.topUpRequiredReminders(observances: rollingUpcomingObservances)
                        await refreshDailyQuoteReminderIfNeeded()
                        notificationStatus = await ReminderScheduler.notificationSummary()
                    }
                } else if newValue == .background {
                    saveAdvancedState()
                }
            }
    }

    func applyPersistenceHandlers(to content: some View) -> some View {
        let snapshotWrapped = applySnapshotPersistenceHandlers(to: content)
        let launchWrapped = applyLaunchPersistenceHandlers(to: snapshotWrapped)
        return applyStateSavePersistenceHandlers(to: launchWrapped)
    }

    func applySnapshotPersistenceHandlers(to content: some View) -> some View {
        content
            .onChange(of: tracker.statusesByID) { _, _ in
                persistWidgetSnapshot()
            }
            .onChange(of: intermittentTracker.activeStart) { _, _ in
                persistWidgetSnapshot()
            }
            .onChange(of: intermittentTracker.sessions) { _, _ in
                persistWidgetSnapshot()
            }
            .onChange(of: year) { _, _ in
                persistWidgetSnapshot()
            }
            .onChange(of: settings) { _, _ in
                persistWidgetSnapshot()
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
        content
            .onChange(of: planningData) { _, _ in
                saveAdvancedState()
            }
            .onChange(of: intermittentSchedules) { _, _ in
                saveAdvancedState()
            }
            .onChange(of: activeIntermittentScheduleID) { _, _ in
                saveAdvancedState()
            }
            .onChange(of: householdProfiles) { _, _ in
                saveAdvancedState()
            }
            .onChange(of: activeHouseholdProfileID) { _, _ in
                saveAdvancedState()
            }
            .onChange(of: devotionalFavorites) { _, _ in
                saveAdvancedState()
            }
            .onChange(of: reflectionEntries) { _, _ in
                saveAdvancedState()
            }
            .onChange(of: premiumChecklist) { _, _ in
                saveAdvancedState()
            }
            .onChange(of: premiumCompanion) { _, _ in
                saveAdvancedState()
            }
            .onChange(of: launchFunnelSnapshot) { _, _ in
                saveAdvancedState()
            }
            .onDisappear {
                saveAdvancedState()
            }
    }

    func saveAdvancedState() {
        LocalFeatureStore.savePlanningData(planningData)
        LocalFeatureStore.saveSchedules(intermittentSchedules)
        LocalFeatureStore.saveActiveScheduleID(activeIntermittentScheduleID)
        LocalFeatureStore.saveProfiles(householdProfiles)
        LocalFeatureStore.saveActiveProfileID(activeHouseholdProfileID)
        LocalFeatureStore.saveDevotionalFavorites(devotionalFavorites)
        LocalFeatureStore.saveReflections(reflectionEntries)
        LocalFeatureStore.saveChecklist(premiumChecklist)
        LocalFeatureStore.savePremiumCompanionState(premiumCompanion)
        LocalFeatureStore.saveLaunchFunnelSnapshot(launchFunnelSnapshot)
    }

    @ViewBuilder
    var seasonBadge: some View {
        let localizedSeason = localizedSeasonLabel(currentLiturgicalSeason)
        let content = HStack(spacing: 6) {
            Image(systemName: "cross.case.fill")
                .foregroundStyle(CatholicTheme.primary)
                .accessibilityHidden(true)
            if liturgicalSeasonColorsEnabled, !dynamicTypeSize.isAccessibilitySize {
                Text(localizedSeason)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CatholicTheme.primary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .allowsHitTesting(false)
        .accessibilityIdentifier("home.season_badge")
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel(
            localizedFormat(
                "home.season_badge.accessibility",
                default: "Liturgical season %@",
                localizedSeason))

        content.appCapsuleGlass()
    }

    func surfaceList(for surface: HomeSurface) -> some View {
        List {
            surfaceSections(for: surface)
        }
        .listStyle(.insetGrouped)
        .appListBackground()
    }

    func tabSurface(for surface: HomeSurface) -> AnyView {
        AnyView(surfaceList(for: surface))
    }

    @ViewBuilder
    func surfaceSections(for surface: HomeSurface) -> some View {
        switch surface {
        case .today:
            Group {
                dashboardSacredImageSection
                todayDecisionCardSection
                dashboardQuickActionsSection
                todayTenSecondSection
                todaySection
                setupProgressSection
                todayRecoverySection
                if !acceptedLegalNotice {
                    unofficialAppNoticeSection
                }
                if simplifiedModeEnabled {
                    todaySimpleSummarySection
                } else {
                    dashboardDevotionalGallerySection
                    planningProgressSection
                    dashboardSeasonSection
                    dashboardHeroSection
                    progressSection
                    analyticsSection
                    milestoneReferralSection
                    personalInsightsSection
                    accessibilitySupportSection
                    dashboardHighlightsSection
                }
            }
        case .fastingDays:
            Group {
                fastingDaysHeroSection
                fastingDaysOverviewSection
                fastingDaysDisplayOptionsSection
                fastingDaysListSection
            }
        case .intermittent:
            Group {
                intermittentHeroSection
                intermittentActiveSection
                intermittentControlsSection
                intermittentOverviewSection
                intermittentAdvancedToolsSection
            }
        case .more:
            Group {
                moreHubSection
                unofficialAppNoticeSection
            }
        }
    }

    @ViewBuilder
    var moreHubSection: some View {
        let hero = moreDestinationHeroItem(for: .supportAndPremium)
        Section {
            VStack(alignment: .leading, spacing: 14) {
                SacredHeroCard(
                    assetName: hero.assetName,
                    title: localizedMoreHubHeroTitle(),
                    subtitle: localizedMoreHubHeroSubtitle(),
                    height: 152,
                    cornerRadius: 16,
                    accessibilityIdentifier: "more.hub.hero")

                CatholicFastingQuoteCard(quote: guidanceFastingQuote, compact: true)
                    .accessibilityIdentifier("more.hub.quote")

                AppSectionLeadCard(
                    eyebrow: localizedMoreHubHeroTitle(),
                    title: localizedMoreHubLeadTitle(),
                    detail: localizedMoreHubLeadDetail())
            }
        }

        Section {
            ForEach(MoreHubDestination.allCases) { destination in
                NavigationLink {
                    moreDestinationList(for: destination)
                } label: {
                    AppDestinationRowCard(
                        title: localizedMoreDestinationTitle(destination),
                        subtitle: localizedMoreDestinationSubtitle(destination),
                        systemImage: destination.iconName,
                        showsChevron: false)
                }
                .accessibilityIdentifier("more.hub.\(destination.rawValue)")
            }
        }
    }

    func moreDestinationList(for destination: MoreHubDestination) -> some View {
        List {
            moreDestinationHeroSection(for: destination)
            switch destination {
            case .supportAndPremium:
                premiumSurfacePickerSection
                if selectedSupportPremiumSurface == .upgrade {
                    premiumAndSupportSection
                } else {
                    if hasPremiumEntitlement(.planning) {
                        premiumToolsHubSection
                    } else {
                        premiumToolsLockedSection
                    }
                }
            case .setupAndReminders:
                quickSetupSection
                notificationsSection
                notesSection
            case .profileAndNorms:
                householdProfilesSection
                profileRulesSection
                regionalNormsSection
                themeSection
                accessibilityModeSection
                planningLayerSection
            case .guidanceAndRules:
                guidanceDevotionalGallerySection
                devotionalPackSection
                guidanceSeasonContextSection
                fastDayQuickRulesSection
                usccbGuidelinesSection
                foodGuidanceSection
                pastoralGuidanceSection
                faqSection
                sourcesSection
            case .privacyAndData:
                privacySection
                backupsSection
                dataManagementSection
            }
        }
        .listStyle(.insetGrouped)
        .appListBackground()
        .navigationTitle(localizedMoreDestinationTitle(destination))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func premiumToolSections(for destination: PremiumToolDestination) -> some View {
        switch destination {
        case .planner:
            premiumPlannerSection
            premiumChecklistSection
        case .reminders:
            premiumRemindersSection
        case .analytics:
            premiumAnalyticsSection
            premiumRecoveryCoachSection
        case .journal:
            premiumReflectionPromptSection
            reflectionJournalSection
            premiumVirtueTrackingSection
        case .export:
            premiumExportSummarySection
            premiumAdvancedExportSection
            premiumHouseholdShareSection
        }
    }

    func premiumToolIntroSection(for destination: PremiumToolDestination) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Label(localizedPremiumToolTitle(destination), systemImage: destination.iconName)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(CatholicTheme.primary)
                Text(localizedPremiumToolSubtitle(destination))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
    }

    func premiumToolList(for destination: PremiumToolDestination) -> some View {
        List {
            premiumToolIntroSection(for: destination)
            premiumToolSections(for: destination)
        }
        .listStyle(.insetGrouped)
        .appListBackground()
        .navigationTitle(localizedPremiumToolTitle(destination))
        .navigationBarTitleDisplayMode(.inline)
    }

    func moreDestinationHeroItem(for destination: MoreHubDestination) -> SacredImageryItem {
        let gallery = SacredImageryCatalog.fastingGallery
        guard !gallery.isEmpty else {
            return SacredImageryItem(
                id: "fallback-hero",
                assetName: "HeroSacred",
                title: localizedMoreDestinationTitle(destination),
                subtitle: localizedMoreDestinationSubtitle(destination))
        }
        let all = MoreHubDestination.allCases
        let idx = all.firstIndex(of: destination) ?? 0
        return gallery[idx % gallery.count]
    }

    func moreDestinationHeroSection(for destination: MoreHubDestination) -> some View {
        let hero = moreDestinationHeroItem(for: destination)
        return Section {
            SacredHeroCard(
                assetName: hero.assetName,
                title: localizedMoreDestinationTitle(destination),
                subtitle: localizedMoreDestinationSubtitle(destination),
                height: 122,
                cornerRadius: 16,
                accessibilityIdentifier: "more.\(destination.rawValue).hero")
        }
    }
}
