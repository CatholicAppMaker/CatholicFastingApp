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
                eyebrow: "Today",
                title: todayActionableObservances.isEmpty ? "No mandatory observance today" : "Today requires attention",
                detail: heroSummaryText
            )

            HStack(spacing: 10) {
                IPadContextBadge(
                    text: todayContext?.regionalContext.classificationLabel ?? RegionalGuidanceContextFactory.generalContext(for: settings).classificationLabel,
                    supportLevel: todayContext?.regionalContext.supportLevel ?? RegionalGuidanceContextFactory.generalContext(for: settings).supportLevel
                )
                if let today = todayActionableObservances.first {
                    StatusTag(text: today.kind.label, color: today.kind.color)
                    StatusTag(text: today.dispositionLabel, color: today.obligation == .mandatory ? .red : .blue)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(decision.obligationLine)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(CatholicTheme.primary)
                if let allowed = decision.allowed.first {
                    Text("Okay today: \(allowed)")
                        .font(.subheadline)
                }
                if let avoid = decision.avoid.first {
                    Text("Avoid today: \(avoid)")
                        .font(.subheadline)
                }
                Text(decision.rationale)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Food guidance")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CatholicTheme.primary)
                Label("Chicken and turkey count as meat.", systemImage: "xmark.circle")
                Label("Eggs, milk, butter, and cheese are generally permitted.", systemImage: "checkmark.circle")
                Label("Fish and shellfish are generally permitted.", systemImage: "checkmark.circle")
                Label(
                    "Broths and gravies may be technically permitted, but many Catholics still avoid them in stricter practice.",
                    systemImage: "questionmark.circle"
                )
                .foregroundStyle(.secondary)
            }
            .accessibilityIdentifier("ipad.today.food_guidance_preview")

            VStack(alignment: .leading, spacing: 6) {
                Text("Next step")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(todayContext?.nextActionText ?? "Keep the next required day visible and review your region profile before planning optional disciplines.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                selectedMoreDestination = .guidanceAndRules
                homeSurface = .more
            } label: {
                Label("Open full food guidance", systemImage: "book.closed")
            }
            .appSecondaryButtonStyle()
            .accessibilityIdentifier("ipad.today.open_food_guidance")
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.today.primary_card")
    }

    var ipadTodayMetricsCard: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            IPadSummaryMetricCard(
                title: "Next required",
                value: upcomingMandatoryObservance?.title ?? "None ahead",
                subtitle: upcomingMandatoryObservance?.date.formatted(date: .abbreviated, time: .omitted) ?? "Current year clear"
            )
            IPadSummaryMetricCard(
                title: "This week",
                value: "\(weeklyCompletedObservancesCount)/\(weeklyActionableObservances.count)",
                subtitle: "discipline days completed",
                tint: CatholicTheme.accent
            )
            IPadSummaryMetricCard(
                title: "Current streak",
                value: "\(currentStreak) days",
                subtitle: streakResilienceMessage
            )
            IPadSummaryMetricCard(
                title: "This month",
                value: "\(monthlyCompletionCount)",
                subtitle: "logged observances",
                tint: .orange
            )
        }
        .accessibilityIdentifier("ipad.today.metrics")
    }

    var ipadTodayQuickActionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: "Do next",
                title: "Quick actions",
                detail: "Keep the next obligation and planning one tap away."
            )

            HStack(spacing: 10) {
                IPadWorkspaceActionButton(title: "Open Fasting Days", systemImage: "calendar", primary: true) {
                    focusFastingDaysOnUpcomingRequired()
                }
                IPadWorkspaceActionButton(title: "Open Planning", systemImage: "slider.horizontal.3", primary: false) {
                    homeSurface = .more
                    selectedMoreDestination = .profileAndNorms
                }
            }

            HStack(spacing: 10) {
                IPadWorkspaceActionButton(title: "Support & Premium", systemImage: "heart.circle", primary: false) {
                    homeSurface = .more
                    selectedMoreDestination = .supportAndPremium
                }
                IPadWorkspaceActionButton(title: "Read Voice Summary", systemImage: "speaker.wave.2", primary: false) {
                    #if canImport(AVFoundation)
                        let utterance = AVSpeechUtterance(string: voiceSummaryText)
                        utterance.rate = 0.5
                        AVSpeechSynthesizer().speak(utterance)
                    #endif
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
                eyebrow: "Planning",
                title: "Year and season snapshot",
                detail: "See progress without leaving the dashboard."
            )

            HStack(spacing: 10) {
                IPadSummaryMetricCard(title: "Required goal", value: "\(yearlyRequiredCompletions)/\(planningData.requiredGoal)", subtitle: "required days logged")
                IPadSummaryMetricCard(title: "Optional goal", value: "\(yearlyOptionalCompletions)/\(planningData.optionalGoal)", subtitle: "optional disciplines logged", tint: CatholicTheme.accent)
            }

            ProgressView(value: requirementGoalProgress)
                .tint(CatholicTheme.primary)
            ProgressView(value: optionalGoalProgress)
                .tint(CatholicTheme.accent)

            if currentSeasonCommitments.isEmpty {
                Text("No active commitments for \(currentLiturgicalSeason.label).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(currentSeasonCommitments.prefix(3)) { commitment in
                    Label(commitment.title, systemImage: "checkmark.circle")
                        .font(.caption)
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
                eyebrow: "Recovery",
                title: missedDayRecoveryPlan == nil ? "No urgent recovery" : "Recovery path ready",
                detail: monetizationStore.premiumUnlocked ? weeklyFormationRecapPremium : weeklyFormationRecapFree
            )

            if let recovery = missedDayRecoveryPlan {
                Text(recovery.titleLine)
                    .font(.headline)
                    .foregroundStyle(CatholicTheme.primary)
                Text(recovery.summaryLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(recovery.steps, id: \.self) { step in
                    Text("• \(step)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(recovery.nextRequiredLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Log recovery substitute today") {
                    logRecoverySubstituteForToday()
                }
                .appSecondaryButtonStyle()
                .disabled(!canLogRecoverySubstituteToday)
            } else {
                Text("No missed observance currently needs recovery. Protect the next required day now.")
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
                eyebrow: "Season",
                title: activeSeasonalContentPack.campaignTitle,
                detail: activeSeasonalContentPack.campaignSubtitle
            )

            Text(dailySeasonalFormationLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(activeSeasonalContentPack.formationLines.prefix(2), id: \.self) { line in
                    Text(line)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(CatholicTheme.parchment.opacity(0.92)))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(CatholicTheme.cardBorder.opacity(0.4), lineWidth: 1))
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
                eyebrow: "Transparency",
                title: regionContext.authorityLabel,
                detail: regionContext.disclosureText
            )

            Text(todayFoodDecision.sourceLine)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(regionContext.citations, id: \.self) { citation in
                    StatusTag(text: citation.authority.rawValue, color: CatholicTheme.primary)
                }
            }

            if !acceptedLegalNotice {
                Text("This remains an independent devotional app and not an official Church authority app.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.today.transparency")
    }
}
