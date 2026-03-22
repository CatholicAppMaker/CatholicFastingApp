import SwiftUI

struct IPadPaneCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .appSurfaceCard(.standard, cornerRadius: 22)
    }
}

extension View {
    func iPadPaneCard() -> some View {
        modifier(IPadPaneCardModifier())
    }
}

struct IPadWorkspaceHeader: View {
    let eyebrow: String
    let title: String
    let detail: String
    var serifTitle: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .appEyebrowStyle()
            Text(title)
                .appSectionTitleStyle(serif: serifTitle)
            Text(detail)
                .appLeadTextStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct IPadSummaryMetricCard: View {
    let title: String
    let value: String
    var subtitle: String?
    var tint: Color = CatholicTheme.primary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .appEyebrowStyle()
            Text(value)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(tint)
            if let subtitle {
                Text(subtitle)
                    .appSupportingTextStyle()
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .appSurfaceCard(.utility, cornerRadius: 16)
    }
}

struct IPadContextBadge: View {
    let text: String
    let supportLevel: RegionalSupportLevel

    var tint: Color {
        switch supportLevel {
        case .full:
            .green
        case .partial:
            .orange
        case .informational:
            .blue
        }
    }

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(tint.opacity(0.14)))
            .overlay(Capsule().stroke(tint.opacity(0.3), lineWidth: 1))
    }
}

struct IPadKeyDateChip: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                Text(subtitle)
                    .appSupportingTextStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .appInteractiveTileStyle(isSelected: isSelected, cornerRadius: 14)
        }
        .buttonStyle(.plain)
    }
}

struct IPadWorkspaceHeroBand: View {
    let assetName: String
    let seasonLabel: String
    let title: String
    let subtitle: String
    let quote: CatholicFastingQuote
    let regionContext: RegionalRuleContext
    var compact: Bool = false
    let accessibilityIdentifier: String

    var body: some View {
        Group {
            if compact {
                VStack(alignment: .leading, spacing: 14) {
                    SacredHeroCard(
                        assetName: assetName,
                        title: title,
                        subtitle: subtitle,
                        height: 144,
                        cornerRadius: 20,
                        accessibilityIdentifier: accessibilityIdentifier
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Liturgical Season: \(seasonLabel)", systemImage: "sparkles")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(CatholicTheme.primary)
                        CatholicFastingQuoteCard(quote: quote, compact: true)
                        HStack(spacing: 8) {
                            IPadContextBadge(text: regionContext.classificationLabel, supportLevel: regionContext.supportLevel)
                            IPadContextBadge(text: regionContext.supportLevel.label, supportLevel: regionContext.supportLevel)
                        }
                        Text(regionContext.disclosureText)
                            .appSupportingTextStyle()
                            .lineLimit(2)
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 18) {
                    SacredHeroCard(
                        assetName: assetName,
                        title: title,
                        subtitle: subtitle,
                        height: 196,
                        cornerRadius: 20,
                        accessibilityIdentifier: accessibilityIdentifier
                    )
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 12) {
                        Label("Liturgical Season: \(seasonLabel)", systemImage: "sparkles")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(CatholicTheme.primary)
                        CatholicFastingQuoteCard(quote: quote, compact: false)
                        HStack(spacing: 8) {
                            IPadContextBadge(text: regionContext.classificationLabel, supportLevel: regionContext.supportLevel)
                            IPadContextBadge(text: regionContext.supportLevel.label, supportLevel: regionContext.supportLevel)
                        }
                        Text(regionContext.disclosureText)
                            .appSupportingTextStyle()
                    }
                    .frame(width: 340, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .iPadPaneCard()
    }
}

struct IPadWorkspaceActionButton: View {
    let title: String
    let systemImage: String
    let primary: Bool
    var accessibilityIdentifier: String? = nil
    let action: () -> Void

    var body: some View {
        let button = Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .if(primary) { view in
            view.appPrimaryButtonStyle()
        }
        .if(!primary) { view in
            view.appSecondaryButtonStyle()
        }

        if let accessibilityIdentifier {
            button.accessibilityIdentifier(accessibilityIdentifier)
        } else {
            button
        }
    }
}

struct IPadObservanceSelectionRow: View {
    let context: ObservancePresentationContext
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text(context.observance.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(context.observance.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    StatusTag(text: context.observance.kind.label, color: context.observance.kind.color)
                    StatusTag(
                        text: context.observance.dispositionLabel,
                        color: context.observance.obligation == .mandatory ? .red : .blue
                    )
                    IPadContextBadge(text: context.regionalContext.classificationLabel, supportLevel: context.regionalContext.supportLevel)
                }
            }
            Spacer(minLength: 0)
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(CatholicTheme.primary)
            }
        }
        .padding(.vertical, 4)
    }
}

private extension View {
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
