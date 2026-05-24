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
                .appEyebrowStyle()
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

struct FastingIntentionOption: Identifiable {
    let id: String
    let label: String
    let detail: String
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
                    ? localized("intermittent.hero.title_idle", default: "Track Fast")
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
        }
    }

    var intermittentControlCenterSection: some View {
        Section(localized("intermittent.live.section", default: "Live Tracker")) {
            VStack(alignment: .leading, spacing: 16) {
                intermittentControlCenterLiveState
                intermittentPrimaryActionControls

                Divider()
                    .overlay(CatholicTheme.cardBorder.opacity(0.35))

                intermittentQuickTargetTiles
                intermittentCustomTargetControl
                intermittentStartTimeControl
                intermittentIntentionControl
            }
            .padding(4)
        }
    }

    private var intermittentQuickTargetTiles: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localized("intermittent.controls.quick_plan", default: "Quick Plan"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(localizedFormat("intermittent.controls.current_target_format", default: "Current target: %@", intermittentWindowLabel))
                        .appSupportingTextStyle()
                }
                Spacer(minLength: 0)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8)], spacing: 8) {
                ForEach([12, 14, 16, 18, 20, 24, 36], id: \.self) { hours in
                    Button {
                        intermittentPresetBinding.wrappedValue = hours
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(localizedFormat("ipad.intermittent.plan_hours_format", default: "%dh", hours))
                                .font(.system(.headline, design: .rounded).weight(.semibold))
                            Text(intermittentPlanDescription(hours))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
                        .appInteractiveTileStyle(isSelected: intermittentTracker.presetHours == hours, cornerRadius: 14)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("intermittent.plan.\(hours)")
                    .appSelectedAccessibility(intermittentTracker.presetHours == hours)
                }
            }
            .accessibilityIdentifier("intermittent.target_picker")
        }
    }

    @ViewBuilder
    private var intermittentCustomTargetControl: some View {
        if monetizationStore.premiumUnlocked {
            Stepper(value: intermittentPresetBinding, in: 12 ... 336, step: 1) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedFormat("intermittent.controls.custom_target_format", default: "Custom target: %dh", intermittentTracker.presetHours))
                    Text(localized("intermittent.controls.custom_target_hint", default: "Longer disciplines remain available here (up to 14 days / 336h)."))
                        .appEyebrowStyle()
                }
            }
            .accessibilityIdentifier("intermittent.custom_target_stepper")
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
        VStack(alignment: .leading, spacing: 6) {
            DatePicker(
                localized("intermittent.controls.started", default: "Started"),
                selection: intermittentTracker.activeStart == nil ? $intermittentManualStart : intermittentActiveStartBinding,
                in: intermittentManualStartRange,
                displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .environment(\.locale, contentLocale)
                .accessibilityIdentifier("intermittent.start_date")

            Text(
                intermittentTracker.activeStart == nil
                    ? localized("intermittent.controls.started_hint", default: "If you already started, set the start time here before beginning the timer.")
                    : localized("intermittent.controls.adjust_hint", default: "Adjust the start time here if you began fasting earlier. The live tracker updates right away."))
                .appSupportingTextStyle()
        }
    }

    private var intermittentIntentionControl: some View {
        VStack(alignment: .leading, spacing: 6) {
            Picker(localized("intermittent.controls.intention", default: "Intention"), selection: $intermittentIntentionRaw) {
                ForEach(intermittentIntentionOptions) { option in
                    Text(option.label).tag(option.id)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("intermittent.intention_picker")

            Text(intermittentIntentionDetail)
                .appSupportingTextStyle()
                .accessibilityIdentifier("intermittent.intention_detail")
        }
    }

    @ViewBuilder
    private var intermittentPrimaryActionControls: some View {
        if intermittentTracker.activeStart == nil {
            Button {
                startIntermittentFastFromSelectedTime()
            } label: {
                Label(localized("intermittent.controls.start_now", default: "Start Fast Now"), systemImage: "play.fill")
            }
            .appPrimaryButtonStyle()
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 56)
            .accessibilityIdentifier("intermittent.start_fast")
        } else {
            HStack(spacing: 10) {
                Button {
                    intermittentTracker.endFast(intentionID: intermittentIntentionRaw)
                    resetIntermittentManualStartToNow()
                } label: {
                    Label(localized("intermittent.controls.end", default: "End Fast"), systemImage: "stop.fill")
                }
                .appPrimaryButtonStyle(legacyTint: .green)
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 56)
                .accessibilityIdentifier("intermittent.end_fast")

                Button {
                    intermittentTracker.cancelActiveFast()
                    resetIntermittentManualStartToNow()
                } label: {
                    Label(localized("intermittent.controls.cancel", default: "Cancel"), systemImage: "xmark")
                }
                .appSecondaryButtonStyle()
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 56)
                .accessibilityIdentifier("intermittent.cancel_fast")
            }
        }
    }

    @ViewBuilder
    private var intermittentControlCenterLiveState: some View {
        if let activeStart = intermittentTracker.activeStart {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let now = context.date
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
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let now = context.date
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
                    intermittentEatingLiveHeader(
                        progress: eatingProgress,
                        hasEatingWindow: hasEatingWindow,
                        countdown: hasEatingWindow
                            ? countdownText(eatingRemaining)
                            : localized("intermittent.live.ready", default: "Ready"),
                        lastEnded: lastEnded,
                        nextSuggestedStart: nextSuggestedStart)

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
                intermittentReadyMetricChips
            }
        }
    }

    private var intermittentUsesStackedLiveLayout: Bool {
        dynamicTypeSize.isAccessibilitySize || horizontalSizeClass == .compact
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
                    .appLeadTextStyle()
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

    private var liveTrackerRingSize: CGFloat {
        if dynamicTypeSize.isAccessibilitySize {
            return 172
        }
        return horizontalSizeClass == .regular ? 204 : 178
    }

    private var liveTrackerRingStroke: CGFloat {
        horizontalSizeClass == .regular ? 16 : 14
    }

    private var liveTrackerCountdownFontSize: CGFloat {
        horizontalSizeClass == .regular ? 30 : 25
    }

    private var liveTrackerLabelFont: Font {
        horizontalSizeClass == .regular
            ? .caption.weight(.semibold)
            : .caption2.weight(.semibold)
    }

    private var liveTrackerSummaryTitleFont: Font {
        horizontalSizeClass == .regular
            ? .title3.weight(.semibold)
            : .headline.weight(.semibold)
    }

    private var liveTrackerSummaryDetailFont: Font {
        horizontalSizeClass == .regular ? .subheadline : .caption
    }

    private var liveTrackerInstructionFont: Font {
        horizontalSizeClass == .regular ? .subheadline.weight(.semibold) : .caption.weight(.semibold)
    }

    var intermittentAdvancedToolsSection: some View {
        Section(localized("intermittent.advanced.title", default: "Advanced Tools")) {
            Button {
                intermittentShowAdvanced.toggle()
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localized("intermittent.advanced.label_title", default: "Schedules, milestones, recovery, and history"))
                            .font(.subheadline.weight(.semibold))
                        Text(localized("intermittent.advanced.label_detail", default: "Keep the live tracker first and open these only when you need deeper tools."))
                            .appSupportingTextStyle()
                    }
                    Spacer(minLength: 8)
                    Image(systemName: intermittentShowAdvanced ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CatholicTheme.primary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("intermittent.advanced.disclosure")

            if intermittentShowAdvanced {
                VStack(alignment: .leading, spacing: 0) {
                    intermittentScheduleSection
                    intermittentMilestonesSection
                    intermittentRecoverySection
                    intermittentSessionHistorySection
                }
            }

            if !intermittentShowAdvanced {
                Text(localized("intermittent.advanced.collapsed_hint", default: "Saved schedules, milestone stats, recovery guidance, and recent history stay tucked away here."))
                    .appSupportingTextStyle()
            }
        }
    }

    var intermittentScheduleSection: some View {
        Section(localized("intermittent.schedules.section", default: "Custom Schedules")) {
            Text(localized("intermittent.schedules.intro", default: "Save reusable plans locally on this device."))
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(localized("intermittent.schedules.name_placeholder", default: "Schedule name (optional)"), text: $newIntermittentScheduleName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .accessibilityIdentifier("intermittent.schedule.name")

            Stepper(
                localizedFormat(
                    "intermittent.schedules.start_hour_format",
                    default: "Start hour: %@",
                    String(format: "%02d:00", newIntermittentScheduleStartHour)),
                value: $newIntermittentScheduleStartHour,
                in: 0 ... 23)
                .accessibilityIdentifier("intermittent.schedule.start_hour")

            VStack(alignment: .leading, spacing: 8) {
                Text(localized("intermittent.schedules.days", default: "Days"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    ForEach(1 ... 7, id: \.self) { weekday in
                        let selected = newIntermittentScheduleWeekdays.contains(weekday)
                        Button(weekdayLabel(for: weekday)) {
                            toggleIntermittentScheduleWeekday(weekday)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(selected ? CatholicTheme.primary : .gray.opacity(0.35))
                    }
                }
            }
            .accessibilityIdentifier("intermittent.schedule.weekdays")

            if intermittentSchedules.isEmpty {
                Text(localized("intermittent.schedules.empty", default: "No saved schedules yet."))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(intermittentSchedules) { plan in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(plan.name)
                                    .font(.subheadline.weight(.semibold))
                                if activeIntermittentScheduleID == plan.id {
                                    Text(localized("intermittent.schedules.applied", default: "Applied"))
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(CatholicTheme.primary))
                                }
                            }
                            Text(
                                localizedFormat(
                                    "intermittent.schedules.plan_summary_format",
                                    default: "Target %dh • Start %@ • Days %@",
                                    plan.targetHours,
                                    String(format: "%02d:00", plan.startHour),
                                    weekdayListText(plan.weekdays)))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            Button(localized("intermittent.schedules.use", default: "Use")) {
                                Task {
                                    await applyIntermittentSchedule(plan)
                                }
                            }
                            .appSecondaryButtonStyle()

                            Button(localized("intermittent.schedules.edit", default: "Edit")) {
                                startEditingIntermittentSchedule(plan)
                            }
                            .appSecondaryButtonStyle(legacyTint: CatholicTheme.accentForeground)

                            Button(localized("intermittent.schedules.delete", default: "Delete"), role: .destructive) {
                                deleteIntermittentSchedule(plan)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            if !notificationStatus.isEmpty {
                Text(notificationStatus)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button(
                    isEditingIntermittentSchedule
                        ? localized("intermittent.schedules.update", default: "Update Schedule")
                        : localized("intermittent.schedules.save_current", default: "Save Current Plan as Schedule"))
                {
                    addOrUpdateIntermittentSchedulePlan()
                }
                .appPrimaryButtonStyle()
                .disabled(!canSaveIntermittentSchedule)
                .accessibilityIdentifier("intermittent.schedule.add")

                if isEditingIntermittentSchedule {
                    Button(localized("intermittent.schedules.cancel_edit", default: "Cancel Edit")) {
                        cancelEditingIntermittentSchedule()
                    }
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("intermittent.schedule.cancel_edit")
                }
            }
        }
    }

    var intermittentMilestonesSection: some View {
        Section(localized("intermittent.milestones.section", default: "Milestones")) {
            let total = intermittentTracker.sessions.count
            let completedTargets = intermittentTracker.sessions.filter(\.completedTarget).count
            let longestHours = Int((intermittentTracker.sessions.map(\.duration).max() ?? 0) / 3600)

            Text(localizedFormat("intermittent.milestones.sessions_format", default: "Sessions completed: %d", total))
            Text(localizedFormat("intermittent.milestones.targets_format", default: "Targets achieved: %d", completedTargets))
            Text(localizedFormat("intermittent.milestones.longest_format", default: "Longest fast: %d hour(s)", longestHours))
            Text(localizedFormat("intermittent.milestones.hit_rate_format", default: "Recent hit rate: %d%%", intermittentHitRatePercent))
                .foregroundStyle(.secondary)
        }
    }

    var intermittentRecoverySection: some View {
        Section(localized("intermittent.recovery.section", default: "Recovery Guidance")) {
            if intermittentTracker.activeStart == nil, let latest = intermittentTracker.sessions.first, !latest.completedTarget {
                Text(localized("intermittent.recovery.below_target", default: "Your latest session ended below target. Consider a lighter target and hydrate well."))
                    .foregroundStyle(CatholicTheme.warningForeground)
            } else {
                Text(localized("intermittent.recovery.none", default: "No immediate recovery actions needed."))
                    .foregroundStyle(.secondary)
            }
            Text(localized("intermittent.recovery.guidance", default: "Adjust fast length when health, duty, or pastoral guidance requires."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    func liveFastRing(progress: Double, reached: Bool, countdown: String) -> some View {
        ZStack {
            Circle()
                .stroke(CatholicTheme.cardBorder.opacity(0.3), lineWidth: liveTrackerRingStroke)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    reached ? .green : CatholicTheme.accent,
                    style: StrokeStyle(lineWidth: liveTrackerRingStroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text(
                    reached
                        ? localized("intermittent.live.ring.target", default: "Target")
                        : localized("intermittent.live.ring.remaining", default: "Remaining"))
                    .font(liveTrackerLabelFont)
                    .foregroundStyle(.secondary)
                Text(countdown)
                    .font(.system(size: liveTrackerCountdownFontSize, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(reached ? CatholicTheme.successForeground : CatholicTheme.primary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: liveTrackerRingSize, height: liveTrackerRingSize)
        .accessibilityIdentifier("intermittent.live_ring")
    }

    private func liveFastSummary(reached: Bool, start: Date, targetDate: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(
                reached
                    ? localized("intermittent.live.fast_target_reached", default: "Fast target reached")
                    : localized("intermittent.live.fast_in_progress", default: "Fasting in progress"))
                .font(liveTrackerSummaryTitleFont)
                .foregroundStyle(CatholicTheme.primary)
            Text(localizedFormat("intermittent.live.started_format", default: "Started %@", localizedAbbreviatedDateTime(start)))
                .font(liveTrackerSummaryDetailFont)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(localizedFormat("intermittent.live.target_ends_format", default: "Target ends %@", localizedAbbreviatedDateTime(targetDate)))
                .font(liveTrackerSummaryDetailFont)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(localizedFormat("intermittent.live.intention_format", default: "Intention: %@", intermittentIntentionLabel))
                .font(liveTrackerSummaryDetailFont)
                .foregroundStyle(CatholicTheme.primary.opacity(0.9))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(
                reached
                    ? localized("intermittent.live.end_anytime", default: "You can end your fast at any time.")
                    : localized("intermittent.live.keep_going", default: "Keep going to complete this plan."))
                .font(liveTrackerInstructionFont)
                .foregroundStyle(reached ? CatholicTheme.successForeground : .secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .layoutPriority(1)
    }

    var intermittentIntentionOptions: [FastingIntentionOption] {
        [
            FastingIntentionOption(
                id: "personal_discipline",
                label: localized("intermittent.intention.discipline.label", default: "Personal discipline"),
                detail: localized("intermittent.intention.discipline.detail", default: "Keep this fast focused on steady discipline, not pressure.")),
            FastingIntentionOption(
                id: "prayer",
                label: localized("intermittent.intention.prayer.label", default: "Prayer"),
                detail: localized("intermittent.intention.prayer.detail", default: "Offer this fast with a concrete prayer intention.")),
            FastingIntentionOption(
                id: "mercy",
                label: localized("intermittent.intention.mercy.label", default: "Mercy"),
                detail: localized("intermittent.intention.mercy.detail", default: "Pair the fast with a work of charity or mercy.")),
            FastingIntentionOption(
                id: "penance",
                label: localized("intermittent.intention.penance.label", default: "Penance"),
                detail: localized("intermittent.intention.penance.detail", default: "Use this as a voluntary penance when health and duty allow.")),
        ]
    }

    var intermittentIntentionLabel: String {
        intermittentIntentionOptions.first(where: { $0.id == intermittentIntentionRaw })?.label
            ?? localized("intermittent.intention.discipline.label", default: "Personal discipline")
    }

    var intermittentIntentionDetail: String {
        intermittentIntentionOptions.first(where: { $0.id == intermittentIntentionRaw })?.detail
            ?? localized("intermittent.intention.discipline.detail", default: "Keep this fast focused on steady discipline, not pressure.")
    }

    func liveEatingRing(progress: Double, hasEatingWindow: Bool, countdown: String) -> some View {
        ZStack {
            Circle()
                .stroke(CatholicTheme.cardBorder.opacity(0.3), lineWidth: liveTrackerRingStroke)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    hasEatingWindow ? CatholicTheme.accent : CatholicTheme.cardBorder,
                    style: StrokeStyle(lineWidth: liveTrackerRingStroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text(
                    hasEatingWindow
                        ? localized("intermittent.live.eating_window", default: "Eating Window")
                        : localized("intermittent.live.next_fast", default: "Next Fast"))
                    .font(liveTrackerLabelFont)
                    .foregroundStyle(.secondary)
                Text(countdown)
                    .font(.system(size: liveTrackerCountdownFontSize, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(CatholicTheme.primary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: liveTrackerRingSize, height: liveTrackerRingSize)
        .accessibilityIdentifier("intermittent.eating_ring")
    }

    private func liveEatingSummary(
        hasEatingWindow: Bool,
        lastEnded: Date,
        nextSuggestedStart: Date) -> some View
    {
        VStack(alignment: .leading, spacing: 8) {
            Text(
                hasEatingWindow
                    ? localized("intermittent.live.eating_window_tracker", default: "Eating window tracker")
                    : localized("intermittent.live.no_fixed_eating_window", default: "No fixed eating window"))
                .font(liveTrackerSummaryTitleFont)
                .foregroundStyle(CatholicTheme.primary)
            Text(localizedFormat("intermittent.live.last_ended_format", default: "Last fast ended %@", localizedAbbreviatedDateTime(lastEnded)))
                .font(liveTrackerSummaryDetailFont)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            if hasEatingWindow {
                Text(localizedFormat("intermittent.live.suggested_start_format", default: "Suggested next fast start: %@", localizedAbbreviatedDateTime(nextSuggestedStart)))
                    .font(liveTrackerSummaryDetailFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(localized("intermittent.live.no_standard_window", default: "Plans above 24h do not use a standard daily eating window."))
                    .font(liveTrackerSummaryDetailFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .layoutPriority(1)
    }

    var intermittentSessionHistorySection: some View {
        Section(localized("intermittent.history.section", default: "Recent Sessions")) {
            if intermittentTracker.sessions.isEmpty {
                Text(localized("intermittent.history.empty", default: "No sessions yet. Start a fast to build your local history."))
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("intermittent.history_empty")
                Button(localized("intermittent.history.start_first", default: "Start First Fast")) {
                    intermittentTracker.startFast()
                }
                .appPrimaryButtonStyle()
            } else {
                let sessionLimit = monetizationStore.premiumUnlocked ? 12 : 3
                ForEach(intermittentTracker.sessions.prefix(sessionLimit)) { session in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: session.completedTarget ? "checkmark.seal.fill" : "clock.badge.xmark.fill")
                            .imageScale(.large)
                            .foregroundStyle(session.completedTarget ? CatholicTheme.successForeground : CatholicTheme.warningForeground)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(
                                localizedFormat(
                                    "intermittent.history.range_format",
                                    default: "%@ → %@",
                                    localizedAbbreviatedDateTime(session.start),
                                    localizedAbbreviatedDateTime(session.end)))
                                .font(.subheadline.weight(.semibold))
                            Text(
                                localizedFormat(
                                    "intermittent.history.detail_format",
                                    default: "Duration: %@ • Plan: %dh",
                                    durationText(session.duration),
                                    session.targetHours))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(
                                session.completedTarget
                                    ? localized("intermittent.history.target_met", default: "Target met")
                                    : localized("intermittent.history.below_target", default: "Below target"))
                                .font(.caption)
                                .foregroundStyle(session.completedTarget ? CatholicTheme.successForeground : CatholicTheme.warningForeground)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("intermittent.session_row")
                }

                if !monetizationStore.premiumUnlocked, intermittentTracker.sessions.count > 3 {
                    Text(localized("intermittent.history.free_limit", default: "Free shows the most recent 3 sessions. Premium unlocks the full recent history view."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(localized("intermittent.history.unlock", default: "Unlock Full History")) {
                        openPremiumUpgrade(focusingOn: .accountability)
                    }
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("intermittent.unlock_history")
                }
            }
        }
    }
}
