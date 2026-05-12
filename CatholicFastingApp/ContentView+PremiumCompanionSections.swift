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
            selectedPremiumToolDestination = premiumToolDestination(for: surface)
        }
        launchFunnelSnapshot.lockedUpgradeTapCount += 1
        selectedMoreDestination = .supportAndPremium
        supportPremiumSurfaceRaw = SupportPremiumSurface.upgrade.rawValue
        homeSurface = .more
    }

    var premiumSurfacePickerSection: some View {
        Section(localized("premium.section.support", default: "Support & Premium")) {
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
                    : localized("premium.section.tools_hint", default: "Open premium planning, journaling, and exports once the journey is set."))
                .appSupportingTextStyle()
        }
    }

    var premiumToolsLockedSection: some View {
        Section(localized("premium.tools.section", default: "Premium Tools")) {
            Text(localized("premium.tools.locked_hint", default: "Unlock premium to open planning, reminders, analytics, journaling, and exports."))
                .foregroundStyle(.secondary)
            Button(localized("premium.tools.go_to_upgrade", default: "Go to Upgrade")) {
                openPremiumUpgrade(focusingOn: .planning)
            }
            .appPrimaryButtonStyle()
            .accessibilityIdentifier("premium.tools.go_to_upgrade")
        }
    }

    var premiumToolsHubSection: some View {
        Section(localized("premium.tools.formation", default: "Formation Toolkit")) {
            ForEach(PremiumEntitlementSurface.allCases) { surface in
                let destination = premiumToolDestination(for: surface)
                NavigationLink(value: destination) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(surface.title, systemImage: destination.iconName)
                            .font(.headline)
                            .foregroundStyle(CatholicTheme.primary)
                        Text(surface.guidance)
                            .appSupportingTextStyle()
                    }
                    .padding(.vertical, 2)
                }
                .disabled(!hasPremiumEntitlement(surface))
                .accessibilityIdentifier("premium.tool.\(surface.rawValue)")
            }
        }
    }

    var premiumAndSupportSection: some View {
        Section(localized("premium.upgrade.section", default: "Premium Upgrade")) {
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier("premium.subscription_store")

            if monetizationStore.premiumUnlocked {
                premiumJourneyCard(sample: false)
            } else {
                premiumJourneyCard(sample: true)
            }

            premiumStatusSummaryCard

            if monetizationStore.premiumUnlocked {
                premiumActiveStateCard
            } else {
                Text(localized("premium.upgrade.choose_plan", default: "Choose the yearly or monthly plan below."))
                    .appSupportingTextStyle()
                    .accessibilityIdentifier("premium.upgrade_summary")
                if monetizationStore.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text(localized("premium.upgrade.loading", default: "Loading purchases…"))
                    }
                    .font(.caption)
                }

                if !monetizationStore.premiumProducts.isEmpty {
                    ForEach(monetizationStore.premiumProducts, id: \.id) { product in
                        let offer = premiumOfferCatalog.offer(for: product.id)
                        premiumOfferCard(product: product, offer: offer)
                    }
                } else {
                    Text(
                        localized(
                            "premium.upgrade.unavailable",
                            default: "Premium plans are temporarily unavailable. Try again in a moment, then use Restore Purchases if needed."))
                        .appSupportingTextStyle()
                }

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

            premiumLegalSupportCard
            premiumStoreFeedbackSection
        }
        .animation(.none, value: monetizationStore.premiumProducts.map(\.id))
        .animation(.none, value: monetizationStore.tipProducts.map(\.id))
        .animation(.none, value: monetizationStore.isLoading)
        .animation(.none, value: monetizationStore.statusMessage)
    }

    @ViewBuilder
    var premiumStoreFeedbackSection: some View {
        if !monetizationStore.subscriptionHealthMessage.isEmpty {
            Text(monetizationStore.subscriptionHealthMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("premium.subscription_health")
        }

        if !monetizationStore.statusMessage.isEmpty {
            Text(monetizationStore.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("premium.status")
        }
    }

    var premiumActiveStateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localized("premium.active.label", default: "Premium is active."))
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.active_summary")

            Button(localized("premium.active.open_tools", default: "Open Premium Tools")) {
                supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue
            }
            .appPrimaryButtonStyle()
            .accessibilityIdentifier("premium.open_tools")
        }
        .padding(14)
        .appSurfaceCard(.primary, cornerRadius: 18)
    }

    var premiumUpgradeHeroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SacredSurfaceAnchorCard(
                assetName: moreDestinationHeroItem(for: .supportAndPremium).assetName,
                title: monetizationStore.premiumUnlocked
                    ? localized("premium.hero.active_title", default: "Formation Toolkit Active")
                    : localized("premium.hero.title", default: "Formation Toolkit"),
                subtitle: monetizationStore.premiumUnlocked
                    ? localized("premium.hero.active_subtitle", default: "Keep planning, recovery, reflection, and review in one focused Catholic workflow.")
                    : localized("premium.hero.subtitle", default: "Choose one clear premium path for planning, reminders, reflection, and review through the Church year."),
                imageHeight: 112,
                accessibilityIdentifier: "premium.hero")

            CatholicFastingQuoteCard(
                quote: guidanceFastingQuote,
                compact: true)
                .accessibilityIdentifier("premium.quote")
        }
    }

    var premiumStatusSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: monetizationStore.premiumUnlocked ? "checkmark.seal.fill" : "star.circle.fill")
                    .appSymbolStyle(.prominent)
                    .foregroundStyle(monetizationStore.premiumUnlocked ? CatholicTheme.successForeground : CatholicTheme.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(monetizationStore.premiumUnlocked ? localized("premium.active.title", default: "Premium active") : premiumOfferCatalog.title)
                        .appSectionTitleStyle(serif: true)
                    Text(
                        monetizationStore.premiumUnlocked
                            ? localized("premium.active.summary", default: "Your planning, accountability, reflection, and export tools are unlocked.")
                            : localized("premium.locked.summary", default: "Stay steady through the Church year with one clear premium path for planning, reminders, and review."))
                        .appLeadTextStyle()
                }
            }

            if monetizationStore.premiumUnlocked {
                Button(localized("premium.active.open_tools", default: "Open Premium Tools")) {
                    supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue
                }
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("premium.open_tools")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(localized("premium.locked.adds", default: "Premium adds:"))
                        .appEyebrowStyle()
                        .foregroundStyle(CatholicTheme.primary)

                    ForEach(premiumOfferCatalog.pillars) { pillar in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: premiumIconName(for: pillar.requiredSurface))
                                .foregroundStyle(CatholicTheme.primary)
                                .frame(width: 18)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pillar.title)
                                    .font(.subheadline.weight(.semibold))
                                Text(pillar.subtitle)
                                    .appSupportingTextStyle()
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(localized("premium.trust.title", default: "Why users upgrade"))
                    .appEyebrowStyle()

                HStack(spacing: 8) {
                    premiumTrustPill(text: localized("premium.trust.local_only", default: "Local-only data"), systemImage: "lock.shield")
                    premiumTrustPill(text: localized("premium.trust.no_ads", default: "No ads"), systemImage: "nosign")
                    premiumTrustPill(text: localized("premium.trust.cancel_anytime", default: "Cancel anytime"), systemImage: "creditcard")
                }
            }
        }
        .padding(14)
        .appSurfaceCard(.utility, cornerRadius: 16)
        .appRoundedGlass(cornerRadius: 16)
    }

    func premiumJourneyCard(sample: Bool) -> some View {
        let journey = premiumGuidedJourneyWeek
        let previewActions = sample ? Array(journey.actions.prefix(3)) : journey.actions

        return VStack(alignment: .leading, spacing: 10) {
            Text(
                sample
                    ? localized("premium.journey.preview_title", default: "See the Guided Seasonal Journey")
                    : localized("premium.journey.current_title", default: "Your Guided Seasonal Journey"))
                .appSectionTitleStyle(serif: true)

            Text(
                sample
                    ? localized("premium.journey.preview_intro", default: "This preview shows how premium turns the current season into one steady weekly rhythm.")
                    : localized("premium.journey.current_intro", default: "Premium keeps the current week visible so you know what to do next without rebuilding the whole plan."))
                .appSupportingTextStyle()

            VStack(alignment: .leading, spacing: 6) {
                Text(
                    sample
                        ? localizedFormat("premium.journey.preview_week_format", default: "Preview journey week: %@", journey.title)
                        : localizedFormat("premium.journey.current_week_format", default: "Current journey week: %@", journey.title))
                    .font(.subheadline.weight(.semibold))
                Text(
                    sample
                        ? localized("premium.journey.preview_eyebrow", default: "Seasonal rhythm")
                        : localized("premium.journey.current_eyebrow", default: "Current weekly rhythm"))
                    .appEyebrowStyle()
                Text(journey.summary)
                    .appSupportingTextStyle()

                ForEach(previewActions, id: \.id) { action in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: sample ? "circle" : (isPremiumJourneyActionCompleted(action) ? "checkmark.circle.fill" : "circle"))
                            .foregroundStyle(sample ? CatholicTheme.primary : (isPremiumJourneyActionCompleted(action) ? CatholicTheme.successForeground : CatholicTheme.primary))
                            .padding(.top, 2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(action.category.label)
                                .appEyebrowStyle()
                            Text(action.title)
                                .font(.subheadline.weight(.semibold))
                            Text(action.detail)
                                .appSupportingTextStyle()
                        }
                    }
                }
            }

            if sample {
                Text(
                    localized(
                        "premium.journey.preview_hint",
                        default: "Preview only. Unlock premium below to track progress, keep the current week, and carry the journey through the season."))
                    .appSupportingTextStyle()
            } else {
                Text(premiumJourneyCompletionSummary)
                    .appSupportingTextStyle()
                if let nextAction = premiumGuidedJourneyNextAction {
                    Text(localizedFormat("premium.journey.next_step_format", default: "Next step: %@", nextAction.title))
                        .appEyebrowStyle()
                }
            }
        }
        .padding(14)
        .appSurfaceCard(sample ? .standard : .primary, cornerRadius: 16)
        .appRoundedGlass(cornerRadius: 16)
        .accessibilityIdentifier("premium.sample_preview")
        .onAppear {
            if launchFunnelSnapshot.premiumPreviewSeenAt == nil {
                launchFunnelSnapshot.premiumPreviewSeenAt = Date()
            }
        }
    }

    func premiumPillarCard(for pillar: SubscriptionOfferCatalog.Pillar) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(pillar.title, systemImage: premiumIconName(for: pillar.requiredSurface))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)

            Text(pillar.subtitle)
                .appSupportingTextStyle()

            ForEach(pillar.outcomes, id: \.self) { outcome in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .appSymbolStyle(.subtle)
                        .foregroundStyle(CatholicTheme.accentForeground)
                        .padding(.top, 5)
                    Text(outcome)
                        .appSupportingTextStyle()
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(.utility, cornerRadius: 14)
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
        VStack(alignment: .leading, spacing: 10) {
            Text(localized("premium.legal.title", default: "Restore / Manage / Legal"))
                .appEyebrowStyle()

            Text(localized("premium.legal.summary", default: "Use these after choosing a plan if you need to restore billing or open legal links."))
                .appSupportingTextStyle()
                .foregroundStyle(.secondary)

            Button(localized("premium.legal.restore", default: "Restore Purchases")) {
                Task {
                    await monetizationStore.restorePurchases()
                }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
            .accessibilityIdentifier("premium.restore")

            Button(localized("premium.legal.manage", default: "Manage Subscription")) {
                Task {
                    await monetizationStore.openManageSubscriptions()
                }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
            .accessibilityIdentifier("premium.manage")

            Link(localized("premium.legal.terms", default: "Terms of Use (EULA)"), destination: UIConstants.termsOfUseURL)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.legal.terms")
            Link(localized("premium.legal.privacy", default: "Privacy Policy"), destination: UIConstants.privacyPolicyURL)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.legal.privacy")
            Link(localized("premium.legal.support", default: "Support"), destination: UIConstants.supportSiteURL)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.legal.support")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(.utility, cornerRadius: 16)
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

    func premiumTrustPill(text: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(CatholicTheme.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(CatholicTheme.accent.opacity(0.12), in: Capsule(style: .continuous))
        .appCapsuleGlass()
    }

    #if canImport(StoreKit)
    private func subscriptionPeriodSuffix(for product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else { return "" }
        let unitText =
            switch period.unit {
            case .day: "day"
            case .week: "week"
            case .month: "month"
            case .year: "year"
            @unknown default: "period"
            }
        let count = period.value
        if count == 1 {
            return " per \(unitText)"
        }
        return " per \(count) \(unitText)s"
    }
    #endif
}
