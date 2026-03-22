import SwiftUI

extension ContentView {
    func ipadIntermittentHeroBand(compact: Bool) -> some View {
        IPadWorkspaceHeroBand(
            assetName: intermittentHeroArtwork.assetName,
            seasonLabel: currentLiturgicalSeason.label,
            title: "Track Fast",
            subtitle: intermittentTracker.activeStart == nil
                ? "Choose a target, then start when ready."
                : "Your live fast and next action stay here.",
            quote: intermittentFastingQuote,
            regionContext: RegionalGuidanceContextFactory.generalContext(for: settings),
            compact: compact,
            accessibilityIdentifier: "ipad.intermittent.hero"
        )
    }

    var ipadIntermittentLiveControlCenter: some View {
        VStack(alignment: .leading, spacing: 16) {
            IPadWorkspaceHeader(
                eyebrow: "Live",
                title: intermittentTracker.activeStart == nil ? "No active fast" : "Fast in progress",
                detail: intermittentTracker.activeStart == nil
                    ? "Set a target and start when ready."
                    : "Elapsed time, target, and next action stay together."
            )

            TimelineView(.periodic(from: .now, by: 1)) { context in
                Group {
                    let now = context.date
                    if let start = intermittentTracker.activeStart {
                        let targetSeconds = TimeInterval(intermittentTracker.presetHours * 3600)
                        let elapsed = max(0, now.timeIntervalSince(start))
                        let remaining = max(0, targetSeconds - elapsed)
                        let progress = min(1.0, elapsed / max(1, targetSeconds))
                        let targetDate = start.addingTimeInterval(targetSeconds)

                        HStack(alignment: .center, spacing: 18) {
                            liveFastRing(progress: progress, reached: progress >= 1, countdown: countdownText(progress >= 1 ? 0 : remaining))
                            VStack(alignment: .leading, spacing: 10) {
                                Text(progress >= 1 ? "Target reached" : "Fasting in progress")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(CatholicTheme.primary)
                                Text("Started \(start.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Target ends \(targetDate.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(progress >= 1 ? "You can end the fast now." : "Keep going to complete this target.")
                                    .font(.caption)
                                    .foregroundStyle(progress >= 1 ? .green : .secondary)
                            }
                            Spacer(minLength: 0)
                        }
                    } else if let latestSession = intermittentTracker.sessions.first {
                        let elapsedSinceEnd = max(0, now.timeIntervalSince(latestSession.end))
                        let eatingSeconds = latestSession.targetHours <= 24 ? TimeInterval(max(0, 24 - latestSession.targetHours) * 3600) : 0
                        let remaining = max(0, eatingSeconds - elapsedSinceEnd)
                        let progress = eatingSeconds > 0 ? min(1.0, elapsedSinceEnd / eatingSeconds) : 1

                        HStack(alignment: .center, spacing: 18) {
                            liveEatingRing(progress: progress, hasEatingWindow: eatingSeconds > 0, countdown: eatingSeconds > 0 ? countdownText(remaining) : "Ready")
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Between fasts")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(CatholicTheme.primary)
                                Text("Last fast ended \(latestSession.end.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(eatingSeconds > 0 ? "Eating window closes in \(countdownText(remaining))." : "This plan does not use a standard eating window.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No fasting session yet")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(CatholicTheme.primary)
                            Text("Choose a quick plan below, then start when ready.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
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
                eyebrow: "Controls",
                title: "Choose a target and act",
                detail: "Quick presets first. Custom longer fasts stay premium."
            )

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
                        Text("Custom target: \(intermittentTracker.presetHours)h")
                        Text("Longer personal disciplines up to 14 days remain available here.")
                            .appSupportingTextStyle()
                    }
                }
                .accessibilityIdentifier("ipad.intermittent.custom_target")
            } else {
                Text("Custom targets above the preset plans remain a premium feature.")
                    .appSupportingTextStyle()
            }

            HStack(spacing: 10) {
                if intermittentTracker.activeStart == nil {
                    Button("Start Fast") { intermittentTracker.startFast() }
                        .appPrimaryButtonStyle()
                        .accessibilityIdentifier("ipad.intermittent.start")
                } else {
                    Button("End Fast") { intermittentTracker.endFast() }
                        .appPrimaryButtonStyle(legacyTint: .green)
                        .accessibilityIdentifier("ipad.intermittent.end")
                    Button("Cancel") { intermittentTracker.cancelActiveFast() }
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
                eyebrow: "Planning",
                title: "Plan snapshot",
                detail: "Keep the current rhythm visible without crowding the live tracker."
            )

            HStack(spacing: 10) {
                IPadSummaryMetricCard(title: "Sessions", value: "\(intermittentTracker.sessions.count)", subtitle: "tracked locally")
                IPadSummaryMetricCard(title: "Plan", value: intermittentWindowLabel, subtitle: reminderTier.summary, tint: CatholicTheme.accent)
                IPadSummaryMetricCard(title: "Longest", value: intermittentLongestSessionText, subtitle: "best recent duration", tint: .orange)
            }

            Text(notificationStatus.isEmpty ? "Reminder status will appear after scheduling." : notificationStatus)
                .appSupportingTextStyle()
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.planning")
    }

    var ipadIntermittentAdvancedToolsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: "Advanced",
                title: "Schedules, milestones, and recovery",
                detail: "Keep deeper tools available without letting them lead the page."
            )
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
                        Text("Show advanced tools")
                            .font(.subheadline.weight(.semibold))
                        Text("Schedules, milestone stats, and recovery guidance.")
                            .appSupportingTextStyle()
                    }
                }
            )
            .accessibilityIdentifier("ipad.intermittent.advanced.disclosure")

            if !intermittentShowAdvanced {
                Text("Advanced tools stay collapsed until you need them.")
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
                eyebrow: "History",
                title: "Recent sessions",
                detail: "Review recent fasts without crowding the live controls."
            )
            intermittentSessionHistorySection
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.history")
    }
}
