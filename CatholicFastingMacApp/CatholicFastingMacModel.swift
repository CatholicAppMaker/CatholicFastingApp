import AppKit
import Combine
import SwiftUI

@MainActor
final class CatholicFastingMacModel: ObservableObject {
    @Published var selectedSurface: CatholicFastingMacSurface = .today
    @Published var selectedSettingsPane: CatholicFastingMacSettingsPane = .profile
    @Published var selectedObservanceID = ""
    @Published var year = Calendar.current.component(.year, from: Date())
    @Published var notificationStatus = "Permission not requested"
    @Published var premiumCoachStatus = ""
    @Published var premiumCompanionStatus = ""
    @Published var selectedVirtue = "Temperance"
    @Published var premiumHouseholdImportCode = ""
    @Published var premiumHouseholdExportCode = ""

    @Published var planningData: FastingPlanningData {
        didSet { persistPlanningData() }
    }

    @Published var intermittentSchedules: [IntermittentSchedulePlan] {
        didSet { persistSchedules() }
    }

    @Published var activeIntermittentScheduleID: String {
        didSet { persistActiveSchedule() }
    }

    @Published var householdProfiles: [HouseholdProfile] {
        didSet { persistProfiles() }
    }

    @Published var activeHouseholdProfileID: String {
        didSet { persistActiveProfile() }
    }

    @Published var devotionalFavorites: Set<String> {
        didSet { persistDevotionalFavorites() }
    }

    @Published var reflectionEntries: [ReflectionJournalEntry] {
        didSet { persistReflections() }
    }

    @Published var premiumChecklist: [PremiumChecklistItem] {
        didSet { persistChecklist() }
    }

    @Published var premiumCompanion: PremiumCompanionState {
        didSet { persistPremiumCompanion() }
    }

    @Published var launchFunnelSnapshot: LaunchFunnelSnapshot {
        didSet { persistLaunchFunnelSnapshot() }
    }

    @Published var age14OrOlderForAbstinence: Bool {
        didSet { persistDefault(age14OrOlderForAbstinence, key: StorageKeys.age14OrOlderForAbstinence) }
    }

    @Published var age18OrOlderForFasting: Bool {
        didSet { persistDefault(age18OrOlderForFasting, key: StorageKeys.age18OrOlderForFasting) }
    }

    @Published var medicalDispensation: Bool {
        didSet { persistDefault(medicalDispensation, key: StorageKeys.medicalDispensation) }
    }

    @Published var ascensionRaw: String {
        didSet { persistDefault(ascensionRaw, key: StorageKeys.ascensionObservance) }
    }

    @Published var fridayModeRaw: String {
        didSet { persistDefault(fridayModeRaw, key: StorageKeys.fridayOutsideLentMode) }
    }

    @Published var provinceRaw: String {
        didSet { persistDefault(provinceRaw, key: StorageKeys.usProvincePreset) }
    }

    @Published var calendarModeRaw: String {
        didSet { persistDefault(calendarModeRaw, key: StorageKeys.calendarMode) }
    }

    @Published var languageModeRaw: String {
        didSet { persistDefault(languageModeRaw, key: StorageKeys.languageMode) }
    }

    @Published var regionProfileRaw: String {
        didSet { persistDefault(regionProfileRaw, key: StorageKeys.regionProfile) }
    }

    @Published var didCompleteOnboarding: Bool {
        didSet { persistDefault(didCompleteOnboarding, key: StorageKeys.didCompleteOnboarding) }
    }

    @Published var acceptedLegalNotice: Bool {
        didSet { persistAcceptedLegalNotice() }
    }

    @Published var acceptedLegalNoticeAt: String {
        didSet { persistDefault(acceptedLegalNoticeAt, key: StorageKeys.acceptedLegalNoticeAt) }
    }

    @Published var liturgicalSeasonColorsEnabled: Bool {
        didSet { persistDefault(liturgicalSeasonColorsEnabled, key: StorageKeys.liturgicalSeasonColorsEnabled) }
    }

    @Published var dailyReminderSupportEnabled: Bool {
        didSet { persistDefault(dailyReminderSupportEnabled, key: StorageKeys.dailyReminderSupportEnabled) }
    }

    @Published var morningReminderEnabled: Bool {
        didSet { persistDefault(morningReminderEnabled, key: StorageKeys.morningReminderEnabled) }
    }

    @Published var eveningReminderEnabled: Bool {
        didSet { persistDefault(eveningReminderEnabled, key: StorageKeys.eveningReminderEnabled) }
    }

    @Published var dailyQuoteReminderEnabled: Bool {
        didSet { persistDefault(dailyQuoteReminderEnabled, key: StorageKeys.dailyQuoteReminderEnabled) }
    }

    @Published var dailyQuoteReminderHour: Int {
        didSet { persistDefault(dailyQuoteReminderHour, key: StorageKeys.dailyQuoteReminderHour) }
    }

    @Published var dailyQuoteReminderMinute: Int {
        didSet { persistDefault(dailyQuoteReminderMinute, key: StorageKeys.dailyQuoteReminderMinute) }
    }

    @Published var dailyQuoteReminderSignature: String {
        didSet { persistDefault(dailyQuoteReminderSignature, key: StorageKeys.dailyQuoteReminderSignature) }
    }

    @Published var reminderTierRaw: String {
        didSet { persistDefault(reminderTierRaw, key: StorageKeys.reminderTier) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { persistDefault(hapticsEnabled, key: StorageKeys.hapticsEnabled) }
    }

    @Published var fastingDaysShowAllYearDays: Bool {
        didSet { persistDefault(fastingDaysShowAllYearDays, key: StorageKeys.fastingDaysShowAllYearDays) }
    }

    @Published var fastingDaysIncludeOptionalDays: Bool {
        didSet { persistDefault(fastingDaysIncludeOptionalDays, key: StorageKeys.fastingDaysIncludeOptionalDays) }
    }

    @Published var fastingDaysIncludeFeastAndHolyDays: Bool {
        didSet { persistDefault(fastingDaysIncludeFeastAndHolyDays, key: StorageKeys.fastingDaysIncludeFeastAndHolyDays) }
    }

    @Published var supportPremiumSurfaceRaw: String {
        didSet { persistDefault(supportPremiumSurfaceRaw, key: StorageKeys.supportPremiumSurface) }
    }

    @Published var simplifiedModeEnabled: Bool {
        didSet { persistDefault(simplifiedModeEnabled, key: StorageKeys.simplifiedModeEnabled) }
    }

    let tracker = FastTracker()
    let penanceNotes = FridayPenanceNotes()
    let intermittentTracker = IntermittentFastTracker()
    let monetizationStore = MonetizationStore()
    let services: CatholicFastingMacPlatformServices

    let defaults: UserDefaults
    var cancellables: Set<AnyCancellable> = []
    var isBootstrapping = true
    let isUITestMode: Bool

    init(
        defaults: UserDefaults = .standard,
        services: CatholicFastingMacPlatformServices = .live,
        isUITestMode: Bool? = nil)
    {
        self.defaults = defaults
        self.services = services
        self.isUITestMode = isUITestMode ?? (ProcessInfo.processInfo.environment["UITEST_MODE"] == "1")

        planningData = LocalFeatureStore.loadPlanningData()
        intermittentSchedules = LocalFeatureStore.loadSchedules()
        activeIntermittentScheduleID = LocalFeatureStore.loadActiveScheduleID() ?? ""
        householdProfiles = LocalFeatureStore.loadProfiles()
        activeHouseholdProfileID = LocalFeatureStore.loadActiveProfileID() ?? ""
        devotionalFavorites = LocalFeatureStore.loadDevotionalFavorites()
        reflectionEntries = LocalFeatureStore.loadReflections()
        premiumChecklist = LocalFeatureStore.loadChecklist()
        premiumCompanion = LocalFeatureStore.loadPremiumCompanionState()
        launchFunnelSnapshot = LocalFeatureStore.loadLaunchFunnelSnapshot()

        age14OrOlderForAbstinence = defaults.object(forKey: StorageKeys.age14OrOlderForAbstinence) as? Bool ?? DefaultValues.age14OrOlderForAbstinence
        age18OrOlderForFasting = defaults.object(forKey: StorageKeys.age18OrOlderForFasting) as? Bool ?? DefaultValues.age18OrOlderForFasting
        medicalDispensation = defaults.object(forKey: StorageKeys.medicalDispensation) as? Bool ?? DefaultValues.medicalDispensation
        ascensionRaw = defaults.string(forKey: StorageKeys.ascensionObservance) ?? DefaultValues.ascension.rawValue
        fridayModeRaw = defaults.string(forKey: StorageKeys.fridayOutsideLentMode) ?? DefaultValues.fridayOutsideLent.rawValue
        provinceRaw = defaults.string(forKey: StorageKeys.usProvincePreset) ?? DefaultValues.province.rawValue
        calendarModeRaw = defaults.string(forKey: StorageKeys.calendarMode) ?? DefaultValues.calendarMode.rawValue
        languageModeRaw = defaults.string(forKey: StorageKeys.languageMode) ?? DefaultValues.language.rawValue
        regionProfileRaw = defaults.string(forKey: StorageKeys.regionProfile) ?? DefaultValues.regionProfile.rawValue
        didCompleteOnboarding = defaults.bool(forKey: StorageKeys.didCompleteOnboarding)
        acceptedLegalNotice = defaults.bool(forKey: StorageKeys.acceptedLegalNotice)
        acceptedLegalNoticeAt = defaults.string(forKey: StorageKeys.acceptedLegalNoticeAt) ?? ""
        liturgicalSeasonColorsEnabled = defaults.object(forKey: StorageKeys.liturgicalSeasonColorsEnabled) as? Bool ?? DefaultValues.liturgicalSeasonColorsEnabled
        dailyReminderSupportEnabled = defaults.object(forKey: StorageKeys.dailyReminderSupportEnabled) as? Bool ?? DefaultValues.dailyReminderSupportEnabled
        morningReminderEnabled = defaults.object(forKey: StorageKeys.morningReminderEnabled) as? Bool ?? DefaultValues.morningReminderEnabled
        eveningReminderEnabled = defaults.object(forKey: StorageKeys.eveningReminderEnabled) as? Bool ?? DefaultValues.eveningReminderEnabled
        dailyQuoteReminderEnabled = defaults.object(forKey: StorageKeys.dailyQuoteReminderEnabled) as? Bool ?? DefaultValues.dailyQuoteReminderEnabled
        dailyQuoteReminderHour = defaults.object(forKey: StorageKeys.dailyQuoteReminderHour) as? Int ?? DefaultValues.dailyQuoteReminderHour
        dailyQuoteReminderMinute = defaults.object(forKey: StorageKeys.dailyQuoteReminderMinute) as? Int ?? DefaultValues.dailyQuoteReminderMinute
        dailyQuoteReminderSignature = defaults.string(forKey: StorageKeys.dailyQuoteReminderSignature) ?? DefaultValues.dailyQuoteReminderSignature
        reminderTierRaw = defaults.string(forKey: StorageKeys.reminderTier) ?? DefaultValues.reminderTier.rawValue
        hapticsEnabled = defaults.object(forKey: StorageKeys.hapticsEnabled) as? Bool ?? DefaultValues.hapticsEnabled
        fastingDaysShowAllYearDays = defaults.bool(forKey: StorageKeys.fastingDaysShowAllYearDays)
        fastingDaysIncludeOptionalDays = defaults.bool(forKey: StorageKeys.fastingDaysIncludeOptionalDays)
        fastingDaysIncludeFeastAndHolyDays = defaults.bool(forKey: StorageKeys.fastingDaysIncludeFeastAndHolyDays)
        supportPremiumSurfaceRaw = defaults.string(forKey: StorageKeys.supportPremiumSurface) ?? DefaultValues.supportPremiumSurface.rawValue
        simplifiedModeEnabled = defaults.bool(forKey: StorageKeys.simplifiedModeEnabled)

        wireObservedState()
        ensureSelections()
        isBootstrapping = false
        persistWidgetSnapshot()
    }
}
