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

enum LanguageMode: String, CaseIterable, Identifiable {
    case english
    case spanish
    case frenchCanadian

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .english:
            "English"
        case .spanish:
            "Español"
        case .frenchCanadian:
            "Français (Canada)"
        }
    }

    var localizationCode: String {
        switch self {
        case .english:
            "en"
        case .spanish:
            "es"
        case .frenchCanadian:
            "fr-CA"
        }
    }

    var contentLocale: ContentLocale {
        switch self {
        case .english:
            .english
        case .spanish:
            .spanish
        case .frenchCanadian:
            .frenchCanadian
        }
    }
}

enum HomeSurface: String, CaseIterable, Identifiable {
    case today
    case fastingDays
    case intermittent
    case more

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .today:
            "Today"
        case .fastingDays:
            "Fasting Days"
        case .intermittent:
            "Track Fast"
        case .more:
            "More"
        }
    }

    var iconName: String {
        switch self {
        case .today:
            "house.fill"
        case .fastingDays:
            "calendar"
        case .intermittent:
            "timer"
        case .more:
            "ellipsis.circle.fill"
        }
    }

    static let primarySurfaces: [HomeSurface] = [.today, .fastingDays, .intermittent, .more]
}

enum AppLayoutProfile: String {
    case phone
    case pad

    var usesSplitViewShell: Bool {
        self == .pad
    }
}

enum MoreHubDestination: String, CaseIterable, Identifiable {
    case supportAndPremium
    case setupAndReminders
    case profileAndNorms
    case guidanceAndRules
    case privacyAndData

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .supportAndPremium:
            "Support & Premium"
        case .setupAndReminders:
            "Setup & Reminders"
        case .profileAndNorms:
            "Profile & Norms"
        case .guidanceAndRules:
            "Guidance & Rules"
        case .privacyAndData:
            "Privacy & Data"
        }
    }

    var subtitle: String {
        switch self {
        case .supportAndPremium:
            "Upgrade or open premium tools."
        case .setupAndReminders:
            "Finish setup and manage reminders."
        case .profileAndNorms:
            "Update your profile, norms, and theme."
        case .guidanceAndRules:
            "Open food guidance, norms, and sources."
        case .privacyAndData:
            "Review consent, exports, backups, and reset tools."
        }
    }

    var iconName: String {
        switch self {
        case .supportAndPremium:
            "heart.circle"
        case .setupAndReminders:
            "bell.badge"
        case .profileAndNorms:
            "person.crop.circle"
        case .guidanceAndRules:
            "book.closed"
        case .privacyAndData:
            "lock.shield"
        }
    }
}

enum SupportPremiumSurface: String, CaseIterable, Identifiable {
    case upgrade
    case tools

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .upgrade:
            "Upgrade"
        case .tools:
            "Premium Tools"
        }
    }
}

enum PremiumToolDestination: String, CaseIterable, Identifiable {
    case planner
    case reminders
    case analytics
    case journal
    case export

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .planner:
            "Planner"
        case .reminders:
            "Reminders"
        case .analytics:
            "Analytics"
        case .journal:
            "Journal"
        case .export:
            "Export"
        }
    }

    var subtitle: String {
        switch self {
        case .planner:
            "Build your season plan and rule template."
        case .reminders:
            "Apply smart reminder recommendations."
        case .analytics:
            "Review completion trends and recovery guidance."
        case .journal:
            "Write reflections and log virtue check-ins."
        case .export:
            "Share summaries and household packets."
        }
    }

    var iconName: String {
        switch self {
        case .planner:
            "calendar.badge.clock"
        case .reminders:
            "bell.badge.waveform"
        case .analytics:
            "chart.bar.xaxis"
        case .journal:
            "book.pages"
        case .export:
            "square.and.arrow.up"
        }
    }
}

enum AppLocalizer {
    static func localized(_ key: String, default defaultValue: String, languageCode: String) -> String {
        let resolvedCode = (LanguageMode(rawValue: languageCode) ?? .english).localizationCode
        guard
            let path = Bundle.main.path(forResource: resolvedCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return NSLocalizedString(
                key, tableName: "Localizable", bundle: .main, value: defaultValue, comment: "")
        }

        return NSLocalizedString(
            key, tableName: "Localizable", bundle: bundle, value: defaultValue, comment: "")
    }
}
