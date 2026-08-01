import SwiftUI

extension ContentView {
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
                        premiumSession.companion.optionalDisciplinesPerWeek),
                    value: $premiumSession.companion.optionalDisciplinesPerWeek,
                    in: 0 ... 7)
                Stepper(
                    localizedFormat(
                        "premium.planner.fixed_fast_day_format",
                        default: "Fixed personal fast day: %@",
                        weekdayLabel(for: premiumSession.companion.fixedFastWeekday)),
                    value: $premiumSession.companion.fixedFastWeekday,
                    in: 1 ... 7)
                Toggle(localized("premium.planner.protect_feasts", default: "Protect feast/holy days from personal fasts"), isOn: $premiumSession.companion.protectFeastDays)
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
                    isOn: $premiumSession.companion.conditionRules.remindIfUnloggedByNoon)
                Toggle(
                    localized(
                        "premium.reminders.rule.double_required",
                        default: "Double reminders on required days"),
                    isOn: $premiumSession.companion.conditionRules.requiredDaysDoubleReminder)
                Toggle(
                    localized(
                        "premium.reminders.rule.milestones",
                        default: "Milestone nudges during active fast"),
                    isOn: $premiumSession.companion.conditionRules.milestoneNudgesForActiveFast)

                Button(localized("premium.reminders.apply_rules", default: "Apply Condition Rules")) {
                    applyPremiumConditionRules()
                }
                .appSecondaryButtonStyle()
            }

            if !feedback.premiumCoachStatus.isEmpty {
                Text(feedback.premiumCoachStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("premium.coach_status")
            }
            if !premiumPresentation.companionStatus.isEmpty {
                Text(premiumPresentation.companionStatus)
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
            Text(localizedFormat(
                "premium.analytics.personal_fast_hits_format",
                default: "Personal fast targets met: %d%%",
                premiumAnalyticsSummary.intermittentTargetHitPercent))
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
}
