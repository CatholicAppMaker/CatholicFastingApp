import SwiftUI
#if canImport(TipKit)
import TipKit
#endif

extension ContentView {
    var dashboardHeroArtwork: SacredHeroArtwork {
        SacredHeroImageSelector.artwork(for: .dashboard)
    }

    var fastingDaysHeroArtwork: SacredHeroArtwork {
        SacredHeroImageSelector.artwork(for: .fastingDays)
    }

    var dashboardFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.seasonalQuote(
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: Date())
    }

    var fastingDaysFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.quote(
            for: .fastingDays,
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: Date())
    }

    var intermittentFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.quote(
            for: .intermittent,
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: Date())
    }

    var guidanceFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.quote(
            for: .guidance,
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: Date())
    }

    var planningProgressSection: some View {
        Section(localized("today.plan_snapshot.section", default: "Year Plan Snapshot")) {
            Text(
                localizedFormat(
                    "today.plan_snapshot.progress_format",
                    default: "Required: %d/%d • Optional: %d/%d",
                    yearlyRequiredCompletions,
                    planningData.requiredGoal,
                    yearlyOptionalCompletions,
                    planningData.optionalGoal))
                .font(.subheadline)
            ProgressView(value: requirementGoalProgress)
                .tint(CatholicTheme.primary)
            ProgressView(value: optionalGoalProgress)
                .tint(CatholicTheme.accent)
            if currentSeasonCommitments.isEmpty {
                Text(localizedFormat("today.plan_snapshot.empty_format", default: "No active commitments for %@.", localizedSeasonLabel(currentLiturgicalSeason)))
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
        Section(localized("today.insights.section", default: "Personal Insights (Local)")) {
            Text(localizedFormat("today.insights.completions_format", default: "This month completions: %d", monthlyCompletionCount))
            Text(localizedFormat("today.insights.hit_rate_format", default: "Recent intermittent hit-rate: %d%%", intermittentHitRatePercent))
            Text(localizedFormat("today.insights.streak_format", default: "Current streak: %d day(s)", currentStreak))
        }
    }

    var accessibilitySupportSection: some View {
        Section(localized("today.accessibility.section", default: "Accessibility Support")) {
            if simplifiedModeEnabled {
                Text(localized("today.accessibility.simplified_enabled", default: "Simplified mode is enabled."))
                    .foregroundStyle(CatholicTheme.primary)
            }
        }
    }

    var unofficialAppNoticeSection: some View {
        Section(localized("today.notice.section", default: "Important Notice")) {
            Text(
                localized(
                    "today.notice.independent",
                    default: "This is an independent devotional app. It is not an official app of the Catholic Church, USCCB, the Vatican, or any diocese/parish."))
                .font(.subheadline)
                .foregroundStyle(CatholicTheme.primary)

            Text(
                localized(
                    "today.notice.follow_authority",
                    default: "Always follow your pastor, local bishop, and legitimate Church authority when guidance differs."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("notice.unofficial")
        }
    }

    @ViewBuilder
    var setupProgressSection: some View {
        if !isQuickSetupComplete {
            Section(localized("today.setup.title", default: "Finish Setup")) {
                Text(localized("today.setup.intro", default: "Complete these once for clearer, safer guidance."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(localizedFormat("today.setup.progress_format", default: "Setup progress: %d/%d", setupChecklistCompleted, setupChecklistTotal))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CatholicTheme.primary)
                    .accessibilityIdentifier("today.setup.progress")

                setupChecklistRow(
                    title: localized("today.setup.consent", default: "Pastoral consent acknowledged"),
                    isComplete: hasConfiguredConsent)
                setupChecklistRow(
                    title: localized("today.setup.region", default: "Region profile selected"),
                    isComplete: hasConfiguredRegionProfile)
                setupChecklistRow(
                    title: localized("today.setup.reminders", default: "Reminder plan selected"),
                    isComplete: hasConfiguredReminderPlan)

                Button(localized("today.setup.open", default: "Open Quick Setup")) {
                    homeSurface = .more
                }
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("today.setup.open_quick_setup")
            }
        }
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
                    height: 168,
                    accessibilityIdentifier: "dashboard.sacred_image")
            }
        }
    }

    var todayTenSecondSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text(localized("today.glance.title", default: "Today at a Glance"))
                    .appEyebrowStyle()
                    .foregroundStyle(CatholicTheme.primary)

                HStack(spacing: 8) {
                    MetricTile(title: localized("today.metric.next", default: "Next"), value: todayAtAGlanceNextLabel)
                    MetricTile(title: localized("today.metric.week", default: "Week"), value: todayAtAGlanceWeekLabel)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(localized("today.metric.streak", default: "Streak"))
                        .appEyebrowStyle()
                    Text(localizedFormat("today.glance.streak_value_format", default: "%d day(s)", currentStreak))
                        .appSectionTitleStyle()
                    Text(streakResilienceMessage)
                        .appLeadTextStyle()
                    Text(monetizationStore.premiumUnlocked ? weeklyFormationRecapPremium : weeklyFormationRecapFree)
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

    var dashboardDevotionalGallerySection: some View {
        Section(localized("today.gallery.title", default: "Sacred Fasting Imagery")) {
            Text(localized("today.gallery.intro", default: "Keep these Catholic symbols in view as you pray, abstain, and fast."))
                .appSupportingTextStyle()

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
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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
                HStack(spacing: 8) {
                    Image(systemName: "cross.fill")
                        .appSymbolStyle(.standard)
                    Text(localized("today.hero.title", default: "Daily Catholic Fasting Plan"))
                        .appSectionTitleStyle(serif: true)
                }
                Text(heroSummaryText)
                    .appLeadTextStyle()
                Text(localized("today.hero.subtitle", default: "Offer each observance with prayer, fasting, and charity."))
                    .appSupportingTextStyle()
                    .foregroundStyle(.secondary)
                ProgressView(value: completionRateValue)
                    .tint(CatholicTheme.accent)
                Text(
                    localizedFormat(
                        "today.plan_snapshot.progress_format",
                        default: "Required: %d/%d • Optional: %d/%d",
                        yearlyRequiredCompletions,
                        planningData.requiredGoal,
                        yearlyOptionalCompletions,
                        planningData.optionalGoal))
                    .appSupportingTextStyle()
            }
            .accessibilityIdentifier("dashboard.hero")
            .padding(14)
            .appSurfaceCard(.standard, cornerRadius: 18)
        }
    }

    var dashboardQuickActionsSection: some View {
        Section(localized("today.actions.title", default: "Primary Actions")) {
            Button {
                homeSurface = .fastingDays
            } label: {
                Label(localized("today.actions.fasting_days", default: "Open Fasting Days"), systemImage: "calendar")
            }
            .accessibilityIdentifier("today.quick.fasting_days")
            .appPrimaryButtonStyle()
            #if canImport(TipKit)
                .popoverTip(FastingDaysFocusTip(), arrowEdge: .top)
            #endif

            Button {
                homeSurface = .intermittent
            } label: {
                Label(localized("today.actions.track_fast", default: "Track Fast Now"), systemImage: "timer")
            }
            .accessibilityIdentifier("today.quick.intermittent")
            .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)
            #if canImport(TipKit)
                .popoverTip(IntermittentTrackerTip(), arrowEdge: .top)
            #endif

            Button {
                homeSurface = .more
            } label: {
                Label(localized("today.actions.more", default: "Open More Tools"), systemImage: "ellipsis.circle")
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
        return Section {
            VStack(alignment: .leading, spacing: 14) {
                Text(decision.obligationLine)
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundStyle(CatholicTheme.primary)
                    .accessibilityIdentifier("today.decision.obligation")

                Text(decision.rationale)
                    .appSupportingTextStyle()

                if !decision.avoid.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localized("today.food.avoid", default: "Avoid today"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        ForEach(decision.avoid, id: \.self) { item in
                            Label(item, systemImage: "xmark.circle.fill")
                        }
                    }
                }

                if !decision.allowed.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localized("today.food.okay", default: "Okay today"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        ForEach(decision.allowed, id: \.self) { item in
                            Label(item, systemImage: "checkmark.circle.fill")
                        }
                    }
                }

                NavigationLink(value: MoreHubDestination.guidanceAndRules) {
                    Label(localized("today.food.open_guidance", default: "Open full food guidance"), systemImage: "book.closed")
                }
                .accessibilityIdentifier("today.decision.open_full_food_guidance")

                VStack(alignment: .leading, spacing: 8) {
                    Text(localized("today.food.common_questions", default: "Common food questions"))
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                    Label(localized("today.food.common.chicken", default: "Chicken and turkey count as meat."), systemImage: "xmark.circle")
                    Label(localized("today.food.common.dairy", default: "Eggs, milk, butter, and cheese are generally permitted."), systemImage: "checkmark.circle")
                    Label(localized("today.food.common.fish", default: "Fish and shellfish are generally permitted."), systemImage: "checkmark.circle")
                    Label(
                        localized("today.food.common.broth", default: "Broths and gravies may be technically permitted, but many Catholics still avoid them in stricter practice."),
                        systemImage: "questionmark.circle")
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)
                .accessibilityIdentifier("today.decision.common_food_questions")

                VStack(alignment: .leading, spacing: 6) {
                    Text(decision.sourceLine)
                        .appSupportingTextStyle()

                    Link(
                        regionProfile == .canada
                            ? localized("today.food.link.cccb", default: "Read CCCB Friday guidance")
                            : localized("today.food.link.usccb", default: "Read official USCCB fast/abstinence guidance"),
                        destination: regionProfile == .canada ? UIConstants.cccbKeepingFridayURL : UIConstants.usccbFastAbstinenceURL)
                        .font(.footnote.weight(.semibold))
                }
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)
            }
            .padding(14)
            .appSurfaceCard(.standard, cornerRadius: 20)
        }
    }

    @ViewBuilder
    var todayRecoverySection: some View {
        if let plan = missedDayRecoveryPlan {
            Section(localized("today.recovery.section", default: "Recovery Plan")) {
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

                Button(localized("today.recovery.mark", default: "Mark Today as Recovery Substitute")) {
                    logRecoverySubstituteForToday()
                }
                .accessibilityIdentifier("today.recovery.mark_substitute")
                .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
                .disabled(!canLogRecoverySubstituteToday)

                Button(localized("today.recovery.focus", default: "Focus Required Fasting Days")) {
                    focusFastingDaysOnUpcomingRequired()
                }
                .accessibilityIdentifier("today.recovery.open_fasting_days")
                .appSecondaryButtonStyle()
            }
        }
    }

    @ViewBuilder
    var milestoneReferralSection: some View {
        if currentStreak >= 3 {
            Section(localized("today.share.section", default: "Share With a Friend")) {
                Text(localizedFormat("today.share.intro_format", default: "You completed a %d-day streak. Share the app if it is helping.", currentStreak))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ShareLink(
                    item:
                    "I have been using Catholic Fasting App for daily fasting guidance and tracking. It has helped me stay consistent.",
                    subject: Text(localized("today.share.subject", default: "Catholic Fasting App")))
                {
                    Label(localized("today.share.button", default: "Share App"), systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
            }
        }
    }

    var dashboardSeasonSection: some View {
        Section(localized("today.season.section", default: "Liturgical Season")) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CatholicTheme.accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(localizedSeasonLabel(currentLiturgicalSeason))
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(CatholicTheme.primary)
                    Text(localized("today.season.intro", default: "Offer your fasting with the spirit of this season through prayer, sacrifice, and charity."))
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

    var dashboardHighlightsSection: some View {
        Section(localized("today.overview.section", default: "Overview")) {
            Text(localizedFormat("today.overview.completion_format", default: "Completion rate: %@", completionRateText))
                .foregroundStyle(CatholicTheme.primary)
            Text(localizedFormat("today.overview.streak_format", default: "Current streak: %d day(s)", currentStreak))
                .foregroundStyle(CatholicTheme.primary.opacity(0.9))
            if let next = upcomingMandatoryObservance {
                Text(
                    localizedFormat(
                        "today.overview.next_required_format",
                        default: "Next required: %@ • %@",
                        localizedObservanceTitle(next.title),
                        localizedAbbreviatedDate(next.date)))
                    .foregroundStyle(.red.opacity(0.85))
            } else {
                Text(localized("today.overview.none", default: "No upcoming required observances this year."))
                    .foregroundStyle(.secondary)
            }
            Button(localized("today.overview.open_view", default: "Open Fasting Days View")) {
                homeSurface = .fastingDays
            }
            .accessibilityIdentifier("dashboard.open_fasting_days")
            .appPrimaryButtonStyle()
            Button(localized("today.overview.focus_required", default: "Focus Required (Next 30 Days)")) {
                focusFastingDaysOnUpcomingRequired()
            }
            .accessibilityIdentifier("dashboard.focus_required")
            .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)
        }
    }

    var todaySimpleSummarySection: some View {
        Section(localized("today.summary.section", default: "Today Summary")) {
            Text(localizedFormat("today.overview.completion_format", default: "Completion rate: %@", completionRateText))
                .foregroundStyle(CatholicTheme.primary)
            Text(localizedFormat("today.overview.streak_format", default: "Current streak: %d day(s)", currentStreak))
                .foregroundStyle(CatholicTheme.primary.opacity(0.9))
            if let next = upcomingMandatoryObservance {
                Text(
                    localizedFormat(
                        "today.overview.next_required_format",
                        default: "Next required: %@ • %@",
                        localizedObservanceTitle(next.title),
                        localizedAbbreviatedDate(next.date)))
                    .foregroundStyle(.red.opacity(0.85))
            } else {
                Text(localized("today.overview.none", default: "No upcoming required observances this year."))
                    .foregroundStyle(.secondary)
            }
            Button(localized("today.actions.fasting_days", default: "Open Fasting Days")) {
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
            return localizedAbbreviatedDate(next.date)
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
        max(1, weeklyActionableObservanceCount)
    }
}
