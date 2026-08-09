import SwiftUI

struct PremiumStoreFeedbackView: View {
    let subscriptionHealthMessage: String
    let statusMessage: String

    var body: some View {
        if !subscriptionHealthMessage.isEmpty {
            Text(subscriptionHealthMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("premium.subscription_health")
        }

        if !statusMessage.isEmpty {
            Text(statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("premium.status")
        }
    }
}

struct PremiumActiveStateCard: View {
    let summary: String
    let buttonTitle: String
    let onOpenTools: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(summary)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.active_summary")

            Button(buttonTitle, action: onOpenTools)
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("premium.open_tools")
        }
        .padding(14)
        .appSurfaceCard(.primary, cornerRadius: 18)
    }
}

private struct PremiumTrustPill: View {
    let text: String
    let systemImage: String
    let identifier: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(CatholicTheme.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(CatholicTheme.accent.opacity(0.12), in: Capsule(style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(identifier)
    }
}

struct PremiumTrustStatements: View {
    let title: String
    let localOnlyTitle: String
    let noAdsTitle: String
    let cancelAnytimeTitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .appEyebrowStyle()

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    localOnlyPill
                        .fixedSize(horizontal: true, vertical: false)
                    noAdsPill
                        .fixedSize(horizontal: true, vertical: false)
                    cancelAnytimePill
                        .fixedSize(horizontal: true, vertical: false)
                }

                VStack(alignment: .leading, spacing: 8) {
                    localOnlyPill
                    noAdsPill
                    cancelAnytimePill
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("premium.trust")
    }

    private var localOnlyPill: some View {
        PremiumTrustPill(
            text: localOnlyTitle,
            systemImage: "lock.shield",
            identifier: "premium.trust.local_only")
    }

    private var noAdsPill: some View {
        PremiumTrustPill(
            text: noAdsTitle,
            systemImage: "nosign",
            identifier: "premium.trust.no_ads")
    }

    private var cancelAnytimePill: some View {
        PremiumTrustPill(
            text: cancelAnytimeTitle,
            systemImage: "creditcard",
            identifier: "premium.trust.cancel_anytime")
    }
}

struct PremiumCatalogLoadingPlaceholder: View {
    let accessibilityLabel: String

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0 ..< 2, id: \.self) { index in
                placeholderOffer(isPrimary: index == 0)
            }
        }
        .redacted(reason: .placeholder)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("premium.catalog.loading")
    }

    private func placeholderOffer(isPrimary: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Premium yearly plan")
                        .appSectionTitleStyle(serif: isPrimary)
                    Text("$00.00")
                        .appMetricValueStyle()
                    Text("Auto-renewing subscription")
                        .appSupportingTextStyle()
                }

                Spacer()

                if isPrimary {
                    Text("Best value")
                        .font(.caption2.weight(.semibold))
                }
            }

            Text("A steady formation rhythm throughout the Church year.")
                .appSupportingTextStyle()
                .lineLimit(2)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(CatholicTheme.primary.opacity(0.16))
                .frame(height: 44)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(isPrimary ? .primary : .standard, cornerRadius: 16)
    }
}

struct PremiumStatusSummaryCard: View {
    let isUnlocked: Bool
    let title: String
    let summary: String
    let openToolsTitle: String
    let lockedAddsTitle: String
    let pillars: [SubscriptionOfferCatalog.Pillar]
    let trustTitle: String
    let localOnlyTitle: String
    let noAdsTitle: String
    let cancelAnytimeTitle: String
    let iconName: (PremiumEntitlementSurface) -> String
    let onOpenTools: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: isUnlocked ? "checkmark.seal.fill" : "star.circle.fill")
                    .appSymbolStyle(.prominent)
                    .foregroundStyle(isUnlocked ? CatholicTheme.successForeground : CatholicTheme.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .appSectionTitleStyle(serif: true)
                    Text(summary)
                        .appLeadTextStyle()
                }
            }

            if isUnlocked {
                Button(openToolsTitle, action: onOpenTools)
                    .appPrimaryButtonStyle()
                    .accessibilityIdentifier("premium.open_tools")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(lockedAddsTitle)
                        .appEyebrowStyle()
                        .foregroundStyle(CatholicTheme.primary)

                    ForEach(pillars) { pillar in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: iconName(pillar.requiredSurface))
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

            PremiumTrustStatements(
                title: trustTitle,
                localOnlyTitle: localOnlyTitle,
                noAdsTitle: noAdsTitle,
                cancelAnytimeTitle: cancelAnytimeTitle)
        }
        .padding(14)
        .appSurfaceCard(.utility, cornerRadius: 16)
    }
}

struct PremiumJourneyCard: View {
    let isSample: Bool
    let title: String
    let intro: String
    let weekTitle: String
    let eyebrow: String
    let summary: String
    let actions: [GuidedSeasonalJourneyAction]
    let completionSummary: String?
    let nextStep: String?
    let previewHint: String?
    let isCompleted: (GuidedSeasonalJourneyAction) -> Bool
    let onAppear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .appSectionTitleStyle(serif: true)
                .accessibilityIdentifier(isSample ? "premium.journey.preview_title" : "premium.journey.current_title")

            Text(intro)
                .appSupportingTextStyle()
                .accessibilityIdentifier(isSample ? "premium.journey.preview_intro" : "premium.journey.current_intro")

            VStack(alignment: .leading, spacing: 6) {
                Text(weekTitle)
                    .font(.subheadline.weight(.semibold))
                    .accessibilityIdentifier(isSample ? "premium.journey.preview_week" : "premium.journey.current_week")
                Text(eyebrow)
                    .appEyebrowStyle()
                    .accessibilityIdentifier(isSample ? "premium.journey.preview_eyebrow" : "premium.journey.current_eyebrow")
                Text(summary)
                    .appSupportingTextStyle()

                ForEach(actions, id: \.id) { action in
                    journeyAction(action)
                }
            }

            if let previewHint {
                Text(previewHint)
                    .appSupportingTextStyle()
            }
            if let completionSummary {
                Text(completionSummary)
                    .appSupportingTextStyle()
            }
            if let nextStep {
                Text(nextStep)
                    .appEyebrowStyle()
            }
        }
        .padding(14)
        .appSurfaceCard(isSample ? .standard : .primary, cornerRadius: 16)
        .accessibilityIdentifier("premium.sample_preview")
        .onAppear(perform: onAppear)
    }

    private func journeyAction(_ action: GuidedSeasonalJourneyAction) -> some View {
        let completed = !isSample && isCompleted(action)

        return HStack(alignment: .top, spacing: 8) {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(completed ? CatholicTheme.successForeground : CatholicTheme.primary)
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

struct PremiumLegalSupportCard: View {
    let title: String
    let summary: String
    let restoreTitle: String
    let manageTitle: String
    let termsTitle: String
    let privacyTitle: String
    let supportTitle: String
    let isPurchasing: Bool
    let onRestore: () -> Void
    let onManage: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .appEyebrowStyle()

            Text(summary)
                .appSupportingTextStyle()
                .foregroundStyle(.secondary)

            Button(restoreTitle, action: onRestore)
                .appSecondaryButtonStyle()
                .disabled(isPurchasing)
                .accessibilityIdentifier("premium.restore")

            Button(manageTitle, action: onManage)
                .appSecondaryButtonStyle()
                .disabled(isPurchasing)
                .accessibilityIdentifier("premium.manage")

            legalLink(termsTitle, destination: UIConstants.termsOfUseURL, identifier: "premium.legal.terms")
            legalLink(privacyTitle, destination: UIConstants.privacyPolicyURL, identifier: "premium.legal.privacy")
            legalLink(supportTitle, destination: UIConstants.supportSiteURL, identifier: "premium.legal.support")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(.utility, cornerRadius: 16)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("premium.legal_actions")
    }

    private func legalLink(_ title: String, destination: URL, identifier: String) -> some View {
        Link(title, destination: destination)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(CatholicTheme.primary)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
            .accessibilityIdentifier(identifier)
    }
}
