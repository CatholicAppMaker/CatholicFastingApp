import Foundation

enum DefaultValues {
    static let birthYear = 0
    static let birthMonth = 0
    static let birthDay = 0
    static let age14OrOlderForAbstinence = true
    static let age18OrOlderForFasting = true
    static let medicalDispensation = false
    static let ascension = RuleSettings.AscensionObservance.sunday
    static let fridayOutsideLent = RuleSettings.FridayOutsideLentMode.substitutePenance
    static let province = RuleSettings.USProvincePreset.otherUSProvince
    static let calendarMode = RuleSettings.CalendarMode.usccb
    static let language = LanguageMode.english
    static let regionProfile = RuleSettings.RegionProfile.us
    static let liturgicalSeasonColorsEnabled = true
    static let dailyReminderSupportEnabled = true
    static let morningReminderEnabled = true
    static let eveningReminderEnabled = false
    static let reminderTier = ReminderTier.balanced
    static let hapticsEnabled = true
    static let supportPremiumSurface = SupportPremiumSurface.upgrade
}

enum StorageKeys {
    static let birthYear = "birth_year"
    static let birthMonth = "birth_month"
    static let birthDay = "birth_day"
    static let age14OrOlderForAbstinence = "age_14_or_older_for_abstinence"
    static let age18OrOlderForFasting = "age_18_or_older_for_fasting"
    static let medicalDispensation = "medical_dispensation"
    static let ascensionObservance = "ascension_observance"
    static let fridayOutsideLentMode = "friday_outside_lent_mode"
    static let usProvincePreset = "us_province_preset"
    static let calendarMode = "calendar_mode"
    static let languageMode = "language_mode"
    static let regionProfile = "region_profile"
    static let didCompleteOnboarding = "did_complete_onboarding"
    static let acceptedLegalNotice = "accepted_legal_notice"
    static let acceptedLegalNoticeAt = "accepted_legal_notice_at"
    static let liturgicalSeasonColorsEnabled = "liturgical_season_colors_enabled"
    static let dailyReminderSupportEnabled = "daily_reminder_support_enabled"
    static let morningReminderEnabled = "morning_reminder_enabled"
    static let eveningReminderEnabled = "evening_reminder_enabled"
    static let reminderTier = "reminder_tier"
    static let hapticsEnabled = "haptics_enabled"
    static let intermittentShowAdvanced = "intermittent_show_advanced"
    static let simplifiedModeEnabled = "simplified_mode_enabled"
    static let fastingDaysShowAllYearDays = "fasting_days_show_all_year_days"
    static let fastingDaysIncludeOptionalDays = "fasting_days_include_optional_days"
    static let fastingDaysIncludeFeastAndHolyDays = "fasting_days_include_feast_and_holy_days"
    static let supportPremiumSurface = "support_premium_surface"
}
