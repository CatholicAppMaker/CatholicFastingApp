import SwiftUI
#if canImport(TipKit)
    import TipKit
#endif
#if canImport(AVFoundation)
    import AVFoundation
#endif

extension ContentView {
    var dashboardHeroArtwork: SacredHeroArtwork {
        SacredHeroImageSelector.artwork(for: .dashboard)
    }

    var fastingDaysHeroArtwork: SacredHeroArtwork {
        SacredHeroImageSelector.artwork(for: .fastingDays)
    }

    var dashboardFastingQuote: CatholicFastingQuote {
        dailySeasonalQuote
    }

    var fastingDaysFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.quote(for: .fastingDays)
    }

    var intermittentFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.quote(for: .intermittent)
    }

    var guidanceFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.quote(for: .guidance)
    }

    var planningProgressSection: some View {
        Section("Year Plan Snapshot") {
            Text("Required: \(yearlyRequiredCompletions)/\(planningData.requiredGoal) • Optional: \(yearlyOptionalCompletions)/\(planningData.optionalGoal)")
                .font(.subheadline)
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
    }

    var personalInsightsSection: some View {
        Section("Personal Insights (Local)") {
            Text("This month completions: \(monthlyCompletionCount)")
            Text("Recent intermittent hit-rate: \(intermittentHitRatePercent)%")
            Text("Current streak: \(currentStreak) day(s)")
        }
    }

    var accessibilitySupportSection: some View {
        Section("Accessibility Support") {
            if simplifiedModeEnabled {
                Text("Simplified mode is enabled.")
                    .foregroundStyle(CatholicTheme.primary)
            }
            if voiceSummaryEnabled {
                Button("Read Voice Summary") {
                    #if canImport(AVFoundation)
                        let utterance = AVSpeechUtterance(string: voiceSummaryText)
                        utterance.rate = 0.5
                        AVSpeechSynthesizer().speak(utterance)
                    #endif
                }
                .appSecondaryButtonStyle()
            }
        }
    }

    var unofficialAppNoticeSection: some View {
        Section("Important Notice") {
            Text(
                "This is an independent devotional app. It is not an official app of the Catholic Church, USCCB, the Vatican, or any diocese/parish."
            )
            .font(.subheadline)
            .foregroundStyle(CatholicTheme.primary)

            Text(
                "Always follow your pastor, local bishop, and legitimate Church authority when guidance differs."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("notice.unofficial")
        }
    }

    var setupProgressSection: some View {
        guard !isQuickSetupComplete else {
            return AnyView(EmptyView())
        }

        return AnyView(
            Section("Finish Setup") {
                Text("Complete these once for clearer, safer guidance.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Setup progress: \(setupChecklistCompleted)/\(setupChecklistTotal)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CatholicTheme.primary)
                    .accessibilityIdentifier("today.setup.progress")

                setupChecklistRow(
                    title: "Pastoral consent acknowledged",
                    isComplete: hasConfiguredConsent
                )
                setupChecklistRow(
                    title: "Region profile selected",
                    isComplete: hasConfiguredRegionProfile
                )
                setupChecklistRow(
                    title: "Reminder plan selected",
                    isComplete: hasConfiguredReminderPlan
                )

                Button("Open Quick Setup") {
                    homeSurface = .more
                }
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("today.setup.open_quick_setup")
            }
        )
    }

    var dashboardSacredImageSection: some View {
        let seasonalAssets = activeSeasonalContentPack.heroAssetNames
        let day = liturgicalCalendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let seasonalAsset = seasonalAssets.isEmpty ? dashboardHeroArtwork.assetName : seasonalAssets[(day - 1) % seasonalAssets.count]
        return Section {
            VStack(alignment: .leading, spacing: 10) {
                SacredHeroCard(
                    assetName: seasonalAsset,
                    title: activeSeasonalContentPack.campaignTitle,
                    subtitle: activeSeasonalContentPack.campaignSubtitle,
                    height: 210,
                    accessibilityIdentifier: "dashboard.sacred_image"
                )

                CatholicFastingQuoteCard(quote: dashboardFastingQuote, compact: true)
                    .accessibilityIdentifier("dashboard.fasting_quote")
                Text(dailySeasonalFormationLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var todayTenSecondSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                SacredHeroCard(
                    assetName: dashboardHeroArtwork.assetName,
                    title: "Today at a Glance",
                    subtitle: heroSummaryText,
                    height: 182,
                    accessibilityIdentifier: "dashboard.today_glance.hero"
                )

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        MetricTile(title: "Next", value: todayAtAGlanceNextLabel)
                        MetricTile(title: "Week", value: todayAtAGlanceWeekLabel)
                        MetricTile(title: "Streak", value: "\(currentStreak)d")
                    }
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            MetricTile(title: "Next", value: todayAtAGlanceNextLabel)
                            MetricTile(title: "Week", value: todayAtAGlanceWeekLabel)
                        }
                        MetricTile(title: "Streak", value: "\(currentStreak)d")
                    }
                }

                Text(monetizationStore.premiumUnlocked ? weeklyFormationRecapPremium : weeklyFormationRecapFree)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(streakResilienceMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityIdentifier("dashboard.today_glance")
        }
    }

    var dashboardDevotionalGallerySection: some View {
        Section("Sacred Fasting Imagery") {
            Text("Keep these Catholic symbols in view as you pray, abstain, and fast.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SacredImageryCatalog.fastingGallery) { item in
                        SacredImageryCard(item: item)
                    }
                }
                .padding(.vertical, 2)
            }
            .accessibilityIdentifier("dashboard.sacred_gallery")
        }
    }

    var readinessMarkers: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier("home.ready")
            Color.clear
                .frame(width: 1, height: 1)
                .accessibilityIdentifier(surfaceReadyIdentifier)
        }
    }

    var surfaceReadyIdentifier: String {
        switch homeSurface {
        case .today:
            "surface.today.ready"
        case .fastingDays:
            "surface.fasting_days.ready"
        case .intermittent:
            "surface.intermittent.ready"
        case .more:
            "surface.more.ready"
        }
    }

    var dashboardHeroSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Label("Daily Catholic Fasting Plan", systemImage: "cross.fill")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(CatholicTheme.primary)
                Text(heroSummaryText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Offer each observance with prayer, fasting, and charity.")
                    .font(.caption)
                    .foregroundStyle(CatholicTheme.primary.opacity(0.85))
                ProgressView(value: completionRateValue)
                    .tint(CatholicTheme.accent)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) {
                        MetricTile(title: "Required", value: "\(mandatoryObservanceCount)")
                        MetricTile(title: "Done", value: "\(completedCount)")
                        MetricTile(title: "Streak", value: "\(currentStreak)d")
                    }
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            MetricTile(title: "Required", value: "\(mandatoryObservanceCount)")
                            MetricTile(title: "Done", value: "\(completedCount)")
                        }
                        MetricTile(title: "Streak", value: "\(currentStreak)d")
                    }
                }
            }
            .accessibilityIdentifier("dashboard.hero")
            .padding(.vertical, 4)
            .padding(.horizontal, 6)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(CatholicTheme.accent.opacity(0.10))
            )
            .appRoundedGlass(cornerRadius: 12)
        }
    }

    var dashboardQuickActionsSection: some View {
        Section("Primary Actions") {
            Button {
                homeSurface = .fastingDays
            } label: {
                Label("Open Fasting Days", systemImage: "calendar")
            }
            .accessibilityIdentifier("today.quick.fasting_days")
            .appPrimaryButtonStyle()
            #if canImport(TipKit)
                .popoverTip(FastingDaysFocusTip(), arrowEdge: .top)
            #endif

            Button {
                homeSurface = .intermittent
            } label: {
                Label("Track Fast Now", systemImage: "timer")
            }
            .accessibilityIdentifier("today.quick.intermittent")
            .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)
            #if canImport(TipKit)
                .popoverTip(IntermittentTrackerTip(), arrowEdge: .top)
            #endif

            Button {
                homeSurface = .more
            } label: {
                Label("Open More Tools", systemImage: "ellipsis.circle")
            }
            .accessibilityIdentifier("today.quick.more")
            .appSecondaryButtonStyle()
            #if canImport(TipKit)
                .popoverTip(MoreToolsTip(), arrowEdge: .top)
            #endif
        }
    }

    var todayDecisionCardSection: some View {
        let decision = todayFoodDecision
        return Section("What Can I Eat Today?") {
            Text(decision.obligationLine)
                .font(.headline)
                .foregroundStyle(CatholicTheme.primary)
                .accessibilityIdentifier("today.decision.obligation")

            if !decision.allowed.isEmpty {
                Text("Okay today")
                    .font(.subheadline.weight(.semibold))
                ForEach(decision.allowed, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle")
                }
            }

            if !decision.avoid.isEmpty {
                Text("Avoid today")
                    .font(.subheadline.weight(.semibold))
                ForEach(decision.avoid, id: \.self) { item in
                    Label(item, systemImage: "xmark.circle")
                }
            }

            Text(decision.rationale)
                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 8) {
                Text("Common food questions")
                    .font(.subheadline.weight(.semibold))
                Label("Chicken and turkey count as meat.", systemImage: "xmark.circle")
                Label("Eggs, milk, butter, and cheese are generally permitted.", systemImage: "checkmark.circle")
                Label("Fish and shellfish are generally permitted.", systemImage: "checkmark.circle")
                Label(
                    "Broths and gravies may be technically permitted, but many Catholics still avoid them in stricter practice.",
                    systemImage: "questionmark.circle"
                )
                .foregroundStyle(.secondary)
            }
            .accessibilityIdentifier("today.decision.common_food_questions")

            NavigationLink {
                moreDestinationList(for: .guidanceAndRules)
            } label: {
                Label("Open full food guidance", systemImage: "book.closed")
            }
            .accessibilityIdentifier("today.decision.open_full_food_guidance")

            Text(decision.sourceLine)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Link(
                regionProfile == .canada
                    ? "Read CCCB Friday guidance"
                    : "Read official USCCB fast/abstinence guidance",
                destination: regionProfile == .canada ? UIConstants.cccbKeepingFridayURL : UIConstants.usccbFastAbstinenceURL
            )
        }
    }

    var todayRecoverySection: some View {
        guard let plan = missedDayRecoveryPlan else {
            return AnyView(EmptyView())
        }

        return AnyView(
            Section("Recovery Plan") {
                Text(plan.titleLine)
                    .font(.headline)
                    .foregroundStyle(CatholicTheme.primary)
                    .accessibilityIdentifier("today.recovery.title")
                Text(plan.summaryLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ForEach(plan.steps, id: \.self) { step in
                    Label(step, systemImage: "arrow.forward.circle")
                }
                Text(plan.nextRequiredLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Mark Today as Recovery Substitute") {
                    logRecoverySubstituteForToday()
                }
                .accessibilityIdentifier("today.recovery.mark_substitute")
                .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
                .disabled(!canLogRecoverySubstituteToday)

                Button("Focus Required Fasting Days") {
                    focusFastingDaysOnUpcomingRequired()
                }
                .accessibilityIdentifier("today.recovery.open_fasting_days")
                .appSecondaryButtonStyle()
            }
        )
    }

    var milestoneReferralSection: some View {
        guard currentStreak >= 3 else {
            return AnyView(EmptyView())
        }

        return AnyView(
            Section("Share With a Friend") {
                Text("You completed a \(currentStreak)-day streak. Share the app if it is helping.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ShareLink(
                    item:
                    "I have been using Catholic Fasting App for daily fasting guidance and tracking. It has helped me stay consistent.",
                    subject: Text("Catholic Fasting App")
                ) {
                    Label("Share App", systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
            }
        )
    }

    var dashboardSeasonSection: some View {
        Section("Liturgical Season") {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CatholicTheme.accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(CatholicTheme.seasonLabel)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(CatholicTheme.primary)
                    Text("Offer your fasting with the spirit of this season through prayer, sacrifice, and charity.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(CatholicTheme.accent.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1)
            )
            .appRoundedGlass(cornerRadius: 12)
        }
    }

    var dashboardHighlightsSection: some View {
        Section("Overview") {
            Text("Completion rate: \(completionRateText)")
                .foregroundStyle(CatholicTheme.primary)
            Text("Current streak: \(currentStreak) day(s)")
                .foregroundStyle(CatholicTheme.primary.opacity(0.9))
            if let next = upcomingMandatoryObservance {
                Text("Next required: \(next.title) • \(next.date.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundStyle(.red.opacity(0.85))
            } else {
                Text("No upcoming required observances this year.")
                    .foregroundStyle(.secondary)
            }
            Button("Open Fasting Days View") {
                homeSurface = .fastingDays
            }
            .accessibilityIdentifier("dashboard.open_fasting_days")
            .appPrimaryButtonStyle()
            Button("Focus Required (Next 30 Days)") {
                focusFastingDaysOnUpcomingRequired()
            }
            .accessibilityIdentifier("dashboard.focus_required")
            .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)
        }
    }

    var todaySimpleSummarySection: some View {
        Section("Today Summary") {
            Text("Completion rate: \(completionRateText)")
                .foregroundStyle(CatholicTheme.primary)
            Text("Current streak: \(currentStreak) day(s)")
                .foregroundStyle(CatholicTheme.primary.opacity(0.9))
            if let next = upcomingMandatoryObservance {
                Text("Next required: \(next.title) • \(next.date.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundStyle(.red.opacity(0.85))
            } else {
                Text("No upcoming required observances this year.")
                    .foregroundStyle(.secondary)
            }
            Button("Open Fasting Days") {
                homeSurface = .fastingDays
            }
            .appPrimaryButtonStyle()
            .accessibilityIdentifier("today.simple.open_fasting_days")
        }
    }

    private func setupChecklistRow(title: String, isComplete: Bool) -> some View {
        Label {
            Text(title)
        } icon: {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isComplete ? Color.green : Color.secondary)
        }
    }

    private var todayAtAGlanceNextLabel: String {
        if let next = upcomingMandatoryObservance {
            return next.date.formatted(.dateTime.month(.abbreviated).day())
        }
        return "Open"
    }

    private var todayAtAGlanceWeekLabel: String {
        "\(weeklyCompletedCount) / \(weeklyDisciplineGoal)"
    }

    private var weeklyCompletedCount: Int {
        weeklyCompletedObservancesCount
    }

    private var weeklyDisciplineGoal: Int {
        max(1, weeklyActionableObservances.count)
    }
}
