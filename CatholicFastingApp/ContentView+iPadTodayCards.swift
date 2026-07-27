import SwiftUI

#if canImport(AVFoundation)
import AVFoundation
#endif

extension ContentView {
    var ipadTodayQuickActionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.today.actions.eyebrow", default: "Do next"),
                title: localized("ipad.today.actions.title", default: "Quick actions"),
                detail: localized("ipad.today.actions.detail", default: "Keep the next obligation and planning one tap away."))

            IPadWorkspaceActionButton(
                title: localized("ipad.today.actions.open_fasting_days", default: "Open Calendar"),
                systemImage: "calendar",
                primary: true,
                accessibilityIdentifier: "ipad.today.action.open_fasting_days")
            {
                focusFastingDaysOnUpcomingRequired()
            }

            HStack(spacing: 10) {
                IPadWorkspaceActionButton(
                    title: localized("ipad.today.actions.open_planning", default: "Open Planning"),
                    systemImage: "slider.horizontal.3",
                    primary: false,
                    accessibilityIdentifier: "ipad.today.action.open_planning")
                {
                    navigateToMoreDestination(.profileAndNorms)
                }

                IPadWorkspaceActionButton(
                    title: localized("ipad.today.actions.support_premium", default: "Support & Premium"),
                    systemImage: "heart.circle",
                    primary: false,
                    accessibilityIdentifier: "ipad.today.action.open_premium")
                {
                    navigateToMoreDestination(.supportAndPremium)
                }
            }

            IPadWorkspaceActionButton(
                title: localized("ipad.today.actions.open_guidance", default: "Open full food guidance"),
                systemImage: "book",
                primary: false,
                accessibilityIdentifier: "ipad.today.action.open_food_guidance")
            {
                navigateToMoreDestination(.guidanceAndRules)
            }
        }
        .padding(14)
        .iPadPaneCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ipad.today.actions")
    }

    var ipadTodayPlanningCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.today.planning.eyebrow", default: "Planning"),
                title: localized("ipad.today.planning.title", default: "Year and season snapshot"),
                detail: localized("ipad.today.planning.detail", default: "See the yearly rhythm without leaving the dashboard."))

            HStack(spacing: 10) {
                IPadSummaryMetricCard(
                    title: localized("ipad.today.planning.required_goal", default: "Required goal"),
                    value: "\(yearlyRequiredCompletions)/\(planningData.requiredGoal)",
                    subtitle: localized(
                        "ipad.today.planning.required_goal_detail",
                        default: "required days logged"))
                IPadSummaryMetricCard(
                    title: localized("ipad.today.planning.optional_goal", default: "Optional goal"),
                    value: "\(yearlyOptionalCompletions)/\(planningData.optionalGoal)",
                    subtitle: localized("ipad.today.planning.optional_goal_detail", default: "optional disciplines logged"),
                    tint: CatholicTheme.accentForeground)
            }

            ProgressView(value: requirementGoalProgress)
                .tint(CatholicTheme.primary)
                .accessibilityHidden(true)
            ProgressView(value: optionalGoalProgress)
                .tint(CatholicTheme.accent)
                .accessibilityHidden(true)

            if currentSeasonCommitments.isEmpty {
                Text(localizedFormat("ipad.today.planning.no_commitments", default: "No active commitments for %@.", localizedSeasonLabel(currentLiturgicalSeason)))
                    .appSupportingTextStyle()
            } else {
                ForEach(currentSeasonCommitments.prefix(3)) { commitment in
                    Label(commitment.title, systemImage: "checkmark.circle")
                        .font(.footnote)
                }
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("ipad.today.planning")
    }

    var ipadTodayRecoveryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.today.recovery.eyebrow", default: "Recovery"),
                title: missedDayRecoveryPlan == nil
                    ? localized("ipad.today.recovery.title_clear", default: "No urgent recovery")
                    : localized("ipad.today.recovery.title_ready", default: "Recovery path ready"),
                detail: monetizationStore.premiumUnlocked ? weeklyFormationRecapPremium : weeklyFormationRecapFree)

            if let recovery = missedDayRecoveryPlan {
                Text(recovery.titleLine)
                    .font(.headline)
                    .foregroundStyle(CatholicTheme.primary)
                Text(recovery.summaryLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(recovery.steps, id: \.self) { step in
                    Text("• \(step)")
                        .appSupportingTextStyle()
                }
                Text(recovery.nextRequiredLine)
                    .appSupportingTextStyle()
                Button(localized("ipad.today.recovery.log_substitute", default: "Log recovery substitute today")) {
                    logRecoverySubstituteForToday()
                }
                .appSecondaryButtonStyle()
                .disabled(!canLogRecoverySubstituteToday)
            } else {
                Text(localized("ipad.today.recovery.none_detail", default: "No missed observance currently needs recovery. Protect the next required day now."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.today.recovery")
    }

    func ipadTodayTrustCard(regionContext: RegionalRuleContext) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.today.transparency.eyebrow", default: "Transparency"),
                title: regionContext.authorityLabel,
                detail: regionContext.disclosureText)

            Text(todayFoodDecision.sourceLine)
                .appSupportingTextStyle()

            HStack(spacing: 8) {
                ForEach(regionContext.citations, id: \.self) { citation in
                    StatusTag(text: citation.authority.rawValue, color: CatholicTheme.primary)
                }
            }

            if !acceptedLegalNotice {
                Text(localized(
                    "ipad.today.transparency.notice",
                    default: "This is an independent devotional app, not an official app of the Catholic Church."))
                    .appSupportingTextStyle()
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityElement(children: .contain)
        .accessibilityValue(Text(regionContext.classificationLabel))
        .accessibilityIdentifier("ipad.today.transparency")
    }
}
