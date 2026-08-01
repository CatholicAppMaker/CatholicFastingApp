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

    var body: some View {
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

            VStack(alignment: .leading, spacing: 8) {
                Text(trustTitle)
                    .appEyebrowStyle()

                HStack(spacing: 8) {
                    PremiumTrustPill(text: localOnlyTitle, systemImage: "lock.shield")
                    PremiumTrustPill(text: noAdsTitle, systemImage: "nosign")
                    PremiumTrustPill(text: cancelAnytimeTitle, systemImage: "creditcard")
                }
            }
        }
        .padding(14)
        .appSurfaceCard(.utility, cornerRadius: 16)
        .appRoundedGlass(cornerRadius: 16)
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
        .appRoundedGlass(cornerRadius: 16)
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
