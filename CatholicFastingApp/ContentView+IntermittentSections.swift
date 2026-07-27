import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private struct LiveTrackerMetricChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .appSurfaceCard(.utility, cornerRadius: 14)
    }
}

extension ContentView {
    func fireIntermittentTargetReachedHapticIfNeeded(start: Date) {
        guard hapticsEnabled else { return }
        let key = String(Int(start.timeIntervalSince1970))
        guard lastTargetReachedHapticKey != key else { return }
        lastTargetReachedHapticKey = key
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
    }

    func fireIntermittentEatingWindowClosedHapticIfNeeded(sessionID: String) {
        guard hapticsEnabled else { return }
        guard lastEatingWindowClosedHapticKey != sessionID else { return }
        lastEatingWindowClosedHapticKey = sessionID
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
        #endif
    }

    var intermittentHeroArtwork: SacredHeroArtwork {
        SacredHeroImageSelector.anchorArtwork(for: .intermittent)
    }

    var intermittentHeroSection: some View {
        Section {
            SacredSurfaceAnchorCard(
                assetName: intermittentHeroArtwork.assetName,
                title: intermittentTracker.activeStart == nil
                    ? localized("intermittent.hero.title_idle", default: "Fast")
                    : localized("intermittent.hero.title_active", default: "Fast in progress"),
                subtitle: intermittentTracker.activeStart == nil
                    ? localized("intermittent.hero.subtitle_idle", default: "Choose a target, then start when ready.")
                    : localized("intermittent.hero.subtitle_active", default: "Your live fast and next action are below."),
                imageHeight: 108,
                accessibilityIdentifier: "intermittent.hero")
        }
    }

    var intermittentOverviewSection: some View {
        Section(localized("intermittent.current_plan.title", default: "Current Plan")) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    MetricTile(
                        title: localized("intermittent.metric.sessions", default: "Sessions"),
                        value: "\(intermittentTracker.sessions.count)",
                        detail: localized("intermittent.metric.sessions.detail", default: "saved locally"))
                        .accessibilityIdentifier("intermittent.metric.sessions")
                        .accessibilityLabel(localized("intermittent.metric.sessions", default: "Sessions"))
                        .accessibilityValue("\(intermittentTracker.sessions.count)")
                    MetricTile(
                        title: localized("intermittent.metric.target", default: "Target"),
                        value: intermittentWindowLabel,
                        detail: localized("intermittent.metric.target.detail", default: "active fasting window"))
                    MetricTile(
                        title: localized("intermittent.metric.longest", default: "Longest"),
                        value: intermittentLongestSessionText,
                        detail: localized("intermittent.metric.longest.detail", default: "best recent duration"))
                }
                VStack(spacing: 8) {
                    HStack {
                        MetricTile(
                            title: localized("intermittent.metric.sessions", default: "Sessions"),
                            value: "\(intermittentTracker.sessions.count)",
                            detail: localized("intermittent.metric.sessions.detail", default: "saved locally"))
                            .accessibilityIdentifier("intermittent.metric.sessions")
                            .accessibilityLabel(localized("intermittent.metric.sessions", default: "Sessions"))
                            .accessibilityValue("\(intermittentTracker.sessions.count)")
                        MetricTile(
                            title: localized("intermittent.metric.target", default: "Target"),
                            value: intermittentWindowLabel,
                            detail: localized("intermittent.metric.target.detail", default: "active fasting window"))
                    }
                    MetricTile(
                        title: localized("intermittent.metric.longest", default: "Longest"),
                        value: intermittentLongestSessionText,
                        detail: localized("intermittent.metric.longest.detail", default: "best recent duration"))
                }
            }

            if let activeStart = intermittentTracker.activeStart {
                Text(localizedFormat("intermittent.current_plan.started_format", default: "Started %@", localizedAbbreviatedDateTime(activeStart)))
                    .appSupportingTextStyle()
                    .foregroundStyle(CatholicTheme.primary.opacity(0.9))
            } else if let latestSession = intermittentTracker.sessions.first {
                Text(localizedFormat("intermittent.current_plan.last_ended_format", default: "Last fast ended %@", localizedAbbreviatedDateTime(latestSession.end)))
                    .appSupportingTextStyle()
                Text(
                    latestSession.completedTarget
                        ? localized("intermittent.current_plan.completed_hint", default: "Repeat this rhythm or increase only if it remains prudent.")
                        : localized("intermittent.current_plan.missed_hint", default: "Choose a lighter target or re-enter with a simpler plan."))
                    .appSupportingTextStyle()
            } else {
                Text(localized("intermittent.current_plan.empty", default: "Your target and recent session summary will show here after the first fast."))
                    .appSupportingTextStyle()
            }

            intermittentHabitSummaryStrip
        }
    }

    private var intermittentHabitSummaryStrip: some View {
        let summary = intermittentHabitSummary
        return VStack(alignment: .leading, spacing: 10) {
            Text(localized("intermittent.rhythm.title", default: "Fasting rhythm"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    rhythmInsight(
                        title: localized("intermittent.rhythm.current_streak", default: "Current streak"),
                        value: localizedFormat("intermittent.rhythm.days_format", default: "%d day(s)", summary.currentStreakDays),
                        detail: localized("intermittent.rhythm.current_streak_detail", default: "steady continuity"))
                    rhythmInsight(
                        title: localized("intermittent.rhythm.weekly", default: "Weekly rhythm"),
                        value: "\(summary.weeklySessionCount)",
                        detail: localized("intermittent.rhythm.weekly_detail", default: "sessions this week"))
                    rhythmInsight(
                        title: localized("intermittent.rhythm.hit_rate", default: "Target met"),
                        value: "\(summary.targetHitPercent)%",
                        detail: localized("intermittent.rhythm.hit_rate_detail", default: "local history"))
                }
                VStack(spacing: 8) {
                    rhythmInsight(
                        title: localized("intermittent.rhythm.current_streak", default: "Current streak"),
                        value: localizedFormat("intermittent.rhythm.days_format", default: "%d day(s)", summary.currentStreakDays),
                        detail: localized("intermittent.rhythm.current_streak_detail", default: "steady continuity"))
                    rhythmInsight(
                        title: localized("intermittent.rhythm.weekly", default: "Weekly rhythm"),
                        value: "\(summary.weeklySessionCount)",
                        detail: localized("intermittent.rhythm.weekly_detail", default: "sessions this week"))
                    rhythmInsight(
                        title: localized("intermittent.rhythm.hit_rate", default: "Target met"),
                        value: "\(summary.targetHitPercent)%",
                        detail: localized("intermittent.rhythm.hit_rate_detail", default: "local history"))
                }
            }
            .accessibilityIdentifier("intermittent.rhythm_summary")
        }
    }

    private func rhythmInsight(title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .appEyebrowStyle()
                .textCase(.uppercase)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
            Text(detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(CatholicTheme.parchment.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(CatholicTheme.cardBorder.opacity(0.22), lineWidth: 1))
    }

    var intermittentControlCenterSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                intermittentControlCenterLiveState

                Divider()
                    .overlay(CatholicTheme.cardBorder.opacity(0.35))

                intermittentQuickTargetTiles
                intermittentCustomTargetControl
                intermittentStartTimeControl
                intermittentIntentionControl
                intermittentRecapNoteControl
                intermittentTargetReminderControl
            }
            .padding(4)
        } header: {
            HStack(alignment: .center, spacing: 12) {
                SacredIdentityThumbnail(
                    assetName: intermittentHeroArtwork.assetName,
                    statusSymbol: "cross.fill",
                    statusTint: CatholicTheme.primary,
                    imageSize: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(localized("intermittent.live.section", default: "Live Tracker"))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(CatholicTheme.primary)
                    Text(localized("intermittent.live.optional_practice", default: "Optional personal practice"))
                        .appEyebrowStyle()
                        .foregroundStyle(CatholicTheme.primary)
                        .textCase(nil)
                }
            }
            .textCase(nil)
        }
        .headerProminence(.increased)
    }

    private var intermittentQuickTargetTiles: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localized("intermittent.controls.quick_plan", default: "Quick Plan"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(localizedFormat("intermittent.controls.current_target_format", default: "Current target: %@", intermittentWindowLabel))
                        .appSupportingTextStyle()
                }
                Spacer(minLength: 0)
            }

            IntermittentFastQuickTargetGrid(
                options: intermittentQuickTargetOptions,
                selectedHours: intermittentPresetBinding,
                presentation: .phone,
                pickerIdentifier: "intermittent.target_picker",
                optionIdentifierPrefix: "intermittent.plan")
        }
    }

    @ViewBuilder
    private var intermittentCustomTargetControl: some View {
        if monetizationStore.premiumUnlocked {
            IntermittentFastCustomTargetStepper(
                targetHours: intermittentPresetBinding,
                title: localizedFormat(
                    "intermittent.controls.custom_target_format",
                    default: "Custom target: %dh",
                    intermittentTracker.presetHours),
                detail: localized(
                    "intermittent.controls.custom_target_hint",
                    default: "Longer disciplines remain available here (up to 14 days / 336h)."),
                presentation: .phone,
                accessibilityIdentifier: "intermittent.custom_target_stepper")
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(localized("intermittent.controls.premium_hint", default: "Custom targets beyond presets are part of Premium."))
                    .appSupportingTextStyle()
                Button(localized("intermittent.controls.unlock", default: "Unlock Custom Long Fasts")) {
                    openPremiumUpgrade(focusingOn: .planning)
                }
                .appSecondaryButtonStyle()
                .accessibilityIdentifier("intermittent.unlock_custom_targets")
            }
        }
    }

    private var intermittentStartTimeControl: some View {
        IntermittentFastStartTimeControl(
            label: localized("intermittent.controls.started", default: "Started"),
            hint: intermittentTracker.activeStart == nil
                ? localized(
                    "intermittent.controls.started_hint",
                    default: "If you already started, set the start time here before beginning the timer.")
                : localized(
                    "intermittent.controls.adjust_hint",
                    default: "Adjust the start time here if you began fasting earlier. The live tracker updates right away."),
            selection: intermittentTracker.activeStart == nil
                ? $intermittentManualStart
                : intermittentActiveStartBinding,
            allowedRange: intermittentManualStartRange,
            locale: contentLocale,
            accessibilityIdentifier: "intermittent.start_date")
    }

    private var intermittentIntentionControl: some View {
        IntermittentFastIntentionControl(
            label: localized("intermittent.controls.intention", default: "Intention"),
            options: intermittentIntentionOptions,
            selection: $intermittentIntentionRaw,
            detail: intermittentIntentionDetail,
            pickerIdentifier: "intermittent.intention_picker",
            detailIdentifier: "intermittent.intention_detail")
    }

    @ViewBuilder
    private var intermittentRecapNoteControl: some View {
        if intermittentTracker.activeStart != nil {
            VStack(alignment: .leading, spacing: 6) {
                Text(localized("intermittent.recap.note.label", default: "Review note"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                TextField(
                    localized("intermittent.recap.note.placeholder", default: "Optional note after this fast"),
                    text: $intermittentRecapNote,
                    axis: .vertical)
                    .lineLimit(2 ... 4)
                    .textInputAutocapitalization(.sentences)
                    .focused($intermittentRecapNoteFocused)
                    .accessibilityIdentifier("intermittent.recap_note")
                if intermittentRecapNoteFocused {
                    HStack {
                        Spacer()
                        Button(localized("common.done", default: "Done")) {
                            intermittentRecapNoteFocused = false
                        }
                        .accessibilityIdentifier("intermittent.recap_note.done")
                    }
                }
                Text(localized("intermittent.recap.note.hint", default: "Saved locally with the session when you end and review."))
                    .appSupportingTextStyle()
            }
        }
    }

    private var intermittentTargetReminderControl: some View {
        IntermittentFastReminderControl(
            isOn: $intermittentTargetReminderEnabled,
            label: localized("intermittent.reminder.target.label", default: "Target reminder"),
            hint: localized(
                "intermittent.reminder.target.hint",
                default: "Notify me calmly when this fast reaches its planned target."),
            accessibilityIdentifier: "intermittent.target_reminder",
            onChange: refreshIntermittentTargetReminder)
    }

    private var intermittentPrimaryActionControls: some View {
        IntermittentFastPrimaryActions(
            isActive: intermittentTracker.activeStart != nil,
            start: IntermittentFastActionDescriptor(
                title: localized("intermittent.controls.start_now", default: "Start Fast Now"),
                systemImage: "play.fill",
                accessibilityIdentifier: "intermittent.start_fast"),
            end: IntermittentFastActionDescriptor(
                title: localized("intermittent.controls.end_review", default: "End & Review"),
                systemImage: nil,
                accessibilityIdentifier: "intermittent.end_fast"),
            cancel: IntermittentFastActionDescriptor(
                title: localized("intermittent.controls.cancel", default: "Cancel"),
                systemImage: nil,
                accessibilityIdentifier: "intermittent.cancel_fast"),
            minimumHeight: 56,
            onStart: startIntermittentFastFromSelectedTime,
            onEnd: endIntermittentFastWithReview,
            onCancel: cancelIntermittentFast)
    }

    @ViewBuilder
    private var intermittentControlCenterLiveState: some View {
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
        VStack(alignment: .leading, spacing: 5) {
            Label(
                localized("intermittent.live.optional_practice", default: "Optional personal practice"),
                systemImage: "person.crop.circle.badge.checkmark")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)

            Text(
                localizedFormat(
                    "intermittent.live.intention_format",
                    default: "Intention: %@",
                    intermittentIntentionLabel(for: intermittentIntentionRaw)))
                .font(.subheadline.weight(.medium))

            Text(
                localized(
                    "intermittent.live.prudence",
                    default: "This tracker does not create a Church obligation. Stop or adjust the fast if you feel unwell, and seek medical or pastoral guidance when needed."))
                .appSupportingTextStyle()
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("intermittent.first_viewport_context")
    }

    private var intermittentUsesStackedLiveLayout: Bool {
        dynamicTypeSize.isAccessibilitySize || horizontalSizeClass == .compact
    }

    func intermittentRecapCard(
        recap: IntermittentFastSessionRecap,
        session: IntermittentFastSession) -> some View
    {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: recap.completedTarget ? "checkmark.seal.fill" : "arrow.clockwise.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(recap.completedTarget ? CatholicTheme.successForeground : CatholicTheme.warningForeground)
                VStack(alignment: .leading, spacing: 4) {
                    Text(recap.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CatholicTheme.primary)
                    Text(recap.encouragement)
                        .appSupportingTextStyle()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .layoutPriority(1)
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                recapMetric(
                    title: localized("intermittent.live.elapsed", default: "Elapsed"),
                    value: durationText(recap.duration))
                recapMetric(
                    title: localized("intermittent.live.target", default: "Target"),
                    value: localizedFormat("intermittent.live.target_value_format", default: "%dh fast", recap.targetHours))
                recapMetric(
                    title: localized("intermittent.controls.intention", default: "Intention"),
                    value: intermittentIntentionLabel(for: session.intentionID))
            }

            if let note = session.note, !note.isEmpty {
                Text(localizedFormat("intermittent.recap.note.saved_format", default: "Note: %@", note))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("intermittent.recap_note.saved")
            }

            Text(recap.suggestedNextAction)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .appSurfaceCard(.primary, cornerRadius: 16)
        .accessibilityValue(Text(session.note ?? ""))
        .accessibilityIdentifier("intermittent.recap_card")
    }

    private func recapMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .appEyebrowStyle()
                .textCase(.uppercase)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        let chips = Group {
            LiveTrackerMetricChip(
                title: localized("intermittent.live.elapsed", default: "Elapsed"),
                value: countdownText(elapsed))
                .accessibilityIdentifier("intermittent.active_elapsed")
            LiveTrackerMetricChip(
                title: localized("intermittent.live.target", default: "Target"),
                value: localizedFormat(
                    "intermittent.live.target_value_format",
                    default: "%dh fast",
                    intermittentTracker.presetHours))
            LiveTrackerMetricChip(
                title: localized("intermittent.live.next", default: "Next"),
                value: reached
                    ? localized("intermittent.live.next_end", default: "End when ready")
                    : localized("intermittent.live.next_continue", default: "Continue"))
        }

        return Group {
            if intermittentUsesStackedLiveLayout {
                VStack(spacing: 8) {
                    chips
                }
            } else {
                HStack(spacing: 8) {
                    chips
                }
            }
        }
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

        let chips = Group {
            LiveTrackerMetricChip(
                title: localized("intermittent.live.since_end", default: "Since End"),
                value: countdownText(elapsedSinceEnd))
            LiveTrackerMetricChip(
                title: localized("intermittent.live.last_fast", default: "Last Fast"),
                value: localizedFormat(
                    "intermittent.live.last_fast_value_format",
                    default: "%dh plan",
                    session.targetHours))
            LiveTrackerMetricChip(
                title: localized("intermittent.live.status", default: "Status"),
                value: statusText)
        }

        return Group {
            if intermittentUsesStackedLiveLayout {
                VStack(spacing: 8) {
                    chips
                }
            } else {
                HStack(spacing: 8) {
                    chips
                }
            }
        }
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
        Group {
            if intermittentUsesStackedLiveLayout {
                VStack(spacing: 8) {
                    readyMetricChips
                }
            } else {
                HStack(spacing: 8) {
                    readyMetricChips
                }
            }
        }
    }

    private var readyMetricChips: some View {
        Group {
            LiveTrackerMetricChip(
                title: localized("intermittent.live.target", default: "Target"),
                value: localizedFormat(
                    "intermittent.live.target_value_format",
                    default: "%dh fast",
                    intermittentTracker.presetHours))
            LiveTrackerMetricChip(
                title: localized("intermittent.live.next", default: "Next"),
                value: localized("intermittent.live.status_ready_anytime", default: "Ready anytime"))
        }
    }
}
