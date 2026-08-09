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
        case .historyOfFasting:
            localized("more.destination.history.title", default: destination.title)
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
        case .historyOfFasting:
            localized("more.destination.history.subtitle", default: destination.subtitle)
        case .privacyAndData:
            localized("more.destination.privacy.subtitle", default: destination.subtitle)
        }
    }

    var tabRootView: some View {
        TabView(selection: $navigationState.homeSurface) {
            todayPhoneTab
            fastingDaysPhoneTab
            intermittentPhoneTab
            morePhoneTab
        }
        .appPhoneTabChrome()
    }

    var tabRootScaffold: some View {
        tabRootView
            .appRootBackground()
            .overlay(alignment: .topLeading) {
                readinessMarkers
            }
            .tint(CatholicTheme.primary)
    }

    var todayPhoneTab: some View {
        PhoneNavigationTab(
            title: localizedHomeSurfaceLabel(.today),
            surface: .today,
            content: { todaySurfaceList },
            toolbar: { phoneTabToolbar },
            more: moreDestinationList,
            premium: premiumToolList,
            history: fastingHistoryArticleDetail)
    }

    var fastingDaysPhoneTab: some View {
        PhoneNavigationTab(
            title: localizedHomeSurfaceLabel(.fastingDays),
            surface: .fastingDays,
            content: { fastingDaysSurfaceList },
            toolbar: { phoneTabToolbar },
            more: moreDestinationList,
            premium: premiumToolList,
            history: fastingHistoryArticleDetail)
    }

    var intermittentPhoneTab: some View {
        PhoneNavigationTab(
            title: localizedHomeSurfaceLabel(.intermittent),
            surface: .intermittent,
            content: { intermittentSurfaceList },
            toolbar: { phoneTabToolbar },
            more: moreDestinationList,
            premium: premiumToolList,
            history: fastingHistoryArticleDetail)
    }

    var morePhoneTab: some View {
        PhonePathNavigationTab(
            title: localizedHomeSurfaceLabel(.more),
            surface: .more,
            path: $navigationState.morePath,
            content: { moreSurfaceList },
            toolbar: { phoneTabToolbar },
            more: moreDestinationList,
            premium: premiumToolList,
            history: fastingHistoryArticleDetail,
            onAppear: openPendingPhoneMoreDestinationIfNeeded)
    }

    @ToolbarContentBuilder
    var phoneTabToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            phoneBrandMark
        }

        ToolbarItem(placement: .topBarTrailing) {
            seasonBadge
        }
    }

    func applyRootLifecycleHandlers(to content: some View) -> some View {
        applyPersistenceHandlers(to: applyCoreLifecycleHandlers(to: content))
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
            .onChange(of: languageModeRaw) { _, _ in
                persistWidgetSnapshot()
            }
    }

    @ViewBuilder
    var seasonBadge: some View {
        let localizedSeason = localizedSeasonLabel(currentLiturgicalSeason)
        PhoneSeasonBadge(
            localizedSeason: localizedSeason,
            showsSeasonName: liturgicalSeasonColorsEnabled && !dynamicTypeSize.isAccessibilitySize,
            accessibilityLabel: localizedFormat(
                "home.season_badge.accessibility",
                default: "Liturgical season %@",
                localizedSeason))
    }

    var phoneBrandMark: some View {
        PhoneBrandMark(
            accessibilityLabel: localized("shared.app_full_title", default: "Catholic Fasting App"))
    }

    var todaySurfaceList: some View {
        PhoneSurfaceList {
            todaySurfaceSections
        }
    }

    var fastingDaysSurfaceList: some View {
        PhoneSurfaceList {
            fastingDaysSurfaceSections
        }
    }

    var intermittentSurfaceList: some View {
        PhoneSurfaceList {
            intermittentSurfaceSections
        }
        .scrollDismissesKeyboard(.immediately)
    }

    var moreSurfaceList: some View {
        PhoneSurfaceList {
            MoreHubSections(
                heroTitle: localizedMoreHubHeroTitle(),
                heroSubtitle: localizedMoreHubHeroSubtitle(),
                destinations: MoreHubDestination.allCases.map { destination in
                    MoreHubDestinationPresentation(
                        destination: destination,
                        title: localizedMoreDestinationTitle(destination),
                        subtitle: localizedMoreDestinationSubtitle(destination))
                },
                quote: guidanceFastingQuote,
                quoteSectionTitle: localized("more.quote.section", default: "Guidance reflection"),
                unofficialNotice: { unofficialAppNoticeSection },
                selectDestination: { destination in
                    navigationState.morePath.append(.more(destination))
                })
        }
    }

    @ViewBuilder
    var todaySurfaceSections: some View {
        companionDashboardSection
        companionLiveStateSection
        todayDecisionCardSection
        todaySection
        todayRecoverySection
        if !acceptedLegalNotice {
            unofficialAppNoticeSection
        }
        if simplifiedModeEnabled {
            todaySimpleSummarySection
        } else {
            companionFormationSection
            planningProgressSection
            setupProgressSection
            todayTenSecondSection
            dashboardSeasonSection
            progressSection
            analyticsSection
            milestoneReferralSection
            personalInsightsSection
            accessibilitySupportSection
            dashboardHighlightsSection
            dashboardFastingQuoteSection
            dashboardHeroSection
        }
    }

    @ViewBuilder
    var fastingDaysSurfaceSections: some View {
        fastingDaysOverviewSection
        fastingDaysHeroSection
        fastingDaysDisplayOptionsSection
        fastingDaysListSection
        fastingDaysFastingQuoteSection
    }

    @ViewBuilder
    var intermittentSurfaceSections: some View {
        intermittentControlCenterSection
        intermittentHeroSection
        intermittentOverviewSection
        intermittentAdvancedToolsSection
        intermittentFastingQuoteSection
    }

    func moreDestinationList(for destination: MoreHubDestination) -> some View {
        PhoneDestinationSurface(title: localizedMoreDestinationTitle(destination)) {
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
                moreDestinationHeroSection(for: destination)
            case .setupAndReminders:
                quickSetupSection
                notificationsSection
                notesSection
                moreDestinationHeroSection(for: destination)
            case .profileAndNorms:
                householdProfilesSection
                profileRulesSection
                regionalNormsSection
                themeSection
                accessibilityModeSection
                planningLayerSection
                moreDestinationHeroSection(for: destination)
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
                moreDestinationHeroSection(for: destination)
            case .historyOfFasting:
                historyOfFastingOverviewSection
                historyOfFastingTimelineSection
                moreDestinationHeroSection(for: destination)
            case .privacyAndData:
                privacySection
                backupsSection
                dataManagementSection
                moreDestinationHeroSection(for: destination)
            }
        }
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
        PremiumToolIntroSection(
            title: localizedPremiumToolTitle(destination),
            subtitle: localizedPremiumToolSubtitle(destination),
            iconName: destination.iconName)
    }

    func premiumToolList(for destination: PremiumToolDestination) -> some View {
        PhoneDestinationSurface(title: localizedPremiumToolTitle(destination)) {
            premiumToolIntroSection(for: destination)
            premiumToolSections(for: destination)
        }
    }

    func moreDestinationHeroItem(for destination: MoreHubDestination) -> SacredImageryItem {
        let assetName = switch destination {
        case .supportAndPremium:
            "SacredChaliceVine"
        case .setupAndReminders:
            "SacredScriptureCandle"
        case .profileAndNorms:
            "SacredMarianMonogram"
        case .guidanceAndRules:
            "GuidanceSacred"
        case .historyOfFasting:
            "SacredBreadRosary"
        case .privacyAndData:
            "SacredAlmsgivingTable"
        }

        return SacredImageryItem(
            id: "\(destination.rawValue)-hero",
            assetName: assetName,
            title: localizedMoreDestinationTitle(destination),
            subtitle: localizedMoreDestinationSubtitle(destination))
    }

    func moreDestinationHeroSection(for destination: MoreHubDestination) -> some View {
        let hero = moreDestinationHeroItem(for: destination)
        return Section {
            SacredSurfaceAnchorCard(
                assetName: hero.assetName,
                title: localizedMoreDestinationTitle(destination),
                subtitle: localizedMoreDestinationSubtitle(destination),
                imageHeight: 104,
                cornerRadius: 16,
                accessibilityIdentifier: "more.\(destination.rawValue).hero")
        }
    }

    func openPendingPhoneMoreDestinationIfNeeded() {
        guard
            !appLayoutProfile.usesSplitViewShell,
            navigationState.homeSurface == .more,
            !navigationState.pendingPhoneNavigationPath.isEmpty
        else {
            return
        }
        navigationState.morePath = navigationState.pendingPhoneNavigationPath
        navigationState.pendingPhoneNavigationPath = []
    }

    func navigateToMoreDestination(_ destination: MoreHubDestination) {
        navigationState.selectedMoreDestination = destination
        if appLayoutProfile.usesSplitViewShell {
            navigationState.homeSurface = .more
            return
        }

        navigationState.pendingPhoneNavigationPath = [.more(destination)]
        if navigationState.homeSurface == .more {
            openPendingPhoneMoreDestinationIfNeeded()
        } else {
            navigationState.homeSurface = .more
        }
    }

    func navigateToPremiumTool(_ destination: PremiumToolDestination) {
        guard monetizationStore.premiumUnlocked else {
            supportPremiumSurfaceRaw = SupportPremiumSurface.upgrade.rawValue
            navigateToMoreDestination(.supportAndPremium)
            return
        }

        navigationState.selectedMoreDestination = .supportAndPremium
        navigationState.selectedPremiumToolDestination = destination
        supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue

        guard !appLayoutProfile.usesSplitViewShell else {
            navigationState.homeSurface = .more
            return
        }

        navigationState.pendingPhoneNavigationPath = [
            .more(.supportAndPremium),
            .premium(destination),
        ]
        if navigationState.homeSurface == .more {
            openPendingPhoneMoreDestinationIfNeeded()
        } else {
            navigationState.homeSurface = .more
        }
    }
}
