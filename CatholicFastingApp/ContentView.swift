import StoreKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ContentView: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.requestReview) var requestReview
    @ScaledMetric(relativeTo: .title2) var regularLiveTrackerCountdownSize: CGFloat = 30
    @ScaledMetric(relativeTo: .title3) var compactLiveTrackerCountdownSize: CGFloat = 25
    @State var year = Calendar.gregorian.component(.year, from: AppClock.now())
    @StateObject var tracker = FastTracker()
    @StateObject var penanceNotes = FridayPenanceNotes()
    @StateObject var intermittentTracker = IntermittentFastTracker()
    @StateObject var monetizationStore = MonetizationStore()
    @State var navigationState = AppNavigationState()
    @State var fastPresentation = FastPresentationState()
    @State var premiumPresentation = PremiumPresentationState()
    @State var feedback = AppFeedbackState()
    @State var launchExecutionState = AppLaunchExecutionState()
    @State var launchFunnelSnapshot = LocalFeatureStore.loadLaunchFunnelSnapshot()
    @State var planningSession = PlanningSessionState()
    @State var profileSession = ProfileSessionState()
    @State var premiumSession = PremiumSessionState()
    @FocusState var intermittentRecapNoteFocused: Bool

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
    @AppStorage(StorageKeys.intermittentIntention) var intermittentIntentionRaw = DefaultValues.intermittentIntention
    @AppStorage(StorageKeys.intermittentTargetReminderEnabled) var intermittentTargetReminderEnabled =
        DefaultValues.intermittentTargetReminderEnabled
    @AppStorage(StorageKeys.didRequestAppReview) var didRequestAppReview = false

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
            for: Calendar.gregorian.component(.year, from: AppClock.now()),
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .pad
        }
        #endif
        return .phone
    }

    var body: some View {
        if didCompleteOnboarding {
            applyRootLifecycleHandlers(
                to: Group {
                    if appLayoutProfile.usesSplitViewShell {
                        ipadRootScaffold
                    } else {
                        tabRootScaffold
                    }
                })
        } else {
            onboardingLaunchRoot
        }
    }
}
