import SwiftUI

extension ContentView {
    var fastingDaysHeroArtwork: SacredHeroArtwork {
        SacredHeroImageSelector.anchorArtwork(for: .fastingDays)
    }

    var dashboardFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.seasonalQuote(
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: AppClock.now())
    }

    var fastingDaysFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.quote(
            for: .fastingDays,
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: AppClock.now())
    }

    var intermittentFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.quote(
            for: .intermittent,
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: AppClock.now())
    }

    var guidanceFastingQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.quote(
            for: .guidance,
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: AppClock.now())
    }

    var planningProgressSection: some View {
        DashboardPlanningProgressSection(
            sectionTitle: localized("today.plan_snapshot.section", default: "Year Plan Snapshot"),
            progressSummary: localizedFormat(
                "today.plan_snapshot.progress_format",
                default: "Required: %d/%d • Optional: %d/%d",
                yearlyRequiredCompletions,
                planningSession.data.requiredGoal,
                yearlyOptionalCompletions,
                planningSession.data.optionalGoal),
            requiredProgress: requirementGoalProgress,
            optionalProgress: optionalGoalProgress,
            emptyCommitmentsText: currentSeasonCommitments.isEmpty
                ? localizedFormat(
                    "today.plan_snapshot.empty_format",
                    default: "No active commitments for %@.",
                    localizedSeasonLabel(currentLiturgicalSeason))
                : nil,
            commitments: currentSeasonCommitments.prefix(3).map { .init(id: $0.id, title: $0.title) })
    }

    var personalInsightsSection: some View {
        DashboardTextLinesSection(
            sectionTitle: localized("today.insights.section", default: "Personal Insights (Local)"),
            lines: [
                localizedFormat("today.insights.completions_format", default: "This month completions: %d", monthlyCompletionCount),
                localizedFormat("today.insights.hit_rate_format", default: "Recent intermittent hit-rate: %d%%", intermittentHitRatePercent),
                localizedFormat("today.insights.steady_days_format", default: "Current rhythm: %d day(s)", currentStreak),
            ])
    }

    var accessibilitySupportSection: some View {
        DashboardAccessibilitySupportSection(
            sectionTitle: localized("today.accessibility.section", default: "Accessibility Support"),
            simplifiedModeMessage: simplifiedModeEnabled
                ? localized("today.accessibility.simplified_enabled", default: "Simplified mode is enabled.")
                : nil)
    }

    var unofficialAppNoticeSection: some View {
        DashboardNoticeSection(
            sectionTitle: localized("today.notice.section", default: "Important Notice"),
            independentNotice: localized(
                "today.notice.independent",
                default: "This is an independent devotional app. It is not an official app of the Catholic Church, USCCB, the Vatican, or any diocese/parish."),
            authorityNotice: localized(
                "today.notice.follow_authority",
                default: "Always follow your pastor, local bishop, and legitimate Church authority when guidance differs."))
    }

    @ViewBuilder
    var setupProgressSection: some View {
        if !isQuickSetupComplete {
            DashboardSetupProgressSection(
                sectionTitle: localized("today.setup.title", default: "Finish Setup"),
                intro: localized("today.setup.intro", default: "Complete these once for clearer, safer guidance."),
                progress: localizedFormat(
                    "today.setup.progress_format",
                    default: "Setup checklist: %d/%d",
                    setupChecklistCompleted,
                    setupChecklistTotal),
                items: [
                    .init(
                        id: "consent",
                        title: localized("today.setup.consent", default: "Pastoral consent acknowledged"),
                        isComplete: hasConfiguredConsent),
                    .init(
                        id: "region",
                        title: localized("today.setup.region", default: "Region profile selected"),
                        isComplete: hasConfiguredRegionProfile),
                    .init(
                        id: "reminders",
                        title: localized("today.setup.reminders", default: "Reminder plan selected"),
                        isComplete: hasConfiguredReminderPlan),
                ],
                openTitle: localized("today.setup.open", default: "Open Quick Setup"),
                openSetup: { navigateToMoreDestination(.setupAndReminders) })
        }
    }

    var dashboardFastingQuoteSection: some View {
        DashboardQuoteSection(
            sectionTitle: localized("today.quote.section", default: "Daily fasting reflection"),
            quote: dashboardFastingQuote,
            accessibilityIdentifier: "dashboard.quote")
    }

    var fastingDaysFastingQuoteSection: some View {
        DashboardQuoteSection(
            sectionTitle: localized("fasting_days.quote.section", default: "Fasting reflection"),
            quote: fastingDaysFastingQuote,
            accessibilityIdentifier: "fasting_days.quote")
    }

    var intermittentFastingQuoteSection: some View {
        DashboardQuoteSection(
            sectionTitle: localized("intermittent.quote.section", default: "Fasting intention"),
            quote: intermittentFastingQuote,
            accessibilityIdentifier: "intermittent.quote")
    }

    var todayTenSecondSection: some View {
        TodayAtAGlanceSection(
            sectionTitle: localized("today.glance.title", default: "Today at a Glance"),
            nextTitle: localized("today.metric.next", default: "Next"),
            nextValue: todayAtAGlanceNextLabel,
            weekTitle: localized("today.metric.week", default: "Week"),
            weekValue: todayAtAGlanceWeekLabel,
            rhythmTitle: localized("today.metric.rhythm", default: "Current rhythm"),
            rhythmValue: localizedFormat("today.glance.rhythm_value_format", default: "%d day(s)", currentStreak),
            resilienceMessage: streakResilienceMessage,
            formationRecap: monetizationStore.premiumUnlocked ? weeklyFormationRecapPremium : weeklyFormationRecapFree)
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
        .accessibilityHidden(!isUITestMode)
    }

    var surfaceReadyIdentifier: String {
        switch navigationState.homeSurface {
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

    var isUITestMode: Bool {
        let processInfo = ProcessInfo.processInfo
        return processInfo.environment["UITEST_MODE"] == "1"
            || processInfo.arguments.contains("-uitest-reset")
            || processInfo.arguments.contains("-uitest-skip-onboarding")
            || processInfo.arguments.contains("-uitest-seed-deterministic")
            || processInfo.arguments.contains("-uitest-seed-missed")
            || processInfo.arguments.contains("-uitest-disable-animations")
    }

    var dashboardHeroSection: some View {
        DashboardHeroSection(
            title: localized("today.hero.title", default: "Daily Catholic Fasting Plan"),
            summary: heroSummaryText,
            subtitle: localized("today.hero.subtitle", default: "Offer each observance with prayer, fasting, and charity."),
            completionRate: completionRateValue,
            progressSummary: localizedFormat(
                "today.plan_snapshot.progress_format",
                default: "Required: %d/%d • Optional: %d/%d",
                yearlyRequiredCompletions,
                planningSession.data.requiredGoal,
                yearlyOptionalCompletions,
                planningSession.data.optionalGoal))
    }

    var todayDecisionCardSection: some View {
        let decision = todayFoodDecision
        let presentation = DailyFoodDecisionPresentation.presentation(for: decision.category)
        return TodayDecisionCardSection(
            eyebrow: localized("today.decision.eyebrow", default: "Today's fasting rule"),
            obligation: decision.obligationLine,
            rationale: decision.rationale,
            iconName: presentation.symbolName,
            tint: presentation.tone.foreground,
            nextActionTitle: localized("today.decision.next_action", default: "Next action"),
            nextAction: localized(
                presentation.nextActionLocalizationKey,
                default: presentation.nextActionDefaultValue),
            avoidTitle: localized("today.food.avoid", default: "Avoid today"),
            avoidItems: decision.avoid,
            allowedTitle: localized("today.food.okay", default: "Okay today"),
            allowedItems: decision.allowed,
            guidanceTitle: localized("today.food.open_guidance", default: "Open full food guidance"),
            commonQuestionsTitle: localized("today.food.common_questions", default: "Common food questions"),
            chickenAnswer: localized("today.food.common.chicken", default: "Chicken and turkey count as meat."),
            dairyAnswer: localized("today.food.common.dairy", default: "Eggs, milk, butter, and cheese are generally permitted."),
            fishAnswer: localized("today.food.common.fish", default: "Fish and shellfish are generally permitted."),
            brothAnswer: localized(
                "today.food.common.broth",
                default: "Broths and gravies may be technically permitted, but many Catholics still avoid them in stricter practice."),
            sourceLine: decision.sourceLine,
            sourceLinkTitle: regionProfile == .canada
                ? localized("today.food.link.cccb", default: "Read CCCB Friday guidance")
                : localized("today.food.link.usccb", default: "Read official USCCB fast/abstinence guidance"),
            sourceURL: regionProfile == .canada ? UIConstants.cccbKeepingFridayURL : UIConstants.usccbFastAbstinenceURL,
            openGuidance: { navigateToMoreDestination(.guidanceAndRules) })
    }

    @ViewBuilder
    var todayRecoverySection: some View {
        if let plan = missedDayRecoveryPlan {
            TodayRecoverySection(
                sectionTitle: localized("today.recovery.section", default: "Recovery Plan"),
                title: plan.titleLine,
                summary: plan.summaryLine,
                steps: plan.steps,
                nextRequired: plan.nextRequiredLine,
                markTitle: localized("today.recovery.mark", default: "Mark Today as Recovery Substitute"),
                canMark: canLogRecoverySubstituteToday,
                focusTitle: localized("today.recovery.focus", default: "Focus Required Days"),
                markRecovery: logRecoverySubstituteForToday,
                focusRequiredDays: focusFastingDaysOnUpcomingRequired)
        }
    }

    @ViewBuilder
    var milestoneReferralSection: some View {
        if yearlyRequiredCompletions >= 3 {
            DashboardReferralSection(
                sectionTitle: localized("today.share.section", default: "Share With a Friend"),
                introduction: localizedFormat(
                    "today.share.intro_format",
                    default: "You have completed %d required discipline days this year. Share the app if it is helping.",
                    yearlyRequiredCompletions),
                shareItem: localizedFormat(
                    "today.share.message_format",
                    default: "Catholic Fasting helps me stay steady with daily fasting guidance, planning, and tracking. Learn more: %@",
                    UIConstants.supportSiteURL.absoluteString),
                subject: localized("today.share.subject", default: "Catholic Fasting App"),
                buttonTitle: localized("today.share.button", default: "Share App"))
        }
    }

    var dashboardSeasonSection: some View {
        DashboardSeasonSection(
            sectionTitle: localized("today.season.section", default: "Liturgical Season"),
            season: localizedSeasonLabel(currentLiturgicalSeason),
            introduction: localized(
                "today.season.intro",
                default: "Offer your fasting with the spirit of this season through prayer, sacrifice, and charity."))
    }

    var dashboardHighlightsSection: some View {
        DashboardOverviewSection(
            sectionTitle: localized("today.overview.section", default: "Overview"),
            completionText: localizedFormat("today.overview.completion_format", default: "Completion rate: %@", completionRateText),
            rhythmText: localizedFormat("today.overview.rhythm_format", default: "Current rhythm: %d day(s)", currentStreak),
            nextRequiredText: dashboardNextRequiredText,
            hasUpcomingRequired: upcomingMandatoryObservance != nil,
            openTitle: localized("today.overview.open_view", default: "Open Calendar"),
            openIdentifier: "dashboard.open_fasting_days",
            focusTitle: localized("today.overview.focus_required", default: "Focus Required (Next 30 Days)"),
            openCalendar: { navigationState.homeSurface = .fastingDays },
            focusRequired: focusFastingDaysOnUpcomingRequired)
    }

    var todaySimpleSummarySection: some View {
        DashboardOverviewSection(
            sectionTitle: localized("today.summary.section", default: "Today Summary"),
            completionText: localizedFormat("today.overview.completion_format", default: "Completion rate: %@", completionRateText),
            rhythmText: localizedFormat("today.overview.rhythm_format", default: "Current rhythm: %d day(s)", currentStreak),
            nextRequiredText: dashboardNextRequiredText,
            hasUpcomingRequired: upcomingMandatoryObservance != nil,
            openTitle: localized("today.actions.fasting_days", default: "Open Calendar"),
            openIdentifier: "today.simple.open_fasting_days",
            focusTitle: nil,
            openCalendar: { navigationState.homeSurface = .fastingDays },
            focusRequired: nil)
    }

    private var dashboardNextRequiredText: String {
        guard let next = upcomingMandatoryObservance else {
            return localized("today.overview.none", default: "No upcoming required observances this year.")
        }
        return localizedFormat(
            "today.overview.next_required_format",
            default: "Next required: %@ • %@",
            localizedObservanceTitle(next.title),
            localizedAbbreviatedDate(next.date))
    }

    private var todayAtAGlanceNextLabel: String {
        if let next = upcomingMandatoryObservance {
            return localizedAbbreviatedDate(next.date)
        }
        return localized("common.open", default: "Open")
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
