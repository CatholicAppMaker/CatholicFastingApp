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
                    title: intermittentTracker.activeStart == nil ? "Track Fast" : "Fast in progress",
                    subtitle: intermittentTracker.activeStart == nil
                        ? "Choose a target, then start when ready."
                        : "Your live fast and next action are below.",
                    height: 152,
                    accessibilityIdentifier: "intermittent.hero.card")

                CatholicFastingQuoteCard(quote: intermittentFastingQuote, compact: true)
                    .accessibilityIdentifier("intermittent.hero.quote")
            }
            .accessibilityIdentifier("intermittent.hero")
        }
    }

    var intermittentOverviewSection: some View {
        Section("Current Plan") {
            ViewThatFits(in: .horizontal) {
                HStack {
                    MetricTile(title: "Sessions", value: "\(intermittentTracker.sessions.count)")
                    MetricTile(title: "Target", value: intermittentWindowLabel)
                    MetricTile(title: "Longest", value: intermittentLongestSessionText)
                }
                VStack(spacing: 8) {
                    HStack {
                        MetricTile(title: "Sessions", value: "\(intermittentTracker.sessions.count)")
                        MetricTile(title: "Target", value: intermittentWindowLabel)
                    }
                    MetricTile(title: "Longest", value: intermittentLongestSessionText)
                }
            }

            if let activeStart = intermittentTracker.activeStart {
                Text("Started \(activeStart.formatted(date: .abbreviated, time: .shortened)).")
                    .appSupportingTextStyle()
                    .foregroundStyle(CatholicTheme.primary.opacity(0.9))
            } else if let latestSession = intermittentTracker.sessions.first {
                Text("Last fast ended \(latestSession.end.formatted(date: .abbreviated, time: .shortened)).")
                    .appSupportingTextStyle()
                Text(
                    latestSession.completedTarget
                        ? "Repeat this rhythm or increase only if it remains prudent."
                        : "Choose a lighter target or re-enter with a simpler plan.")
                    .appSupportingTextStyle()
            } else {
                Text("Your target and recent session summary will show here after the first fast.")
                    .appSupportingTextStyle()
            }
        }
    }

    var intermittentControlsSection: some View {
        Section("Target and Controls") {
            Picker("Quick Plan", selection: intermittentPresetBinding) {
                ForEach([12, 14, 16, 18, 20, 24, 36], id: \.self) { hours in
                    Text(intermittentPlanDescription(hours)).tag(hours)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("intermittent.target_picker")

            if monetizationStore.premiumUnlocked {
                Stepper(value: intermittentPresetBinding, in: 12 ... 336, step: 1) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Custom target: \(intermittentTracker.presetHours)h")
                        Text("Longer disciplines remain available here (up to 14 days / 336h).")
                            .appEyebrowStyle()
                    }
                }
                .accessibilityIdentifier("intermittent.custom_target_stepper")
            } else {
                Text("Custom targets beyond presets are part of Premium.")
                    .appSupportingTextStyle()
                Button("Unlock Custom Long Fasts") {
                    openPremiumUpgrade(focusingOn: .planning)
                }
                .appSecondaryButtonStyle()
                .accessibilityIdentifier("intermittent.unlock_custom_targets")
            }

            Text("Current target: \(intermittentWindowLabel)")
                .appSupportingTextStyle()

            if intermittentTracker.activeStart == nil {
                DatePicker(
                    "Started",
                    selection: $intermittentManualStart,
                    in: intermittentManualStartRange,
                    displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("intermittent.start_date")

                Text("If you already started, set the start time here before beginning the timer.")
                    .appSupportingTextStyle()

                Button {
                    startIntermittentFastFromSelectedTime()
                } label: {
                    Label("Start Fast Now", systemImage: "play.fill")
                }
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("intermittent.start_fast")
            } else {
                DatePicker(
                    "Started",
                    selection: intermittentActiveStartBinding,
                    in: intermittentManualStartRange,
                    displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("intermittent.start_date")

                Text("Adjust the start time here if you began fasting earlier. The live tracker updates right away.")
                    .appSupportingTextStyle()

                HStack {
                    Button {
                        intermittentTracker.endFast()
                        resetIntermittentManualStartToNow()
                    } label: {
                        Label("End Fast", systemImage: "stop.fill")
                    }
                    .appPrimaryButtonStyle(legacyTint: .green)
                    .accessibilityIdentifier("intermittent.end_fast")

                    Button {
                        intermittentTracker.cancelActiveFast()
                        resetIntermittentManualStartToNow()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("intermittent.cancel_fast")
                }
            }
        }
    }

    var intermittentAdvancedToolsSection: some View {
        Section("Advanced Tools") {
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
                        Text("Schedules, milestones, recovery, and history")
                            .font(.subheadline.weight(.semibold))
                        Text("Keep the live tracker first and open these only when you need deeper tools.")
                            .appSupportingTextStyle()
                    }
                })
                .accessibilityIdentifier("intermittent.advanced.disclosure")

            if !intermittentShowAdvanced {
                Text("Saved schedules, milestone stats, recovery guidance, and recent history stay tucked away here.")
                    .appSupportingTextStyle()
            }
        }
    }

    var intermittentScheduleSection: some View {
        Section("Custom Schedules") {
            Text("Save reusable plans locally on this device.")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("Schedule name (optional)", text: $newIntermittentScheduleName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .accessibilityIdentifier("intermittent.schedule.name")

            Stepper("Start hour: \(String(format: "%02d:00", newIntermittentScheduleStartHour))", value: $newIntermittentScheduleStartHour, in: 0 ... 23)
                .accessibilityIdentifier("intermittent.schedule.start_hour")

            VStack(alignment: .leading, spacing: 8) {
                Text("Days")
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
                Text("No saved schedules yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(intermittentSchedules) { plan in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(plan.name)
                                    .font(.subheadline.weight(.semibold))
                                if activeIntermittentScheduleID == plan.id {
                                    Text("Applied")
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(CatholicTheme.primary))
                                }
                            }
                            Text("Target \(plan.targetHours)h • Start \(String(format: "%02d:00", plan.startHour)) • Days \(weekdayListText(plan.weekdays))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            Button("Use") {
                                Task {
                                    await applyIntermittentSchedule(plan)
                                }
                            }
                            .appSecondaryButtonStyle()

                            Button("Edit") {
                                startEditingIntermittentSchedule(plan)
                            }
                            .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)

                            Button("Delete", role: .destructive) {
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
                Button(isEditingIntermittentSchedule ? "Update Schedule" : "Save Current Plan as Schedule") {
                    addOrUpdateIntermittentSchedulePlan()
                }
                .appPrimaryButtonStyle()
                .disabled(!canSaveIntermittentSchedule)
                .accessibilityIdentifier("intermittent.schedule.add")

                if isEditingIntermittentSchedule {
                    Button("Cancel Edit") {
                        cancelEditingIntermittentSchedule()
                    }
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("intermittent.schedule.cancel_edit")
                }
            }
        }
    }

    var intermittentMilestonesSection: some View {
        Section("Milestones") {
            let total = intermittentTracker.sessions.count
            let completedTargets = intermittentTracker.sessions.filter(\.completedTarget).count
            let longestHours = Int((intermittentTracker.sessions.map(\.duration).max() ?? 0) / 3600)

            Text("Sessions completed: \(total)")
            Text("Targets achieved: \(completedTargets)")
            Text("Longest fast: \(longestHours) hour(s)")
            Text("Recent hit rate: \(intermittentHitRatePercent)%")
                .foregroundStyle(.secondary)
        }
    }

    var intermittentRecoverySection: some View {
        Section("Recovery Guidance") {
            if intermittentTracker.activeStart == nil, let latest = intermittentTracker.sessions.first, !latest.completedTarget {
                Text("Your latest session ended below target. Consider a lighter target and hydrate well.")
                    .foregroundStyle(.orange)
            } else {
                Text("No immediate recovery actions needed.")
                    .foregroundStyle(.secondary)
            }
            Text("Adjust fast length when health, duty, or pastoral guidance requires.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var intermittentActiveSection: some View {
        Section("Live Tracker") {
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
                                LiveTrackerMetricChip(title: "Elapsed", value: countdownText(elapsed))
                                    .accessibilityIdentifier("intermittent.active_elapsed")
                                LiveTrackerMetricChip(title: "Target", value: "\(intermittentTracker.presetHours)h fast")
                                LiveTrackerMetricChip(
                                    title: "Next",
                                    value: eatingHours > 0 ? "\(eatingHours)h after fast" : "Custom rhythm")
                            }
                        } else {
                            HStack(spacing: 8) {
                                LiveTrackerMetricChip(title: "Elapsed", value: countdownText(elapsed))
                                    .accessibilityIdentifier("intermittent.active_elapsed")
                                LiveTrackerMetricChip(title: "Target", value: "\(intermittentTracker.presetHours)h fast")
                                LiveTrackerMetricChip(
                                    title: "Next",
                                    value: eatingHours > 0 ? "\(eatingHours)h after fast" : "Custom rhythm")
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
                                liveEatingRing(progress: eatingProgress, hasEatingWindow: hasEatingWindow, countdown: hasEatingWindow ? countdownText(eatingRemaining) : "Ready")
                                liveEatingSummary(
                                    hasEatingWindow: hasEatingWindow,
                                    lastEnded: lastEnded,
                                    nextSuggestedStart: nextSuggestedStart)
                            }
                        } else {
                            HStack(alignment: .center, spacing: 16) {
                                liveEatingRing(progress: eatingProgress, hasEatingWindow: hasEatingWindow, countdown: hasEatingWindow ? countdownText(eatingRemaining) : "Ready")
                                liveEatingSummary(
                                    hasEatingWindow: hasEatingWindow,
                                    lastEnded: lastEnded,
                                    nextSuggestedStart: nextSuggestedStart)
                            }
                        }

                        if accessibilityLayout {
                            VStack(spacing: 8) {
                                LiveTrackerMetricChip(title: "Since End", value: countdownText(elapsedSinceEnd))
                                LiveTrackerMetricChip(title: "Last Fast", value: "\(latestSession.targetHours)h plan")
                                LiveTrackerMetricChip(
                                    title: "Status",
                                    value: hasEatingWindow
                                        ? (eatingRemaining > 0 ? "Eating window open" : "Ready to fast")
                                        : "Ready anytime")
                            }
                        } else {
                            HStack(spacing: 8) {
                                LiveTrackerMetricChip(title: "Since End", value: countdownText(elapsedSinceEnd))
                                LiveTrackerMetricChip(title: "Last Fast", value: "\(latestSession.targetHours)h plan")
                                LiveTrackerMetricChip(
                                    title: "Status",
                                    value: hasEatingWindow
                                        ? (eatingRemaining > 0 ? "Eating window open" : "Ready to fast")
                                        : "Ready anytime")
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
                        Text("No active fast")
                            .appSectionTitleStyle()
                        Text("Pick a target below, adjust the start time if you already began, and start when ready.")
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
                Text(reached ? "Target" : "Remaining")
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
            Text(reached ? "Fast target reached" : "Fasting in progress")
                .font(.headline.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
            Text("Started \(start.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Target ends \(targetDate.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(reached ? "You can end your fast at any time." : "Keep going to complete this plan.")
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
                Text(hasEatingWindow ? "Eating Window" : "Next Fast")
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
            Text(hasEatingWindow ? "Eating window tracker" : "No fixed eating window")
                .font(.headline.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
            Text("Last fast ended \(lastEnded.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)
            if hasEatingWindow {
                Text("Suggested next fast start: \(nextSuggestedStart.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Plans above 24h do not use a standard daily eating window.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var intermittentSessionHistorySection: some View {
        Section("Recent Sessions") {
            if intermittentTracker.sessions.isEmpty {
                Text("No sessions yet. Start a fast to build your local history.")
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("intermittent.history_empty")
                Button("Start First Fast") {
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
                            Text("\(session.start.formatted(date: .abbreviated, time: .shortened)) → \(session.end.formatted(date: .abbreviated, time: .shortened))")
                                .font(.subheadline.weight(.semibold))
                            Text("Duration: \(durationText(session.duration)) • Plan: \(session.targetHours)h")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(session.completedTarget ? "Target met" : "Below target")
                                .font(.caption)
                                .foregroundStyle(session.completedTarget ? .green : .orange)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                    .accessibilityIdentifier("intermittent.session_row")
                }

                if !monetizationStore.premiumUnlocked, intermittentTracker.sessions.count > 3 {
                    Text("Free shows the most recent 3 sessions. Premium unlocks the full recent history view.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Unlock Full History") {
                        openPremiumUpgrade(focusingOn: .accountability)
                    }
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("intermittent.unlock_history")
                }
            }
        }
    }
}
