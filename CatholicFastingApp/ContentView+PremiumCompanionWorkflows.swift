import SwiftUI

extension ContentView {
    private func localizedVirtueLabel(_ virtue: String) -> String {
        switch virtue {
        case "Temperance":
            localized("premium.virtue.temperance", default: "Temperance")
        case "Patience":
            localized("premium.virtue.patience", default: "Patience")
        case "Charity":
            localized("premium.virtue.charity", default: "Charity")
        case "Humility":
            localized("premium.virtue.humility", default: "Humility")
        case "Obedience":
            localized("premium.virtue.obedience", default: "Obedience")
        default:
            virtue
        }
    }

    var premiumChecklistSection: some View {
        Section(localized("premium.checklist.section", default: "Consistency Checklist")) {
            Text(localized("premium.checklist.intro", default: "Keep one clear next step visible instead of carrying the whole season in your head."))
                .font(.caption)
                .foregroundStyle(.secondary)
            if !monetizationStore.premiumUnlocked {
                Text(localized("premium.checklist.unlock_hint", default: "Unlock Premium to keep a focused consistency checklist."))
                    .foregroundStyle(.secondary)
            } else {
                if premiumChecklist.isEmpty {
                    Text(localized("premium.checklist.empty", default: "No checklist items yet. Add one to keep your next Catholic fasting step visible."))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(premiumChecklist) { item in
                        Button {
                            toggleChecklistItem(item.id)
                        } label: {
                            HStack {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isDone ? CatholicTheme.successForeground : .secondary)
                                Text(item.title)
                                    .strikethrough(item.isDone, color: .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("premium.checklist.\(item.id)")
                    }
                }
                Button(localized("premium.checklist.add_suggested", default: "Add Suggested Checklist Item")) {
                    premiumChecklist.append(
                        PremiumChecklistItem(
                            id: UUID().uuidString,
                            title: localized("premium.checklist.suggested_item", default: "Review upcoming required observances for next 30 days"),
                            isDone: false))
                }
                .appSecondaryButtonStyle()
            }
        }
    }

    var reflectionJournalSection: some View {
        Section(localized("premium.journal.section", default: "Reflection & Review (Local)")) {
            if !monetizationStore.premiumUnlocked {
                Text(localized("premium.journal.unlock_hint", default: "Premium unlocks local reflection and review tools."))
                    .foregroundStyle(.secondary)
            } else {
                Text(localized("premium.journal.intro", default: "Keep reflections short. The goal is consistency, not long journaling."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(localized("premium.journal.title_placeholder", default: "Reflection title"), text: $newReflectionTitle)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("premium.journal.title")
                TextField(localized("premium.journal.body_placeholder", default: "Write a short reflection"), text: $newReflectionBody, axis: .vertical)
                    .lineLimit(2 ... 5)
                    .accessibilityIdentifier("premium.journal.body")
                Button(localized("premium.journal.save", default: "Save Reflection")) {
                    addReflectionEntry()
                }
                .appPrimaryButtonStyle()
                .disabled(!canSaveReflection)
                .accessibilityIdentifier("premium.journal.save")

                if reflectionEntries.isEmpty {
                    Text(localized("premium.journal.empty", default: "No reflections yet. Capture one short line after your fast to build a faithful habit."))
                        .foregroundStyle(.secondary)
                } else {
                    DisclosureGroup(localized("premium.journal.recent", default: "Recent reflections")) {
                        ForEach(reflectionEntries.prefix(5)) { entry in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.title)
                                    .font(.subheadline.weight(.semibold))
                                Text(entry.body)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                ShareLink(item: seasonPlanExportText) {
                    Label(localized("premium.journal.export_plan", default: "Export Season Plan (Text)"), systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)
            }
        }
    }

    var premiumPlannerSection: some View {
        Section(localized("premium.planner.section", default: "Discipline Planner")) {
            Text(localized("premium.planner.intro", default: "Set a realistic season path, cadence, and guardrails."))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            DisclosureGroup(localized("premium.planner.controls", default: "Planner controls")) {
                Picker(
                    localized("premium.planner.rule_template", default: "Rule Template"),
                    selection: Binding(
                        get: { selectedPremiumTemplate },
                        set: { applyPremiumRuleTemplate($0) }))
                {
                    ForEach(PremiumRuleTemplate.allCases) { template in
                        Text(template.label).tag(template)
                    }
                }
                .pickerStyle(.menu)

                Stepper(
                    localizedFormat(
                        "premium.planner.optional_per_week_format",
                        default: "Optional disciplines/week: %d",
                        premiumCompanion.optionalDisciplinesPerWeek),
                    value: $premiumCompanion.optionalDisciplinesPerWeek,
                    in: 0 ... 7)
                Stepper(
                    localizedFormat(
                        "premium.planner.fixed_fast_day_format",
                        default: "Fixed personal fast day: %@",
                        weekdayLabel(for: premiumCompanion.fixedFastWeekday)),
                    value: $premiumCompanion.fixedFastWeekday,
                    in: 1 ... 7)
                Toggle(localized("premium.planner.protect_feasts", default: "Protect feast/holy days from personal fasts"), isOn: $premiumCompanion.protectFeastDays)
            }

            Text(premiumAdaptivePlan.title)
                .font(.subheadline.weight(.semibold))
            Text(premiumAdaptivePlan.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(premiumAdaptivePlan.weeklyActions, id: \.self) { action in
                Text("• \(action)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(premiumAdaptivePlan.caution)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Divider()

            Text(localizedFormat("premium.planner.season_plan_format", default: "Season Plan: %@", premiumSeasonPlan.titleLine))
                .font(.subheadline.weight(.semibold))
            Text(premiumSeasonPlan.focusLine)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(localizedFormat("premium.planner.intensity_format", default: "Intensity: %@", premiumSeasonPlan.fastingIntensity))
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(premiumSeasonPlan.practices, id: \.self) { practice in
                Text("• \(practice)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("premium.planner")
    }

    var premiumRemindersSection: some View {
        Section(localized("premium.reminders.section", default: "Reminders")) {
            Text(localized("premium.reminders.intro", default: "Start with the recommendation first. Use advanced rules only if you need more pressure or structure."))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(localized("premium.reminders.smart", default: "Smart Recommendation"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(premiumReminderRecommendation.summaryLine)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(premiumReminderRecommendationLine)
                .font(.caption)
                .foregroundStyle(.secondary)

            Button(localized("premium.reminders.apply_smart", default: "Apply Smart Reminder Plan")) {
                applyPremiumReminderRecommendation()
            }
            .appPrimaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
            .accessibilityIdentifier("premium.apply_reminder_plan")

            DisclosureGroup(localized("premium.reminders.advanced", default: "Advanced reminder rules")) {
                Toggle(
                    localized(
                        "premium.reminders.rule.unlogged_by_noon",
                        default: "Remind if no fasting log by noon"),
                    isOn: $premiumCompanion.conditionRules.remindIfUnloggedByNoon)
                Toggle(
                    localized(
                        "premium.reminders.rule.double_required",
                        default: "Double reminders on required days"),
                    isOn: $premiumCompanion.conditionRules.requiredDaysDoubleReminder)
                Toggle(
                    localized(
                        "premium.reminders.rule.milestones",
                        default: "Milestone nudges during active fast"),
                    isOn: $premiumCompanion.conditionRules.milestoneNudgesForActiveFast)

                Button(localized("premium.reminders.apply_rules", default: "Apply Condition Rules")) {
                    applyPremiumConditionRules()
                }
                .appSecondaryButtonStyle()
            }

            if !premiumCoachStatus.isEmpty {
                Text(premiumCoachStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("premium.coach_status")
            }
            if !premiumCompanionStatus.isEmpty {
                Text(premiumCompanionStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("premium.reminders")
    }

    var premiumAnalyticsSection: some View {
        Section(localized("premium.analytics.section", default: "Analytics")) {
            Text(localized("premium.analytics.intro", default: "Review completion, consistency, and seasonal trend lines."))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(localizedFormat("premium.analytics.required_format", default: "Required completion: %d%%", premiumAnalyticsSummary.requiredCompletionPercent))
                .font(.caption)
            Text(localizedFormat("premium.analytics.overall_format", default: "Overall completion: %d%%", premiumAnalyticsSummary.overallCompletionPercent))
                .font(.caption)
            Text(
                localizedFormat(
                    "premium.analytics.missed_format",
                    default: "Missed: %d • Substituted: %d",
                    premiumAnalyticsSummary.missedCount,
                    premiumAnalyticsSummary.substitutedCount))
                .font(.caption)
            Text(localizedFormat("premium.analytics.intermittent_hits_format", default: "Intermittent target hits: %d%%", premiumAnalyticsSummary.intermittentTargetHitPercent))
                .font(.caption)

            if !premiumAnalyticsSummary.seasonRows.isEmpty {
                DisclosureGroup(localized("premium.analytics.breakdown", default: "Season-by-season breakdown")) {
                    ForEach(premiumAnalyticsSummary.seasonRows) { row in
                        Text(
                            localizedFormat(
                                "premium.analytics.season_row_format",
                                default: "%@: %d%% (%d/%d)",
                                localizedSeasonLabel(row.season),
                                row.completionPercent,
                                row.completedCount,
                                row.totalCount))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .accessibilityIdentifier("premium.analytics")
    }

    private var premiumReminderRecommendationLine: String {
        let enabledText = localized("shared.on", default: "On")
        let disabledText = localized("shared.off", default: "Off")
        let segments = [
            "\(localized("premium.reminders.daily_support", default: "Daily support")): \(premiumReminderRecommendation.shouldEnableDailySupport ? enabledText : disabledText)",
            "\(localized("premium.reminders.morning", default: "Morning")): \(premiumReminderRecommendation.shouldEnableMorning ? enabledText : disabledText)",
            "\(localized("premium.reminders.evening", default: "Evening")): \(premiumReminderRecommendation.shouldEnableEvening ? enabledText : disabledText)",
        ]
        return segments.joined(separator: " • ")
    }

    var premiumRecoveryCoachSection: some View {
        Section(localized("premium.recovery.section", default: "Recovery Coaching")) {
            Text(premiumRecoveryCoachPlan.title)
                .font(.subheadline.weight(.semibold))
            Text(premiumRecoveryCoachPlan.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(premiumRecoveryCoachPlan.steps, id: \.self) { step in
                Text("• \(step)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("premium.recovery")
    }

    var premiumReflectionPromptSection: some View {
        Section(localized("premium.reflection.section", default: "Daily Premium Reflection")) {
            Text(premiumReflection.title)
                .font(.subheadline.weight(.semibold))
            Text(premiumReflection.body)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(localizedFormat("premium.reflection.action_format", default: "Action: %@", premiumReflection.action))
                .font(.caption)
                .foregroundStyle(CatholicTheme.primary)
        }
        .accessibilityIdentifier("premium.reflection")
    }

    var premiumVirtueTrackingSection: some View {
        Section(localized("premium.virtue.section", default: "Virtue Check-ins")) {
            Text(localized("premium.virtue.intro", default: "Use one short note to connect fasting effort with a concrete virtue."))
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker(localized("premium.virtue.picker", default: "Virtue"), selection: $selectedVirtue) {
                ForEach(["Temperance", "Patience", "Charity", "Humility", "Obedience"], id: \.self) { virtue in
                    Text(localizedVirtueLabel(virtue)).tag(virtue)
                }
            }
            .pickerStyle(.menu)

            TextField(localized("premium.virtue.note_placeholder", default: "Virtue note"), text: $newVirtueNote, axis: .vertical)
                .lineLimit(2 ... 4)
            Button(localized("premium.virtue.log", default: "Log Virtue Check-in")) {
                addPremiumVirtueLog()
            }
            .appPrimaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
            .disabled(newVirtueNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if premiumCompanion.virtueLogs.isEmpty {
                Text(localized("premium.virtue.empty", default: "No virtue check-ins yet."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(premiumCompanion.virtueLogs.prefix(5)) { log in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(localizedVirtueLabel(log.virtue)) • \(log.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption.weight(.semibold))
                            Text(log.note)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(role: .destructive) {
                            deletePremiumVirtueLog(log)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .accessibilityIdentifier("premium.virtue")
    }

    var premiumExportSummarySection: some View {
        Section(localized("premium.export.section", default: "Export Summary")) {
            ShareLink(
                item: premiumDirectionSummaryText,
                subject: Text(localized("premium.export.subject", default: "Catholic Fasting Summary")),
                message: Text(localized("premium.export.message", default: "Structured fasting summary for personal review.")))
            {
                Label(localized("premium.export.button", default: "Export Fasting Summary"), systemImage: "square.and.arrow.up")
            }
            .appSecondaryButtonStyle()
            .disabled(!acceptedLegalNotice)
            .accessibilityIdentifier("premium.export_summary")

            Text(localized("premium.export.summary_note", default: "Use this when you want one concise snapshot for personal review or spiritual conversation."))
                .font(.caption)
                .foregroundStyle(.secondary)

            if !acceptedLegalNotice {
                Text(localized("premium.export.consent_note", default: "Enable consent in Privacy & Data before exporting premium summaries."))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var premiumAdvancedExportSection: some View {
        Section(localized("premium.export.advanced.section", default: "Advanced Exports")) {
            DisclosureGroup(localized("premium.export.advanced.group", default: "Weekly and monthly reports")) {
                ShareLink(
                    item: premiumWeeklySummaryText,
                    subject: Text(localized("premium.export.weekly.subject", default: "Catholic Fasting Weekly Report")),
                    message: Text(localized("premium.export.weekly.message", default: "Weekly fasting summary from Premium.")))
                {
                    Label(localized("premium.export.weekly.button", default: "Export Weekly Report"), systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)

                ShareLink(
                    item: premiumMonthlySummaryText,
                    subject: Text(localized("premium.export.monthly.subject", default: "Catholic Fasting Monthly Report")),
                    message: Text(localized("premium.export.monthly.message", default: "Monthly fasting summary from Premium.")))
                {
                    Label(localized("premium.export.monthly.button", default: "Export Monthly Report"), systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)
            }
        }
    }

    var premiumHouseholdShareSection: some View {
        Section(localized("premium.household.section", default: "Household Share (Local)")) {
            Text(localized("premium.household.intro", default: "This is a local transfer tool for households sharing one device workflow. It is not cloud sync."))
                .font(.caption)
                .foregroundStyle(.secondary)
            DisclosureGroup(localized("premium.household.group", default: "Share code tools")) {
                Button(localized("premium.household.generate", default: "Generate Local Share Code")) {
                    generatePremiumHouseholdShareCode()
                }
                .appSecondaryButtonStyle()
                if !premiumHouseholdExportCode.isEmpty {
                    Text(premiumHouseholdExportCode)
                        .font(.caption2.monospaced())
                        .textSelection(.enabled)
                }
                TextField(localized("premium.household.import.placeholder", default: "Paste household share code"), text: $premiumHouseholdImportCode, axis: .vertical)
                    .lineLimit(2 ... 6)
                Button(localized("premium.household.import.button", default: "Import Household Code (Local)")) {
                    importPremiumHouseholdShareCode()
                }
                .appSecondaryButtonStyle()
                .disabled(premiumHouseholdImportCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if !premiumCompanionStatus.isEmpty {
                Text(premiumCompanionStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
