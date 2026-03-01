import SwiftUI
#if canImport(StoreKit)
  import StoreKit
#endif

extension ContentView {
  var premiumAndSupportSection: some View {
    Section("Free Core + Premium + Optional Tip") {
      Text("Core Catholic fasting calendar and guidance stay free. Premium unlocks advanced tools.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Label("Free core: USCCB calendar, required fast days, abstinence guidance, daily logging", systemImage: "checkmark.circle")
      Label(
        "Premium: adaptive plans, reminder automation, exports, season programs, custom long-fast controls, and full intermittent history",
        systemImage: "star.circle"
      )
      Label("Optional tip: one-time support, no extra features required", systemImage: "heart.circle")

      if monetizationStore.premiumUnlocked {
        Label("Premium active", systemImage: "checkmark.seal.fill")
          .foregroundStyle(.green)
      } else {
        Label("Premium not active", systemImage: "lock.fill")
          .foregroundStyle(.secondary)
      }

      #if canImport(StoreKit)
        if !monetizationStore.premiumUnlocked {
          VStack(alignment: .leading, spacing: 4) {
            Text("Unlock Premium (Apple Subscription)")
              .font(.caption.weight(.semibold))
              .foregroundStyle(.secondary)
            Text("Choose monthly or yearly below.")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
          .accessibilityIdentifier("premium.subscription_store")
        }

        HStack(spacing: 8) {
          if monetizationStore.isLoading {
            ProgressView()
            Text("Loading purchases…")
          } else {
            Image(systemName: "checkmark.circle")
              .opacity(0)
            Text("Purchases loaded")
              .opacity(0)
          }
        }
        .font(.caption)

        if !monetizationStore.premiumProducts.isEmpty {
          Text("Premium Plans")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
          ForEach(monetizationStore.premiumProducts, id: \.id) { product in
            Button("Unlock \(product.displayName) • \(product.displayPrice)") {
              Task {
                await monetizationStore.purchase(product)
              }
            }
            .appPrimaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
          }
        } else {
          Text("Premium products are not loaded yet. Confirm product IDs in App Store Connect.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        if !monetizationStore.tipProducts.isEmpty {
          Text("Optional Support Tips")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
          ForEach(monetizationStore.tipProducts, id: \.id) { product in
            Button("Send Tip • \(product.displayPrice)") {
              Task {
                await monetizationStore.purchase(product)
              }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
          }
        }

        let loadedTipIDs = Set(monetizationStore.tipProducts.map(\.id))
        let missingTipIDs = MonetizationStore.tipProductIDs.subtracting(loadedTipIDs)
        if !missingTipIDs.isEmpty {
          Text(
            "Missing tip products: \(missingTipIDs.sorted().joined(separator: ", ")). Complete metadata and availability in App Store Connect."
          )
          .font(.caption2)
          .foregroundStyle(.secondary)
        }
      #endif

      Button("Restore Purchases") {
        Task {
          await monetizationStore.restorePurchases()
        }
      }
      .appSecondaryButtonStyle()
      .disabled(monetizationStore.isPurchasing)
      .accessibilityIdentifier("premium.restore")

      Button("Manage Subscription") {
        Task {
          await monetizationStore.openManageSubscriptions()
        }
      }
      .appSecondaryButtonStyle()
      .disabled(monetizationStore.isPurchasing)
      .accessibilityIdentifier("premium.manage")

      if !monetizationStore.subscriptionHealthMessage.isEmpty {
        Text(monetizationStore.subscriptionHealthMessage)
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("premium.subscription_health")
      }

      if !monetizationStore.statusMessage.isEmpty {
        Text(monetizationStore.statusMessage)
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("premium.status")
      }

      if monetizationStore.premiumUnlocked {
        Divider()

        Text("Premium Formation Tools")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
        Label("Seasonal fasting plans", systemImage: "calendar.badge.clock")
        Label("Smart reminder planner", systemImage: "bell.badge.waveform")
        Label("Advanced analytics dashboard", systemImage: "chart.bar.xaxis")
        Label("Daily premium reflection", systemImage: "book.pages")
        Label("Fasting summary export", systemImage: "square.and.arrow.up")

        VStack(alignment: .leading, spacing: 6) {
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
        .accessibilityIdentifier("premium.season_plan")

        VStack(alignment: .leading, spacing: 6) {
          Text("Smart Reminder Recommendation")
            .font(.subheadline.weight(.semibold))
          Text(premiumReminderRecommendation.summaryLine)
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(
            "Daily support: \(premiumReminderRecommendation.shouldEnableDailySupport ? "On" : "Off") • Morning: \(premiumReminderRecommendation.shouldEnableMorning ? "On" : "Off") • Evening: \(premiumReminderRecommendation.shouldEnableEvening ? "On" : "Off")"
          )
          .font(.caption)
          .foregroundStyle(.secondary)
        }
        .accessibilityIdentifier("premium.smart_reminders")

        Button("Apply Smart Reminder Plan") {
          applyPremiumReminderRecommendation()
        }
        .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
        .accessibilityIdentifier("premium.apply_reminder_plan")

        if !premiumCoachStatus.isEmpty {
          Text(premiumCoachStatus)
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("premium.coach_status")
        }

        VStack(alignment: .leading, spacing: 6) {
          Text("Advanced Analytics")
            .font(.subheadline.weight(.semibold))
          Text("Required completion: \(premiumAnalyticsSummary.requiredCompletionPercent)%")
            .font(.caption)
          Text("Overall completion: \(premiumAnalyticsSummary.overallCompletionPercent)%")
            .font(.caption)
          Text("Missed: \(premiumAnalyticsSummary.missedCount) • Substituted: \(premiumAnalyticsSummary.substitutedCount)")
            .font(.caption)
          Text("Intermittent target hits: \(premiumAnalyticsSummary.intermittentTargetHitPercent)%")
            .font(.caption)
          if !premiumAnalyticsSummary.seasonRows.isEmpty {
            ForEach(premiumAnalyticsSummary.seasonRows) { row in
              Text("\(row.season.label): \(row.completionPercent)% (\(row.completedCount)/\(row.totalCount))")
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
        }
        .accessibilityIdentifier("premium.analytics")

        VStack(alignment: .leading, spacing: 6) {
          Text("Today's Premium Reflection")
            .font(.subheadline.weight(.semibold))
          Text(premiumReflection.title)
            .font(.caption.weight(.semibold))
          Text(premiumReflection.body)
            .font(.caption)
            .foregroundStyle(.secondary)
          Text("Action: \(premiumReflection.action)")
            .font(.caption)
            .foregroundStyle(CatholicTheme.primary)
        }
        .accessibilityIdentifier("premium.reflection")

        ShareLink(
          item: premiumDirectionSummaryText,
          subject: Text("Catholic Fasting Summary"),
          message: Text("Structured fasting summary for personal review.")
        ) {
          Label("Export Fasting Summary", systemImage: "square.and.arrow.up")
        }
        .appSecondaryButtonStyle()
        .disabled(!acceptedLegalNotice)
        .accessibilityIdentifier("premium.export_summary")

        if !acceptedLegalNotice {
          Text("Enable consent in Privacy & Data before exporting premium summaries.")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      } else {
        Divider()
        Text("Premium unlock includes:")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
        Text("• Seasonal fasting plans")
          .font(.caption)
        Text("• Smart reminder planner")
          .font(.caption)
        Text("• Advanced analytics dashboard")
          .font(.caption)
        Text("• Daily premium reflections")
          .font(.caption)
        Text("• Fasting summary export")
          .font(.caption)
          .accessibilityIdentifier("premium.locked_feature_preview")
      }
    }
    .animation(.none, value: monetizationStore.premiumProducts.map(\.id))
    .animation(.none, value: monetizationStore.tipProducts.map(\.id))
    .animation(.none, value: monetizationStore.isLoading)
    .animation(.none, value: monetizationStore.statusMessage)
  }

  var premiumChecklistSection: some View {
    Section("Premium Focus Checklist") {
      if !monetizationStore.premiumUnlocked {
        Text("Unlock Premium to use the advanced checklist.")
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
              isDone: false
            )
          )
        }
        .appSecondaryButtonStyle()
      }
    }
  }

  var reflectionJournalSection: some View {
    Section("Reflection Journal (Local)") {
      if !monetizationStore.premiumUnlocked {
        Text("Premium unlocks local reflection journaling.")
          .foregroundStyle(.secondary)
      } else {
        TextField("Reflection title", text: $newReflectionTitle)
          .textInputAutocapitalization(.sentences)
          .accessibilityIdentifier("premium.journal.title")
        TextField("Write a short reflection", text: $newReflectionBody, axis: .vertical)
          .lineLimit(2...5)
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
        ShareLink(item: seasonPlanExportText) {
          Label("Export Season Plan (Text)", systemImage: "square.and.arrow.up")
        }
        .appSecondaryButtonStyle()
        .disabled(!acceptedLegalNotice)
      }
    }
  }

  var premiumSeasonPlan: PremiumSeasonPlan {
    PremiumSeasonPlanEngine.plan(for: currentLiturgicalSeason, settings: settings)
  }

  var selectedPremiumTemplate: PremiumRuleTemplate {
    PremiumRuleTemplate(rawValue: premiumCompanion.templateRawValue) ?? .steady
  }

  var selectedPremiumSeasonProgram: PremiumSeasonProgram {
    PremiumSeasonProgram(rawValue: premiumCompanion.seasonProgramRawValue) ?? .liturgicalRhythm
  }

  var premiumProgramWeek: Int {
    let days =
      liturgicalCalendar.dateComponents(
        [.day],
        from: liturgicalCalendar.startOfDay(for: premiumCompanion.seasonProgramStartDate),
        to: liturgicalCalendar.startOfDay(for: Date())
      ).day ?? 0
    return max(1, (days / 7) + 1)
  }

  var premiumAdaptivePlan: PremiumAdaptiveRulePlan {
    PremiumAdaptiveRulePlanner.plan(
      season: currentLiturgicalSeason,
      settings: settings,
      template: selectedPremiumTemplate,
      optionalDisciplinesPerWeek: premiumCompanion.optionalDisciplinesPerWeek,
      fixedFastWeekday: premiumCompanion.fixedFastWeekday,
      protectFeastDays: premiumCompanion.protectFeastDays
    )
  }

  var premiumReminderRecommendation: PremiumReminderRecommendation {
    PremiumReminderPlanner.recommendation(
      observances: currentYearObservances,
      statusesByID: tracker.statusesByID
    )
  }

  var premiumConditionRuleRecommendation: PremiumReminderRecommendation {
    PremiumConditionReminderAdvisor.applyRules(
      premiumCompanion.conditionRules,
      hasUpcomingRequiredDays: upcomingMandatoryObservance != nil
    )
  }

  var premiumAnalyticsSummary: PremiumAnalyticsSummary {
    PremiumAnalyticsEngine.summary(
      observances: currentYearObservances,
      statusesByID: tracker.statusesByID,
      sessions: intermittentTracker.sessions
    )
  }

  var premiumReflection: PremiumReflection {
    PremiumReflectionEngine.reflection(
      season: currentLiturgicalSeason
    )
  }

  var premiumRecoveryCoachPlan: PremiumRecoveryCoachPlan {
    PremiumRecoveryCoachEngine.plan(
      missedPlan: missedDayRecoveryPlan,
      season: currentLiturgicalSeason
    )
  }

  var premiumSeasonProgramActions: [String] {
    PremiumSeasonProgramEngine.actions(
      for: selectedPremiumSeasonProgram,
      week: premiumProgramWeek
    )
  }

  var premiumPrepAndRefeedGuidance: [String] {
    PremiumFastPrepGuidanceEngine.prepAndRefeed(
      targetHours: intermittentTracker.presetHours,
      hasMedicalDispensation: settings.hasMedicalDispensation
    )
  }

  var premiumMotivationLine: String {
    PremiumMotivationEngine.line(
      season: currentLiturgicalSeason,
      streak: currentStreak,
      template: selectedPremiumTemplate
    )
  }

  var premiumDirectionSummaryText: String {
    PremiumDirectionSummaryEngine.summaryText(
      season: currentLiturgicalSeason,
      analytics: premiumAnalyticsSummary,
      reminder: premiumReminderRecommendation,
      plan: premiumSeasonPlan,
      latestReflection: premiumReflection
    )
  }

  var premiumWeeklySummaryText: String {
    let start = liturgicalCalendar.date(byAdding: .day, value: -6, to: Date()) ?? Date()
    let weeklyObservances = currentYearObservances.filter { $0.date >= start && $0.date <= Date() }
    let completed = weeklyObservances.filter { tracker.status(for: $0.id).countsTowardProgress }.count
    return [
      "Catholic Fasting Weekly Report",
      "Week ending \(Date().formatted(date: .abbreviated, time: .omitted))",
      "",
      "Completed observances: \(completed)/\(weeklyObservances.count)",
      "Current streak: \(currentStreak) day(s)",
      "Template: \(selectedPremiumTemplate.label)",
      "Program: \(selectedPremiumSeasonProgram.label) (Week \(premiumProgramWeek))",
      "Motivation: \(premiumMotivationLine)",
    ].joined(separator: "\n")
  }

  var premiumMonthlySummaryText: String {
    let month = liturgicalCalendar.component(.month, from: Date())
    let year = liturgicalCalendar.component(.year, from: Date())
    let monthlyObservances = currentYearObservances.filter {
      liturgicalCalendar.component(.month, from: $0.date) == month
        && liturgicalCalendar.component(.year, from: $0.date) == year
    }
    let completed = monthlyObservances.filter { tracker.status(for: $0.id).countsTowardProgress }.count
    return [
      "Catholic Fasting Monthly Report",
      "Month: \(Date().formatted(.dateTime.month(.wide).year()))",
      "",
      "Completed observances: \(completed)/\(monthlyObservances.count)",
      "Required completion: \(premiumAnalyticsSummary.requiredCompletionPercent)%",
      "Overall completion: \(premiumAnalyticsSummary.overallCompletionPercent)%",
      "Intermittent target hit rate: \(premiumAnalyticsSummary.intermittentTargetHitPercent)%",
      "Motivation: \(premiumMotivationLine)",
    ].joined(separator: "\n")
  }

  func applyPremiumReminderRecommendation() {
    let recommendation = premiumReminderRecommendation
    dailyReminderSupportEnabled = recommendation.shouldEnableDailySupport
    morningReminderEnabled = recommendation.shouldEnableMorning
    eveningReminderEnabled = recommendation.shouldEnableEvening
    premiumCoachStatus = recommendation.summaryLine
  }

  func applyPremiumConditionRules() {
    let recommendation = premiumConditionRuleRecommendation
    dailyReminderSupportEnabled = recommendation.shouldEnableDailySupport
    morningReminderEnabled = recommendation.shouldEnableMorning
    eveningReminderEnabled = recommendation.shouldEnableEvening
    premiumCompanionStatus = recommendation.summaryLine
  }

  func applyPremiumRuleTemplate(_ template: PremiumRuleTemplate) {
    premiumCompanion.templateRawValue = template.rawValue
    switch template {
    case .beginner:
      premiumCompanion.optionalDisciplinesPerWeek = 1
    case .steady:
      premiumCompanion.optionalDisciplinesPerWeek = 2
    case .disciplined:
      premiumCompanion.optionalDisciplinesPerWeek = 3
    case .traditional:
      premiumCompanion.optionalDisciplinesPerWeek = 4
    case .custom:
      break
    }
    premiumCompanionStatus = "\(template.label) template applied."
  }

  func togglePremiumSeasonProgramAction(_ action: String) {
    let key = "\(selectedPremiumSeasonProgram.rawValue)-w\(premiumProgramWeek)-\(action)"
    if premiumCompanion.completedProgramActions.contains(key) {
      premiumCompanion.completedProgramActions.removeAll { $0 == key }
    } else {
      premiumCompanion.completedProgramActions.append(key)
    }
  }

  func isPremiumSeasonProgramActionCompleted(_ action: String) -> Bool {
    let key = "\(selectedPremiumSeasonProgram.rawValue)-w\(premiumProgramWeek)-\(action)"
    return premiumCompanion.completedProgramActions.contains(key)
  }

  func restartPremiumSeasonProgram() {
    premiumCompanion.seasonProgramStartDate = Date()
    premiumCompanion.completedProgramActions = []
    premiumCompanionStatus = "\(selectedPremiumSeasonProgram.label) restarted."
  }

  func addPremiumVirtueLog() {
    let trimmed = newVirtueNote.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    premiumCompanion.virtueLogs.insert(
      PremiumVirtueLog(
        id: UUID().uuidString,
        createdAt: Date(),
        virtue: selectedVirtue,
        note: trimmed
      ),
      at: 0
    )
    newVirtueNote = ""
  }

  func deletePremiumVirtueLog(_ log: PremiumVirtueLog) {
    premiumCompanion.virtueLogs.removeAll { $0.id == log.id }
  }

  func generatePremiumHouseholdShareCode() {
    let packet = PremiumHouseholdSharePacket(
      generatedAt: Date(),
      planningData: planningData,
      schedules: intermittentSchedules,
      checklist: premiumChecklist
    )
    guard let data = try? JSONEncoder().encode(packet) else {
      premiumCompanionStatus = "Could not generate household share code."
      return
    }
    premiumHouseholdExportCode = data.base64EncodedString()
    premiumCompanionStatus = "Household share code generated."
  }

  func importPremiumHouseholdShareCode() {
    let code = premiumHouseholdImportCode.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !code.isEmpty, let data = Data(base64Encoded: code) else {
      premiumCompanionStatus = "Invalid share code."
      return
    }
    guard let packet = try? JSONDecoder().decode(PremiumHouseholdSharePacket.self, from: data) else {
      premiumCompanionStatus = "Could not decode household packet."
      return
    }
    planningData = packet.planningData
    intermittentSchedules = packet.schedules
    premiumChecklist = packet.checklist
    premiumCompanionStatus = "Household packet imported locally."
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
              set: { applyPremiumRuleTemplate($0) }
            )
          ) {
            ForEach(PremiumRuleTemplate.allCases) { template in
              Text(template.label).tag(template)
            }
          }
          .pickerStyle(.menu)

          Stepper("Optional disciplines/week: \(premiumCompanion.optionalDisciplinesPerWeek)", value: $premiumCompanion.optionalDisciplinesPerWeek, in: 0...7)
          Stepper("Fixed personal fast day: \(weekdayLabel(for: premiumCompanion.fixedFastWeekday))", value: $premiumCompanion.fixedFastWeekday, in: 1...7)
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
            message: Text("Weekly fasting summary from Premium.")
          ) {
            Label("Export Weekly Report", systemImage: "square.and.arrow.up")
          }
          .appSecondaryButtonStyle()
          .disabled(!acceptedLegalNotice)

          ShareLink(
            item: premiumMonthlySummaryText,
            subject: Text("Catholic Fasting Monthly Report"),
            message: Text("Monthly fasting summary from Premium.")
          ) {
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
                  ? "checkmark.circle.fill" : "circle"
              )
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
            .lineLimit(2...4)
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
            .lineLimit(2...6)
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
