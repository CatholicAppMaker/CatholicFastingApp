import SwiftUI

#if canImport(UserNotifications)
  import UserNotifications
#endif

extension View {
  @ViewBuilder
  func appPrimaryButtonStyle(legacyTint: Color = CatholicTheme.primary) -> some View {
    if #available(iOS 26.0, *) {
      buttonStyle(.glassProminent)
    } else {
      buttonStyle(.borderedProminent)
        .tint(legacyTint)
    }
  }

  @ViewBuilder
  func appSecondaryButtonStyle(legacyTint: Color = CatholicTheme.primary) -> some View {
    if #available(iOS 26.0, *) {
      buttonStyle(.glass)
    } else {
      buttonStyle(.bordered)
        .tint(legacyTint)
    }
  }

  @ViewBuilder
  func appRootBackground() -> some View {
    background(CatholicTheme.background)
  }

  @ViewBuilder
  func appListBackground() -> some View {
    scrollContentBackground(.hidden)
      .background(CatholicTheme.background)
  }

  @ViewBuilder
  func appRoundedGlass(cornerRadius: CGFloat) -> some View {
    if #available(iOS 26.0, *) {
      glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    } else {
      self
    }
  }

  @ViewBuilder
  func appCapsuleGlass() -> some View {
    if #available(iOS 26.0, *) {
      glassEffect(in: Capsule())
    } else {
      self
    }
  }
}

enum UIConstants {
  static var yearRange: ClosedRange<Int> {
    let currentYear = Calendar.current.component(.year, from: Date())
    return (currentYear - 5)...(currentYear + 15)
  }
  static let minBirthYear = 1900
  static let legalPolicyURL = URL(
    string: "https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar")!
  static let usccbFastAbstinenceURL = URL(
    string:
      "https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar/lent/catholic-information-on-lenten-fast-and-abstinence"
  )!
  static let supportEmail = URL(
    string: "mailto:support@catholicfasting.app?subject=Catholic%20Fasting%20App%20Feedback")!
  static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!
  static let exportISO8601: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()
}

enum CatholicTheme {
  struct Palette {
    let season: LiturgicalSeason
    let primary: Color
    let accent: Color
    let parchment: Color
    let parchmentShade: Color
    let cardBorder: Color
  }

  static var activePalette: Palette {
    let enabled =
      UserDefaults.standard.object(forKey: StorageKeys.liturgicalSeasonColorsEnabled) == nil
      ? true
      : UserDefaults.standard.bool(forKey: StorageKeys.liturgicalSeasonColorsEnabled)
    return palette(seasonModeEnabled: enabled, date: Date())
  }

  static var primary: Color { activePalette.primary }
  static var accent: Color { activePalette.accent }
  static var parchment: Color { activePalette.parchment }
  static var parchmentShade: Color { activePalette.parchmentShade }
  static var cardBorder: Color { activePalette.cardBorder }
  static var seasonLabel: String { activePalette.season.label }
  static var seasonToolbarLabel: String {
    switch activePalette.season {
    case .ordinary:
      return "Ordinary"
    case .advent:
      return "Advent"
    case .christmas:
      return "Christmas"
    case .lent:
      return "Lent"
    case .easter:
      return "Easter"
    }
  }

  static var background: LinearGradient {
    LinearGradient(
      colors: [parchment, parchmentShade],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  static func palette(seasonModeEnabled: Bool, date: Date) -> Palette {
    guard seasonModeEnabled else {
      return Palette(
        season: .ordinary,
        primary: Color(red: 0.38, green: 0.12, blue: 0.15),
        accent: Color(red: 0.72, green: 0.56, blue: 0.18),
        parchment: Color(red: 0.97, green: 0.94, blue: 0.86),
        parchmentShade: Color(red: 0.91, green: 0.87, blue: 0.77),
        cardBorder: Color(red: 0.67, green: 0.58, blue: 0.34)
      )
    }

    let season = LiturgicalSeasonThemeEngine.season(for: date)
    switch season {
    case .advent:
      return Palette(
        season: season,
        primary: Color(red: 0.16, green: 0.23, blue: 0.46),
        accent: Color(red: 0.68, green: 0.40, blue: 0.56),
        parchment: Color(red: 0.95, green: 0.95, blue: 0.98),
        parchmentShade: Color(red: 0.86, green: 0.88, blue: 0.95),
        cardBorder: Color(red: 0.44, green: 0.48, blue: 0.71)
      )
    case .christmas:
      return Palette(
        season: season,
        primary: Color(red: 0.46, green: 0.30, blue: 0.09),
        accent: Color(red: 0.80, green: 0.63, blue: 0.20),
        parchment: Color(red: 0.99, green: 0.98, blue: 0.93),
        parchmentShade: Color(red: 0.95, green: 0.93, blue: 0.83),
        cardBorder: Color(red: 0.75, green: 0.63, blue: 0.30)
      )
    case .lent:
      return Palette(
        season: season,
        primary: Color(red: 0.29, green: 0.16, blue: 0.40),
        accent: Color(red: 0.56, green: 0.47, blue: 0.67),
        parchment: Color(red: 0.95, green: 0.92, blue: 0.94),
        parchmentShade: Color(red: 0.86, green: 0.82, blue: 0.89),
        cardBorder: Color(red: 0.53, green: 0.44, blue: 0.62)
      )
    case .easter:
      return Palette(
        season: season,
        primary: Color(red: 0.18, green: 0.33, blue: 0.20),
        accent: Color(red: 0.77, green: 0.63, blue: 0.20),
        parchment: Color(red: 0.98, green: 0.98, blue: 0.93),
        parchmentShade: Color(red: 0.91, green: 0.93, blue: 0.84),
        cardBorder: Color(red: 0.52, green: 0.64, blue: 0.45)
      )
    case .ordinary:
      return Palette(
        season: season,
        primary: Color(red: 0.14, green: 0.34, blue: 0.20),
        accent: Color(red: 0.66, green: 0.52, blue: 0.16),
        parchment: Color(red: 0.96, green: 0.95, blue: 0.87),
        parchmentShade: Color(red: 0.88, green: 0.90, blue: 0.79),
        cardBorder: Color(red: 0.43, green: 0.56, blue: 0.39)
      )
    }
  }
}

enum DefaultValues {
  static let birthYear = 0
  static let medicalDispensation = false
  static let ascension = RuleSettings.AscensionObservance.sunday
  static let fridayOutsideLent = RuleSettings.FridayOutsideLentMode.substitutePenance
  static let province = RuleSettings.USProvincePreset.otherUSProvince
  static let calendarMode = RuleSettings.CalendarMode.usccb
  static let language = LanguageMode.english
  static let liturgicalSeasonColorsEnabled = true
  static let dailyReminderSupportEnabled = true
  static let morningReminderEnabled = true
  static let eveningReminderEnabled = false
  static let allowLocalAnalytics = false
}

enum StorageKeys {
  static let birthYear = "birth_year"
  static let medicalDispensation = "medical_dispensation"
  static let ascensionObservance = "ascension_observance"
  static let fridayOutsideLentMode = "friday_outside_lent_mode"
  static let usProvincePreset = "us_province_preset"
  static let calendarMode = "calendar_mode"
  static let languageMode = "language_mode"
  static let didCompleteOnboarding = "did_complete_onboarding"
  static let acceptedLegalNotice = "accepted_legal_notice"
  static let acceptedLegalNoticeAt = "accepted_legal_notice_at"
  static let crashReportingEnabled = "crash_reporting_enabled"
  static let allowCloudSync = "allow_cloud_sync"
  static let allowDiagnostics = "allow_diagnostics"
  static let allowLocalAnalytics = LocalAnalyticsStore.enabledKey
  static let liturgicalSeasonColorsEnabled = "liturgical_season_colors_enabled"
  static let dailyReminderSupportEnabled = "daily_reminder_support_enabled"
  static let morningReminderEnabled = "morning_reminder_enabled"
  static let eveningReminderEnabled = "evening_reminder_enabled"
}

enum LanguageMode: String, CaseIterable, Identifiable {
  case english
  case spanish

  var id: String { rawValue }

  var label: String {
    switch self {
    case .english:
      return "English"
    case .spanish:
      return "Español"
    }
  }
}

enum HomeSurface: String, CaseIterable, Identifiable {
  case today
  case calendar
  case intermittent
  case more

  var id: String { rawValue }

  var label: String {
    switch self {
    case .today:
      return "Today"
    case .calendar:
      return "Calendar"
    case .intermittent:
      return "Track Fast"
    case .more:
      return "More"
    }
  }

  var iconName: String {
    switch self {
    case .today:
      return "house.fill"
    case .calendar:
      return "calendar"
    case .intermittent:
      return "timer"
    case .more:
      return "ellipsis.circle.fill"
    }
  }

  static let primarySurfaces: [HomeSurface] = [.today, .calendar, .intermittent, .more]
}

enum MoreHubDestination: String, CaseIterable, Identifiable {
  case supportAndPremium
  case setupAndReminders
  case profileAndNorms
  case guidanceAndRules
  case privacyAndData

  var id: String { rawValue }

  var title: String {
    switch self {
    case .supportAndPremium:
      return "Support & Premium"
    case .setupAndReminders:
      return "Setup & Reminders"
    case .profileAndNorms:
      return "Profile & Norms"
    case .guidanceAndRules:
      return "Guidance & Rules"
    case .privacyAndData:
      return "Privacy & Data"
    }
  }

  var subtitle: String {
    switch self {
    case .supportAndPremium:
      return "Manage premium access and optional one-time support tips."
    case .setupAndReminders:
      return "Finish setup, schedule notifications, and log Friday penance notes."
    case .profileAndNorms:
      return "Update profile, fasting norms, and liturgical appearance preferences."
    case .guidanceAndRules:
      return "Read practical fasting guidance, examples, and source links."
    case .privacyAndData:
      return "Review consent, exports, backups, and delete/reset controls."
    }
  }

  var iconName: String {
    switch self {
    case .supportAndPremium:
      return "heart.circle"
    case .setupAndReminders:
      return "bell.badge"
    case .profileAndNorms:
      return "person.crop.circle"
    case .guidanceAndRules:
      return "book.closed"
    case .privacyAndData:
      return "lock.shield"
    }
  }
}

enum AppLocalizer {
  static func localized(_ key: String, default defaultValue: String, languageCode: String) -> String {
    let resolvedCode = languageCode == LanguageMode.spanish.rawValue ? "es" : "en"
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

struct ContentView: View {
  @Environment(\.dynamicTypeSize) var dynamicTypeSize
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
  @State var observanceFilter: ObservanceFilter = .all
  @State var observanceQuery = ""
  @State var calendarWindow: CalendarWindow = .allYear
  @State var observanceSortOrder: ObservanceSortOrder = .chronological
  @State var didTrackLaunchAnalytics = false

  @AppStorage(StorageKeys.birthYear) var birthYear = DefaultValues.birthYear
  @AppStorage(StorageKeys.medicalDispensation) var medicalDispensation = DefaultValues
    .medicalDispensation
  @AppStorage(StorageKeys.ascensionObservance) var ascensionRaw = DefaultValues.ascension.rawValue
  @AppStorage(StorageKeys.fridayOutsideLentMode) var fridayModeRaw = DefaultValues.fridayOutsideLent
    .rawValue
  @AppStorage(StorageKeys.usProvincePreset) var provinceRaw = DefaultValues.province.rawValue
  @AppStorage(StorageKeys.calendarMode) var calendarModeRaw = DefaultValues.calendarMode.rawValue
  @AppStorage(StorageKeys.languageMode) var languageModeRaw = DefaultValues.language.rawValue
  @AppStorage(StorageKeys.didCompleteOnboarding) var didCompleteOnboarding = false
  @AppStorage(StorageKeys.acceptedLegalNotice) var acceptedLegalNotice = false
  @AppStorage(StorageKeys.acceptedLegalNoticeAt) var acceptedLegalNoticeAt = ""
  @AppStorage(StorageKeys.crashReportingEnabled) var crashReportingEnabled = false
  @AppStorage(StorageKeys.allowCloudSync) var allowCloudSync = true
  @AppStorage(StorageKeys.allowDiagnostics) var allowDiagnostics = true
  @AppStorage(StorageKeys.allowLocalAnalytics) var allowLocalAnalytics = DefaultValues.allowLocalAnalytics
  @AppStorage(StorageKeys.liturgicalSeasonColorsEnabled) var liturgicalSeasonColorsEnabled =
    DefaultValues.liturgicalSeasonColorsEnabled
  @AppStorage(StorageKeys.dailyReminderSupportEnabled) var dailyReminderSupportEnabled =
    DefaultValues.dailyReminderSupportEnabled
  @AppStorage(StorageKeys.morningReminderEnabled) var morningReminderEnabled =
    DefaultValues.morningReminderEnabled
  @AppStorage(StorageKeys.eveningReminderEnabled) var eveningReminderEnabled =
    DefaultValues.eveningReminderEnabled

  var settings: RuleSettings {
    RuleSettings(
      birthYear: birthYear,
      hasMedicalDispensation: medicalDispensation,
      ascensionObservance: RuleSettings.AscensionObservance(rawValue: ascensionRaw) ?? .sunday,
      fridayOutsideLentMode: RuleSettings.FridayOutsideLentMode(rawValue: fridayModeRaw)
        ?? .substitutePenance,
      calendarMode: RuleSettings.CalendarMode(rawValue: calendarModeRaw) ?? .usccb
    )
  }

  var provinceSelection: RuleSettings.USProvincePreset {
    RuleSettings.USProvincePreset(rawValue: provinceRaw) ?? .otherUSProvince
  }

  var languageMode: LanguageMode {
    LanguageMode(rawValue: languageModeRaw) ?? .english
  }

  var observances: [Observance] {
    ObservanceCalculator.makeCalendar(for: year, settings: settings)
  }

  var actionableObservances: [Observance] {
    observances.filter { $0.obligation != .notApplicable }
  }

  var completedCount: Int {
    actionableObservances.filter { tracker.status(for: $0.id).countsTowardProgress }.count
  }

  var syncSnapshot: SyncSnapshot {
    SyncDiagnostics.snapshot()
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

  func localizedFormat(_ key: String, default defaultFormat: String, _ value: CVarArg) -> String {
    let format = localized(key, default: defaultFormat)
    return String(format: format, locale: Locale.current, value)
  }

  var body: some View {
    NavigationStack {
      TabView(selection: $homeSurface) {
        surfaceList(for: .today)
          .tabItem {
            Label(HomeSurface.today.label, systemImage: HomeSurface.today.iconName)
          }
          .tag(HomeSurface.today)
          .accessibilityIdentifier("tab.today")
        surfaceList(for: .calendar)
          .tabItem {
            Label(HomeSurface.calendar.label, systemImage: HomeSurface.calendar.iconName)
          }
          .tag(HomeSurface.calendar)
          .accessibilityIdentifier("tab.calendar")
        surfaceList(for: .intermittent)
          .tabItem {
            Label(HomeSurface.intermittent.label, systemImage: HomeSurface.intermittent.iconName)
          }
          .tag(HomeSurface.intermittent)
          .accessibilityIdentifier("tab.intermittent")
        surfaceList(for: .more)
          .tabItem {
            Label(HomeSurface.more.label, systemImage: HomeSurface.more.iconName)
          }
          .tag(HomeSurface.more)
          .accessibilityIdentifier("tab.more")
      }
      .appRootBackground()
      .toolbarBackground(.visible, for: .tabBar)
      .toolbarBackground(.ultraThinMaterial, for: .tabBar)
      .overlay(alignment: .topLeading) {
        readinessMarkers
      }
      .navigationTitle("Catholic Fasting")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        if #available(iOS 26.0, *) {
          ToolbarItem(placement: .topBarTrailing) {
            seasonBadge
          }
          .sharedBackgroundVisibility(.hidden)
        } else {
          ToolbarItem(placement: .topBarTrailing) {
            seasonBadge
          }
        }
      }
      .tint(CatholicTheme.primary)
      .onChange(of: acceptedLegalNotice) { _, newValue in
        acceptedLegalNoticeAt = newValue ? UIConstants.exportISO8601.string(from: Date()) : ""
      }
      .onChange(of: allowLocalAnalytics) { _, newValue in
        LocalAnalyticsStore.setEnabled(newValue)
      }
      .sheet(isPresented: onboardingBinding) {
        OnboardingView(
          birthYear: $birthYear,
          medicalDispensation: $medicalDispensation,
          fridayModeRaw: $fridayModeRaw,
          dailyReminderSupportEnabled: $dailyReminderSupportEnabled
        ) {
          didCompleteOnboarding = true
          LocalAnalyticsStore.track(.onboardingCompleted)
        }
      }
      .task {
        LocalAnalyticsStore.setEnabled(allowLocalAnalytics)
        if !didTrackLaunchAnalytics {
          LocalAnalyticsStore.track(.appLaunch)
          didTrackLaunchAnalytics = true
        }
        await monetizationStore.refreshCatalogAndEntitlements()
        notificationStatus = await ReminderScheduler.notificationSummary()
      }
    }
  }

  @ViewBuilder
  var seasonBadge: some View {
    let content = HStack(spacing: 6) {
      Image(systemName: "cross.case.fill")
        .foregroundStyle(CatholicTheme.primary)
        .accessibilityHidden(true)
      if liturgicalSeasonColorsEnabled && !dynamicTypeSize.isAccessibilitySize {
        Text(CatholicTheme.seasonToolbarLabel)
          .font(.caption2.weight(.bold))
          .foregroundStyle(CatholicTheme.primary)
          .lineLimit(1)
          .fixedSize(horizontal: true, vertical: false)
      }
    }
    .padding(.horizontal, 9)
    .padding(.vertical, 5)
    .accessibilityIdentifier("home.season_badge")
    .accessibilityLabel("Liturgical season \(CatholicTheme.seasonToolbarLabel)")

    if #available(iOS 26.0, *) {
      content.appCapsuleGlass()
    } else {
      content
        .background(
          Capsule()
            .fill(CatholicTheme.parchment)
        )
        .overlay(
          Capsule()
            .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1)
        )
    }
  }

  @ViewBuilder
  func surfaceList(for surface: HomeSurface) -> some View {
    List {
      surfaceSections(for: surface)
    }
    .listStyle(.insetGrouped)
    .appListBackground()
  }

  @ViewBuilder
  func surfaceSections(for surface: HomeSurface) -> some View {
    switch surface {
    case .today:
      unofficialAppNoticeSection
      dashboardSacredImageSection
      dashboardDevotionalGallerySection
      dashboardQuickActionsSection
      setupProgressSection
      todayDecisionCardSection
      todayRecoverySection
      dashboardSeasonSection
      dashboardHeroSection
      todaySection
      progressSection
      analyticsSection
      dashboardHighlightsSection
    case .calendar:
      yearSection
      observanceControlsSection
      calendarInsightsSection
      observanceLegendSection
      observancesSection
    case .intermittent:
      intermittentHeroSection
      intermittentOverviewSection
      intermittentControlsSection
      intermittentActiveSection
      intermittentSessionHistorySection
    case .more:
      unofficialAppNoticeSection
      moreHubSection
    }
  }

  var moreHubSection: some View {
    Section("More Tools") {
      Text("Choose a focused page instead of scrolling through every setting in one place.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      ForEach(MoreHubDestination.allCases) { destination in
        NavigationLink {
          moreDestinationList(for: destination)
        } label: {
          VStack(alignment: .leading, spacing: 4) {
            Label(destination.title, systemImage: destination.iconName)
              .font(.headline)
              .foregroundStyle(CatholicTheme.primary)
            Text(destination.subtitle)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          .padding(.vertical, 2)
        }
        .accessibilityIdentifier("more.hub.\(destination.rawValue)")
      }
    }
  }

  @ViewBuilder
  func moreDestinationList(for destination: MoreHubDestination) -> some View {
    List {
      switch destination {
      case .supportAndPremium:
        premiumAndSupportSection
      case .setupAndReminders:
        quickSetupSection
        notificationsSection
        notesSection
      case .profileAndNorms:
        profileRulesSection
        regionalNormsSection
        themeSection
      case .guidanceAndRules:
        guidanceSacredImageSection
        guidanceDevotionalGallerySection
        guidanceSeasonContextSection
        fastDayQuickRulesSection
        usccbGuidelinesSection
        foodGuidanceSection
        practicalFoodExamplesSection
        pastoralGuidanceSection
        faqSection
        sourcesSection
      case .privacyAndData:
        privacySection
        backupsSection
        dataManagementSection
      }
    }
    .listStyle(.insetGrouped)
    .appListBackground()
    .navigationTitle(destination.title)
    .navigationBarTitleDisplayMode(.inline)
  }
}
