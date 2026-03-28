import SwiftUI
#if canImport(StoreKit)
import StoreKit
#endif

extension ContentView {
    var ipadMoreWorkspace: some View {
        GeometryReader { geometry in
            let stacked = geometry.size.width < 1200
            let destination = selectedMoreDestination ?? MoreHubDestination.allCases.first ?? .supportAndPremium

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
                            .frame(width: 280)
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
            .padding(20)
        }
    }

    var ipadSimplePremiumWorkspace: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AppSectionLeadCard(
                    eyebrow: "Support & Premium",
                    title: "Choose a plan, then keep the journey visible",
                    detail: "Yearly stays primary. Tips, billing, and legal tools remain below the plan choice.",
                    serifTitle: true,
                    style: .utility)

                premiumJourneyCard(sample: !monetizationStore.premiumUnlocked)

                #if canImport(StoreKit)
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(monetizationStore.premiumProducts, id: \.id) { product in
                        ipadCompactPremiumOfferCard(product: product, offer: premiumOfferCatalog.offer(for: product.id))
                    }
                }

                if !monetizationStore.tipProducts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Optional support tips")
                            .appEyebrowStyle()
                        Text("Tips support ongoing development and do not unlock features.")
                            .appSupportingTextStyle()
                        ForEach(monetizationStore.tipProducts, id: \.id) { product in
                            Button {
                                Task { await monetizationStore.purchase(product) }
                            } label: {
                                Text("Send Tip • \(product.displayPrice)")
                            }
                            .appSecondaryButtonStyle()
                            .accessibilityIdentifier("ipad.more.tip.\(product.id)")
                        }
                    }
                    .padding(14)
                    .appSurfaceCard(.utility, cornerRadius: 16)
                }
                #endif

                ipadCompactPremiumUtilitiesCard
            }
            .padding(18)
        }
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.more.premium")
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
                    Text(offer?.billingCadenceLabel ?? "Auto-renewing subscription")
                        .appSupportingTextStyle()
                }

                Spacer()

                if offer?.isPrimaryAnchor == true {
                    Text("Best value")
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

            Button("Unlock \(offer?.displayTitle ?? product.displayName) • \(product.displayPrice)") {
                Task {
                    await monetizationStore.purchase(product)
                }
            }
            .appPrimaryButtonStyle(legacyTint: offer?.isPrimaryAnchor == true ? CatholicTheme.primary : CatholicTheme.accent)
            .disabled(monetizationStore.isPurchasing)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(offer?.isPrimaryAnchor == true ? .primary : .standard, cornerRadius: 16)
        .appRoundedGlass(cornerRadius: 16)
    }
    #endif

    var ipadCompactPremiumUtilitiesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Restore / Manage / Legal")
                .appEyebrowStyle()

            Text("Keep these below the plan choice. Use them only if you need billing or legal help.")
                .appSupportingTextStyle()

            Button("Restore Purchases") {
                Task {
                    await monetizationStore.restorePurchases()
                }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
            .accessibilityIdentifier("premium.restore")

            Button("Manage Subscription") {
                Task {
                    await monetizationStore.openManageSubscriptions()
                }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
            .accessibilityIdentifier("premium.manage")

            Link("Terms of Use (EULA)", destination: UIConstants.termsOfUseURL)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.legal.terms")
            Link("Privacy Policy", destination: UIConstants.privacyPolicyURL)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.legal.privacy")
            Link("Support", destination: UIConstants.supportSiteURL)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.legal.support")
        }
        .padding(14)
        .appSurfaceCard(.utility, cornerRadius: 16)
    }
}
