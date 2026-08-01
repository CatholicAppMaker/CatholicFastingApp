import SwiftUI

extension ContentView {
    @ViewBuilder
    var intermittentControlCenterLiveState: some View {
        if let activeStart = intermittentTracker.activeStart {
            TimelineView(.periodic(from: .now, by: 1)) { _ in
                let now = AppClock.now()
                let start = intermittentTracker.activeStart ?? activeStart
                let targetSeconds = TimeInterval(intermittentTracker.presetHours * 3600)
                let elapsed = max(0, now.timeIntervalSince(start))
                let remaining = max(0, targetSeconds - elapsed)
                let overtime = max(0, elapsed - targetSeconds)
                let progress = min(1.0, elapsed / max(1, targetSeconds))
                let targetDate = start.addingTimeInterval(targetSeconds)

                VStack(alignment: .leading, spacing: 14) {
                    intermittentFastLiveHeader(
                        progress: progress,
                        countdown: countdownText(progress >= 1 ? overtime : remaining),
                        reached: progress >= 1,
                        start: start,
                        targetDate: targetDate)

                    intermittentPrimaryActionControls
                    intermittentFirstViewportContext

                    intermittentFastMetricChips(
                        elapsed: elapsed,
                        reached: progress >= 1)
                }
                .onChange(of: elapsed >= targetSeconds, initial: true) { _, reached in
                    if reached {
                        fireIntermittentTargetReachedHapticIfNeeded(start: start)
                    }
                }
            }
            .id(activeStart)
        } else if let latestSession = intermittentTracker.sessions.first {
            TimelineView(.periodic(from: .now, by: 60)) { _ in
                let now = AppClock.now()
                let recap = IntermittentFastSessionRecap.make(
                    session: latestSession,
                    hasMedicalDispensation: medicalDispensation)
                let endedRecently = now.timeIntervalSince(latestSession.end) <= 2 * 3600
                let lastEnded = latestSession.end
                let elapsedSinceEnd = max(0, now.timeIntervalSince(lastEnded))
                let eatingSeconds =
                    latestSession.targetHours <= 24
                        ? TimeInterval(max(0, 24 - latestSession.targetHours) * 3600) : 0
                let hasEatingWindow = eatingSeconds > 0
                let eatingRemaining = max(0, eatingSeconds - elapsedSinceEnd)
                let eatingProgress = hasEatingWindow ? min(1.0, elapsedSinceEnd / eatingSeconds) : 1
                let nextSuggestedStart = lastEnded.addingTimeInterval(eatingSeconds)

                VStack(alignment: .leading, spacing: 14) {
                    if endedRecently {
                        intermittentRecapCard(recap: recap, session: latestSession)
                    }

                    intermittentEatingLiveHeader(
                        progress: eatingProgress,
                        hasEatingWindow: hasEatingWindow,
                        countdown: hasEatingWindow
                            ? countdownText(eatingRemaining)
                            : localized("intermittent.live.ready", default: "Ready"),
                        lastEnded: lastEnded,
                        nextSuggestedStart: nextSuggestedStart)

                    intermittentPrimaryActionControls
                    intermittentFirstViewportContext

                    intermittentEatingMetricChips(
                        elapsedSinceEnd: elapsedSinceEnd,
                        session: latestSession,
                        hasEatingWindow: hasEatingWindow,
                        eatingRemaining: eatingRemaining)
                }
                .onChange(
                    of: hasEatingWindow && eatingRemaining <= 0,
                    initial: true)
                { _, closed in
                    if closed {
                        fireIntermittentEatingWindowClosedHapticIfNeeded(sessionID: latestSession.id)
                    }
                }
            }
            .id(latestSession.id)
        } else {
            VStack(alignment: .leading, spacing: 14) {
                intermittentReadyLiveHeader
                intermittentPrimaryActionControls
                intermittentFirstViewportContext
                intermittentReadyMetricChips
            }
        }
    }

    var intermittentFirstViewportContext: some View {
        IntermittentFastFirstViewportContext(
            optionalPracticeLabel: localized(
                "intermittent.live.optional_practice",
                default: "Optional personal practice"),
            intentionText: localizedFormat(
                "intermittent.live.intention_format",
                default: "Intention: %@",
                intermittentIntentionLabel(for: intermittentIntentionRaw)),
            prudenceText: localized(
                "intermittent.live.prudence",
                default: "This tracker does not create a Church obligation. Stop or adjust the fast if you feel unwell, and seek medical or pastoral guidance when needed."))
    }

    private var intermittentUsesStackedLiveLayout: Bool {
        dynamicTypeSize.isAccessibilitySize || horizontalSizeClass == .compact
    }

    func intermittentRecapCard(
        recap: IntermittentFastSessionRecap,
        session: IntermittentFastSession) -> some View
    {
        IntermittentFastSessionRecapView(
            recap: recap,
            session: session,
            elapsedTitle: localized("intermittent.live.elapsed", default: "Elapsed"),
            elapsedValue: durationText(recap.duration),
            targetTitle: localized("intermittent.live.target", default: "Target"),
            targetValue: localizedFormat(
                "intermittent.live.target_value_format",
                default: "%dh fast",
                recap.targetHours),
            intentionTitle: localized("intermittent.controls.intention", default: "Intention"),
            intentionValue: intermittentIntentionLabel(for: session.intentionID),
            savedNoteText: session.note.flatMap { note in
                note.isEmpty
                    ? nil
                    : localizedFormat("intermittent.recap.note.saved_format", default: "Note: %@", note)
            })
    }

    private func intermittentFastLiveHeader(
        progress: Double,
        countdown: String,
        reached: Bool,
        start: Date,
        targetDate: Date) -> some View
    {
        Group {
            if intermittentUsesStackedLiveLayout {
                VStack(alignment: .center, spacing: 14) {
                    liveFastRing(progress: progress, reached: reached, countdown: countdown)
                    liveFastSummary(reached: reached, start: start, targetDate: targetDate)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                HStack(alignment: .center, spacing: 16) {
                    liveFastRing(progress: progress, reached: reached, countdown: countdown)
                    liveFastSummary(reached: reached, start: start, targetDate: targetDate)
                }
            }
        }
    }

    private func intermittentFastMetricChips(elapsed: TimeInterval, reached: Bool) -> some View {
        IntermittentFastMetricGrid(
            metrics: [
                IntermittentFastMetricValue(
                    id: "elapsed",
                    title: localized("intermittent.live.elapsed", default: "Elapsed"),
                    value: countdownText(elapsed),
                    accessibilityIdentifier: "intermittent.active_elapsed"),
                IntermittentFastMetricValue(
                    id: "target",
                    title: localized("intermittent.live.target", default: "Target"),
                    value: localizedFormat(
                        "intermittent.live.target_value_format",
                        default: "%dh fast",
                        intermittentTracker.presetHours)),
                IntermittentFastMetricValue(
                    id: "next",
                    title: localized("intermittent.live.next", default: "Next"),
                    value: reached
                        ? localized("intermittent.live.next_end", default: "End when ready")
                        : localized("intermittent.live.next_continue", default: "Continue")),
            ],
            stacked: intermittentUsesStackedLiveLayout)
    }

    private func intermittentEatingLiveHeader(
        progress: Double,
        hasEatingWindow: Bool,
        countdown: String,
        lastEnded: Date,
        nextSuggestedStart: Date) -> some View
    {
        Group {
            if intermittentUsesStackedLiveLayout {
                VStack(alignment: .center, spacing: 14) {
                    liveEatingRing(progress: progress, hasEatingWindow: hasEatingWindow, countdown: countdown)
                    liveEatingSummary(
                        hasEatingWindow: hasEatingWindow,
                        lastEnded: lastEnded,
                        nextSuggestedStart: nextSuggestedStart)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                HStack(alignment: .center, spacing: 16) {
                    liveEatingRing(progress: progress, hasEatingWindow: hasEatingWindow, countdown: countdown)
                    liveEatingSummary(
                        hasEatingWindow: hasEatingWindow,
                        lastEnded: lastEnded,
                        nextSuggestedStart: nextSuggestedStart)
                }
            }
        }
    }

    private func intermittentEatingMetricChips(
        elapsedSinceEnd: TimeInterval,
        session: IntermittentFastSession,
        hasEatingWindow: Bool,
        eatingRemaining: TimeInterval) -> some View
    {
        let statusText = hasEatingWindow
            ? (
                eatingRemaining > 0
                    ? localized("intermittent.live.status_eating_window_open", default: "Eating window open")
                    : localized("intermittent.live.status_ready_to_fast", default: "Ready to fast"))
            : localized("intermittent.live.status_ready_anytime", default: "Ready anytime")

        return IntermittentFastMetricGrid(
            metrics: [
                IntermittentFastMetricValue(
                    id: "since-end",
                    title: localized("intermittent.live.since_end", default: "Since End"),
                    value: countdownText(elapsedSinceEnd)),
                IntermittentFastMetricValue(
                    id: "last-fast",
                    title: localized("intermittent.live.last_fast", default: "Last Fast"),
                    value: localizedFormat(
                        "intermittent.live.last_fast_value_format",
                        default: "%dh plan",
                        session.targetHours)),
                IntermittentFastMetricValue(
                    id: "status",
                    title: localized("intermittent.live.status", default: "Status"),
                    value: statusText),
            ],
            stacked: intermittentUsesStackedLiveLayout)
    }

    private var intermittentReadyLiveHeader: some View {
        VStack(alignment: .center, spacing: 14) {
            liveEatingRing(
                progress: 1,
                hasEatingWindow: false,
                countdown: localized("intermittent.live.ready", default: "Ready"))
            VStack(alignment: .leading, spacing: 8) {
                Text(localized("intermittent.live.no_active", default: "No active fast"))
                    .appSectionTitleStyle()
                    .accessibilityIdentifier("intermittent.no_active")
                Text(localized("intermittent.live.no_active_detail", default: "Pick a target below, adjust the start time if you already began, and start when ready."))
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var intermittentReadyMetricChips: some View {
        IntermittentFastMetricGrid(
            metrics: [
                IntermittentFastMetricValue(
                    id: "target",
                    title: localized("intermittent.live.target", default: "Target"),
                    value: localizedFormat(
                        "intermittent.live.target_value_format",
                        default: "%dh fast",
                        intermittentTracker.presetHours)),
                IntermittentFastMetricValue(
                    id: "next",
                    title: localized("intermittent.live.next", default: "Next"),
                    value: localized("intermittent.live.status_ready_anytime", default: "Ready anytime")),
            ],
            stacked: intermittentUsesStackedLiveLayout)
    }
}
