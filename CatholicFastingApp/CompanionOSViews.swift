import SwiftUI

enum CompanionDashboardPresentation {
    case phone
    case workspace
}

struct CompanionDashboardCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let snapshot: CompanionSnapshot
    let todayLabel: String
    let nextRequiredLabel: String
    let seasonLabel: String
    var presentation: CompanionDashboardPresentation = .phone
    let onPrimaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: presentation == .workspace ? 16 : 13) {
            if dynamicTypeSize.isAccessibilitySize {
                guidanceHeader(horizontal: false)
            } else {
                guidanceHeader(horizontal: true)
            }

            SacredEditorialRule()

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 0) {
                    CompanionMetricPill(
                        title: localized("companion.metric.today", default: "Today"),
                        value: todayLabel)
                    SacredEditorialRule()
                    CompanionMetricPill(
                        title: localized("companion.metric.next", default: "Next"),
                        value: nextRequiredLabel)
                }
            } else {
                HStack(alignment: .top, spacing: 14) {
                    CompanionMetricPill(
                        title: localized("companion.metric.today", default: "Today"),
                        value: todayLabel)

                    Rectangle()
                        .fill(CatholicTheme.primary.opacity(0.14))
                        .frame(width: 1, height: 46)
                        .accessibilityHidden(true)

                    CompanionMetricPill(
                        title: localized("companion.metric.next", default: "Next"),
                        value: nextRequiredLabel)
                }
            }

            SacredEditorialRule()

            VStack(alignment: .leading, spacing: 7) {
                Text(localized("companion.next_action.eyebrow", default: "Next faithful action"))
                    .appEyebrowStyle()
                    .textCase(.uppercase)
                Text(snapshot.primaryAction.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(snapshot.primaryAction.detail)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .lineLimit(2 ... 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)
            .background(CatholicTheme.parchment)
            .accessibilityIdentifier("companion.primary_action")

            Button(action: onPrimaryAction) {
                Label(snapshot.primaryAction.title, systemImage: primaryActionIconName)
                    .frame(maxWidth: presentation == .workspace ? 300 : .infinity)
            }
            .appPrimaryButtonStyle()
            .accessibilityIdentifier("companion.primary_action.button")

            Label(snapshot.ruleDecision.sourceLine, systemImage: "book.closed")
                .font(.footnote)
                .foregroundStyle(.primary)
                .padding(.vertical, 4)
                .background(CatholicTheme.parchment)
                .accessibilityIdentifier("companion.rule.source")
        }
        .padding(.vertical, presentation == .workspace ? 4 : 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("companion.dashboard")
    }

    @ViewBuilder
    private func guidanceHeader(horizontal: Bool) -> some View {
        if horizontal {
            HStack(alignment: .top, spacing: presentation == .workspace ? 18 : 12) {
                sacredAnchor
                guidanceCopy
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                sacredAnchor
                guidanceCopy
            }
        }
    }

    private var sacredAnchor: some View {
        SacredIdentityThumbnail(
            assetName: "SacredSacredHeart",
            statusSymbol: iconName,
            statusTint: iconTint,
            imageSize: presentation == .workspace ? 92 : 72)
            .accessibilityHidden(false)
            .accessibilityLabel(sacredAnchorAccessibilityLabel)
            .accessibilityIdentifier("companion.sacred_masthead")
    }

    private var sacredAnchorAccessibilityLabel: String {
        let title = AppLocalizer.localizedCurrent(
            "companion.sacred_anchor.accessibility",
            default: "Sacred Heart devotional image")
        return "\(title), \(seasonLabel)"
    }

    private var guidanceCopy: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(localized("companion.dashboard.eyebrow", default: "Today’s guidance"))
                .appEyebrowStyle()
                .textCase(.uppercase)
                .foregroundStyle(CatholicTheme.primary)

            Text(snapshot.ruleDecision.obligationLine)
                .font(.system(presentation == .workspace ? .title2 : .title3, design: .serif).weight(.bold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("companion.rule.obligation")

            Text(snapshot.ruleDecision.rationale)
                .appSupportingTextStyle()
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var iconName: String {
        decisionPresentation.symbolName
    }

    private var iconTint: Color {
        decisionPresentation.tone.foreground
    }

    private var decisionPresentation: DailyFoodDecisionPresentation {
        .presentation(for: snapshot.ruleDecision.category)
    }

    private var primaryActionIconName: String {
        switch snapshot.primaryAction.destination {
        case .today:
            "house"
        case .fastingDays:
            "calendar"
        case .trackFast:
            "timer"
        case .guidance:
            "book.closed"
        case .setup:
            "slider.horizontal.3"
        case .premium:
            "heart.circle"
        case .journal:
            "book.pages"
        }
    }
}

struct CompanionLiveStateCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let detail: String
    let stageLabel: String
    let progress: Double?
    let metrics: [CompanionCardMetric]
    let actionTitle: String
    let actionSystemImage: String
    let onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "timer")
                    .appSymbolStyle(.prominent)
                    .foregroundStyle(CatholicTheme.accentForeground)
                    .padding(.top, 2)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    if dynamicTypeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 8) {
                            liveFastingEyebrow
                            stageBadge
                        }
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            liveFastingEyebrow
                            Spacer(minLength: 8)
                            stageBadge
                        }
                    }

                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(detail)
                        .appSupportingTextStyle()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let progress {
                ProgressView(value: progress)
                    .tint(CatholicTheme.primary)
                    .accessibilityElement()
                    .accessibilityLabel(
                        Text(localized("companion.live.progress.label", default: "Fast progress")))
                    .accessibilityValue(Text("\(Int((progress * 100).rounded()))%"))
                    .accessibilityIdentifier("companion.live.progress")
            }

            LazyVGrid(
                columns: dynamicTypeSize.isAccessibilitySize
                    ? [GridItem(.flexible())]
                    : [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 8)
            {
                ForEach(metrics) { metric in
                    CompanionMetricPill(title: metric.title, value: metric.value)
                }
            }

            Button(action: onAction) {
                Label(actionTitle, systemImage: actionSystemImage)
            }
            .appSecondaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
            .accessibilityIdentifier("companion.live.action")
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("companion.live_state")
    }

    private var liveFastingEyebrow: some View {
        Text(localized("companion.live.eyebrow", default: "Live fasting"))
            .font(.body.weight(.semibold))
            .foregroundStyle(.primary)
    }

    private var stageBadge: some View {
        Text(stageLabel)
            .font(.caption.weight(.semibold))
            .foregroundStyle(CatholicTheme.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .appCapsuleGlass()
    }
}

struct CompanionInactiveFastCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let stageLabel: String
    let targetTitle: String
    let targetValue: String
    let intentionTitle: String
    let intentionValue: String
    let actionTitle: String
    let actionSystemImage: String
    let onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 8) {
                        inactiveFastTitle
                        stageBadge
                    }
                } else {
                    HStack(alignment: .center, spacing: 10) {
                        inactiveFastTitle
                        Spacer(minLength: 8)
                        stageBadge
                    }
                }
            }

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 8) {
                        CompanionMetricPill(title: targetTitle, value: targetValue)
                        CompanionMetricPill(title: intentionTitle, value: intentionValue)
                    }
                } else {
                    HStack(alignment: .top, spacing: 14) {
                        CompanionMetricPill(title: targetTitle, value: targetValue)

                        Rectangle()
                            .fill(CatholicTheme.primary.opacity(0.14))
                            .frame(width: 1, height: 42)
                            .accessibilityHidden(true)

                        CompanionMetricPill(title: intentionTitle, value: intentionValue)
                    }
                }
            }

            Button(action: onAction) {
                HStack(spacing: 8) {
                    Image(systemName: actionSystemImage)
                        .accessibilityHidden(true)
                    Text(actionTitle)
                }
                .font(.body)
                .foregroundStyle(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44)
            .background {
                Capsule()
                    .fill(CatholicTheme.parchment)
                    .accessibilityHidden(true)
            }
            .overlay {
                Capsule()
                    .stroke(CatholicTheme.cardBorder, lineWidth: 1)
                    .accessibilityHidden(true)
            }
            .contentShape(Capsule())
            .accessibilityLabel(Text(actionTitle))
            .accessibilityIdentifier("companion.live.action")
        }
        .padding(.vertical, 6)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("companion.live_state")
    }

    private var inactiveFastTitle: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "timer")
                .appSymbolStyle(.prominent)
                .foregroundStyle(CatholicTheme.accentForeground)
                .accessibilityHidden(true)

            Text(localized("intermittent.live.optional_practice", default: "Optional personal practice"))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var stageBadge: some View {
        Text(stageLabel)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(CatholicTheme.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .appCapsuleGlass()
    }
}

struct CompanionFormationCard: View {
    let formation: CompanionFormationState
    let onOpenFormation: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .appSymbolStyle(.prominent)
                    .foregroundStyle(CatholicTheme.primary)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 5) {
                    Text(AppLocalizer.localizedCurrentFormat(
                        "companion.formation.seasonal_program_format",
                        default: "Seasonal formation • %@",
                        formation.seasonLabel))
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                    Text(formation.journeyTitle)
                        .font(.system(.headline, design: .serif).weight(.semibold))
                        .foregroundStyle(CatholicTheme.primary)
                    Text(formation.completionSummary)
                        .appSupportingTextStyle()
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(localized("companion.formation.next_action", default: "Next formation action"))
                    .appEyebrowStyle()
                    .textCase(.uppercase)
                Text(formation.nextJourneyActionTitle)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(formation.nextJourneyActionDetail)
                    .appSupportingTextStyle()
            }
            .padding(.top, 2)

            CompanionMetricPill(
                title: localized("companion.formation.current_rhythm", default: "Current rhythm"),
                value: currentStreakValue)

            if let recoverySummary = formation.recoverySummary {
                Text(recoverySummary)
                    .appSupportingTextStyle()
                    .padding(.vertical, 4)
            }

            Button(action: onOpenFormation) {
                Label(
                    formation.premiumUnlocked
                        ? localized("companion.formation.open_tools", default: "Open Formation Tools")
                        : localized("companion.formation.preview", default: "Preview Formation"),
                    systemImage: formation.premiumUnlocked ? "heart.circle" : "lock.open")
            }
            .appSecondaryButtonStyle()
            .accessibilityIdentifier("companion.formation.action")
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("companion.formation")
    }

    private var currentStreakValue: String {
        if formation.currentStreak == 1 {
            return localized("companion.formation.current_streak.one", default: "1 day")
        }
        return AppLocalizer.localizedCurrentFormat(
            "companion.formation.current_streak.many",
            default: "%d days",
            formation.currentStreak)
    }
}

private func localized(_ key: String, default defaultValue: String) -> String {
    AppLocalizer.localizedCurrent(key, default: defaultValue)
}

struct CompanionCardMetric: Identifiable, Hashable {
    let id: String
    let title: String
    let value: String

    init(title: String, value: String) {
        id = title
        self.title = title
        self.value = value
    }
}

private struct CompanionMetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .textCase(.uppercase)
            Text(value)
                .font(.subheadline)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .foregroundStyle(CatholicTheme.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 7)
    }
}
