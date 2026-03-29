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
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .appSurfaceCard(.utility, cornerRadius: 12)
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
        SacredHeroImageSelector.artwork(for: .intermittent)
    }

    var intermittentHeroSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                SacredHeroCard(
                    assetName: intermittentHeroArtwork.assetName,
                    title: intermittentTracker.activeStart == nil
                        ? localized("intermittent.hero.title_idle", default: "Track Fast")
                        : localized("intermittent.hero.title_active", default: "Fast in progress"),
                    subtitle: intermittentTracker.activeStart == nil
                        ? localized("intermittent.hero.subtitle_idle", default: "Choose a target, then start when ready.")
                        : localized("intermittent.hero.subtitle_active", default: "Your live fast and next action are below."),
                    height: 152,
                    accessibilityIdentifier: "intermittent.hero.card")

                CatholicFastingQuoteCard(quote: intermittentFastingQuote, compact: true)
                    .accessibilityIdentifier("intermittent.hero.quote")
            }
            .accessibilityIdentifier("intermittent.hero")
        }
    }

    var intermittentOverviewSection: some View {
        Section(localized("intermittent.current_plan.title", default: "Current Plan")) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    MetricTile(title: localized("intermittent.metric.sessions", default: "Sessions"), value: "\(intermittentTracker.sessions.count)", detail: localized("intermittent.metric.sessions.detail", default: "saved locally"))
                    MetricTile(title: localized("intermittent.metric.target", default: "Target"), value: intermittentWindowLabel, detail: localized("intermittent.metric.target.detail", default: "active fasting window"))
                    MetricTile(title: localized("intermittent.metric.longest", default: "Longest"), value: intermittentLongestSessionText, detail: localized("intermittent.metric.longest.detail", default: "best recent duration"))
                }
                VStack(spacing: 8) {
                    HStack {
                        MetricTile(title: localized("intermittent.metric.sessions", default: "Sessions"), value: "\(intermittentTracker.sessions.count)", detail: localized("intermittent.metric.sessions.detail", default: "saved locally"))
                        MetricTile(title: localized("intermittent.metric.target", default: "Target"), value: intermittentWindowLabel, detail: localized("intermittent.metric.target.detail", default: "active fasting window"))
                    }
                    MetricTile(title: localized("intermittent.metric.longest", default: "Longest"), value: intermittentLongestSessionText, detail: localized("intermittent.metric.longest.detail", default: "best recent duration"))
                }
            }

            if let activeStart = intermittentTracker.activeStart {
                Text(localizedFormat("intermittent.current_plan.started_format", default: "Started %@", activeStart.formatted(date: .abbreviated, time: .shortened)))
                    .appSupportingTextStyle()
                    .foregroundStyle(CatholicTheme.primary.opacity(0.9))
            } else if let latestSession = intermittentTracker.sessions.first {
                Text(localizedFormat("intermittent.current_plan.last_ended_format", default: "Last fast ended %@", latestSession.end.formatted(date: .abbreviated, time: .shortened)))
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

    var intermittentControlsSection: some View {
        Section(localized("intermittent.controls.title", default: "Target and Controls")) {
            Picker(localized("intermittent.controls.quick_plan", default: "Quick Plan"), selection: intermittentPresetBinding) {
                ForEach([12, 14, 16, 18, 20, 24, 36], id: \.self) { hours in
                    Text(intermittentPlanDescription(hours)).tag(hours)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("intermittent.target_picker")

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
                Text(localized("intermittent.controls.premium_hint", default: "Custom targets beyond presets are part of Premium."))
                    .appSupportingTextStyle()
                Button(localized("intermittent.controls.unlock", default: "Unlock Custom Long Fasts")) {
                    openPremiumUpgrade(focusingOn: .planning)
                }
                .appSecondaryButtonStyle()
                .accessibilityIdentifier("intermittent.unlock_custom_targets")
            }

            Text(localizedFormat("intermittent.controls.current_target_format", default: "Current target: %@", intermittentWindowLabel))
                .appSupportingTextStyle()

            if intermittentTracker.activeStart == nil {
                DatePicker(
                    localized("intermittent.controls.started", default: "Started"),
                    selection: $intermittentManualStart,
                    in: intermittentManualStartRange,
                    displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("intermittent.start_date")

                Text(localized("intermittent.controls.started_hint", default: "If you already started, set the start time here before beginning the timer."))
                    .appSupportingTextStyle()

                Button {
                    startIntermittentFastFromSelectedTime()
                } label: {
                    Label(localized("intermittent.controls.start_now", default: "Start Fast Now"), systemImage: "play.fill")
                }
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("intermittent.start_fast")
            } else {
                DatePicker(
                    localized("intermittent.controls.started", default: "Started"),
                    selection: intermittentActiveStartBinding,
                    in: intermittentManualStartRange,
                    displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("intermittent.start_date")

                Text(localized("intermittent.controls.adjust_hint", default: "Adjust the start time here if you began fasting earlier. The live tracker updates right away."))
                    .appSupportingTextStyle()

                HStack {
                    Button {
                        intermittentTracker.endFast()
                        resetIntermittentManualStartToNow()
                    } label: {
                        Label(localized("intermittent.controls.end", default: "End Fast"), systemImage: "stop.fill")
                    }
                    .appPrimaryButtonStyle(legacyTint: .green)
                    .accessibilityIdentifier("intermittent.end_fast")

                    Button {
                        intermittentTracker.cancelActiveFast()
                        resetIntermittentManualStartToNow()
                    } label: {
                        Label(localized("intermittent.controls.cancel", default: "Cancel"), systemImage: "xmark")
                    }
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("intermittent.cancel_fast")
                }
            }
        }
    }

    var intermittentAdvancedToolsSection: some View {
        Section(localized("intermittent.advanced.title", default: "Advanced Tools")) {
            DisclosureGroup(
                isExpanded: $intermittentShowAdvanced,
                content: {
                    VStack(alignment: .leading, spacing: 0) {
                        intermittentScheduleSection
                        intermittentMilestonesSection
                        intermittentRecoverySection
                        intermittentSessionHistorySection
                    }
                },
                label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localized("intermittent.advanced.label_title", default: "Schedules, milestones, recovery, and history"))
                            .font(.subheadline.weight(.semibold))
                        Text(localized("intermittent.advanced.label_detail", default: "Keep the live tracker first and open these only when you need deeper tools."))
                            .appSupportingTextStyle()
                    }
                })
                .accessibilityIdentifier("intermittent.advanced.disclosure")

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
                            .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)

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
                    .foregroundStyle(.orange)
            } else {
                Text(localized("intermittent.recovery.none", default: "No immediate recovery actions needed."))
                    .foregroundStyle(.secondary)
            }
            Text(localized("intermittent.recovery.guidance", default: "Adjust fast length when health, duty, or pastoral guidance requires."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var intermittentActiveSection: some View {
        Section(localized("intermittent.live.section", default: "Live Tracker")) {
            if let activeStart = intermittentTracker.activeStart {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let now = context.date
                    let accessibilityLayout = dynamicTypeSize.isAccessibilitySize
                    let start = intermittentTracker.activeStart ?? activeStart
                    let targetSeconds = TimeInterval(intermittentTracker.presetHours * 3600)
                    let elapsed = max(0, now.timeIntervalSince(start))
                    let remaining = max(0, targetSeconds - elapsed)
                    let overtime = max(0, elapsed - targetSeconds)
                    let progress = min(1.0, elapsed / max(1, targetSeconds))
                    let eatingHours = max(0, 24 - intermittentTracker.presetHours)
                    let targetDate = start.addingTimeInterval(targetSeconds)

                    VStack(alignment: .leading, spacing: 14) {
                        if accessibilityLayout {
                            VStack(alignment: .leading, spacing: 12) {
                                liveFastRing(progress: progress, reached: progress >= 1, countdown: countdownText(progress >= 1 ? overtime : remaining))
                                liveFastSummary(reached: progress >= 1, start: start, targetDate: targetDate)
                            }
                        } else {
                            HStack(alignment: .center, spacing: 16) {
                                liveFastRing(progress: progress, reached: progress >= 1, countdown: countdownText(progress >= 1 ? overtime : remaining))
                                liveFastSummary(reached: progress >= 1, start: start, targetDate: targetDate)
                            }
                        }

                        if accessibilityLayout {
                            VStack(spacing: 8) {
                                LiveTrackerMetricChip(title: localized("intermittent.live.elapsed", default: "Elapsed"), value: countdownText(elapsed))
                                    .accessibilityIdentifier("intermittent.active_elapsed")
                                LiveTrackerMetricChip(title: localized("intermittent.live.target", default: "Target"), value: localizedFormat("intermittent.live.target_value_format", default: "%dh fast", intermittentTracker.presetHours))
                                LiveTrackerMetricChip(
                                    title: localized("intermittent.live.next", default: "Next"),
                                    value: eatingHours > 0
                                        ? localizedFormat("intermittent.live.next_value_format", default: "%dh after fast", eatingHours)
                                        : localized("intermittent.live.next_custom", default: "Custom rhythm"))
                            }
                        } else {
                            HStack(spacing: 8) {
                                LiveTrackerMetricChip(title: localized("intermittent.live.elapsed", default: "Elapsed"), value: countdownText(elapsed))
                                    .accessibilityIdentifier("intermittent.active_elapsed")
                                LiveTrackerMetricChip(title: localized("intermittent.live.target", default: "Target"), value: localizedFormat("intermittent.live.target_value_format", default: "%dh fast", intermittentTracker.presetHours))
                                LiveTrackerMetricChip(
                                    title: localized("intermittent.live.next", default: "Next"),
                                    value: eatingHours > 0
                                        ? localizedFormat("intermittent.live.next_value_format", default: "%dh after fast", eatingHours)
                                        : localized("intermittent.live.next_custom", default: "Custom rhythm"))
                            }
                        }
                    }
                    .padding(4)
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
                    let accessibilityLayout = dynamicTypeSize.isAccessibilitySize
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
                        if accessibilityLayout {
                            VStack(alignment: .leading, spacing: 12) {
                                liveEatingRing(progress: eatingProgress, hasEatingWindow: hasEatingWindow, countdown: hasEatingWindow ? countdownText(eatingRemaining) : localized("intermittent.live.ready", default: "Ready"))
                                liveEatingSummary(
                                    hasEatingWindow: hasEatingWindow,
                                    lastEnded: lastEnded,
                                    nextSuggestedStart: nextSuggestedStart)
                            }
                        } else {
                            HStack(alignment: .center, spacing: 16) {
                                liveEatingRing(progress: eatingProgress, hasEatingWindow: hasEatingWindow, countdown: hasEatingWindow ? countdownText(eatingRemaining) : localized("intermittent.live.ready", default: "Ready"))
                                liveEatingSummary(
                                    hasEatingWindow: hasEatingWindow,
                                    lastEnded: lastEnded,
                                    nextSuggestedStart: nextSuggestedStart)
                            }
                        }

                        if accessibilityLayout {
                            VStack(spacing: 8) {
                                LiveTrackerMetricChip(title: localized("intermittent.live.since_end", default: "Since End"), value: countdownText(elapsedSinceEnd))
                                LiveTrackerMetricChip(title: localized("intermittent.live.last_fast", default: "Last Fast"), value: localizedFormat("intermittent.live.last_fast_value_format", default: "%dh plan", latestSession.targetHours))
                                LiveTrackerMetricChip(
                                    title: localized("intermittent.live.status", default: "Status"),
                                    value: hasEatingWindow
                                        ? (
                                            eatingRemaining > 0
                                                ? localized("intermittent.live.status_eating_window_open", default: "Eating window open")
                                                : localized("intermittent.live.status_ready_to_fast", default: "Ready to fast"))
                                        : localized("intermittent.live.status_ready_anytime", default: "Ready anytime"))
                            }
                        } else {
                            HStack(spacing: 8) {
                                LiveTrackerMetricChip(title: localized("intermittent.live.since_end", default: "Since End"), value: countdownText(elapsedSinceEnd))
                                LiveTrackerMetricChip(title: localized("intermittent.live.last_fast", default: "Last Fast"), value: localizedFormat("intermittent.live.last_fast_value_format", default: "%dh plan", latestSession.targetHours))
                                LiveTrackerMetricChip(
                                    title: localized("intermittent.live.status", default: "Status"),
                                    value: hasEatingWindow
                                        ? (
                                            eatingRemaining > 0
                                                ? localized("intermittent.live.status_eating_window_open", default: "Eating window open")
                                                : localized("intermittent.live.status_ready_to_fast", default: "Ready to fast"))
                                        : localized("intermittent.live.status_ready_anytime", default: "Ready anytime"))
                            }
                        }
                    }
                    .padding(4)
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
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localized("intermittent.live.no_active", default: "No active fast"))
                            .appSectionTitleStyle()
                        Text(localized("intermittent.live.no_active_detail", default: "Pick a target below, adjust the start time if you already began, and start when ready."))
                            .appLeadTextStyle()
                            .accessibilityIdentifier("intermittent.no_active")
                    }
                }
            }
        }
    }

    func liveFastRing(progress: Double, reached: Bool, countdown: String) -> some View {
        ZStack {
            Circle()
                .stroke(CatholicTheme.cardBorder.opacity(0.3), lineWidth: 12)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    reached ? .green : CatholicTheme.accent,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text(
                    reached
                        ? localized("intermittent.live.ring.target", default: "Target")
                        : localized("intermittent.live.ring.remaining", default: "Remaining"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(countdown)
                    .font(.system(.headline, design: .rounded).monospacedDigit())
                    .foregroundStyle(reached ? .green : CatholicTheme.primary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: 150, height: 150)
        .accessibilityIdentifier("intermittent.live_ring")
    }

    private func liveFastSummary(reached: Bool, start: Date, targetDate: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(
                reached
                    ? localized("intermittent.live.fast_target_reached", default: "Fast target reached")
                    : localized("intermittent.live.fast_in_progress", default: "Fasting in progress"))
                .font(.headline.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
            Text(localizedFormat("intermittent.live.started_format", default: "Started %@", start.formatted(date: .abbreviated, time: .shortened)))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(localizedFormat("intermittent.live.target_ends_format", default: "Target ends %@", targetDate.formatted(date: .abbreviated, time: .shortened)))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(
                reached
                    ? localized("intermittent.live.end_anytime", default: "You can end your fast at any time.")
                    : localized("intermittent.live.keep_going", default: "Keep going to complete this plan."))
                .font(.caption)
                .foregroundStyle(reached ? .green : .secondary)
        }
    }

    func liveEatingRing(progress: Double, hasEatingWindow: Bool, countdown: String) -> some View {
        ZStack {
            Circle()
                .stroke(CatholicTheme.cardBorder.opacity(0.3), lineWidth: 12)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    hasEatingWindow ? CatholicTheme.accent : CatholicTheme.cardBorder,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text(
                    hasEatingWindow
                        ? localized("intermittent.live.eating_window", default: "Eating Window")
                        : localized("intermittent.live.next_fast", default: "Next Fast"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(countdown)
                    .font(.system(.headline, design: .rounded).monospacedDigit())
                    .foregroundStyle(CatholicTheme.primary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: 150, height: 150)
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
                .font(.headline.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
            Text(localizedFormat("intermittent.live.last_ended_format", default: "Last fast ended %@", lastEnded.formatted(date: .abbreviated, time: .shortened)))
                .font(.caption)
                .foregroundStyle(.secondary)
            if hasEatingWindow {
                Text(localizedFormat("intermittent.live.suggested_start_format", default: "Suggested next fast start: %@", nextSuggestedStart.formatted(date: .abbreviated, time: .shortened)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text(localized("intermittent.live.no_standard_window", default: "Plans above 24h do not use a standard daily eating window."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
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
                            .foregroundStyle(session.completedTarget ? .green : .orange)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(localizedFormat("intermittent.history.range_format", default: "%@ → %@", session.start.formatted(date: .abbreviated, time: .shortened), session.end.formatted(date: .abbreviated, time: .shortened)))
                                .font(.subheadline.weight(.semibold))
                            Text(localizedFormat("intermittent.history.detail_format", default: "Duration: %@ • Plan: %dh", durationText(session.duration), session.targetHours))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(
                                session.completedTarget
                                    ? localized("intermittent.history.target_met", default: "Target met")
                                    : localized("intermittent.history.below_target", default: "Below target"))
                                .font(.caption)
                                .foregroundStyle(session.completedTarget ? .green : .orange)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
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
