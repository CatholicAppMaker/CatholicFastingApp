import SwiftUI

extension ContentView {
    func ipadIntermittentHeroBand(compact: Bool) -> some View {
        IPadWorkspaceHeroBand(
            assetName: intermittentHeroArtwork.assetName,
            seasonLabel: localizedSeasonLabel(currentLiturgicalSeason),
            seasonContextLabel: localizedFormat("ipad.hero.season_label", default: "Liturgical Season: %@", localizedSeasonLabel(currentLiturgicalSeason)),
            title: localized("ipad.intermittent.hero.title", default: "Track Fast"),
            subtitle: intermittentTracker.activeStart == nil
                ? localized("ipad.intermittent.hero.subtitle_idle", default: "Choose a target, set the start time if needed, then begin.")
                : localized("ipad.intermittent.hero.subtitle_active", default: "Your live fast and next action stay here first."),
            quote: intermittentFastingQuote,
            regionContext: RegionalGuidanceContextFactory.generalContext(for: settings),
            compact: compact,
            accessibilityIdentifier: "ipad.intermittent.hero")
    }

    var ipadIntermittentLiveControlCenter: some View {
        VStack(alignment: .leading, spacing: 16) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.intermittent.live.eyebrow", default: "Live"),
                title: intermittentTracker.activeStart == nil
                    ? localized("ipad.intermittent.live.title_idle", default: "No active fast")
                    : localized("ipad.intermittent.live.title_active", default: "Fast in progress"),
                detail: intermittentTracker.activeStart == nil
                    ? localized("ipad.intermittent.live.detail_idle", default: "Set a target and start when ready.")
                    : localized("ipad.intermittent.live.detail_active", default: "Elapsed time, target, and next action stay together."))

            if let activeStart = intermittentTracker.activeStart {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let now = context.date
                    let start = intermittentTracker.activeStart ?? activeStart
                    let targetSeconds = TimeInterval(intermittentTracker.presetHours * 3600)
                    let elapsed = max(0, now.timeIntervalSince(start))
                    let remaining = max(0, targetSeconds - elapsed)
                    let progress = min(1.0, elapsed / max(1, targetSeconds))
                    let targetDate = start.addingTimeInterval(targetSeconds)

                    HStack(alignment: .center, spacing: 18) {
                        liveFastRing(progress: progress, reached: progress >= 1, countdown: countdownText(progress >= 1 ? 0 : remaining))
                        VStack(alignment: .leading, spacing: 10) {
                            Text(
                                progress >= 1
                                    ? localized("ipad.intermittent.live.target_reached", default: "Target reached")
                                    : localized("ipad.intermittent.live.fasting", default: "Fasting in progress"))
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(CatholicTheme.primary)
                            Text(localizedFormat("ipad.intermittent.live.started", default: "Started %@", start.formatted(date: .abbreviated, time: .shortened)))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(localizedFormat("ipad.intermittent.live.ends", default: "Target ends %@", targetDate.formatted(date: .abbreviated, time: .shortened)))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(
                                progress >= 1
                                    ? localized("ipad.intermittent.live.can_end", default: "You can end the fast now.")
                                    : localized("ipad.intermittent.live.keep_going", default: "Keep going to complete this target."))
                                .appSupportingTextStyle()
                                .foregroundStyle(progress >= 1 ? .green : .secondary)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .id(activeStart)
            } else if let latestSession = intermittentTracker.sessions.first {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let now = context.date
                    let elapsedSinceEnd = max(0, now.timeIntervalSince(latestSession.end))
                    let eatingSeconds = latestSession.targetHours <= 24 ? TimeInterval(max(0, 24 - latestSession.targetHours) * 3600) : 0
                    let remaining = max(0, eatingSeconds - elapsedSinceEnd)
                    let progress = eatingSeconds > 0 ? min(1.0, elapsedSinceEnd / eatingSeconds) : 1

                    HStack(alignment: .center, spacing: 18) {
                        liveEatingRing(progress: progress, hasEatingWindow: eatingSeconds > 0, countdown: eatingSeconds > 0 ? countdownText(remaining) : "Ready")
                        VStack(alignment: .leading, spacing: 10) {
                            Text(localized("ipad.intermittent.live.between_fasts", default: "Between fasts"))
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(CatholicTheme.primary)
                            Text(localizedFormat("ipad.intermittent.live.last_ended", default: "Last fast ended %@", latestSession.end.formatted(date: .abbreviated, time: .shortened)))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(
                                eatingSeconds > 0
                                    ? localizedFormat("ipad.intermittent.live.window_closes", default: "Eating window closes in %@.", countdownText(remaining))
                                    : localized("ipad.intermittent.live.no_eating_window", default: "This plan does not use a standard eating window."))
                                .appSupportingTextStyle()
                        }
                        Spacer(minLength: 0)
                    }
                }
                .id(latestSession.id)
            } else {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localized("ipad.intermittent.live.empty_title", default: "No fasting session yet"))
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(CatholicTheme.primary)
                        Text(localized("ipad.intermittent.live.empty_detail", default: "Choose a quick plan below, then start when ready."))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.live")
    }

    var ipadIntermittentQuickPlansCard: some View {
        let quickPlans = [12, 14, 16, 18, 20, 24, 36]

        return VStack(alignment: .leading, spacing: 16) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.intermittent.controls.eyebrow", default: "Controls"),
                title: localized("ipad.intermittent.controls.title", default: "Set the target and start"),
                detail: localized("ipad.intermittent.controls.detail", default: "Quick presets first. Adjust the start time if you already began fasting."))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(quickPlans, id: \.self) { hours in
                    Button {
                        intermittentPresetBinding.wrappedValue = hours
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(hours)h")
                                .font(.headline)
                            Text(intermittentPlanDescription(hours))
                                .appSupportingTextStyle()
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .appInteractiveTileStyle(isSelected: intermittentTracker.presetHours == hours)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("ipad.intermittent.plan.\(hours)")
                }
            }
            .accessibilityIdentifier("ipad.intermittent.preset_picker")

            if monetizationStore.premiumUnlocked {
                Stepper(value: intermittentPresetBinding, in: 12 ... 336, step: 1) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(localizedFormat("ipad.intermittent.controls.custom_target", default: "Custom target: %dh", intermittentTracker.presetHours))
                        Text(localized("ipad.intermittent.controls.custom_target_detail", default: "Longer personal disciplines up to 14 days remain available here."))
                            .appSupportingTextStyle()
                    }
                }
                .accessibilityIdentifier("ipad.intermittent.custom_target")
            } else {
                Text(localized("ipad.intermittent.controls.custom_target_premium", default: "Custom targets above the preset plans remain a premium feature."))
                    .appSupportingTextStyle()
            }

            if intermittentTracker.activeStart == nil {
                DatePicker(
                    localized("ipad.intermittent.controls.started", default: "Started"),
                    selection: $intermittentManualStart,
                    in: intermittentManualStartRange,
                    displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("ipad.intermittent.start_date")

                Text(localized("ipad.intermittent.controls.started_hint", default: "If you already began fasting, backdate the start time here before you start the timer."))
                    .appSupportingTextStyle()
            } else {
                DatePicker(
                    localized("ipad.intermittent.controls.started", default: "Started"),
                    selection: intermittentActiveStartBinding,
                    in: intermittentManualStartRange,
                    displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .accessibilityIdentifier("ipad.intermittent.start_date")

                Text(localized("ipad.intermittent.controls.adjust_hint", default: "If you started earlier than the timer, adjust the start time here and the live tracker updates immediately."))
                    .appSupportingTextStyle()
            }

            HStack(spacing: 10) {
                if intermittentTracker.activeStart == nil {
                    Button(localized("ipad.intermittent.controls.start", default: "Start Fast")) { startIntermittentFastFromSelectedTime() }
                        .appPrimaryButtonStyle()
                        .accessibilityIdentifier("ipad.intermittent.start")
                } else {
                    Button(localized("ipad.intermittent.controls.end", default: "End Fast")) {
                        intermittentTracker.endFast()
                        resetIntermittentManualStartToNow()
                    }
                    .appPrimaryButtonStyle(legacyTint: .green)
                    .accessibilityIdentifier("ipad.intermittent.end")

                    Button(localized("ipad.intermittent.controls.cancel", default: "Cancel")) {
                        intermittentTracker.cancelActiveFast()
                        resetIntermittentManualStartToNow()
                    }
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("ipad.intermittent.cancel")
                }
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.controls")
    }

    var ipadIntermittentPlanningCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.intermittent.planning.eyebrow", default: "Planning"),
                title: localized("ipad.intermittent.planning.title", default: "Current plan"),
                detail: localized("ipad.intermittent.planning.detail", default: "Keep the current rhythm visible without crowding the live tracker."))

            HStack(spacing: 10) {
                IPadSummaryMetricCard(title: localized("ipad.intermittent.planning.sessions", default: "Sessions"), value: "\(intermittentTracker.sessions.count)", subtitle: localized("ipad.intermittent.planning.sessions_detail", default: "tracked locally"))
                IPadSummaryMetricCard(title: localized("ipad.intermittent.planning.plan", default: "Plan"), value: intermittentWindowLabel, subtitle: reminderTier.summary, tint: CatholicTheme.accent)
                IPadSummaryMetricCard(title: localized("ipad.intermittent.planning.longest", default: "Longest"), value: intermittentLongestSessionText, subtitle: localized("ipad.intermittent.planning.longest_detail", default: "best recent duration"), tint: .orange)
            }

            Text(notificationStatus.isEmpty ? localized("ipad.intermittent.planning.notification_empty", default: "Reminder status will appear after scheduling.") : notificationStatus)
                .appSupportingTextStyle()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appSurfaceCard(.utility, cornerRadius: 14)
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.planning")
    }

    var ipadIntermittentAdvancedToolsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.intermittent.advanced.eyebrow", default: "Advanced"),
                title: localized("ipad.intermittent.advanced.title", default: "Schedules, milestones, and recovery"),
                detail: localized("ipad.intermittent.advanced.detail", default: "Keep deeper tools available without letting them lead the page."))
            DisclosureGroup(
                isExpanded: $intermittentShowAdvanced,
                content: {
                    VStack(alignment: .leading, spacing: 12) {
                        intermittentScheduleSection
                        intermittentMilestonesSection
                        intermittentRecoverySection
                    }
                },
                label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localized("ipad.intermittent.advanced.show", default: "Show advanced tools"))
                            .font(.subheadline.weight(.semibold))
                        Text(localized("ipad.intermittent.advanced.show_detail", default: "Schedules, milestone stats, and recovery guidance."))
                            .appSupportingTextStyle()
                    }
                })
                .accessibilityIdentifier("ipad.intermittent.advanced.disclosure")

            if !intermittentShowAdvanced {
                Text(localized("ipad.intermittent.advanced.collapsed_hint", default: "Advanced tools stay collapsed until you need them."))
                    .appSupportingTextStyle()
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.advanced")
    }

    var ipadIntermittentHistoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: localized("ipad.intermittent.history.eyebrow", default: "History"),
                title: localized("ipad.intermittent.history.title", default: "Recent sessions"),
                detail: localized("ipad.intermittent.history.detail", default: "Review recent fasts without crowding the live controls."))
            intermittentSessionHistorySection
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.history")
    }
}
