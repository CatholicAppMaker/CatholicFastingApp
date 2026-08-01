import SwiftUI

extension ContentView {
    var intermittentQuickTargetOptions: [IntermittentFastTargetOption] {
        [12, 14, 16, 18, 20, 24, 36].map { hours in
            IntermittentFastTargetOption(
                hours: hours,
                title: localizedFormat("ipad.intermittent.plan_hours_format", default: "%dh", hours),
                detail: intermittentPlanDescription(hours))
        }
    }

    private var liveTrackerRingSize: CGFloat {
        if dynamicTypeSize.isAccessibilitySize {
            return 220
        }
        return horizontalSizeClass == .regular ? 204 : 178
    }

    private var liveTrackerRingStroke: CGFloat {
        horizontalSizeClass == .regular ? 16 : 14
    }

    private var liveTrackerCountdownFontSize: CGFloat {
        horizontalSizeClass == .regular
            ? regularLiveTrackerCountdownSize
            : compactLiveTrackerCountdownSize
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
                        Text(localized("intermittent.advanced.label_title", default: "History, recovery, and saved schedules"))
                            .font(.subheadline.weight(.semibold))
                        Text(localized("intermittent.advanced.label_detail", default: "Review recent fasts first, then open schedule tools only when needed."))
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
                    intermittentSessionHistorySection
                    intermittentRecoverySection
                    intermittentScheduleSection
                }
            }

            if !intermittentShowAdvanced {
                Text(localized("intermittent.advanced.collapsed_hint", default: "Recent history, recovery guidance, and saved schedules stay tucked away here."))
                    .appSupportingTextStyle()
            }
        }
    }

    var intermittentScheduleSection: some View {
        Section(localized("intermittent.schedules.section", default: "Custom Schedules")) {
            intermittentScheduleEditor(presentation: .phone)
        }
    }

    func intermittentScheduleEditor(presentation: IntermittentFastControlPresentation) -> some View {
        IntermittentScheduleEditor(
            presentation: presentation,
            copy: intermittentScheduleCopy,
            plans: planningSession.schedules,
            activeScheduleID: planningSession.activeScheduleID,
            isEditing: isEditingIntermittentSchedule,
            showsEditor: $fastPresentation.showsScheduleEditor,
            scheduleName: $fastPresentation.scheduleName,
            startHour: $fastPresentation.scheduleStartHour,
            weekdays: $fastPresentation.scheduleWeekdays,
            notificationStatus: feedback.notificationStatus,
            canSave: canSaveIntermittentSchedule,
            toggleWeekday: toggleIntermittentScheduleWeekday,
            apply: { plan in
                Task {
                    await applyIntermittentSchedule(plan)
                }
            },
            edit: startEditingIntermittentSchedule,
            delete: deleteIntermittentSchedule,
            save: addOrUpdateIntermittentSchedulePlan,
            cancelEditing: cancelEditingIntermittentSchedule)
    }

    private var intermittentScheduleCopy: IntermittentScheduleCopy {
        IntermittentScheduleCopy(
            sectionTitle: localized("intermittent.schedules.section", default: "Custom Schedules"),
            intro: localized("intermittent.schedules.intro", default: "Save reusable plans locally on this device."),
            empty: localized("intermittent.schedules.empty", default: "No saved schedules yet."),
            namePlaceholder: localized("intermittent.schedules.name_placeholder", default: "Schedule name (optional)"),
            startHourLabel: { hour in
                localizedFormat(
                    "intermittent.schedules.start_hour_format",
                    default: "Start hour: %@",
                    String(format: "%02d:00", hour))
            },
            weekdaysTitle: localized("intermittent.schedules.days", default: "Days"),
            weekdayLabel: weekdayLabel,
            applied: localized("intermittent.schedules.applied", default: "Applied"),
            planSummary: { plan in
                localizedFormat(
                    "intermittent.schedules.plan_summary_format",
                    default: "Target %dh • Start %@ • Days %@",
                    plan.targetHours,
                    String(format: "%02d:00", plan.startHour),
                    weekdayListText(plan.weekdays))
            },
            hideEditor: localized("intermittent.schedules.hide_editor", default: "Hide"),
            newSchedule: localized("intermittent.schedules.new_schedule", default: "New"),
            use: localized("intermittent.schedules.use", default: "Use"),
            edit: localized("intermittent.schedules.edit", default: "Edit"),
            delete: localized("intermittent.schedules.delete", default: "Delete"),
            update: localized("intermittent.schedules.update", default: "Update Schedule"),
            save: localized("intermittent.schedules.save_current", default: "Save Current Plan as Schedule"),
            cancelEdit: localized("intermittent.schedules.cancel_edit", default: "Cancel Edit"))
    }

    var intermittentRecoverySection: some View {
        Section(localized("intermittent.recovery.section", default: "Recovery Guidance")) {
            if intermittentTracker.activeStart == nil, let latest = intermittentTracker.sessions.first, !latest.completedTarget {
                Text(localized("intermittent.recovery.below_target", default: "Re-enter gently: choose a lighter target next time and hydrate well."))
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
                    .foregroundStyle(CatholicTheme.secondaryInk)
                Text(countdown)
                    .font(.system(size: liveTrackerCountdownFontSize, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(reached ? CatholicTheme.successForeground : CatholicTheme.primary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: liveTrackerRingSize, height: liveTrackerRingSize)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            reached
                ? localized("intermittent.live.ring.target", default: "Target")
                : localized("intermittent.live.ring.remaining", default: "Remaining"))
        .accessibilityValue(countdown)
        .accessibilityIdentifier("intermittent.live_ring")
    }

    func liveFastSummary(reached: Bool, start: Date, targetDate: Date) -> some View {
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
        intermittentIntentionLabel(for: intermittentIntentionRaw)
    }

    func intermittentIntentionLabel(for intentionID: String?) -> String {
        intermittentIntentionOptions.first(where: { $0.id == intentionID })?.label
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
                    hasEatingWindow ? CatholicTheme.accentForeground : CatholicTheme.primary,
                    style: StrokeStyle(lineWidth: liveTrackerRingStroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text(
                    hasEatingWindow
                        ? localized("intermittent.live.eating_window", default: "Eating Window")
                        : localized("intermittent.live.next_fast", default: "Next Fast"))
                    .font(liveTrackerLabelFont)
                    .foregroundStyle(.primary)
                Text(countdown)
                    .font(.system(size: liveTrackerCountdownFontSize, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(CatholicTheme.primary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(width: liveTrackerRingSize, height: liveTrackerRingSize)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            hasEatingWindow
                ? localized("intermittent.live.eating_window", default: "Eating Window")
                : localized("intermittent.live.next_fast", default: "Next Fast"))
        .accessibilityValue(countdown)
        .accessibilityIdentifier("intermittent.eating_ring")
    }

    func liveEatingSummary(
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
                                    : localized("intermittent.history.below_target", default: "Re-enter gently"))
                                .font(.caption)
                                .foregroundStyle(session.completedTarget ? CatholicTheme.successForeground : CatholicTheme.warningForeground)
                            Text(localizedFormat("intermittent.history.intention_format", default: "Intention: %@", intermittentIntentionLabel(for: session.intentionID)))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            if let note = session.note, !note.isEmpty {
                                Label(localized("intermittent.history.note_saved", default: "Note saved"), systemImage: "note.text")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(CatholicTheme.primary)
                            }
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
