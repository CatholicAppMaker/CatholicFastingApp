import SwiftUI
#if canImport(StoreKit)
import StoreKit
#endif

extension ContentView {
    var ipadMoreWorkspace: some View {
        GeometryReader { geometry in
            let stacked = geometry.size.width < 700 || dynamicTypeSize.isAccessibilitySize
            let destination = navigationState.selectedMoreDestination ?? MoreHubDestination.allCases.first ?? .supportAndPremium

            Group {
                if stacked {
                    VStack(alignment: .leading, spacing: 20) {
                        ipadMoreCompactSelector

                        if destination == .supportAndPremium {
                            ipadSimplePremiumWorkspace
                        } else {
                            ipadMoreDestinationDetail(for: destination)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    HStack(alignment: .top, spacing: 20) {
                        ipadMoreDestinationRail
                            .frame(minWidth: 240, idealWidth: 280, maxWidth: 320)
                            .frame(maxHeight: .infinity)

                        Group {
                            if destination == .supportAndPremium {
                                ipadSimplePremiumWorkspace
                            } else {
                                ipadMoreDestinationDetail(for: destination)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
            }
            .padding(28)
        }
    }

    var ipadSimplePremiumWorkspace: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AppSectionLeadCard(
                    eyebrow: localized("premium.section.support", default: "Support & Premium"),
                    title: monetizationStore.premiumUnlocked
                        ? localized("ipad.more.premium.active_title", default: "Premium formation is active")
                        : localized("ipad.more.premium.title", default: "Choose a plan, then keep the journey visible"),
                    detail: monetizationStore.premiumUnlocked
                        ? localized("ipad.more.premium.active_detail", default: "Open the current journey and formation tools; billing and legal actions remain available below.")
                        : localized("ipad.more.premium.detail", default: "Yearly stays primary. Tips, billing, and legal tools remain below the plan choice."),
                    serifTitle: true,
                    style: .utility)

                #if canImport(StoreKit)
                ipadPremiumPlanChoiceSection

                ipadCompactPremiumUtilitiesCard

                ipadPremiumFormationPreviewCard

                companionIPadPremiumToolsCard

                if !monetizationStore.tipProducts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(localized("ipad.more.tips.title", default: "Optional support tips"))
                            .appEyebrowStyle()
                        Text(localized("ipad.more.tips.detail", default: "Tips support ongoing development and do not unlock features."))
                            .appSupportingTextStyle()
                        ForEach(monetizationStore.tipProducts, id: \.id) { product in
                            Button {
                                Task { await monetizationStore.purchase(product) }
                            } label: {
                                Text(localizedFormat("ipad.more.tips.send_format", default: "Send Tip • %@", product.displayPrice))
                            }
                            .appSecondaryButtonStyle()
                            .accessibilityIdentifier("ipad.more.tip.\(product.id)")
                        }
                    }
                    .padding(14)
                    .appSurfaceCard(.utility, cornerRadius: 16)
                    .accessibilityIdentifier("premium.optional_tips")
                }
                #endif
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("ipad.more.premium")
    }

    #if canImport(StoreKit)
    var ipadPremiumPlanChoiceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localized("premium.plan_choice.title", default: "Plan choice"))
                .appEyebrowStyle()
                .accessibilityIdentifier("premium.plan_choice")

            if monetizationStore.premiumUnlocked {
                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        localized("premium.active.label", default: "Premium is active."),
                        systemImage: "checkmark.seal.fill")
                        .appSectionTitleStyle(serif: true)
                    Text(
                        localized(
                            "premium.active.summary",
                            default: "Your guided journey, reminders, reflection, and export tools are unlocked."))
                        .appSupportingTextStyle()
                    Text(localized("premium.active.manage_hint", default: "Manage or restore access below whenever you need it."))
                        .appEyebrowStyle()
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appSurfaceCard(.primary, cornerRadius: 16)
                .accessibilityIdentifier("premium.plan_choice_state")
            } else if monetizationStore.isLoading {
                VStack {
                    premiumCatalogLoadingPlaceholder
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("premium.plan_choice_state")
            } else if monetizationStore.premiumProducts.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text(premiumCatalogRecoveryMessage)
                        .appSupportingTextStyle()
                        .accessibilityIdentifier("premium.plan_choice_state")
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
            } else {
                ForEach(monetizationStore.premiumProducts, id: \.id) { product in
                    ipadCompactPremiumOfferCard(product: product, offer: premiumOfferCatalog.offer(for: product.id))
                }
            }

            premiumTrustStatements
        }
    }
    #endif

    var ipadPremiumFormationPreviewCard: some View {
        let journey = premiumGuidedJourneyWeek
        let title = monetizationStore.premiumUnlocked
            ? localized("premium.journey.current_title", default: "Your Guided Seasonal Journey")
            : localized("premium.journey.preview_title", default: "Preview Guided Seasonal Formation")
        let intro = monetizationStore.premiumUnlocked
            ? localized("premium.journey.current_intro", default: "Premium keeps the current week and next faithful action visible without rebuilding the whole plan.")
            : localized(
                "premium.journey.preview_intro",
                default: "This preview shows how premium turns the current season into one weekly rhythm for fasting, prayer, mercy, and review.")
        let week = monetizationStore.premiumUnlocked
            ? localizedFormat("premium.journey.current_week_format", default: "Current journey week: %@", journey.title)
            : localizedFormat("premium.journey.preview_week_format", default: "Preview journey week: %@", journey.title)

        return VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .appSectionTitleStyle(serif: true)
            Text(intro)
                .appSupportingTextStyle()
            Text(week)
                .font(.subheadline.weight(.semibold))
            Text(journey.summary)
                .appSupportingTextStyle()
            if let nextAction = premiumGuidedJourneyNextAction {
                Text(localizedFormat("premium.journey.next_step_format", default: "Next step: %@", nextAction.title))
                    .appEyebrowStyle()
            }
        }
        .padding(14)
        .appSurfaceCard(monetizationStore.premiumUnlocked ? .primary : .standard, cornerRadius: 16)
        .accessibilityIdentifier(monetizationStore.premiumUnlocked ? "premium.journey.current" : "premium.journey.preview")
    }

    #if canImport(StoreKit)
    func ipadCompactPremiumOfferCard(product: Product, offer: SubscriptionOfferCatalog.Offer?) -> some View {
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

            if let summary = offer?.outcomeSummary {
                Text(summary)
                    .appSupportingTextStyle()
                    .foregroundStyle(offer?.isPrimaryAnchor == true ? CatholicTheme.primary.opacity(0.9) : .secondary)
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
            } else {
                Button(localizedFormat("premium.offer.unlock_format", default: "Unlock %@ • %@", offer?.displayTitle ?? product.displayName, product.displayPrice)) {
                    Task {
                        await monetizationStore.purchase(product)
                    }
                }
                .appSecondaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
                .disabled(monetizationStore.isPurchasing)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(offer?.isPrimaryAnchor == true ? .primary : .standard, cornerRadius: 16)
        .accessibilityIdentifier("premium.offer.\(product.id)")
    }
    #endif

    var ipadCompactPremiumUtilitiesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localized("premium.legal.title", default: "Restore / Manage / Legal"))
                .appEyebrowStyle()

            Text(localized("premium.legal.summary", default: "Keep these below the plan choice. Use them only if you need billing or legal help."))
                .appSupportingTextStyle()

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
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
                .accessibilityIdentifier("premium.legal.terms")
            Link(localized("premium.legal.privacy", default: "Privacy Policy"), destination: UIConstants.privacyPolicyURL)
                .appSupportingTextStyle()
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
                .accessibilityIdentifier("premium.legal.privacy")
            Link(localized("premium.legal.support", default: "Support"), destination: UIConstants.supportSiteURL)
                .appSupportingTextStyle()
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
                .accessibilityIdentifier("premium.legal.support")
        }
        .padding(14)
        .appSurfaceCard(.utility, cornerRadius: 16)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("premium.legal_actions")
    }
}
