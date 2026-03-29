import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UserNotifications)
import UserNotifications
#endif
#if canImport(TipKit)
import TipKit
#endif

struct ContentView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var year = Calendar.current.component(.year, from: Date())
    @StateObject var tracker = FastTracker()
    @StateObject var penanceNotes = FridayPenanceNotes()
    @StateObject var intermittentTracker = IntermittentFastTracker()
    @StateObject var monetizationStore = MonetizationStore()
    @State var notificationStatus = "Not scheduled"
    @State var premiumCoachStatus = ""
    @State var showDeleteDataConfirm = false
    @State var guidanceScenario: GuidanceScenario = .normalDay
    @State var homeSurface: HomeSurface = .today
    @State var selectedMoreDestination: MoreHubDestination? = .supportAndPremium
    @State var selectedPremiumToolDestination: PremiumToolDestination? = .planner
    @State var selectedFastingObservanceID = ""
    @State var didConfigureTips = false
    @State var planningData = LocalFeatureStore.loadPlanningData()
    @State var intermittentSchedules = LocalFeatureStore.loadSchedules()
    @State var activeIntermittentScheduleID = LocalFeatureStore.loadActiveScheduleID() ?? ""
    @State var editingIntermittentScheduleID = ""
    @State var newIntermittentScheduleName = ""
    @State var newIntermittentScheduleStartHour = 20
    @State var newIntermittentScheduleWeekdays: Set<Int> = [2, 4, 6]
    @State var intermittentManualStart = Date()
    @State var lastTargetReachedHapticKey = ""
    @State var lastEatingWindowClosedHapticKey = ""
    @State var householdProfiles = LocalFeatureStore.loadProfiles()
    @State var activeHouseholdProfileID = LocalFeatureStore.loadActiveProfileID() ?? ""
    @State var devotionalFavorites = LocalFeatureStore.loadDevotionalFavorites()
    @State var reflectionEntries = LocalFeatureStore.loadReflections()
    @State var premiumChecklist = LocalFeatureStore.loadChecklist()
    @State var premiumCompanion = LocalFeatureStore.loadPremiumCompanionState()
    @State var newHouseholdProfileName = ""
    @State var newSeasonCommitmentTitle = ""
    @State var newReflectionTitle = ""
    @State var newReflectionBody = ""
    @State var newVirtueNote = ""
    @State var selectedVirtue = "Temperance"
    @State var premiumHouseholdImportCode = ""
    @State var premiumHouseholdExportCode = ""
    @State var premiumCompanionStatus = ""
    @State var launchFunnelSnapshot = LocalFeatureStore.loadLaunchFunnelSnapshot()

    @AppStorage(StorageKeys.age14OrOlderForAbstinence) var age14OrOlderForAbstinence =
        DefaultValues.age14OrOlderForAbstinence
    @AppStorage(StorageKeys.age18OrOlderForFasting) var age18OrOlderForFasting =
        DefaultValues.age18OrOlderForFasting
    @AppStorage(StorageKeys.medicalDispensation) var medicalDispensation = DefaultValues
        .medicalDispensation
    @AppStorage(StorageKeys.ascensionObservance) var ascensionRaw = DefaultValues.ascension.rawValue
    @AppStorage(StorageKeys.fridayOutsideLentMode) var fridayModeRaw = DefaultValues.fridayOutsideLent
        .rawValue
    @AppStorage(StorageKeys.usProvincePreset) var provinceRaw = DefaultValues.province.rawValue
    @AppStorage(StorageKeys.calendarMode) var calendarModeRaw = DefaultValues.calendarMode.rawValue
    @AppStorage(StorageKeys.languageMode) var languageModeRaw = DefaultValues.language.rawValue
    @AppStorage(StorageKeys.regionProfile) var regionProfileRaw = DefaultValues.regionProfile.rawValue
    @AppStorage(StorageKeys.didCompleteOnboarding) var didCompleteOnboarding = false
    @AppStorage(StorageKeys.acceptedLegalNotice) var acceptedLegalNotice = false
    @AppStorage(StorageKeys.acceptedLegalNoticeAt) var acceptedLegalNoticeAt = ""
    @AppStorage(StorageKeys.liturgicalSeasonColorsEnabled) var liturgicalSeasonColorsEnabled =
        DefaultValues.liturgicalSeasonColorsEnabled
    @AppStorage(StorageKeys.dailyReminderSupportEnabled) var dailyReminderSupportEnabled =
        DefaultValues.dailyReminderSupportEnabled
    @AppStorage(StorageKeys.morningReminderEnabled) var morningReminderEnabled =
        DefaultValues.morningReminderEnabled
    @AppStorage(StorageKeys.eveningReminderEnabled) var eveningReminderEnabled =
        DefaultValues.eveningReminderEnabled
    @AppStorage(StorageKeys.dailyQuoteReminderEnabled) var dailyQuoteReminderEnabled =
        DefaultValues.dailyQuoteReminderEnabled
    @AppStorage(StorageKeys.dailyQuoteReminderHour) var dailyQuoteReminderHour =
        DefaultValues.dailyQuoteReminderHour
    @AppStorage(StorageKeys.dailyQuoteReminderMinute) var dailyQuoteReminderMinute =
        DefaultValues.dailyQuoteReminderMinute
    @AppStorage(StorageKeys.dailyQuoteReminderSignature) var dailyQuoteReminderSignature =
        DefaultValues.dailyQuoteReminderSignature
    @AppStorage(StorageKeys.reminderTier) var reminderTierRaw = DefaultValues.reminderTier.rawValue
    @AppStorage(StorageKeys.hapticsEnabled) var hapticsEnabled = DefaultValues.hapticsEnabled
    @AppStorage(StorageKeys.intermittentShowAdvanced) var intermittentShowAdvanced = false
    @AppStorage(StorageKeys.fastingDaysShowAllYearDays) var fastingDaysShowAllYearDays = false
    @AppStorage(StorageKeys.fastingDaysIncludeOptionalDays) var fastingDaysIncludeOptionalDays = false
    @AppStorage(StorageKeys.fastingDaysIncludeFeastAndHolyDays) var fastingDaysIncludeFeastAndHolyDays = false
    @AppStorage(StorageKeys.supportPremiumSurface) var supportPremiumSurfaceRaw = DefaultValues.supportPremiumSurface.rawValue
    @AppStorage(StorageKeys.simplifiedModeEnabled) var simplifiedModeEnabled = false

    var settings: RuleSettings {
        RuleSettings(
            birthYear: 0,
            birthMonth: 0,
            birthDay: 0,
            isAge14OrOlderForAbstinence: age14OrOlderForAbstinence,
            isAge18OrOlderForFasting: age18OrOlderForFasting,
            hasMedicalDispensation: medicalDispensation,
            ascensionObservance: RuleSettings.AscensionObservance(rawValue: ascensionRaw) ?? .sunday,
            fridayOutsideLentMode: RuleSettings.FridayOutsideLentMode(rawValue: fridayModeRaw)
                ?? .substitutePenance,
            calendarMode: RuleSettings.CalendarMode(rawValue: calendarModeRaw) ?? .usccb,
            regionProfile: RuleSettings.RegionProfile(rawValue: regionProfileRaw) ?? .us)
    }

    var provinceSelection: RuleSettings.USProvincePreset {
        RuleSettings.USProvincePreset(rawValue: provinceRaw) ?? .otherUSProvince
    }

    var languageMode: LanguageMode {
        LanguageMode(rawValue: languageModeRaw) ?? .english
    }

    var reminderTier: ReminderTier {
        ReminderTier(rawValue: reminderTierRaw) ?? .balanced
    }

    var observances: [Observance] {
        ObservanceCalculator.makeCalendar(for: year, settings: settings)
    }

    var currentYearObservances: [Observance] {
        ObservanceCalculator.makeCalendar(
            for: Calendar.current.component(.year, from: Date()),
            settings: settings)
    }

    var actionableObservances: [Observance] {
        currentYearObservances.filter { $0.obligation != .notApplicable }
    }

    var completedCount: Int {
        actionableObservances.count(where: { tracker.status(for: $0.id).countsTowardProgress })
    }

    var ruleBundleMetadata: RuleBundleMetadata {
        ObservanceCalculator.ruleBundleMetadata()
    }

    var ruleBundleAudit: RuleBundleAudit {
        ObservanceCalculator.ruleBundleAudit()
    }

    var ruleBundleChanges: [RuleBundleChange] {
        ObservanceCalculator.ruleBundleChanges()
    }

    func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageModeRaw)
    }

    func localizedFormat(_ key: String, default defaultFormat: String, _ values: CVarArg...) -> String {
        let format = localized(key, default: defaultFormat)
        return String(format: format, locale: Locale.current, arguments: values)
    }

    func localizedSeasonLabel(_ season: LiturgicalSeason) -> String {
        switch season {
        case .advent:
            localized("season.advent", default: season.label)
        case .christmas:
            localized("season.christmas", default: season.label)
        case .lent:
            localized("season.lent", default: season.label)
        case .easter:
            localized("season.easter", default: season.label)
        case .ordinary:
            localized("season.ordinary", default: season.label)
        }
    }

    var appLayoutProfile: AppLayoutProfile {
        #if canImport(UIKit)
        if UIDevice.current.userInterfaceIdiom == .pad, horizontalSizeClass == .regular {
            return .pad
        }
        #endif
        return .phone
    }
}
