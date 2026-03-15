import SwiftUI

extension ContentView {
    func ipadIntermittentHeroBand(compact: Bool) -> some View {
        IPadWorkspaceHeroBand(
            assetName: intermittentHeroArtwork.assetName,
            seasonLabel: currentLiturgicalSeason.label,
            title: "Intermittent Fasting Control Center",
            subtitle: "Keep the live fast, next eating window, and schedule choices together.",
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
                detail: "The ring, elapsed time, and next action stay in one place."
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
                                Text(progress >= 1 ? "You can end the fast at any time." : "Hold steady until the ring reaches the target.")
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
                                Text(eatingSeconds > 0 ? "Eating window closes in \(countdownText(remaining))." : "This plan does not use a standard daily eating window.")
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
                title: "Start, end, or adjust the fast",
                detail: "Quick presets stay simple; custom longer fasts remain a premium option."
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
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .appSurfaceCard(intermittentTracker.presetHours == hours ? .primary : .utility, cornerRadius: 16)
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
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityIdentifier("ipad.intermittent.custom_target")
            } else {
                Text("Custom targets above the preset plans remain a premium feature.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
                title: "Schedule and cadence",
                detail: "Review cadence, milestones, and recovery together."
            )

            HStack(spacing: 10) {
                IPadSummaryMetricCard(title: "Sessions", value: "\(intermittentTracker.sessions.count)", subtitle: "tracked locally")
                IPadSummaryMetricCard(title: "Plan", value: intermittentWindowLabel, subtitle: reminderTier.summary, tint: CatholicTheme.accent)
                IPadSummaryMetricCard(title: "Longest", value: intermittentLongestSessionText, subtitle: "best recent duration", tint: .orange)
            }

            DisclosureGroup("Schedules and milestones") {
                VStack(alignment: .leading, spacing: 12) {
                    intermittentScheduleSection
                    intermittentMilestonesSection
                    intermittentRecoverySection
                }
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.planning")
    }

    var ipadIntermittentMilestoneCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: "Status",
                title: "Reminder and recovery status",
                detail: "Pair the fast with a realistic cadence and recovery guidance."
            )
            Text(notificationStatus.isEmpty ? "Reminder status will appear here after scheduling." : notificationStatus)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            DisclosureGroup("Advanced tools") {
                VStack(alignment: .leading, spacing: 12) {
                    intermittentAdvancedToggleSection
                    if intermittentShowAdvanced {
                        intermittentOverviewSection
                    }
                }
            }
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.status")
    }

    var ipadIntermittentHistoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            IPadWorkspaceHeader(
                eyebrow: "History",
                title: "Recent sessions",
                detail: "Review the latest fasts without losing the live workspace."
            )
            intermittentSessionHistorySection
        }
        .padding(18)
        .iPadPaneCard()
        .accessibilityIdentifier("ipad.intermittent.history")
    }
}
