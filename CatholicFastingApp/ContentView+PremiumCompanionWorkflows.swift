import SwiftUI

extension ContentView {
    var premiumChecklistSection: some View {
        Section("Consistency Checklist") {
            Text("Keep one clear next step visible instead of carrying the whole season in your head.")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !monetizationStore.premiumUnlocked {
                Text("Unlock Premium to keep a focused consistency checklist.")
                    .foregroundStyle(.secondary)
            } else {
                if premiumChecklist.isEmpty {
                    Text("No checklist items yet. Add one to keep your next Catholic fasting step visible.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(premiumChecklist) { item in
                        Button {
                            toggleChecklistItem(item.id)
                        } label: {
                            HStack {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isDone ? .green : .secondary)
                                Text(item.title)
                                    .strikethrough(item.isDone, color: .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("premium.checklist.\(item.id)")
                    }
                }
                Button("Add Suggested Checklist Item") {
                    premiumChecklist.append(
                        PremiumChecklistItem(
                            id: UUID().uuidString,
                            title: "Review upcoming required observances for next 30 days",
                            isDone: false))
                }
                .appSecondaryButtonStyle()
            }
        }
    }

    var reflectionJournalSection: some View {
        Section("Reflection & Review (Local)") {
            if !monetizationStore.premiumUnlocked {
                Text("Premium unlocks local reflection and review tools.")
                    .foregroundStyle(.secondary)
            } else {
                Text("Keep reflections short. The goal is consistency, not long journaling.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Reflection title", text: $newReflectionTitle)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("premium.journal.title")
                TextField("Write a short reflection", text: $newReflectionBody, axis: .vertical)
                    .lineLimit(2 ... 5)
                    .accessibilityIdentifier("premium.journal.body")
                Button("Save Reflection") {
                    addReflectionEntry()
                }
                .appPrimaryButtonStyle()
                .disabled(!canSaveReflection)
                .accessibilityIdentifier("premium.journal.save")

                if reflectionEntries.isEmpty {
                    Text("No reflections yet. Capture one short line after your fast to build a faithful habit.")
                        .foregroundStyle(.secondary)
                } else {
                    DisclosureGroup("Recent reflections") {
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
                    Label("Export Season Plan (Text)", systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)
            }
        }
    }

    var premiumPlannerSection: some View {
        Section("Discipline Planner") {
            Text("Set a realistic season path, cadence, and guardrails.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            DisclosureGroup("Planner controls") {
                Picker(
                    "Rule Template",
                    selection: Binding(
                        get: { selectedPremiumTemplate },
                        set: { applyPremiumRuleTemplate($0) }))
                {
                    ForEach(PremiumRuleTemplate.allCases) { template in
                        Text(template.label).tag(template)
                    }
                }
                .pickerStyle(.menu)

                Stepper("Optional disciplines/week: \(premiumCompanion.optionalDisciplinesPerWeek)", value: $premiumCompanion.optionalDisciplinesPerWeek, in: 0 ... 7)
                Stepper("Fixed personal fast day: \(weekdayLabel(for: premiumCompanion.fixedFastWeekday))", value: $premiumCompanion.fixedFastWeekday, in: 1 ... 7)
                Toggle("Protect feast/holy days from personal fasts", isOn: $premiumCompanion.protectFeastDays)
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

            Text("Season Plan: \(premiumSeasonPlan.titleLine)")
                .font(.subheadline.weight(.semibold))
            Text(premiumSeasonPlan.focusLine)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Intensity: \(premiumSeasonPlan.fastingIntensity)")
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
        Section("Reminders") {
            Text("Start with the recommendation first. Use advanced rules only if you need more pressure or structure.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Smart Recommendation")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(premiumReminderRecommendation.summaryLine)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(
                "Daily support: \(premiumReminderRecommendation.shouldEnableDailySupport ? "On" : "Off") • Morning: \(premiumReminderRecommendation.shouldEnableMorning ? "On" : "Off") • Evening: \(premiumReminderRecommendation.shouldEnableEvening ? "On" : "Off")")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Apply Smart Reminder Plan") {
                applyPremiumReminderRecommendation()
            }
            .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
            .accessibilityIdentifier("premium.apply_reminder_plan")

            DisclosureGroup("Advanced reminder rules") {
                Toggle("Remind if no fasting log by noon", isOn: $premiumCompanion.conditionRules.remindIfUnloggedByNoon)
                Toggle("Double reminders on required days", isOn: $premiumCompanion.conditionRules.requiredDaysDoubleReminder)
                Toggle("Milestone nudges during active fast", isOn: $premiumCompanion.conditionRules.milestoneNudgesForActiveFast)

                Button("Apply Condition Rules") {
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
        Section("Analytics") {
            Text("Review completion, consistency, and seasonal trend lines.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Required completion: \(premiumAnalyticsSummary.requiredCompletionPercent)%")
                .font(.caption)
            Text("Overall completion: \(premiumAnalyticsSummary.overallCompletionPercent)%")
                .font(.caption)
            Text("Missed: \(premiumAnalyticsSummary.missedCount) • Substituted: \(premiumAnalyticsSummary.substitutedCount)")
                .font(.caption)
            Text("Intermittent target hits: \(premiumAnalyticsSummary.intermittentTargetHitPercent)%")
                .font(.caption)

            if !premiumAnalyticsSummary.seasonRows.isEmpty {
                DisclosureGroup("Season-by-season breakdown") {
                    ForEach(premiumAnalyticsSummary.seasonRows) { row in
                        Text("\(row.season.label): \(row.completionPercent)% (\(row.completedCount)/\(row.totalCount))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .accessibilityIdentifier("premium.analytics")
    }

    var premiumRecoveryCoachSection: some View {
        Section("Recovery Coaching") {
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
        Section("Daily Premium Reflection") {
            Text(premiumReflection.title)
                .font(.subheadline.weight(.semibold))
            Text(premiumReflection.body)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Action: \(premiumReflection.action)")
                .font(.caption)
                .foregroundStyle(CatholicTheme.primary)
        }
        .accessibilityIdentifier("premium.reflection")
    }

    var premiumVirtueTrackingSection: some View {
        Section("Virtue Check-ins") {
            Text("Use one short note to connect fasting effort with a concrete virtue.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Virtue", selection: $selectedVirtue) {
                ForEach(["Temperance", "Patience", "Charity", "Humility", "Obedience"], id: \.self) { virtue in
                    Text(virtue).tag(virtue)
                }
            }
            .pickerStyle(.menu)

            TextField("Virtue note", text: $newVirtueNote, axis: .vertical)
                .lineLimit(2 ... 4)
            Button("Log Virtue Check-in") {
                addPremiumVirtueLog()
            }
            .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
            .disabled(newVirtueNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if premiumCompanion.virtueLogs.isEmpty {
                Text("No virtue check-ins yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(premiumCompanion.virtueLogs.prefix(5)) { log in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(log.virtue) • \(log.createdAt.formatted(date: .abbreviated, time: .shortened))")
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
        Section("Export Summary") {
            ShareLink(
                item: premiumDirectionSummaryText,
                subject: Text("Catholic Fasting Summary"),
                message: Text("Structured fasting summary for personal review."))
            {
                Label("Export Fasting Summary", systemImage: "square.and.arrow.up")
            }
            .appSecondaryButtonStyle()
            .disabled(!acceptedLegalNotice)
            .accessibilityIdentifier("premium.export_summary")

            Text("Use this when you want one concise snapshot for personal review or spiritual conversation.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if !acceptedLegalNotice {
                Text("Enable consent in Privacy & Data before exporting premium summaries.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var premiumAdvancedExportSection: some View {
        Section("Advanced Exports") {
            DisclosureGroup("Weekly and monthly reports") {
                ShareLink(
                    item: premiumWeeklySummaryText,
                    subject: Text("Catholic Fasting Weekly Report"),
                    message: Text("Weekly fasting summary from Premium."))
                {
                    Label("Export Weekly Report", systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)

                ShareLink(
                    item: premiumMonthlySummaryText,
                    subject: Text("Catholic Fasting Monthly Report"),
                    message: Text("Monthly fasting summary from Premium."))
                {
                    Label("Export Monthly Report", systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)
            }
        }
    }

    var premiumHouseholdShareSection: some View {
        Section("Household Share (Local)") {
            Text("This is a local transfer tool for households sharing one device workflow. It is not cloud sync.")
                .font(.caption)
                .foregroundStyle(.secondary)
            DisclosureGroup("Share code tools") {
                Button("Generate Local Share Code") {
                    generatePremiumHouseholdShareCode()
                }
                .appSecondaryButtonStyle()
                if !premiumHouseholdExportCode.isEmpty {
                    Text(premiumHouseholdExportCode)
                        .font(.caption2.monospaced())
                        .textSelection(.enabled)
                }
                TextField("Paste household share code", text: $premiumHouseholdImportCode, axis: .vertical)
                    .lineLimit(2 ... 6)
                Button("Import Household Code (Local)") {
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

    var premiumCompanionLabSection: some View {
        Section("Premium Companion Lab") {
            if !monetizationStore.premiumUnlocked {
                Text("Unlock Premium to access adaptive planning, advanced exports, season programs, virtue tracking, and private household sharing.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Adaptive Rule-of-Life Planner")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Picker(
                        "Rule Template",
                        selection: Binding(
                            get: { selectedPremiumTemplate },
                            set: { applyPremiumRuleTemplate($0) }))
                    {
                        ForEach(PremiumRuleTemplate.allCases) { template in
                            Text(template.label).tag(template)
                        }
                    }
                    .pickerStyle(.menu)

                    Stepper("Optional disciplines/week: \(premiumCompanion.optionalDisciplinesPerWeek)", value: $premiumCompanion.optionalDisciplinesPerWeek, in: 0 ... 7)
                    Stepper("Fixed personal fast day: \(weekdayLabel(for: premiumCompanion.fixedFastWeekday))", value: $premiumCompanion.fixedFastWeekday, in: 1 ... 7)
                    Toggle("Protect feast/holy days from personal fasts", isOn: $premiumCompanion.protectFeastDays)

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
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("2. Condition-based Reminder Engine")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Toggle("Remind if no fasting log by noon", isOn: $premiumCompanion.conditionRules.remindIfUnloggedByNoon)
                    Toggle("Double reminders on required days", isOn: $premiumCompanion.conditionRules.requiredDaysDoubleReminder)
                    Toggle("Milestone nudges during active fast", isOn: $premiumCompanion.conditionRules.milestoneNudgesForActiveFast)

                    Button("Apply Condition Rules") {
                        applyPremiumConditionRules()
                    }
                    .appSecondaryButtonStyle()
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("3. Recovery Coaching")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
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

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("4. Advanced Export Pack")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ShareLink(
                        item: premiumWeeklySummaryText,
                        subject: Text("Catholic Fasting Weekly Report"),
                        message: Text("Weekly fasting summary from Premium."))
                    {
                        Label("Export Weekly Report", systemImage: "square.and.arrow.up")
                    }
                    .appSecondaryButtonStyle()
                    .disabled(!acceptedLegalNotice)

                    ShareLink(
                        item: premiumMonthlySummaryText,
                        subject: Text("Catholic Fasting Monthly Report"),
                        message: Text("Monthly fasting summary from Premium."))
                    {
                        Label("Export Monthly Report", systemImage: "square.and.arrow.up")
                    }
                    .appSecondaryButtonStyle()
                    .disabled(!acceptedLegalNotice)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("5. Premium Season Programs")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Picker("Season Program", selection: $premiumCompanion.seasonProgramRawValue) {
                        ForEach(PremiumSeasonProgram.allCases) { program in
                            Text(program.label).tag(program.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    Text("Current week: \(premiumProgramWeek)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(premiumSeasonProgramActions, id: \.self) { action in
                        Button {
                            togglePremiumSeasonProgramAction(action)
                        } label: {
                            Label(
                                action,
                                systemImage: isPremiumSeasonProgramActionCompleted(action)
                                    ? "checkmark.circle.fill" : "circle")
                        }
                        .buttonStyle(.plain)
                    }
                    Button("Restart Program Week Cycle") {
                        restartPremiumSeasonProgram()
                    }
                    .appSecondaryButtonStyle()
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("6. Personal Rule Templates")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(PremiumRuleTemplate.allCases) { template in
                        Button("Apply \(template.label) Template") {
                            applyPremiumRuleTemplate(template)
                        }
                        .appSecondaryButtonStyle()
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("7. Milestone + Virtue Tracking")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Picker("Virtue", selection: $selectedVirtue) {
                        ForEach(["Temperance", "Patience", "Charity", "Humility", "Obedience"], id: \.self) { virtue in
                            Text(virtue).tag(virtue)
                        }
                    }
                    .pickerStyle(.menu)
                    TextField("Virtue note", text: $newVirtueNote, axis: .vertical)
                        .lineLimit(2 ... 4)
                    Button("Log Virtue Check-in") {
                        addPremiumVirtueLog()
                    }
                    .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
                    .disabled(newVirtueNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    if premiumCompanion.virtueLogs.isEmpty {
                        Text("No virtue check-ins yet.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(premiumCompanion.virtueLogs.prefix(5)) { log in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(log.virtue) • \(log.createdAt.formatted(date: .abbreviated, time: .shortened))")
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

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("8. Home/Lock Motivation")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(premiumMotivationLine)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CatholicTheme.primary)
                    Text("This line is also pushed to the widget snapshot.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Button("Refresh Motivation in Widget") {
                        persistWidgetSnapshot()
                        premiumCompanionStatus = "Widget motivation refreshed."
                    }
                    .appSecondaryButtonStyle()
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("9. Fast Prep + Refeed Guidance")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("Plan target: \(intermittentTracker.presetHours)h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(premiumPrepAndRefeedGuidance, id: \.self) { item in
                        Text("• \(item)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("10. Private Household Mode (Local)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Button("Generate Local Share Code") {
                        generatePremiumHouseholdShareCode()
                    }
                    .appSecondaryButtonStyle()
                    if !premiumHouseholdExportCode.isEmpty {
                        Text(premiumHouseholdExportCode)
                            .font(.caption2.monospaced())
                            .textSelection(.enabled)
                    }
                    TextField("Paste household share code", text: $premiumHouseholdImportCode, axis: .vertical)
                        .lineLimit(2 ... 6)
                    Button("Import Household Code (Local)") {
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
}
