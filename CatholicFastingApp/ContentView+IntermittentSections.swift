import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension ContentView {
    func fireIntermittentTargetReachedHapticIfNeeded(start: Date) {
        guard hapticsEnabled else { return }
        let key = String(Int(start.timeIntervalSince1970))
        guard fastPresentation.lastTargetReachedHapticKey != key else { return }
        fastPresentation.lastTargetReachedHapticKey = key
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
    }

    func fireIntermittentEatingWindowClosedHapticIfNeeded(sessionID: String) {
        guard hapticsEnabled else { return }
        guard fastPresentation.lastEatingWindowClosedHapticKey != sessionID else { return }
        fastPresentation.lastEatingWindowClosedHapticKey = sessionID
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
        IntermittentFastHeroSection(
            assetName: intermittentHeroArtwork.assetName,
            title: intermittentTracker.activeStart == nil
                ? localized("intermittent.hero.title_idle", default: "Fast")
                : localized("intermittent.hero.title_active", default: "Fast in progress"),
            subtitle: intermittentTracker.activeStart == nil
                ? localized("intermittent.hero.subtitle_idle", default: "Choose a target, then start when ready.")
                : localized("intermittent.hero.subtitle_active", default: "Your live fast and next action are below."))
    }

    var intermittentOverviewSection: some View {
        let summary = intermittentHabitSummary
        return IntermittentFastOverviewSection(
            title: localized("intermittent.current_plan.title", default: "Current Plan"),
            metrics: intermittentOverviewMetrics,
            status: intermittentOverviewStatus,
            rhythmTitle: localized("intermittent.rhythm.title", default: "Fasting rhythm"),
            rhythmMetrics: [
                IntermittentFastRhythmMetric(
                    id: "current-streak",
                    title: localized("intermittent.rhythm.current_streak", default: "Current streak"),
                    value: localizedFormat("intermittent.rhythm.days_format", default: "%d day(s)", summary.currentStreakDays),
                    detail: localized("intermittent.rhythm.current_streak_detail", default: "steady continuity")),
                IntermittentFastRhythmMetric(
                    id: "weekly",
                    title: localized("intermittent.rhythm.weekly", default: "Weekly rhythm"),
                    value: "\(summary.weeklySessionCount)",
                    detail: localized("intermittent.rhythm.weekly_detail", default: "sessions this week")),
                IntermittentFastRhythmMetric(
                    id: "hit-rate",
                    title: localized("intermittent.rhythm.hit_rate", default: "Target met"),
                    value: "\(summary.targetHitPercent)%",
                    detail: localized("intermittent.rhythm.hit_rate_detail", default: "local history")),
            ])
    }

    private var intermittentOverviewMetrics: [IntermittentFastOverviewMetric] {
        let sessionsTitle = localized("intermittent.metric.sessions", default: "Sessions")
        return [
            IntermittentFastOverviewMetric(
                id: "sessions",
                title: sessionsTitle,
                value: "\(intermittentTracker.sessions.count)",
                detail: localized("intermittent.metric.sessions.detail", default: "saved locally"),
                tone: .primary,
                accessibilityIdentifier: "intermittent.metric.sessions",
                accessibilityLabel: sessionsTitle,
                accessibilityValue: "\(intermittentTracker.sessions.count)"),
            IntermittentFastOverviewMetric(
                id: "target",
                title: localized("intermittent.metric.target", default: "Target"),
                value: intermittentWindowLabel,
                detail: localized("intermittent.metric.target.detail", default: "active fasting window"),
                tone: .information),
            IntermittentFastOverviewMetric(
                id: "longest",
                title: localized("intermittent.metric.longest", default: "Longest"),
                value: intermittentLongestSessionText,
                detail: localized("intermittent.metric.longest.detail", default: "best recent duration"),
                tone: .success),
        ]
    }

    private var intermittentOverviewStatus: [IntermittentFastOverviewStatus] {
        if let activeStart = intermittentTracker.activeStart {
            return [
                IntermittentFastOverviewStatus(
                    id: "active-start",
                    text: localizedFormat(
                        "intermittent.current_plan.started_format",
                        default: "Started %@",
                        localizedAbbreviatedDateTime(activeStart)),
                    emphasized: true),
            ]
        }
        if let latestSession = intermittentTracker.sessions.first {
            return [
                IntermittentFastOverviewStatus(
                    id: "last-ended",
                    text: localizedFormat(
                        "intermittent.current_plan.last_ended_format",
                        default: "Last fast ended %@",
                        localizedAbbreviatedDateTime(latestSession.end))),
                IntermittentFastOverviewStatus(
                    id: "last-result",
                    text: latestSession.completedTarget
                        ? localized("intermittent.current_plan.completed_hint", default: "Repeat this rhythm or increase only if it remains prudent.")
                        : localized("intermittent.current_plan.missed_hint", default: "Choose a lighter target or re-enter with a simpler plan.")),
            ]
        }
        return [
            IntermittentFastOverviewStatus(
                id: "empty",
                text: localized(
                    "intermittent.current_plan.empty",
                    default: "Your target and recent session summary will show here after the first fast.")),
        ]
    }

    var intermittentControlCenterSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                intermittentControlCenterLiveState

                Divider()
                    .overlay(CatholicTheme.cardBorder.opacity(0.35))
                    .accessibilityHidden(true)

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
                ? $fastPresentation.manualStart
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
                    text: $fastPresentation.recapNote,
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

    var intermittentPrimaryActionControls: some View {
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
}
