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
                Text("Support & Premium")
                    .font(.system(.title2, design: .serif).weight(.bold))
                    .foregroundStyle(CatholicTheme.primary)

                #if canImport(StoreKit)
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(monetizationStore.premiumProducts, id: \.id) { product in
                            ipadCompactPremiumOfferCard(product: product, offer: premiumOfferCatalog.offer(for: product.id))
                        }
                    }

                    if !monetizationStore.tipProducts.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Optional support tips")
                                .font(.headline)
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
                            .font(.headline)
                            .foregroundStyle(CatholicTheme.primary)
                        Text(product.displayPrice)
                            .font(.title3.weight(.bold))
                        Text(offer?.billingCadenceLabel ?? "Auto-renewing subscription")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
        }
    #endif

    var ipadCompactPremiumUtilitiesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Restore / Manage / Legal")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

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
                .font(.caption)
                .accessibilityIdentifier("premium.legal.terms")
            Link("Privacy Policy", destination: UIConstants.privacyPolicyURL)
                .font(.caption)
                .accessibilityIdentifier("premium.legal.privacy")
            Link("Support", destination: UIConstants.supportSiteURL)
                .font(.caption)
                .accessibilityIdentifier("premium.legal.support")
        }
        .padding(14)
        .appSurfaceCard(.utility, cornerRadius: 16)
    }
}
