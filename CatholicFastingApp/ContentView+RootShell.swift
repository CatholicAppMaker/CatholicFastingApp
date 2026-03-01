import SwiftUI

extension ContentView {
  var tabRootView: AnyView {
    AnyView(
      TabView(selection: $homeSurface) {
        surfaceList(for: .today)
          .tabItem {
            Label(HomeSurface.today.label, systemImage: HomeSurface.today.iconName)
          }
          .tag(HomeSurface.today)
          .accessibilityIdentifier("tab.today")
        surfaceList(for: .fastingDays)
          .tabItem {
            Label(HomeSurface.fastingDays.label, systemImage: HomeSurface.fastingDays.iconName)
          }
          .tag(HomeSurface.fastingDays)
          .accessibilityIdentifier("tab.fasting_days")
        surfaceList(for: .intermittent)
          .tabItem {
            Label(HomeSurface.intermittent.label, systemImage: HomeSurface.intermittent.iconName)
          }
          .tag(HomeSurface.intermittent)
          .accessibilityIdentifier("tab.intermittent")
        surfaceList(for: .more)
          .tabItem {
            Label(HomeSurface.more.label, systemImage: HomeSurface.more.iconName)
          }
          .tag(HomeSurface.more)
          .accessibilityIdentifier("tab.more")
      }
    )
  }

  var body: some View {
    applyRootLifecycleHandlers(
      to: NavigationStack {
        tabRootScaffold
      }
    )
  }

  var tabRootScaffold: AnyView {
    AnyView(
      tabRootView
        .appRootBackground()
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .overlay(alignment: .topLeading) {
          readinessMarkers
        }
        .navigationTitle("Catholic Fasting")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
          if #available(iOS 26.0, *) {
            ToolbarItem(placement: .topBarTrailing) {
              seasonBadge
            }
            .sharedBackgroundVisibility(.hidden)
          } else {
            ToolbarItem(placement: .topBarTrailing) {
              seasonBadge
            }
          }
        }
        .tint(CatholicTheme.primary)
    )
  }

  func applyRootLifecycleHandlers<Content: View>(to content: Content) -> some View {
    applyPersistenceHandlers(to: applyCoreLifecycleHandlers(to: content))
  }

  func applyCoreLifecycleHandlers<Content: View>(to content: Content) -> some View {
    content
      .onOpenURL { url in
        handleDeepLink(url)
      }
      .onChange(of: acceptedLegalNotice) { _, newValue in
        acceptedLegalNoticeAt = newValue ? UIConstants.exportISO8601.string(from: Date()) : ""
      }
      .sheet(isPresented: onboardingBinding) {
        OnboardingView(
          age14OrOlderForAbstinence: $age14OrOlderForAbstinence,
          age18OrOlderForFasting: $age18OrOlderForFasting,
          medicalDispensation: $medicalDispensation,
          fridayModeRaw: $fridayModeRaw,
          dailyReminderSupportEnabled: $dailyReminderSupportEnabled
        ) {
          didCompleteOnboarding = true
        }
      }
      .task {
        await performInitialStartupTasks()
      }
      .onChange(of: scenePhase) { _, newValue in
        if newValue == .active {
          Task {
            _ = await ReminderScheduler.topUpRequiredReminders(observances: rollingUpcomingObservances)
            notificationStatus = await ReminderScheduler.notificationSummary()
          }
        } else if newValue == .background {
          saveAdvancedState()
        }
      }
  }

  func applyPersistenceHandlers<Content: View>(to content: Content) -> some View {
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
      .onChange(of: planningData) { _, _ in
        saveAdvancedState()
      }
      .onChange(of: intermittentSchedules) { _, _ in
        saveAdvancedState()
      }
      .onChange(of: activeIntermittentScheduleID) { _, _ in
        saveAdvancedState()
      }
      .onChange(of: savedFastingDaysPresets) { _, _ in
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
      .onDisappear {
        saveAdvancedState()
      }
  }

  func saveAdvancedState() {
    LocalFeatureStore.savePlanningData(planningData)
    LocalFeatureStore.saveSchedules(intermittentSchedules)
    LocalFeatureStore.saveActiveScheduleID(activeIntermittentScheduleID)
    LocalFeatureStore.savePresets(savedFastingDaysPresets)
    LocalFeatureStore.saveProfiles(householdProfiles)
    LocalFeatureStore.saveActiveProfileID(activeHouseholdProfileID)
    LocalFeatureStore.saveDevotionalFavorites(devotionalFavorites)
    LocalFeatureStore.saveReflections(reflectionEntries)
    LocalFeatureStore.saveChecklist(premiumChecklist)
    LocalFeatureStore.savePremiumCompanionState(premiumCompanion)
  }

  @ViewBuilder
  var seasonBadge: some View {
    let content = HStack(spacing: 6) {
      Image(systemName: "cross.case.fill")
        .foregroundStyle(CatholicTheme.primary)
        .accessibilityHidden(true)
      if liturgicalSeasonColorsEnabled && !dynamicTypeSize.isAccessibilitySize {
        Text("Liturgical Season: \(CatholicTheme.seasonToolbarLabel)")
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
    .accessibilityLabel("Liturgical season \(CatholicTheme.seasonToolbarLabel)")

    if #available(iOS 26.0, *) {
      content.appCapsuleGlass()
    } else {
      content
        .background(
          Capsule()
            .fill(CatholicTheme.parchment)
        )
        .overlay(
          Capsule()
            .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1)
        )
    }
  }

  func surfaceList(for surface: HomeSurface) -> some View {
    List {
      surfaceSections(for: surface)
    }
    .listStyle(.insetGrouped)
    .appListBackground()
  }

  func surfaceSections(for surface: HomeSurface) -> AnyView {
    switch surface {
    case .today:
      return AnyView(
        Group {
          unofficialAppNoticeSection
          dashboardSacredImageSection
          if !simplifiedModeEnabled {
            dashboardDevotionalGallerySection
          }
          dashboardQuickActionsSection
          setupProgressSection
          planningProgressSection
          todayDecisionCardSection
          todayRecoverySection
          dashboardSeasonSection
          dashboardHeroSection
          todaySection
          progressSection
          analyticsSection
          personalInsightsSection
          accessibilitySupportSection
          dashboardHighlightsSection
        }
      )
    case .fastingDays:
      return AnyView(
        Group {
          fastingDaysHeroSection
          fastingDaysOverviewSection
          fastingDaysDisplayOptionsSection
          fastingDaysListSection
        }
      )
    case .intermittent:
      return AnyView(
        Group {
          intermittentHeroSection
          intermittentActiveSection
          intermittentOverviewSection
          intermittentControlsSection
          intermittentAdvancedToggleSection
          if intermittentShowAdvanced {
            intermittentScheduleSection
            intermittentMilestonesSection
            intermittentRecoverySection
            intermittentSessionHistorySection
          }
        }
      )
    case .more:
      return AnyView(
        Group {
          unofficialAppNoticeSection
          moreHubSection
        }
      )
    }
  }

  var moreHubSection: some View {
    Section("More Tools") {
      Text("Choose a focused page instead of scrolling through every setting in one place.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      ForEach(MoreHubDestination.allCases) { destination in
        NavigationLink {
          moreDestinationList(for: destination)
        } label: {
          VStack(alignment: .leading, spacing: 4) {
            Label(destination.title, systemImage: destination.iconName)
              .font(.headline)
              .foregroundStyle(CatholicTheme.primary)
            Text(destination.subtitle)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          .padding(.vertical, 2)
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
        premiumAndSupportSection
        premiumCompanionLabSection
        premiumChecklistSection
        reflectionJournalSection
      case .setupAndReminders:
        quickSetupSection
        notificationsSection
        notesSection
      case .profileAndNorms:
        householdProfilesSection
        planningLayerSection
        profileRulesSection
        regionalNormsSection
        accessibilityModeSection
        themeSection
      case .guidanceAndRules:
        guidanceSacredImageSection
        guidanceDevotionalGallerySection
        devotionalPackSection
        guidanceSeasonContextSection
        fastDayQuickRulesSection
        usccbGuidelinesSection
        foodGuidanceSection
        practicalFoodExamplesSection
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
    .navigationTitle(destination.title)
    .navigationBarTitleDisplayMode(.inline)
  }

  func moreDestinationHeroItem(for destination: MoreHubDestination) -> SacredImageryItem {
    let gallery = SacredImageryCatalog.fastingGallery
    guard !gallery.isEmpty else {
      return SacredImageryItem(
        id: "fallback-hero",
        assetName: "HeroSacred",
        title: destination.title,
        subtitle: destination.subtitle
      )
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
        title: destination.title,
        subtitle: hero.subtitle,
        height: 122,
        cornerRadius: 16,
        accessibilityIdentifier: "more.\(destination.rawValue).hero"
      )
    }
  }
}
