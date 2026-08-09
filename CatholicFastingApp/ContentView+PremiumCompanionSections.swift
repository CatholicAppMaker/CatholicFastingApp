import SwiftUI
#if canImport(StoreKit)
import StoreKit
#endif

extension ContentView {
    var premiumOfferCatalog: SubscriptionOfferCatalog {
        .catholicFasting
    }

    func hasPremiumEntitlement(_: PremiumEntitlementSurface) -> Bool {
        // Current SKU grants all premium surfaces; keep explicit surface gate for future splits.
        monetizationStore.premiumUnlocked
    }

    func hasPremiumEntitlement(_: PremiumToolDestination) -> Bool {
        monetizationStore.premiumUnlocked
    }

    func premiumToolDestination(for surface: PremiumEntitlementSurface) -> PremiumToolDestination {
        switch surface {
        case .planning:
            .planner
        case .accountability:
            .analytics
        case .reflection:
            .journal
        case .export:
            .export
        }
    }

    var selectedSupportPremiumSurface: SupportPremiumSurface {
        SupportPremiumSurface(rawValue: supportPremiumSurfaceRaw) ?? .upgrade
    }

    func openPremiumUpgrade(focusingOn surface: PremiumEntitlementSurface? = nil) {
        if let surface {
            navigationState.selectedPremiumToolDestination = premiumToolDestination(for: surface)
        }
        launchFunnelSnapshot.lockedUpgradeTapCount += 1
        supportPremiumSurfaceRaw = SupportPremiumSurface.upgrade.rawValue
        navigateToMoreDestination(.supportAndPremium)
    }

    var premiumSurfacePickerSection: some View {
        Section {
            Picker(
                localized("premium.section.view", default: "View"),
                selection: Binding(
                    get: { selectedSupportPremiumSurface },
                    set: { supportPremiumSurfaceRaw = $0.rawValue }))
            {
                ForEach(SupportPremiumSurface.allCases) { item in
                    Text(localizedSupportPremiumSurfaceLabel(item)).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("premium.surface_picker")

            Text(
                selectedSupportPremiumSurface == .upgrade
                    ? localized("premium.section.upgrade_hint", default: "Choose a plan first. Tips plus billing and legal tools stay below.")
                    : localized("premium.section.tools_hint", default: "Open formation tools after the Guided Seasonal Journey sets the week."))
                .appSupportingTextStyle()
        }
    }

    var premiumToolsLockedSection: some View {
        Section(localized("premium.tools.section", default: "Guided Seasonal Formation")) {
            Text(localized("premium.tools.locked_hint", default: "Unlock premium to keep the current journey week, reminders, review, journaling, and exports together."))
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("premium.locked_feature_preview")
            Button(localized("premium.tools.go_to_upgrade", default: "Go to Upgrade")) {
                openPremiumUpgrade(focusingOn: .planning)
            }
            .appPrimaryButtonStyle()
            .accessibilityIdentifier("premium.tools.go_to_upgrade")
        }
    }

    var premiumToolsHubSection: some View {
        Section(localized("premium.tools.formation", default: "Formation Tools")) {
            ForEach(PremiumToolDestination.allCases) { destination in
                NavigationLink(value: PhoneNavigationRoute.premium(destination)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(
                            localizedPremiumToolTitle(destination),
                            systemImage: destination.iconName)
                            .font(.headline)
                            .foregroundStyle(CatholicTheme.primary)
                        Text(localizedPremiumToolSubtitle(destination))
                            .appSupportingTextStyle()
                    }
                    .padding(.vertical, 2)
                }
                .disabled(!hasPremiumEntitlement(destination))
                .accessibilityIdentifier("premium.tool.\(destination.rawValue)")
            }
        }
    }

    var companionIPadPremiumToolsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            IPadWorkspaceHeader(
                eyebrow: localized("premium.tools.formation", default: "Formation Tools"),
                title: monetizationStore.premiumUnlocked
                    ? localized("premium.active.title", default: "Premium active")
                    : localized("premium.plan_choice.title", default: "Plan choice"),
                detail: monetizationStore.premiumUnlocked
                    ? localized(
                        "premium.active.summary",
                        default: "Your guided journey, reminders, reflection, and export tools are unlocked.")
                    : localized(
                        "premium.locked.summary",
                        default: "Stay steady through the Church year with one weekly formation path, reminders, and review."),
                serifTitle: true)

            if monetizationStore.premiumUnlocked {
                ForEach(PremiumToolDestination.allCases) { destination in
                    NavigationLink(destination: premiumToolList(for: destination)) {
                        AppDestinationRowCard(
                            title: localizedPremiumToolTitle(destination),
                            subtitle: localizedPremiumToolSubtitle(destination),
                            systemImage: destination.iconName,
                            showsChevron: true,
                            usesPrimarySubtitle: true)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("ipad.premium.tool.\(destination.rawValue)")
                }
            } else {
                Button(localized("premium.tools.go_to_upgrade", default: "Go to Upgrade")) {
                    openPremiumUpgrade(focusingOn: .planning)
                }
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("ipad.premium.tools.upgrade")
            }
        }
        .padding(18)
        .iPadPaneCard(.utility)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ipad.premium.tools")
    }

    var premiumAndSupportSection: some View {
        Section {
            if monetizationStore.premiumUnlocked {
                premiumStatusSummaryCard
                premiumLegalSupportCard
                premiumJourneyCardWithStoreMarker
                premiumActiveStateCard
            } else {
                Text(localized("premium.plan_choice.title", default: "Plan choice"))
                    .appEyebrowStyle()
                    .accessibilityIdentifier("premium.plan_choice")
                Text(localized("premium.upgrade.choose_plan", default: "Choose the yearly or monthly plan below."))
                    .appSupportingTextStyle()
                    .accessibilityIdentifier("premium.upgrade_summary")
                if monetizationStore.isLoading {
                    premiumCatalogLoadingPlaceholder
                } else if !monetizationStore.premiumProducts.isEmpty {
                    ForEach(monetizationStore.premiumProducts, id: \.id) { product in
                        let offer = premiumOfferCatalog.offer(for: product.id)
                        premiumOfferCard(product: product, offer: offer)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(premiumCatalogRecoveryMessage)
                            .appSupportingTextStyle()
                            .accessibilityIdentifier("premium.catalog.recovery")
                        Button {
                            Task { await monetizationStore.refreshCatalogAndEntitlements() }
                        } label: {
                            Label(
                                localized("premium.catalog.retry", default: "Try loading plans again"),
                                systemImage: "arrow.clockwise")
                        }
                        .appSecondaryButtonStyle()
                        .accessibilityIdentifier("premium.catalog.retry")
                    }
                }

                premiumStatusSummaryCard

                premiumLegalSupportCard

                premiumJourneyCardWithStoreMarker

                if !monetizationStore.tipProducts.isEmpty {
                    premiumTipsSupportCard
                }

                let loadedTipIDs = Set(monetizationStore.tipProducts.map(\.id))
                let missingTipIDs = MonetizationStore.tipProductIDs.subtracting(loadedTipIDs)
                if !missingTipIDs.isEmpty {
                    Text(localized("premium.tips.loading_hint", default: "Optional support tips may take a moment to appear after the App Store finishes loading."))
                        .appEyebrowStyle()
                }
            }

            premiumStoreFeedbackSection
        }
        .animation(.none, value: monetizationStore.premiumProducts.map(\.id))
        .animation(.none, value: monetizationStore.tipProducts.map(\.id))
        .animation(.none, value: monetizationStore.isLoading)
        .animation(.none, value: monetizationStore.statusMessage)
    }

    var premiumCatalogRecoveryMessage: String {
        switch monetizationStore.catalogLoadState {
        case .offline:
            localized(
                "premium.catalog.offline",
                default: "You appear to be offline. Premium plans need an App Store connection; your current access remains unchanged.")
        case .loading:
            localized("premium.upgrade.loading", default: "Loading purchases…")
        case .idle, .loaded, .failed:
            localized(
                "premium.upgrade.unavailable",
                default: "Premium plans are temporarily unavailable. Try again in a moment, then use Restore Purchases if needed.")
        }
    }

    var premiumJourneyCardWithStoreMarker: some View {
        ZStack(alignment: .topLeading) {
            if monetizationStore.premiumUnlocked {
                premiumJourneyCard(sample: false)
            } else {
                premiumJourneyCard(sample: true)
            }

            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier("premium.subscription_store")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("premium.journey")
    }

    var premiumStoreFeedbackSection: some View {
        PremiumStoreFeedbackView(
            subscriptionHealthMessage: monetizationStore.subscriptionHealthMessage,
            statusMessage: monetizationStore.statusMessage)
    }

    var premiumActiveStateCard: some View {
        PremiumActiveStateCard(
            summary: localized("premium.active.label", default: "Premium is active."),
            buttonTitle: localized("premium.active.open_tools", default: "Open Formation Tools"),
            onOpenTools: {
                supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue
            })
    }

    var premiumStatusSummaryCard: some View {
        PremiumStatusSummaryCard(
            isUnlocked: monetizationStore.premiumUnlocked,
            title: monetizationStore.premiumUnlocked
                ? localized("premium.active.title", default: "Premium active")
                : premiumOfferCatalog.title,
            summary: monetizationStore.premiumUnlocked
                ? localized("premium.active.summary", default: "Your guided journey, reminders, reflection, and export tools are unlocked.")
                : localized("premium.locked.summary", default: "Stay steady through the Church year with one weekly formation path, reminders, and review."),
            openToolsTitle: localized("premium.active.open_tools", default: "Open Formation Tools"),
            lockedAddsTitle: localized("premium.locked.adds", default: "Guided formation adds:"),
            pillars: premiumOfferCatalog.pillars,
            trustTitle: localized("premium.trust.title", default: "Why users upgrade"),
            localOnlyTitle: localized("premium.trust.local_only", default: "Local-only data"),
            noAdsTitle: localized("premium.trust.no_ads", default: "No ads"),
            cancelAnytimeTitle: localized("premium.trust.cancel_anytime", default: "Cancel anytime"),
            iconName: premiumIconName,
            onOpenTools: {
                supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue
            })
    }

    var premiumTrustStatements: some View {
        PremiumTrustStatements(
            title: localized("premium.trust.title", default: "Why users upgrade"),
            localOnlyTitle: localized("premium.trust.local_only", default: "Local-only data"),
            noAdsTitle: localized("premium.trust.no_ads", default: "No ads"),
            cancelAnytimeTitle: localized("premium.trust.cancel_anytime", default: "Cancel anytime"))
    }

    var premiumCatalogLoadingPlaceholder: some View {
        PremiumCatalogLoadingPlaceholder(
            accessibilityLabel: localized("premium.upgrade.loading", default: "Loading purchases…"))
    }

    func premiumJourneyCard(sample: Bool) -> some View {
        let journey = premiumGuidedJourneyWeek
        let previewActions = sample ? Array(journey.actions.prefix(3)) : journey.actions

        return PremiumJourneyCard(
            isSample: sample,
            title: sample
                ? localized("premium.journey.preview_title", default: "Preview Guided Seasonal Formation")
                : localized("premium.journey.current_title", default: "Your Guided Seasonal Journey"),
            intro: sample
                ? localized(
                    "premium.journey.preview_intro",
                    default: "This preview shows how premium turns the current season into one weekly rhythm for fasting, prayer, mercy, and review.")
                : localized(
                    "premium.journey.current_intro",
                    default: "Premium keeps the current week and next faithful action visible without rebuilding the whole plan."),
            weekTitle: sample
                ? localizedFormat("premium.journey.preview_week_format", default: "Preview journey week: %@", journey.title)
                : localizedFormat("premium.journey.current_week_format", default: "Current journey week: %@", journey.title),
            eyebrow: sample
                ? localized("premium.journey.preview_eyebrow", default: "Seasonal rhythm")
                : localized("premium.journey.current_eyebrow", default: "Current weekly rhythm"),
            summary: journey.summary,
            actions: previewActions,
            completionSummary: sample ? nil : premiumJourneyCompletionSummary,
            nextStep: sample ? nil : premiumGuidedJourneyNextAction.map {
                localizedFormat("premium.journey.next_step_format", default: "Next step: %@", $0.title)
            },
            previewHint: sample
                ? localized(
                    "premium.journey.preview_hint",
                    default: "Preview only. Unlock premium below to keep the current week, carry the journey through the season, and review the rhythm gently.")
                : nil,
            isCompleted: isPremiumJourneyActionCompleted,
            onAppear: {
                if launchFunnelSnapshot.premiumPreviewSeenAt == nil {
                    launchFunnelSnapshot.premiumPreviewSeenAt = Date()
                }
            })
    }

    #if canImport(StoreKit)
    func premiumOfferCard(product: Product, offer: SubscriptionOfferCatalog.Offer?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(offer?.displayTitle ?? product.displayName)
                        .appSectionTitleStyle(serif: offer?.isPrimaryAnchor == true)
                    Text(product.displayPrice)
                        .appMetricValueStyle()
                    Text(offer?.billingCadenceLabel ?? localized("premium.offer.auto_renew", default: "Auto-renewing subscription"))
                        .appSupportingTextStyle()
                }

                Spacer()

                if offer?.isPrimaryAnchor == true {
                    Text(localized("premium.offer.best_value", default: "Best value"))
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(CatholicTheme.accent.opacity(0.18)))
                        .foregroundStyle(CatholicTheme.primary)
                }
            }

            if offer?.isPrimaryAnchor == true {
                Text(offer?.outcomeSummary ?? localized("premium.offer.best_value_summary", default: "Best value for one steady rhythm through the Church year."))
                    .appSupportingTextStyle()
                    .foregroundStyle(CatholicTheme.primary.opacity(0.9))
            } else if let summary = offer?.outcomeSummary {
                Text(summary)
                    .appSupportingTextStyle()
                    .lineLimit(2)
            }

            if offer?.isPrimaryAnchor == true {
                Button(localizedFormat("premium.offer.unlock_format", default: "Unlock %@ • %@", offer?.displayTitle ?? product.displayName, product.displayPrice)) {
                    Task {
                        await monetizationStore.purchase(product)
                    }
                }
                .appPrimaryButtonStyle()
                .disabled(monetizationStore.isPurchasing)
                .accessibilityIdentifier("premium.offer.unlock.\(product.id)")
            } else {
                Button(localizedFormat("premium.offer.unlock_format", default: "Unlock %@ • %@", offer?.displayTitle ?? product.displayName, product.displayPrice)) {
                    Task {
                        await monetizationStore.purchase(product)
                    }
                }
                .appSecondaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
                .disabled(monetizationStore.isPurchasing)
                .accessibilityIdentifier("premium.offer.unlock.\(product.id)")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(offer?.isPrimaryAnchor == true ? .primary : .standard, cornerRadius: 16)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("premium.offer.\(product.id)")
    }
    #endif

    var premiumTipsSupportCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localized("premium.tips.title", default: "Optional support tips"))
                .appEyebrowStyle()

            Text(localized("premium.tips.summary", default: "Tips support ongoing development and do not unlock features."))
                .appSupportingTextStyle()

            ForEach(monetizationStore.tipProducts, id: \.id) { product in
                Button(localizedFormat("premium.tips.send_tip_format", default: "Send Tip • %@", product.displayPrice)) {
                    Task {
                        await monetizationStore.purchase(product)
                    }
                }
                .appSecondaryButtonStyle()
                .disabled(monetizationStore.isPurchasing)
                .accessibilityIdentifier("premium.tip.\(product.id)")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(.utility, cornerRadius: 16)
        .accessibilityIdentifier("premium.tips_card")
    }

    var premiumLegalSupportCard: some View {
        PremiumLegalSupportCard(
            title: localized("premium.legal.title", default: "Restore / Manage / Legal"),
            summary: localized(
                "premium.legal.summary",
                default: "Use these after choosing a plan if you need to restore billing or open legal links."),
            restoreTitle: localized("premium.legal.restore", default: "Restore Purchases"),
            manageTitle: localized("premium.legal.manage", default: "Manage Subscription"),
            termsTitle: localized("premium.legal.terms", default: "Terms of Use (EULA)"),
            privacyTitle: localized("premium.legal.privacy", default: "Privacy Policy"),
            supportTitle: localized("premium.legal.support", default: "Support"),
            isPurchasing: monetizationStore.isPurchasing,
            onRestore: {
                Task {
                    await monetizationStore.restorePurchases()
                }
            },
            onManage: {
                Task {
                    await monetizationStore.openManageSubscriptions()
                }
            })
    }

    func premiumIconName(for surface: PremiumEntitlementSurface) -> String {
        switch surface {
        case .planning:
            "calendar.badge.clock"
        case .accountability:
            "chart.bar.xaxis"
        case .reflection:
            "book.closed"
        case .export:
            "square.and.arrow.up"
        }
    }
}
