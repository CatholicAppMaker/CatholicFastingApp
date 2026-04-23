import SwiftUI

struct CatholicFastingMacPremiumView: View {
    @ObservedObject var model: CatholicFastingMacModel
    @State private var reflectionTitle = ""
    @State private var reflectionBody = ""
    @State private var virtueNote = ""

    var body: some View {
        MacSurfaceContainer(
            title: "Premium Toolkit",
            subtitle: "Keep subscriptions, planning, reminders, analytics, and review tools visible as a first-class desktop workspace.",
            accessibilityID: "mac.surface.premium.ready")
        {
            subscriptionCard

            HStack(alignment: .top, spacing: 16) {
                plannerCard
                remindersCard
            }

            HStack(alignment: .top, spacing: 16) {
                analyticsCard
                recoveryAndReflectionCard
            }

            HStack(alignment: .top, spacing: 16) {
                journeyAndChecklistCard
                journalAndVirtueCard
            }

            HStack(alignment: .top, spacing: 16) {
                exportsCard
                householdShareCard
            }
        }
    }

    private var subscriptionCard: some View {
        CatholicFastingMacPremiumSubscriptionCard(model: model)
    }

    private var plannerCard: some View {
        MacCard(title: "Planner", subtitle: model.premiumAdaptivePlan.title) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Adaptive plan")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(model.premiumAdaptivePlan.summary)
                Picker("Rule template", selection: templateBinding) {
                    ForEach(PremiumRuleTemplate.allCases) { template in
                        Text(template.label).tag(template)
                    }
                }
                .accessibilityIdentifier("mac.premium.planner.template")

                Stepper(
                    "Optional disciplines/week: \(model.premiumCompanion.optionalDisciplinesPerWeek)",
                    value: optionalDisciplinesBinding,
                    in: 0 ... 7)
                    .accessibilityIdentifier("mac.premium.planner.optional_count")

                Stepper(
                    "Fixed personal fast day: \(model.weekdayLabel(for: model.premiumCompanion.fixedFastWeekday))",
                    value: fixedFastWeekdayBinding,
                    in: 1 ... 7)
                    .accessibilityIdentifier("mac.premium.planner.fixed_day")

                Toggle("Protect feast and holy days", isOn: protectFeastDaysBinding)
                    .accessibilityIdentifier("mac.premium.planner.protect_feasts")

                ForEach(model.premiumAdaptivePlan.weeklyActions, id: \.self) { action in
                    Label(action, systemImage: "calendar.badge.clock")
                        .font(.caption)
                }

                Divider()

                Text(model.seasonPlan.titleLine)
                    .font(.headline)
                Text(model.seasonPlan.focusLine)
                Text("Intensity: \(model.seasonPlan.fastingIntensity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(model.seasonPlan.practices, id: \.self) { practice in
                    Label(practice, systemImage: "sparkles")
                        .font(.caption)
                }

                ShareLink(item: model.seasonPlanExportText) {
                    Label("Export Season Plan", systemImage: "square.and.arrow.up")
                }
                .accessibilityIdentifier("mac.premium.planner.export")
            }
            .accessibilityIdentifier("mac.premium.planner")
        }
    }

    private var remindersCard: some View {
        MacCard(title: "Reminders", subtitle: "Smart recommendation plus advanced support rules") {
            VStack(alignment: .leading, spacing: 12) {
                Text(model.premiumReminderRecommendation.summaryLine)
                Text(model.premiumReminderRecommendationLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Apply Smart Plan") {
                        model.applyPremiumReminderRecommendation()
                    }
                    .accessibilityIdentifier("mac.premium.apply_reminder_plan")

                    Button("Schedule Support") {
                        Task { await model.scheduleDailySupportReminders() }
                    }
                    .disabled(!model.monetizationStore.premiumUnlocked)
                    .accessibilityIdentifier("mac.premium.schedule_support")
                }

                Toggle(
                    "Noon recovery nudge",
                    isOn: Binding(
                        get: { model.premiumCompanion.conditionRules.remindIfUnloggedByNoon },
                        set: { model.premiumCompanion.conditionRules.remindIfUnloggedByNoon = $0 }))
                Toggle(
                    "Double reminders on required days",
                    isOn: Binding(
                        get: { model.premiumCompanion.conditionRules.requiredDaysDoubleReminder },
                        set: { model.premiumCompanion.conditionRules.requiredDaysDoubleReminder = $0 }))
                Toggle(
                    "Milestone nudges during active fasts",
                    isOn: Binding(
                        get: { model.premiumCompanion.conditionRules.milestoneNudgesForActiveFast },
                        set: { model.premiumCompanion.conditionRules.milestoneNudgesForActiveFast = $0 }))

                Button("Apply Advanced Rules") {
                    model.applyPremiumConditionRules()
                }
                .accessibilityIdentifier("mac.premium.apply_condition_rules")

                Text(currentSupportSetupSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !model.premiumCoachStatus.isEmpty {
                    Text(model.premiumCoachStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("mac.premium.coach_status")
                }

                if !model.premiumCompanionStatus.isEmpty {
                    Text(model.premiumCompanionStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !model.monetizationStore.premiumUnlocked {
                    Text("Premium is required to schedule morning and evening support reminders on Mac.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityIdentifier("mac.premium.reminders")
        }
    }

    private var analyticsCard: some View {
        MacCard(title: "Analytics", subtitle: "Completion, consistency, and season trend lines") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Required completion: \(model.premiumAnalyticsSummary.requiredCompletionPercent)%")
                Text("Overall completion: \(model.premiumAnalyticsSummary.overallCompletionPercent)%")
                Text("Missed: \(model.premiumAnalyticsSummary.missedCount) • Substituted: \(model.premiumAnalyticsSummary.substitutedCount)")
                Text("Intermittent target hits: \(model.premiumAnalyticsSummary.intermittentTargetHitPercent)%")
                Text("Current streak: \(model.currentStreak) day(s)")
                    .foregroundStyle(.secondary)

                if !model.premiumAnalyticsSummary.seasonRows.isEmpty {
                    Divider()
                    ForEach(model.premiumAnalyticsSummary.seasonRows) { row in
                        Text("\(model.localizedSeasonLabel(row.season)): \(row.completionPercent)% (\(row.completedCount)/\(row.totalCount))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .accessibilityIdentifier("mac.premium.analytics")
        }
    }

    private var recoveryAndReflectionCard: some View {
        MacCard(title: model.premiumRecoveryCoachPlan.title, subtitle: "Recovery coaching and daily reflection") {
            VStack(alignment: .leading, spacing: 12) {
                Text(model.premiumRecoveryCoachPlan.summary)
                ForEach(model.premiumRecoveryCoachPlan.steps, id: \.self) { step in
                    Label(step, systemImage: "arrow.triangle.turn.up.right.diamond")
                        .font(.caption)
                }

                Divider()

                Text(model.premiumReflection.title)
                    .font(.headline)
                Text(model.premiumReflection.body)
                    .foregroundStyle(.secondary)
                Text("Action: \(model.premiumReflection.action)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityIdentifier("mac.premium.recovery")
        }
    }

    private var journeyAndChecklistCard: some View {
        MacCard(title: "Journey & Checklist", subtitle: model.journeyProgress.completionSummary) {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Program", selection: seasonProgramBinding) {
                    ForEach(PremiumSeasonProgram.allCases) { program in
                        Text(program.label).tag(program)
                    }
                }
                .accessibilityIdentifier("mac.premium.program")

                Button("Restart Program Week") {
                    model.restartPremiumSeasonProgram()
                }
                .accessibilityIdentifier("mac.premium.restart_program")

                ForEach(model.journeyWeek.actions) { action in
                    Toggle(
                        isOn: Binding(
                            get: { model.isJourneyActionCompleted(action.id) },
                            set: { _ in model.toggleJourneyAction(action.id) }))
                    {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(action.title)
                            Text(action.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityIdentifier("mac.premium.journey.\(action.id)")
                }

                Divider()

                if model.premiumChecklist.isEmpty {
                    Text("No checklist items yet. Add one from iPhone or bring one over with household share.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.premiumChecklist) { item in
                        Toggle(
                            isOn: Binding(
                                get: { item.isDone },
                                set: { _ in model.toggleChecklistItem(item) }))
                        {
                            Text(item.title)
                        }
                        .accessibilityIdentifier("mac.premium.checklist.\(item.id)")
                    }
                }
            }
            .accessibilityIdentifier("mac.premium.checklist")
        }
    }

    private var journalAndVirtueCard: some View {
        MacCard(title: "Journal & Virtue Check-ins", subtitle: "Short reflection, not long-form writing") {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Reflection title", text: $reflectionTitle)
                    .accessibilityIdentifier("mac.premium.reflection_title")
                TextEditor(text: $reflectionBody)
                    .frame(minHeight: 100)
                    .accessibilityIdentifier("mac.premium.reflection_body")
                Button("Add Reflection") {
                    model.addReflection(title: reflectionTitle, body: reflectionBody)
                    reflectionTitle = ""
                    reflectionBody = ""
                }
                .accessibilityIdentifier("mac.premium.add_reflection")

                if !model.reflectionEntries.isEmpty {
                    Divider()
                    ForEach(Array(model.reflectionEntries.prefix(3))) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.title)
                            Text(entry.body)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                    }
                }

                Divider()

                Picker("Virtue", selection: $model.selectedVirtue) {
                    ForEach(["Temperance", "Patience", "Charity", "Humility", "Obedience"], id: \.self) { virtue in
                        Text(virtue).tag(virtue)
                    }
                }
                .accessibilityIdentifier("mac.premium.virtue_picker")

                TextField("Virtue note", text: $virtueNote, axis: .vertical)
                    .lineLimit(2 ... 4)
                    .accessibilityIdentifier("mac.premium.virtue_note")

                Button("Log Virtue Check-in") {
                    model.addPremiumVirtueLog(note: virtueNote)
                    virtueNote = ""
                }
                .disabled(virtueNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("mac.premium.add_virtue")

                if model.premiumCompanion.virtueLogs.isEmpty {
                    Text("No virtue check-ins yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.premiumCompanion.virtueLogs.prefix(5)) { log in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(log.virtue) • \(model.localizedDateTime(log.createdAt))")
                                    .font(.caption.weight(.semibold))
                                Text(log.note)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                model.deletePremiumVirtueLog(log)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .accessibilityIdentifier("mac.premium.virtue")
        }
    }

    private var exportsCard: some View {
        MacCard(title: "Exports & Review", subtitle: "Text summaries for review, direction, or planning") {
            VStack(alignment: .leading, spacing: 12) {
                ShareLink(item: model.premiumDirectionSummaryText) {
                    Label("Export Fasting Summary", systemImage: "square.and.arrow.up")
                }
                .disabled(!model.acceptedLegalNotice)
                .accessibilityIdentifier("mac.premium.export_summary")

                ShareLink(item: model.premiumWeeklySummaryText) {
                    Label("Export Weekly Report", systemImage: "calendar")
                }
                .disabled(!model.acceptedLegalNotice)
                .accessibilityIdentifier("mac.premium.export_weekly")

                ShareLink(item: model.premiumMonthlySummaryText) {
                    Label("Export Monthly Report", systemImage: "calendar.badge.clock")
                }
                .disabled(!model.acceptedLegalNotice)
                .accessibilityIdentifier("mac.premium.export_monthly")

                Button("Copy Summary") {
                    model.copyPremiumSummaryToPasteboard()
                }
                .accessibilityIdentifier("mac.premium.copy_summary")

                if !model.acceptedLegalNotice {
                    Text("Enable Privacy & Data consent before exporting premium summaries.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityIdentifier("mac.premium.exports")
        }
    }

    private var householdShareCard: some View {
        MacCard(title: "Household Share", subtitle: "Local transfer only, not sync") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Use this to move planning, checklist, and schedule state between local workflows on this Mac.")
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Generate Share Code") {
                        model.generatePremiumHouseholdShareCode()
                    }
                    .accessibilityIdentifier("mac.premium.generate_share_code")

                    Button("Copy Code") {
                        model.copyPremiumHouseholdCodeToPasteboard()
                    }
                    .disabled(model.premiumHouseholdExportCode.isEmpty)
                    .accessibilityIdentifier("mac.premium.copy_share_code")
                }

                if !model.premiumHouseholdExportCode.isEmpty {
                    Text(model.premiumHouseholdExportCode)
                        .font(.caption2.monospaced())
                        .textSelection(.enabled)
                }

                TextField("Paste household share code", text: $model.premiumHouseholdImportCode, axis: .vertical)
                    .lineLimit(2 ... 6)
                    .accessibilityIdentifier("mac.premium.import_share_code")

                Button("Import Household Code") {
                    model.importPremiumHouseholdShareCode()
                }
                .disabled(model.premiumHouseholdImportCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("mac.premium.import_household")

                if !model.premiumCompanionStatus.isEmpty {
                    Text(model.premiumCompanionStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityIdentifier("mac.premium.household")
        }
    }

    private var templateBinding: Binding<PremiumRuleTemplate> {
        Binding(
            get: { model.selectedPremiumTemplate },
            set: { model.applyPremiumRuleTemplate($0) })
    }

    private var seasonProgramBinding: Binding<PremiumSeasonProgram> {
        Binding(
            get: { model.selectedPremiumSeasonProgram },
            set: { model.premiumCompanion.seasonProgramRawValue = $0.rawValue })
    }

    private var optionalDisciplinesBinding: Binding<Int> {
        Binding(
            get: { model.premiumCompanion.optionalDisciplinesPerWeek },
            set: { model.premiumCompanion.optionalDisciplinesPerWeek = $0 })
    }

    private var fixedFastWeekdayBinding: Binding<Int> {
        Binding(
            get: { model.premiumCompanion.fixedFastWeekday },
            set: { model.premiumCompanion.fixedFastWeekday = $0 })
    }

    private var protectFeastDaysBinding: Binding<Bool> {
        Binding(
            get: { model.premiumCompanion.protectFeastDays },
            set: { model.premiumCompanion.protectFeastDays = $0 })
    }

    private var currentSupportSetupSummary: String {
        let daily = supportState(model.dailyReminderSupportEnabled)
        let morning = supportState(model.morningReminderEnabled)
        let evening = supportState(model.eveningReminderEnabled)
        return "Current support setup: daily \(daily), morning \(morning), evening \(evening)."
    }

    private func supportState(_ isEnabled: Bool) -> String {
        isEnabled ? "on" : "off"
    }
}
