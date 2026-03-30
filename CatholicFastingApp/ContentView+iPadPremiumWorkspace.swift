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
                        seasonLabel: localizedSeasonLabel(currentLiturgicalSeason),
                        seasonContextLabel: localizedFormat("ipad.hero.season_label", default: "Liturgical Season: %@", localizedSeasonLabel(currentLiturgicalSeason)),
                        title: localized("premium.workspace.hero.title", default: "Premium Formation Toolkit"),
                        subtitle: localized("premium.workspace.hero.subtitle", default: "Choose a plan, keep the Guided Seasonal Journey visible, and use the rest of premium as supporting tools."),
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
                eyebrow: localized("premium.workspace.access.eyebrow", default: "Access"),
                title: monetizationStore.premiumUnlocked
                    ? localized("premium.active.title", default: "Premium active")
                    : localized("premium.workspace.access.unlock", default: "Unlock Premium"),
                detail: localized("premium.workspace.access.detail", default: "Choose yearly or monthly first. Tips, billing, and legal tools stay secondary."))
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
                eyebrow: localized("premium.workspace.pillars.eyebrow", default: "Pillars"),
                title: localized("premium.workspace.pillars.title", default: "Choose the workflow"),
                detail: localized("premium.workspace.pillars.detail", default: "Planning, accountability, reflection, and exports stay grouped by outcome."))

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
                eyebrow: localized("premium.workspace.dashboard.eyebrow", default: "Dashboard"),
                title: localized("premium.workspace.dashboard.title", default: "Guided journey first"),
                detail: localized("premium.workspace.dashboard.detail", default: "Keep the current week visible, then use the surrounding tools to support it."))

            HStack(spacing: 10) {
                IPadSummaryMetricCard(title: localized("premium.workspace.metrics.required.title", default: "Required"), value: "\(analytics.requiredCompletionPercent)%", subtitle: localized("premium.workspace.metrics.required.subtitle", default: "required days completed"))
                IPadSummaryMetricCard(title: localized("premium.workspace.metrics.overall.title", default: "Overall"), value: "\(analytics.overallCompletionPercent)%", subtitle: localized("premium.workspace.metrics.overall.subtitle", default: "all logged observances"), tint: CatholicTheme.accent)
                IPadSummaryMetricCard(title: localized("premium.workspace.metrics.intermittent.title", default: "Intermittent"), value: "\(analytics.intermittentTargetHitPercent)%", subtitle: localized("premium.workspace.metrics.intermittent.subtitle", default: "recent target hit rate"), tint: .orange)
            }

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(localized("premium.workspace.journey.eyebrow", default: "Guided Journey"))
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
                    Text(localized("premium.workspace.readiness.eyebrow", default: "Reminder readiness"))
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                    Text(reminderRecommendation.summaryLine)
                        .appSectionTitleStyle()
                    Text(localizedFormat("premium.workspace.readiness.tier_format", default: "Current tier: %@", localizedReminderTierLabel(reminderTier)))
                        .appSupportingTextStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text(localized("premium.workspace.next_step.eyebrow", default: "Next step"))
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                    Text(premiumGuidedJourneyNextAction?.title ?? localized("premium.workspace.next_step.complete", default: "Week complete"))
                        .appSectionTitleStyle(serif: true)
                    Text(premiumGuidedJourneyNextAction?.detail ?? localized("premium.workspace.next_step.detail", default: "Use the reflection or accountability tools below to keep the rhythm steady."))
                        .appSupportingTextStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(localized("premium.workspace.actions.eyebrow", default: "Current journey actions"))
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
                eyebrow: localized("premium.workspace.selected_tool.eyebrow", default: "Selected tool"),
                title: localizedPremiumToolTitle(selectedPremiumToolDestination ?? .planner),
                detail: localizedPremiumToolSubtitle(selectedPremiumToolDestination ?? .planner))
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
                eyebrow: localized("premium.legal.title", default: "Restore / Manage / Legal"),
                title: localized("ipad.premium.legal.title", default: "Billing and legal tools"),
                detail: localized("ipad.premium.legal.detail", default: "Use these only after plan choice or if you need billing and legal help."))

            HStack(spacing: 10) {
                Button(localized("premium.legal.restore", default: "Restore Purchases")) {
                    Task { await monetizationStore.restorePurchases() }
                }
                .appSecondaryButtonStyle()

                Button(localized("premium.legal.manage", default: "Manage Subscription")) {
                    Task { await monetizationStore.openManageSubscriptions() }
                }
                .appSecondaryButtonStyle()
            }

            VStack(alignment: .leading, spacing: 6) {
                Link(localized("premium.legal.terms", default: "Terms of Use (EULA)"), destination: UIConstants.termsOfUseURL)
                Link(localized("premium.legal.privacy", default: "Privacy Policy"), destination: UIConstants.privacyPolicyURL)
                Link(localized("premium.legal.support", default: "Support"), destination: UIConstants.supportSiteURL)
            }
            .appSupportingTextStyle()
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.premium.legal_footer")
    }
}
