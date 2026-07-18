import SwiftUI

extension ContentView {
    var companionSnapshot: CompanionSnapshot {
        CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: Date(),
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
                nextRequiredLabel: companionNextRequiredLabel)
            {
                performCompanionAction(companionSnapshot.primaryAction)
            }
        }
    }

    var companionLiveStateSection: some View {
        Section {
            companionLiveStateCard
        }
    }

    var companionFormationSection: some View {
        Section {
            CompanionFormationCard(formation: companionSnapshot.formation) {
                openCompanionFormation()
            }
        }
    }

    func companionIPadTriad(stacked: Bool) -> some View {
        Group {
            if stacked {
                VStack(alignment: .leading, spacing: 20) {
                    companionIPadDashboardCard
                    companionLiveStateCard
                    companionIPadFormationCard
                }
            } else {
                HStack(alignment: .top, spacing: 20) {
                    companionIPadDashboardCard
                        .frame(maxWidth: .infinity, alignment: .top)

                    companionLiveStateCard
                        .frame(maxWidth: .infinity, alignment: .top)

                    companionIPadFormationCard
                        .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
    }

    func companionIPadEditorialLayout(stacked: Bool) -> some View {
        Group {
            if stacked {
                VStack(alignment: .leading, spacing: 24) {
                    companionIPadDashboardCard
                    ipadTodayQuickActionsCard
                    SacredEditorialRule()
                    companionLiveStateCard
                    SacredEditorialRule()
                    companionIPadFormationCard
                }
            } else {
                HStack(alignment: .top, spacing: 32) {
                    VStack(alignment: .leading, spacing: 20) {
                        companionIPadDashboardCard
                        ipadTodayQuickActionsCard
                    }
                        .frame(maxWidth: .infinity, alignment: .top)

                    VStack(alignment: .leading, spacing: 20) {
                        companionLiveStateCard
                        SacredEditorialRule()
                        companionIPadFormationCard
                    }
                    .frame(width: 360, alignment: .top)
                }
            }
        }
    }

    var companionIPadDashboardCard: some View {
        CompanionDashboardCard(
            snapshot: companionSnapshot,
            todayLabel: companionTodayLabel,
            nextRequiredLabel: companionNextRequiredLabel)
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
                actionTitle: localized("companion.live.open_tracker", default: "Open Track Fast"),
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
                actionTitle: localized("companion.live.open_tracker", default: "Open Track Fast"),
                actionSystemImage: "timer")
            {
                homeSurface = .intermittent
            }
        case .inactive(let targetHours, let latestSession):
            CompanionLiveStateCard(
                title: localized("companion.live.inactive.title", default: "Ready for the next fast"),
                detail: companionInactiveFastDetail(latestSession: latestSession),
                stageLabel: FastStage.ready.label,
                progress: nil,
                metrics: [
                    CompanionCardMetric(title: localized("intermittent.live.target", default: "Target"), value: "\(targetHours)h"),
                    CompanionCardMetric(
                        title: localized("intermittent.live.last_fast", default: "Last Fast"),
                        value: latestSession.map { durationText($0.duration) }
                            ?? localized("companion.live.none_yet", default: "None yet")),
                    CompanionCardMetric(title: localized("intermittent.controls.intention", default: "Intention"), value: intermittentIntentionLabel),
                    CompanionCardMetric(
                        title: localized("intermittent.live.next", default: "Next"),
                        value: localized("intermittent.live.status_ready_anytime", default: "Ready anytime")),
                ],
                actionTitle: localized("today.actions.track_fast", default: "Track Fast Now"),
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

    private func companionInactiveFastDetail(latestSession: IntermittentFastSession?) -> String {
        if latestSession == nil {
            return localized("companion.live.inactive.empty_detail", default: "Choose a target, set an intention, and start when ready.")
        }
        return localized("companion.live.inactive.detail", default: "Your last fast is saved locally. Repeat the rhythm only if it remains prudent.")
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
