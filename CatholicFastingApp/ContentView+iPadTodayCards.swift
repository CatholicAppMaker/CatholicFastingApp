import SwiftUI

#if canImport(AVFoundation)
import AVFoundation
#endif

extension ContentView {
    var ipadTodayPrimaryGuidanceCard: some View {
        let decision = todayFoodDecision
        let todayContext = todayActionableObservances.first.map { RegionalGuidanceContextFactory.presentationContext(for: $0, settings: settings) }

        return VStack(alignment: .leading, spacing: 16) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.today.primary.eyebrow", default: "Today"),
                title: todayActionableObservances.isEmpty
                    ? localized("ipad.today.primary.title_clear", default: "No mandatory observance today")
                    : localized("ipad.today.primary.title_attention", default: "Today requires attention"),
                detail: heroSummaryText)

            HStack(spacing: 10) {
                IPadContextBadge(
                    text: todayContext?.regionalContext.classificationLabel ?? RegionalGuidanceContextFactory.generalContext(for: settings).classificationLabel,
                    supportLevel: todayContext?.regionalContext.supportLevel ?? RegionalGuidanceContextFactory.generalContext(for: settings).supportLevel)
                if let today = todayActionableObservances.first {
                    StatusTag(text: today.kind.label, color: today.kind.color)
                    StatusTag(text: today.dispositionLabel, color: today.obligation == .mandatory ? .red : .blue)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(decision.obligationLine)
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundStyle(CatholicTheme.primary)
                if let allowed = decision.allowed.first {
                    Text(localizedFormat("ipad.today.primary.allowed_format", default: "Okay today: %@", allowed))
                        .font(.subheadline)
                }
                if let avoid = decision.avoid.first {
                    Text(localizedFormat("ipad.today.primary.avoid_format", default: "Avoid today: %@", avoid))
                        .font(.subheadline)
                }
                Text(decision.rationale)
                    .appLeadTextStyle()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(localized("ipad.today.primary.next_step", default: "Next step"))
                    .appEyebrowStyle()
                    .textCase(.uppercase)
                Text(
                    todayContext?.nextActionText
                        ?? localized(
                            "ipad.today.primary.next_step_detail",
                            default: "Keep the next required day visible and review your region profile before planning optional disciplines."))
                    .appLeadTextStyle()
            }
            .padding(12)
            .appSurfaceCard(.utility, cornerRadius: 16)

            Button {
                selectedMoreDestination = .guidanceAndRules
                homeSurface = .more
            } label: {
                Label(localized("ipad.today.primary.open_guidance", default: "Open full food guidance"), systemImage: "book.closed")
            }
            .appSecondaryButtonStyle()
            .accessibilityIdentifier("ipad.today.open_food_guidance")

            VStack(alignment: .leading, spacing: 8) {
                Text(localized("ipad.today.primary.common_questions", default: "Common food questions"))
                    .appEyebrowStyle()
                    .foregroundStyle(CatholicTheme.primary)
                    .textCase(.uppercase)
                Label(localized("ipad.today.primary.common.chicken", default: "Chicken and turkey count as meat."), systemImage: "xmark.circle")
                Label(localized("ipad.today.primary.common.dairy", default: "Eggs, milk, butter, and cheese are generally permitted."), systemImage: "checkmark.circle")
                Label(localized("ipad.today.primary.common.fish", default: "Fish and shellfish are generally permitted."), systemImage: "checkmark.circle")
                Label(
                    localized(
                        "ipad.today.primary.common.open_guidance_hint",
                        default: "Open the full guidance page if you need stricter-practice details or region-specific notes."),
                    systemImage: "book.closed")
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .appSurfaceCard(.utility, cornerRadius: 16)
            .accessibilityIdentifier("ipad.today.food_guidance_preview")
        }
        .padding(18)
        .iPadPaneCard(.primary)
        .accessibilityIdentifier("ipad.today.primary_card")
    }

    var ipadTodayMetricsCard: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            IPadSummaryMetricCard(
                title: localized("ipad.today.metrics.next_required", default: "Next required"),
                value: upcomingMandatoryObservance.map { localizedObservanceTitle($0.title) }
                    ?? localized("ipad.today.metrics.none_ahead", default: "None ahead"),
                subtitle: upcomingMandatoryObservance.map { localizedAbbreviatedDate($0.date) }
                    ?? localized("ipad.today.metrics.current_year_clear", default: "Current year clear"))
                IPadSummaryMetricCard(
                    title: localized("ipad.today.metrics.this_week", default: "This week"),
                    value: "\(weeklyCompletedObservancesCount)/\(weeklyActionableObservanceCount)",
                    subtitle: localized("ipad.today.metrics.this_week_detail", default: "discipline days completed"),
                    tint: CatholicTheme.accentForeground)
            IPadSummaryMetricCard(
                title: localized("ipad.today.metrics.current_streak", default: "Current streak"),
                value: localizedFormat("ipad.today.metrics.current_streak_value", default: "%d days", currentStreak),
                subtitle: streakResilienceMessage)
                IPadSummaryMetricCard(
                    title: localized("ipad.today.metrics.this_month", default: "This month"),
                    value: "\(monthlyCompletionCount)",
                    subtitle: localized("ipad.today.metrics.this_month_detail", default: "logged observances"),
                    tint: CatholicTheme.warningForeground)
        }
        .accessibilityIdentifier("ipad.today.metrics")
    }

    var ipadTodayQuickActionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.today.actions.eyebrow", default: "Do next"),
                title: localized("ipad.today.actions.title", default: "Quick actions"),
                detail: localized("ipad.today.actions.detail", default: "Keep the next obligation and planning one tap away."))

            HStack(spacing: 10) {
                IPadWorkspaceActionButton(
                    title: localized("ipad.today.actions.open_fasting_days", default: "Open Fasting Days"),
                    systemImage: "calendar",
                    primary: true,
                    accessibilityIdentifier: "ipad.today.action.open_fasting_days")
                {
                    focusFastingDaysOnUpcomingRequired()
                }
                IPadWorkspaceActionButton(
                    title: localized("ipad.today.actions.open_planning", default: "Open Planning"),
                    systemImage: "slider.horizontal.3",
                    primary: false,
                    accessibilityIdentifier: "ipad.today.action.open_planning")
                {
                    homeSurface = .more
                    selectedMoreDestination = .profileAndNorms
                }
            }

            HStack(spacing: 10) {
                IPadWorkspaceActionButton(
                    title: localized("ipad.today.actions.support_premium", default: "Support & Premium"),
                    systemImage: "heart.circle",
                    primary: false,
                    accessibilityIdentifier: "ipad.today.action.open_premium")
                {
                    homeSurface = .more
                    selectedMoreDestination = .supportAndPremium
                }
                IPadWorkspaceActionButton(
                    title: localized("ipad.today.actions.open_guidance", default: "Open full food guidance"),
                    systemImage: "book",
                    primary: false,
                    accessibilityIdentifier: "ipad.today.action.open_food_guidance")
                {
                    homeSurface = .more
                    selectedMoreDestination = .guidanceAndRules
                }
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.today.actions")
    }

    var ipadTodayPlanningCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.today.planning.eyebrow", default: "Planning"),
                title: localized("ipad.today.planning.title", default: "Year and season snapshot"),
                detail: localized("ipad.today.planning.detail", default: "See progress without leaving the dashboard."))

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
            ProgressView(value: optionalGoalProgress)
                .tint(CatholicTheme.accent)

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

    var ipadTodaySeasonCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.today.season.eyebrow", default: "Season"),
                title: activeSeasonalContentPack.campaignTitle,
                detail: activeSeasonalContentPack.campaignSubtitle)

            Text(dailySeasonalFormationLine)
                .appLeadTextStyle()

            HStack(spacing: 8) {
                ForEach(activeSeasonalContentPack.formationLines.prefix(2), id: \.self) { line in
                    Text(line)
                        .appSupportingTextStyle()
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appSurfaceCard(.utility, cornerRadius: 14)
                }
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.today.season")
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
                Text(localized("ipad.today.transparency.notice", default: "This remains an independent devotional app and not an official Church authority app."))
                    .appSupportingTextStyle()
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.today.transparency")
    }
}
