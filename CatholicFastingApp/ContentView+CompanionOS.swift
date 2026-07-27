import SwiftUI

extension ContentView {
    var companionSnapshot: CompanionSnapshot {
        CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: AppClock.now(),
            observances: rollingUpcomingObservances,
            settings: settings,
            statusesByID: tracker.statusesByID,
            activeFastStart: intermittentTracker.activeStart,
            activeFastTargetHours: intermittentTracker.presetHours,
            intermittentSessions: intermittentTracker.sessions,
            journeyWeek: premiumGuidedJourneyWeek,
            journeyProgress: premiumJourneyProgress,
            currentStreak: currentStreak,
            premiumUnlocked: monetizationStore.premiumUnlocked,
            calendar: liturgicalCalendar))
    }

    var companionDashboardSection: some View {
        Section {
            CompanionDashboardCard(
                snapshot: companionSnapshot,
                todayLabel: companionTodayLabel,
                nextRequiredLabel: companionNextRequiredLabel,
                seasonLabel: localizedSeasonLabel(currentLiturgicalSeason))
            {
                performCompanionAction(companionSnapshot.primaryAction)
            }
        }
    }

    var companionLiveStateSection: some View {
        Section {
            companionLiveStateCard
                .frame(maxWidth: .infinity, alignment: .leading)
                // List can under-measure conditional cards on iOS 26; keep the
                // action and metrics inside the first measured row.
                .frame(minHeight: 230, alignment: .topLeading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var companionFormationSection: some View {
        Section {
            CompanionFormationCard(formation: companionSnapshot.formation) {
                openCompanionFormation()
            }
        }
    }

    func companionIPadEditorialLayout(stacked: Bool) -> some View {
        Group {
            if stacked {
                VStack(alignment: .leading, spacing: 20) {
                    companionIPadDashboardCard
                    ipadTodayQuickActionsCard
                    SacredEditorialRule()
                    companionLiveStateCard
                    SacredEditorialRule()
                    companionIPadFormationCard
                }
            } else {
                HStack(alignment: .top, spacing: 24) {
                    VStack(alignment: .leading, spacing: 18) {
                        companionIPadDashboardCard
                        ipadTodayQuickActionsCard
                    }
                    .frame(maxWidth: .infinity, alignment: .top)

                    Rectangle()
                        .fill(CatholicTheme.primary.opacity(0.14))
                        .frame(width: 1)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 18) {
                        companionLiveStateCard
                        SacredEditorialRule()
                        companionIPadFormationCard
                    }
                    .frame(minWidth: 310, idealWidth: 340, maxWidth: 380, alignment: .top)
                }
            }
        }
    }

    var companionIPadDashboardCard: some View {
        CompanionDashboardCard(
            snapshot: companionSnapshot,
            todayLabel: companionTodayLabel,
            nextRequiredLabel: companionNextRequiredLabel,
            seasonLabel: localizedSeasonLabel(currentLiturgicalSeason),
            presentation: .workspace)
        {
            performCompanionAction(companionSnapshot.primaryAction)
        }
    }

    var companionIPadFormationCard: some View {
        CompanionFormationCard(formation: companionSnapshot.formation) {
            openCompanionFormation()
        }
    }

    @ViewBuilder
    var companionLiveStateCard: some View {
        switch companionSnapshot.liveFast.progress {
        case .active(_, let targetHours, let elapsed, let remaining, let progress, let stage):
            CompanionLiveStateCard(
                title: localized("companion.live.active.title", default: "Fast in progress"),
                detail: localized("companion.live.active.detail", default: "Elapsed, remaining, target, and intention stay together."),
                stageLabel: stage.label,
                progress: progress,
                metrics: [
                    CompanionCardMetric(title: localized("intermittent.live.elapsed", default: "Elapsed"), value: durationText(elapsed)),
                    CompanionCardMetric(title: localized("companion.live.remaining", default: "Remaining"), value: countdownText(remaining)),
                    CompanionCardMetric(title: localized("intermittent.live.target", default: "Target"), value: "\(targetHours)h"),
                    CompanionCardMetric(title: localized("intermittent.controls.intention", default: "Intention"), value: intermittentIntentionLabel),
                ],
                actionTitle: localized("companion.live.open_tracker", default: "Open Fast"),
                actionSystemImage: "timer")
            {
                homeSurface = .intermittent
            }
        case .targetReached(_, let targetHours, let elapsed, let progress, let stage):
            CompanionLiveStateCard(
                title: localized("companion.live.target_reached.title", default: "Target reached"),
                detail: localized("companion.live.target_reached.detail", default: "You can end the fast when ready and review the fruit."),
                stageLabel: stage.label,
                progress: progress,
                metrics: [
                    CompanionCardMetric(title: localized("intermittent.live.elapsed", default: "Elapsed"), value: durationText(elapsed)),
                    CompanionCardMetric(title: localized("intermittent.live.target", default: "Target"), value: "\(targetHours)h"),
                    CompanionCardMetric(title: localized("intermittent.live.next", default: "Next"), value: localized("intermittent.live.next_end", default: "End when ready")),
                    CompanionCardMetric(title: localized("intermittent.controls.intention", default: "Intention"), value: intermittentIntentionLabel),
                ],
                actionTitle: localized("companion.live.end_fast", default: "Open to End Fast"),
                actionSystemImage: "stop.fill")
            {
                homeSurface = .intermittent
            }
        case .completedRecap(let recap):
            CompanionLiveStateCard(
                title: recap.title,
                detail: recap.encouragement,
                stageLabel: FastStage.completed.label,
                progress: recap.completedTarget ? 1 : nil,
                metrics: [
                    CompanionCardMetric(title: localized("intermittent.live.elapsed", default: "Elapsed"), value: durationText(recap.duration)),
                    CompanionCardMetric(title: localized("intermittent.live.target", default: "Target"), value: "\(recap.targetHours)h"),
                    CompanionCardMetric(
                        title: localized("intermittent.live.status", default: "Status"),
                        value: recap.completedTarget
                            ? localized("fast.recap.status.completed", default: "Completed")
                            : localized("fast.recap.status.ended", default: "Ended")),
                    CompanionCardMetric(title: localized("intermittent.live.next", default: "Next"), value: localized("companion.live.recap_next", default: "Review")),
                ],
                actionTitle: localized("companion.live.review_recap", default: "Review Recap"),
                actionSystemImage: "checkmark.seal")
            {
                homeSurface = .intermittent
            }
        case .eatingWindow(let latestSession, let elapsedSinceEnd, let suggestedNextStart):
            CompanionLiveStateCard(
                title: localized("companion.live.eating_window.title", default: "Between fasts"),
                detail: suggestedNextStart.map {
                    localizedFormat(
                        "companion.live.eating_window.detail_format",
                        default: "Suggested next fast begins %@.",
                        localizedAbbreviatedDateTime($0))
                } ?? localized("companion.live.eating_window.detail", default: "Receive the fast and prepare the next one prudently."),
                stageLabel: FastStage.eatingWindow.label,
                progress: nil,
                metrics: [
                    CompanionCardMetric(
                        title: localized("intermittent.live.since_end", default: "Since End"),
                        value: durationText(elapsedSinceEnd)),
                    CompanionCardMetric(title: localized("intermittent.live.last_fast", default: "Last Fast"), value: durationText(latestSession.duration)),
                    CompanionCardMetric(title: localized("intermittent.live.target", default: "Target"), value: "\(latestSession.targetHours)h"),
                    CompanionCardMetric(
                        title: localized("intermittent.live.next", default: "Next"),
                        value: suggestedNextStart.map(localizedAbbreviatedDateTime)
                            ?? localized("intermittent.live.status_ready_anytime", default: "Ready anytime")),
                ],
                actionTitle: localized("companion.live.open_tracker", default: "Open Fast"),
                actionSystemImage: "timer")
            {
                homeSurface = .intermittent
            }
        case .inactive(let targetHours, _):
            CompanionInactiveFastCard(
                stageLabel: FastStage.ready.label,
                targetTitle: localized("intermittent.live.target", default: "Target"),
                targetValue: "\(targetHours)h",
                intentionTitle: localized("intermittent.controls.intention", default: "Intention"),
                intentionValue: intermittentIntentionLabel,
                actionTitle: localized("today.actions.track_fast", default: "Open Fast"),
                actionSystemImage: "play.fill")
            {
                homeSurface = .intermittent
            }
        }
    }

    private var companionTodayLabel: String {
        if let first = companionSnapshot.ruleDecision.todayTitles.first {
            return localizedObservanceTitle(first)
        }
        return localized("companion.today.clear", default: "No required day")
    }

    private var companionNextRequiredLabel: String {
        guard let next = companionSnapshot.nextRequiredObservance else {
            return localized("companion.next_required.none", default: "None ahead")
        }
        return localizedAbbreviatedDate(next.date)
    }

    func performCompanionAction(_ action: CompanionNextAction) {
        switch action.destination {
        case .today:
            homeSurface = .today
        case .fastingDays:
            focusFastingDaysOnUpcomingRequired()
        case .trackFast:
            homeSurface = .intermittent
        case .guidance:
            navigateToMoreDestination(.guidanceAndRules)
        case .setup:
            navigateToMoreDestination(.setupAndReminders)
        case .premium:
            navigateToMoreDestination(.supportAndPremium)
            supportPremiumSurfaceRaw = monetizationStore.premiumUnlocked
                ? SupportPremiumSurface.tools.rawValue
                : SupportPremiumSurface.upgrade.rawValue
        case .journal:
            navigateToMoreDestination(.supportAndPremium)
            supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue
            selectedPremiumToolDestination = .journal
        }
    }

    private func openCompanionFormation() {
        navigateToMoreDestination(.supportAndPremium)
        supportPremiumSurfaceRaw = monetizationStore.premiumUnlocked
            ? SupportPremiumSurface.tools.rawValue
            : SupportPremiumSurface.upgrade.rawValue
    }
}
