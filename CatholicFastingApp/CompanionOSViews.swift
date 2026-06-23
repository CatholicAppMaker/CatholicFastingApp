import SwiftUI

struct CompanionDashboardCard: View {
    let snapshot: CompanionSnapshot
    let todayLabel: String
    let nextRequiredLabel: String
    let onPrimaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: iconName)
                    .appSymbolStyle(.prominent)
                    .foregroundStyle(iconTint)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 5) {
                    Text(localized("companion.dashboard.eyebrow", default: "Companion OS"))
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                        .foregroundStyle(CatholicTheme.primary)

                    Text(snapshot.ruleDecision.obligationLine)
                        .font(.system(.title3, design: .serif).weight(.bold))
                        .foregroundStyle(CatholicTheme.primary)
                        .accessibilityIdentifier("companion.rule.obligation")

                    Text(snapshot.ruleDecision.rationale)
                        .appSupportingTextStyle()
                }
            }

            HStack(spacing: 8) {
                CompanionMetricPill(
                    title: localized("companion.metric.today", default: "Today"),
                    value: todayLabel)
                CompanionMetricPill(
                    title: localized("companion.metric.next", default: "Next"),
                    value: nextRequiredLabel)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(localized("companion.next_action.eyebrow", default: "Next faithful action"))
                    .appEyebrowStyle()
                    .textCase(.uppercase)
                Text(snapshot.primaryAction.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CatholicTheme.primary)
                Text(snapshot.primaryAction.detail)
                    .appSupportingTextStyle()
                    .lineLimit(2 ... 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .appSurfaceCard(.utility, cornerRadius: 16)
            .accessibilityIdentifier("companion.primary_action")

            Button(action: onPrimaryAction) {
                Label(snapshot.primaryAction.title, systemImage: primaryActionIconName)
            }
            .appPrimaryButtonStyle()
            .accessibilityIdentifier("companion.primary_action.button")

            Text(snapshot.ruleDecision.sourceLine)
                .appSupportingTextStyle()
                .accessibilityIdentifier("companion.rule.source")
        }
        .padding(14)
        .appSurfaceCard(.primary, cornerRadius: 20)
        .accessibilityIdentifier("companion.dashboard")
    }

    private var iconName: String {
        if snapshot.ruleDecision.obligationLine.localizedCaseInsensitiveContains("dispensation") {
            return "cross.case.fill"
        }
        if snapshot.ruleDecision.hasMandatoryObservance {
            return "exclamationmark.circle.fill"
        }
        return "checkmark.circle.fill"
    }

    private var iconTint: Color {
        if snapshot.ruleDecision.hasMandatoryObservance {
            return CatholicTheme.dangerForeground
        }
        return CatholicTheme.successForeground
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

                VStack(alignment: .leading, spacing: 5) {
                    Text(localized("companion.live.eyebrow", default: "Live fasting"))
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CatholicTheme.primary)
                    Text(detail)
                        .appSupportingTextStyle()
                }
            }

            if let progress {
                ProgressView(value: progress)
                    .tint(CatholicTheme.primary)
                    .accessibilityIdentifier("companion.live.progress")
            }

            Text(stageLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .appCapsuleGlass()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
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
        .padding(14)
        .appSurfaceCard(.standard, cornerRadius: 18)
        .accessibilityIdentifier("companion.live_state")
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
                    Text(formation.seasonLabel)
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
                    .foregroundStyle(CatholicTheme.primary)
                Text(formation.nextJourneyActionDetail)
                    .appSupportingTextStyle()
            }
            .padding(12)
            .appSurfaceCard(.utility, cornerRadius: 16)

            CompanionMetricPill(
                title: localized("companion.formation.current_rhythm", default: "Current rhythm"),
                value: currentStreakValue)

            if let recoverySummary = formation.recoverySummary {
                Text(recoverySummary)
                    .appSupportingTextStyle()
                    .padding(12)
                    .appSurfaceCard(.utility, cornerRadius: 16)
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
        .padding(14)
        .appSurfaceCard(.standard, cornerRadius: 18)
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
                .appEyebrowStyle()
                .textCase(.uppercase)
            Text(value)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .appSurfaceCard(.utility, cornerRadius: 14)
    }
}
