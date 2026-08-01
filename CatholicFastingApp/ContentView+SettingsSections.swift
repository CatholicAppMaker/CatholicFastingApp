import SwiftUI

extension ContentView {
    var quickSetupSection: some View {
        SettingsQuickSetupSection(
            languageCode: languageModeRaw,
            setupChecklistCompleted: setupChecklistCompleted,
            setupChecklistTotal: setupChecklistTotal,
            premiumUnlocked: monetizationStore.premiumUnlocked,
            dailyQuoteReminderTime: dailyQuoteReminderTimeBinding,
            regionLabel: localizedRegionLabel,
            reminderTierLabel: localizedReminderTierLabel,
            reminderTierSummary: localizedReminderTierSummary,
            applyReminderTier: applyReminderTier,
            openPremiumUpgrade: { openPremiumUpgrade(focusingOn: .accountability) },
            requestNotificationPermission: { await ReminderScheduler.requestPermission() },
            scheduleRequiredDayReminders: {
                await ReminderScheduler.schedule(observances: rollingUpcomingObservances)
            },
            scheduleDailyQuoteReminder: scheduleDailyQuoteReminderFromCurrentSettings,
            scheduleDailySupportReminders: {
                await ReminderScheduler.scheduleHabitSupport(
                    morning: dailyReminderSupportEnabled && morningReminderEnabled,
                    evening: dailyReminderSupportEnabled && eveningReminderEnabled)
            },
            refreshReminderStatus: { await ReminderScheduler.notificationSummary() },
            age14OrOlderForAbstinence: $age14OrOlderForAbstinence,
            age18OrOlderForFasting: $age18OrOlderForFasting,
            regionProfileRaw: $regionProfileRaw,
            languageModeRaw: $languageModeRaw,
            acceptedLegalNotice: $acceptedLegalNotice,
            dailyReminderSupportEnabled: $dailyReminderSupportEnabled,
            reminderTierRaw: $reminderTierRaw,
            dailyQuoteReminderEnabled: $dailyQuoteReminderEnabled,
            morningReminderEnabled: $morningReminderEnabled,
            eveningReminderEnabled: $eveningReminderEnabled,
            notificationStatus: $feedback.notificationStatus)
    }

    var profileRulesSection: some View {
        SettingsProfileRulesSection(
            languageCode: languageModeRaw,
            medicalDispensation: $medicalDispensation,
            languageModeRaw: $languageModeRaw)
    }

    var regionalNormsSection: some View {
        SettingsRegionalNormsSection(
            languageCode: languageModeRaw,
            pastoralGuidance: regionPastoralGuidanceText,
            regionLabel: localizedRegionLabel,
            fridayModeLabel: localizedFridayModeLabel,
            regionProfileRaw: $regionProfileRaw,
            ascensionRaw: $ascensionRaw,
            fridayModeRaw: $fridayModeRaw)
    }

    var themeSection: some View {
        SettingsLiturgicalThemeSection(
            languageCode: languageModeRaw,
            currentSeasonLabel: localizedSeasonLabel(currentLiturgicalSeason),
            liturgicalSeasonColorsEnabled: $liturgicalSeasonColorsEnabled)
    }

    var householdProfilesSection: some View {
        SettingsHouseholdProfilesSection(
            languageCode: languageModeRaw,
            profiles: profileSession.householdProfiles,
            activeProfile: activeHouseholdProfile,
            canAddProfile: canAddHouseholdProfile,
            applyActiveProfile: applyActiveHouseholdProfile,
            addProfile: addHouseholdProfile,
            activeProfileID: $profileSession.activeHouseholdProfileID,
            newProfileName: $premiumPresentation.newHouseholdProfileName)
    }

    var planningLayerSection: some View {
        SettingsPlanningSection(
            languageCode: languageModeRaw,
            requiredProgress: requirementGoalProgress,
            optionalProgress: optionalGoalProgress,
            yearlyRequiredCompletions: yearlyRequiredCompletions,
            yearlyOptionalCompletions: yearlyOptionalCompletions,
            currentSeasonCommitments: currentSeasonCommitments,
            canAddCommitment: canAddSeasonCommitment,
            addCommitment: addSeasonCommitment,
            planningData: $planningSession.data,
            newCommitmentTitle: $premiumPresentation.newSeasonCommitmentTitle)
    }

    var accessibilityModeSection: some View {
        SettingsAccessibilitySection(
            languageCode: languageModeRaw,
            simplifiedModeEnabled: $simplifiedModeEnabled,
            hapticsEnabled: $hapticsEnabled)
    }

    var regionPastoralGuidanceText: String {
        let region = RuleSettings.RegionProfile(rawValue: regionProfileRaw) ?? .us
        switch region {
        case .us:
            return localized(
                "settings.region_guidance.us",
                default:
                "United States profile: Ash Wednesday and Good Friday are fast and abstinence days, Fridays of Lent are abstinence, and Fridays outside Lent are penitential.")
        case .canada:
            return localized(
                "settings.region_guidance.canada",
                default:
                "Canada profile: the app models the national baseline, including Canada-wide holy day obligations " +
                    "and CCCB Friday guidance. Diocesan proper calendars are not included yet.")
        case .other:
            return localized(
                "settings.region_guidance.other",
                default: "Outside U.S./Canada: follow your local bishop conference, parish guidance, and your pastor for binding norms.")
        }
    }

    func localizedRegionLabel(_ option: RuleSettings.RegionProfile) -> String {
        switch option {
        case .us:
            localized("onboarding.region.us", default: option.label)
        case .canada:
            localized("onboarding.region.canada", default: option.label)
        case .other:
            localized("onboarding.region.other", default: option.label)
        }
    }

    func localizedFridayModeLabel(_ option: RuleSettings.FridayOutsideLentMode) -> String {
        switch option {
        case .abstainFromMeat:
            localized("onboarding.friday.abstain", default: option.label)
        case .substitutePenance:
            localized("onboarding.friday.substitute", default: option.label)
        }
    }

    func localizedReminderTierLabel(_ tier: ReminderTier) -> String {
        switch tier {
        case .minimal:
            localized("onboarding.reminder.minimal.label", default: tier.label)
        case .balanced:
            localized("onboarding.reminder.balanced.label", default: tier.label)
        case .guided:
            localized("onboarding.reminder.guided.label", default: tier.label)
        }
    }

    func localizedReminderTierSummary(_ tier: ReminderTier) -> String {
        switch tier {
        case .minimal:
            localized("onboarding.reminder.minimal.summary", default: tier.summary)
        case .balanced:
            localized("onboarding.reminder.balanced.summary", default: tier.summary)
        case .guided:
            localized("onboarding.reminder.guided.summary", default: tier.summary)
        }
    }
}
