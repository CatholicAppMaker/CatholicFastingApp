import SwiftUI

struct DashboardPlanningProgressSection: View {
    struct CommitmentItem: Identifiable {
        let id: String
        let title: String
    }

    let sectionTitle: String
    let progressSummary: String
    let requiredProgress: Double
    let optionalProgress: Double
    let emptyCommitmentsText: String?
    let commitments: [CommitmentItem]

    var body: some View {
        Section(sectionTitle) {
            Text(progressSummary)
                .font(.subheadline)
            ProgressView(value: requiredProgress)
                .tint(CatholicTheme.primary)
            ProgressView(value: optionalProgress)
                .tint(CatholicTheme.accent)
            if let emptyCommitmentsText {
                Text(emptyCommitmentsText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(commitments) { commitment in
                    Label(commitment.title, systemImage: "checkmark.circle")
                        .font(.caption)
                }
            }
        }
    }
}

struct DashboardTextLinesSection: View {
    let sectionTitle: String
    let lines: [String]

    var body: some View {
        Section(sectionTitle) {
            ForEach(lines.indices, id: \.self) { index in
                Text(lines[index])
            }
        }
    }
}

struct DashboardAccessibilitySupportSection: View {
    let sectionTitle: String
    let simplifiedModeMessage: String?

    var body: some View {
        Section(sectionTitle) {
            if let simplifiedModeMessage {
                Text(simplifiedModeMessage)
                    .foregroundStyle(CatholicTheme.primary)
            }
        }
    }
}

struct DashboardNoticeSection: View {
    let sectionTitle: String
    let independentNotice: String
    let authorityNotice: String

    var body: some View {
        Section(sectionTitle) {
            Text(independentNotice)
                .font(.subheadline)
                .foregroundStyle(CatholicTheme.primary)
            Text(authorityNotice)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("notice.unofficial")
        }
    }
}

struct DashboardQuoteSection: View {
    let sectionTitle: String
    let quote: CatholicFastingQuote
    let accessibilityIdentifier: String

    var body: some View {
        Section(sectionTitle) {
            CatholicFastingQuoteCard(quote: quote, compact: true)
                .accessibilityIdentifier(accessibilityIdentifier)
        }
    }
}

struct DashboardSetupProgressSection: View {
    struct ChecklistItem: Identifiable {
        let id: String
        let title: String
        let isComplete: Bool
    }

    let sectionTitle: String
    let intro: String
    let progress: String
    let items: [ChecklistItem]
    let openTitle: String
    let openSetup: () -> Void

    var body: some View {
        Section(sectionTitle) {
            Text(intro)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(progress)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
                .accessibilityIdentifier("today.setup.progress")

            ForEach(items) { item in
                Label {
                    Text(item.title)
                } icon: {
                    Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.isComplete ? CatholicTheme.successForeground : Color.secondary)
                }
            }

            Button(openTitle, action: openSetup)
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("today.setup.open_quick_setup")
        }
    }
}

struct DashboardReferralSection: View {
    let sectionTitle: String
    let introduction: String
    let shareItem: String
    let subject: String
    let buttonTitle: String

    var body: some View {
        Section(sectionTitle) {
            Text(introduction)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ShareLink(item: shareItem, subject: Text(subject)) {
                Label(buttonTitle, systemImage: "square.and.arrow.up")
            }
            .appSecondaryButtonStyle()
        }
    }
}

struct TodayAtAGlanceSection: View {
    let sectionTitle: String
    let nextTitle: String
    let nextValue: String
    let weekTitle: String
    let weekValue: String
    let rhythmTitle: String
    let rhythmValue: String
    let resilienceMessage: String
    let formationRecap: String

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text(sectionTitle)
                    .appEyebrowStyle()
                    .foregroundStyle(CatholicTheme.primary)

                HStack(spacing: 8) {
                    MetricTile(title: nextTitle, value: nextValue)
                    MetricTile(title: weekTitle, value: weekValue)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(rhythmTitle)
                        .appEyebrowStyle()
                    Text(rhythmValue)
                        .appSectionTitleStyle()
                    Text(resilienceMessage)
                        .appLeadTextStyle()
                    Text(formationRecap)
                        .appSupportingTextStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)
            }
            .padding(14)
            .appSurfaceCard(.utility, cornerRadius: 22)
            .accessibilityIdentifier("dashboard.today_glance")
        }
    }
}

struct DashboardHeroSection: View {
    let title: String
    let summary: String
    let subtitle: String
    let completionRate: Double
    let progressSummary: String

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "cross.fill")
                        .appSymbolStyle(.standard)
                    Text(title)
                        .appSectionTitleStyle(serif: true)
                }
                Text(summary)
                    .appLeadTextStyle()
                Text(subtitle)
                    .appSupportingTextStyle()
                    .foregroundStyle(.secondary)
                ProgressView(value: completionRate)
                    .tint(CatholicTheme.accent)
                Text(progressSummary)
                    .appSupportingTextStyle()
            }
            .accessibilityIdentifier("dashboard.plan_summary")
            .padding(14)
            .appSurfaceCard(.standard, cornerRadius: 18)
        }
    }
}

struct TodayDecisionCardSection: View {
    let eyebrow: String
    let obligation: String
    let rationale: String
    let iconName: String
    let tint: Color
    let nextActionTitle: String
    let nextAction: String
    let avoidTitle: String
    let avoidItems: [String]
    let allowedTitle: String
    let allowedItems: [String]
    let guidanceTitle: String
    let commonQuestionsTitle: String
    let chickenAnswer: String
    let dairyAnswer: String
    let fishAnswer: String
    let brothAnswer: String
    let sourceLine: String
    let sourceLinkTitle: String
    let sourceURL: URL
    let openGuidance: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                decisionHeader
                nextActionCard
                foodList(title: avoidTitle, items: avoidItems, systemImage: "xmark.circle.fill")
                foodList(title: allowedTitle, items: allowedItems, systemImage: "checkmark.circle.fill")

                Button(action: openGuidance) {
                    Label(guidanceTitle, systemImage: "book.closed")
                }
                .accessibilityIdentifier("today.decision.open_full_food_guidance")

                commonQuestions
                sourceCard
            }
            .padding(14)
            .appSurfaceCard(.standard, cornerRadius: 20)
        }
    }

    private var decisionHeader: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: iconName)
                .appSymbolStyle(.prominent)
                .foregroundStyle(tint)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 5) {
                Text(eyebrow)
                    .appEyebrowStyle()
                    .textCase(.uppercase)
                    .foregroundStyle(CatholicTheme.primary)
                Text(obligation)
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundStyle(CatholicTheme.primary)
                    .accessibilityIdentifier("today.decision.obligation")
                Text(rationale)
                    .appSupportingTextStyle()
            }
        }
    }

    private var nextActionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(nextActionTitle)
                .appEyebrowStyle()
                .textCase(.uppercase)
            Text(nextAction)
                .appLeadTextStyle()
        }
        .padding(12)
        .appSurfaceCard(.utility, cornerRadius: 16)
        .accessibilityIdentifier("today.decision.next_action")
    }

    @ViewBuilder
    private func foodList(title: String, items: [String], systemImage: String) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                ForEach(items, id: \.self) { item in
                    Label(item, systemImage: systemImage)
                }
            }
        }
    }

    private var commonQuestions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(commonQuestionsTitle)
                .appEyebrowStyle()
                .textCase(.uppercase)
            Label(chickenAnswer, systemImage: "xmark.circle")
            Label(dairyAnswer, systemImage: "checkmark.circle")
            Label(fishAnswer, systemImage: "checkmark.circle")
            Label(brothAnswer, systemImage: "questionmark.circle")
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .appSurfaceCard(.utility, cornerRadius: 16)
        .accessibilityIdentifier("today.decision.common_food_questions")
    }

    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(sourceLine)
                .appSupportingTextStyle()
            Link(sourceLinkTitle, destination: sourceURL)
                .font(.footnote.weight(.semibold))
        }
        .padding(12)
        .appSurfaceCard(.utility, cornerRadius: 16)
    }
}

struct TodayRecoverySection: View {
    let sectionTitle: String
    let title: String
    let summary: String
    let steps: [String]
    let nextRequired: String
    let markTitle: String
    let canMark: Bool
    let focusTitle: String
    let markRecovery: () -> Void
    let focusRequiredDays: () -> Void

    var body: some View {
        Section(sectionTitle) {
            Text(title)
                .font(.headline)
                .foregroundStyle(CatholicTheme.primary)
                .accessibilityIdentifier("today.recovery.title")
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ForEach(steps, id: \.self) { step in
                Label(step, systemImage: "arrow.forward.circle")
            }
            Text(nextRequired)
                .font(.caption)
                .foregroundStyle(.secondary)

            Button(markTitle, action: markRecovery)
                .accessibilityIdentifier("today.recovery.mark_substitute")
                .appPrimaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
                .disabled(!canMark)

            Button(focusTitle, action: focusRequiredDays)
                .accessibilityIdentifier("today.recovery.open_fasting_days")
                .appSecondaryButtonStyle()
        }
    }
}

struct DashboardSeasonSection: View {
    let sectionTitle: String
    let season: String
    let introduction: String

    var body: some View {
        Section(sectionTitle) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CatholicTheme.accentForeground)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(season)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(CatholicTheme.primary)
                    Text(introduction)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(CatholicTheme.parchment.opacity(0.92), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(CatholicTheme.accent.opacity(0.10)))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1))
            .appRoundedGlass(cornerRadius: 12)
        }
    }
}

struct DashboardOverviewSection: View {
    let sectionTitle: String
    let completionText: String
    let rhythmText: String
    let nextRequiredText: String
    let hasUpcomingRequired: Bool
    let openTitle: String
    let openIdentifier: String
    let focusTitle: String?
    let openCalendar: () -> Void
    let focusRequired: (() -> Void)?

    var body: some View {
        Section(sectionTitle) {
            Text(completionText)
                .foregroundStyle(CatholicTheme.primary)
            Text(rhythmText)
                .foregroundStyle(CatholicTheme.primary.opacity(0.9))
            Text(nextRequiredText)
                .foregroundStyle(hasUpcomingRequired ? CatholicTheme.dangerForeground : Color.secondary)
            Button(openTitle, action: openCalendar)
                .appPrimaryButtonStyle()
                .accessibilityIdentifier(openIdentifier)
            if let focusTitle, let focusRequired {
                Button(focusTitle, action: focusRequired)
                    .accessibilityIdentifier("dashboard.focus_required")
                    .appSecondaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
            }
        }
    }
}
