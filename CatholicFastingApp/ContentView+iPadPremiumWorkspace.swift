import SwiftUI

extension ContentView {
    var ipadPremiumWorkspace: some View {
        GeometryReader { geometry in
            let compact = geometry.size.width < 1280
            let stacked = geometry.size.width < 1040

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    IPadWorkspaceHeroBand(
                        assetName: moreDestinationHeroItem(for: .supportAndPremium).assetName,
                        seasonLabel: currentLiturgicalSeason.label,
                        title: "Premium Formation Toolkit",
                        subtitle: "Keep plans, reminders, reflection, and review together in one clear premium workspace.",
                        quote: dailySeasonalQuote,
                        regionContext: RegionalGuidanceContextFactory.generalContext(for: settings),
                        compact: compact,
                        accessibilityIdentifier: "ipad.premium.hero")

                    if stacked {
                        VStack(alignment: .leading, spacing: 18) {
                            ipadPremiumSubscriptionCard
                            ipadPremiumPillarRail
                            ipadPremiumDashboardCard
                            ipadPremiumSelectedToolCard
                            ipadPremiumLegalFooterCard
                        }
                    } else {
                        HStack(alignment: .top, spacing: 20) {
                            VStack(alignment: .leading, spacing: 18) {
                                ipadPremiumSubscriptionCard
                                ipadPremiumPillarRail
                            }
                            .frame(width: compact ? 290 : 330)

                            VStack(alignment: .leading, spacing: 18) {
                                ipadPremiumDashboardCard
                                ipadPremiumSelectedToolCard
                                ipadPremiumLegalFooterCard
                            }
                            .frame(maxWidth: .infinity, alignment: .top)
                        }
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .accessibilityIdentifier("ipad.premium.workspace")
    }

    private var ipadPremiumSubscriptionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: "Access",
                title: monetizationStore.premiumUnlocked ? "Premium active" : "Unlock Premium",
                detail: "Choose yearly or monthly first. Billing and legal tools stay below.")
            premiumSurfacePickerSection
            if selectedSupportPremiumSurface == .upgrade {
                premiumAndSupportSection
            } else if !monetizationStore.premiumUnlocked {
                premiumToolsLockedSection
            }
        }
        .padding(18)
        .iPadPaneCard()
    }

    private var ipadPremiumPillarRail: some View {
        VStack(alignment: .leading, spacing: 12) {
            IPadWorkspaceHeader(
                eyebrow: "Pillars",
                title: "Choose the workflow",
                detail: "Planning, accountability, reflection, and exports stay grouped by outcome.")

            ForEach(PremiumEntitlementSurface.allCases) { surface in
                let destination = premiumToolDestination(for: surface)
                Button {
                    supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue
                    selectedPremiumToolDestination = destination
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(surface.title, systemImage: destination.iconName)
                            .font(.headline)
                            .foregroundStyle(selectedPremiumToolDestination == destination ? CatholicTheme.primary : .primary)
                        Text(surface.guidance)
                            .appSupportingTextStyle()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appInteractiveTileStyle(isSelected: selectedPremiumToolDestination == destination)
                }
                .buttonStyle(.plain)
                .disabled(!monetizationStore.premiumUnlocked)
                .accessibilityIdentifier("ipad.premium.tool.\(surface.rawValue)")
            }
        }
        .padding(18)
        .iPadPaneCard()
    }

    private var ipadPremiumDashboardCard: some View {
        let analytics = PremiumAnalyticsEngine.summary(
            observances: currentYearObservances,
            statusesByID: tracker.statusesByID,
            sessions: intermittentTracker.sessions)
        let reminderRecommendation = PremiumReminderPlanner.recommendation(
            observances: rollingUpcomingObservances,
            statusesByID: tracker.statusesByID,
            now: Date(),
            calendar: liturgicalCalendar)

        return VStack(alignment: .leading, spacing: 16) {
            IPadWorkspaceHeader(
                eyebrow: "Dashboard",
                title: "Formation Toolkit overview",
                detail: "Keep premium in one coherent workspace.")

            HStack(spacing: 10) {
                IPadSummaryMetricCard(title: "Required", value: "\(analytics.requiredCompletionPercent)%", subtitle: "required days completed")
                IPadSummaryMetricCard(title: "Overall", value: "\(analytics.overallCompletionPercent)%", subtitle: "all logged observances", tint: CatholicTheme.accent)
                IPadSummaryMetricCard(title: "Intermittent", value: "\(analytics.intermittentTargetHitPercent)%", subtitle: "recent target hit rate", tint: .orange)
            }

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Guided Journey")
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                    Text(premiumGuidedJourneyWeek.title)
                        .appSectionTitleStyle(serif: true)
                    Text(premiumGuidedJourneyWeek.summary)
                        .appSupportingTextStyle()
                    Text(premiumJourneyCompletionSummary)
                        .appSupportingTextStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Reminder readiness")
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                    Text(reminderRecommendation.summaryLine)
                        .appSectionTitleStyle()
                    Text("Current tier: \(reminderTier.label)")
                        .appSupportingTextStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Next step")
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                    Text(premiumGuidedJourneyNextAction?.title ?? "Week complete")
                        .appSectionTitleStyle(serif: true)
                    Text(premiumGuidedJourneyNextAction?.detail ?? "Use the reflection or accountability tools below to keep the rhythm steady.")
                        .appSupportingTextStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Current journey actions")
                    .appEyebrowStyle()
                ForEach(premiumGuidedJourneyWeek.actions, id: \.id) { action in
                    Button {
                        if monetizationStore.premiumUnlocked {
                            togglePremiumJourneyAction(action)
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: isPremiumJourneyActionCompleted(action) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isPremiumJourneyActionCompleted(action) ? .green : CatholicTheme.primary)
                                .padding(.top, 2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(action.category.label)
                                    .appEyebrowStyle()
                                Text(action.title)
                                    .font(.subheadline.weight(.semibold))
                                Text(action.detail)
                                    .appSupportingTextStyle()
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appInteractiveTileStyle(isSelected: isPremiumJourneyActionCompleted(action), cornerRadius: 14)
                    }
                    .buttonStyle(.plain)
                    .disabled(!monetizationStore.premiumUnlocked)
                }
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.premium.dashboard")
    }

    private var ipadPremiumSelectedToolCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: "Selected tool",
                title: (selectedPremiumToolDestination ?? .planner).title,
                detail: (selectedPremiumToolDestination ?? .planner).subtitle)
            List {
                premiumToolIntroSection(for: selectedPremiumToolDestination ?? .planner)
                premiumToolSections(for: selectedPremiumToolDestination ?? .planner)
            }
            .listStyle(.insetGrouped)
            .frame(minHeight: 380)
            .appListBackground()
        }
        .padding(18)
        .iPadPaneCard()
    }

    private var ipadPremiumLegalFooterCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            IPadWorkspaceHeader(
                eyebrow: "Restore / Manage / Legal",
                title: "Billing and legal tools",
                detail: "Use these after choosing a plan if you need to restore billing or open legal links.")

            HStack(spacing: 10) {
                Button("Restore Purchases") {
                    Task { await monetizationStore.restorePurchases() }
                }
                .appSecondaryButtonStyle()

                Button("Manage Subscription") {
                    Task { await monetizationStore.openManageSubscriptions() }
                }
                .appSecondaryButtonStyle()
            }

            VStack(alignment: .leading, spacing: 6) {
                Link("Terms of Use (EULA)", destination: UIConstants.termsOfUseURL)
                Link("Privacy Policy", destination: UIConstants.privacyPolicyURL)
                Link("Support", destination: UIConstants.supportSiteURL)
            }
            .appSupportingTextStyle()
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.premium.legal_footer")
    }
}
