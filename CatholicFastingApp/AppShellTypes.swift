import Foundation

struct AppNavigationState {
    var homeSurface: HomeSurface = .today
    var selectedMoreDestination: MoreHubDestination? = .supportAndPremium
    var morePath: [MoreHubDestination] = []
    var pendingPhoneMoreDestination: MoreHubDestination?
    var selectedPremiumToolDestination: PremiumToolDestination? = .planner
    var selectedFastingObservanceID = ""
}

struct FastPresentationState {
    var editingScheduleID = ""
    var showsScheduleEditor = false
    var scheduleName = ""
    var scheduleStartHour = 20
    var scheduleWeekdays: Set<Int> = [2, 4, 6]
    var manualStart = AppClock.now()
    var recapNote = ""
    var lastTargetReachedHapticKey = ""
    var lastEatingWindowClosedHapticKey = ""
}

struct PremiumPresentationState {
    var newHouseholdProfileName = ""
    var newSeasonCommitmentTitle = ""
    var newReflectionTitle = ""
    var newReflectionBody = ""
    var newVirtueNote = ""
    var selectedVirtue = "Temperance"
    var householdImportCode = ""
    var householdExportCode = ""
    var companionStatus = ""
}

struct AppFeedbackState {
    var notificationStatus = ""
    var premiumCoachStatus = ""
    var showsDeleteDataConfirmation = false
    var guidanceScenario: GuidanceScenario = .normalDay
}

struct PlanningSessionState {
    var data = LocalFeatureStore.loadPlanningData()
    var schedules = LocalFeatureStore.loadSchedules()
    var activeScheduleID = LocalFeatureStore.loadActiveScheduleID() ?? ""
}

struct ProfileSessionState {
    var householdProfiles = LocalFeatureStore.loadProfiles()
    var activeHouseholdProfileID = LocalFeatureStore.loadActiveProfileID() ?? ""
    var devotionalFavorites = LocalFeatureStore.loadDevotionalFavorites()
}

struct PremiumSessionState {
    var reflections = LocalFeatureStore.loadReflections()
    var checklist = LocalFeatureStore.loadChecklist()
    var companion = LocalFeatureStore.loadPremiumCompanionState()
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
        case .today: "Today"
        case .fastingDays: "Calendar"
        case .intermittent: "Fast"
        case .more: "More"
        }
    }

    var iconName: String {
        switch self {
        case .today: "house.fill"
        case .fastingDays: "calendar"
        case .intermittent: "timer"
        case .more: "ellipsis.circle.fill"
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

enum MoreHubDestination: String, CaseIterable, Hashable, Identifiable {
    case supportAndPremium
    case setupAndReminders
    case profileAndNorms
    case guidanceAndRules
    case historyOfFasting
    case privacyAndData

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .supportAndPremium: "Support & Premium"
        case .setupAndReminders: "Setup & Reminders"
        case .profileAndNorms: "Profile & Norms"
        case .guidanceAndRules: "Guidance & Rules"
        case .historyOfFasting: "History of Fasting"
        case .privacyAndData: "Privacy & Data"
        }
    }

    var subtitle: String {
        switch self {
        case .supportAndPremium: "Upgrade or open premium tools."
        case .setupAndReminders: "Finish setup and manage reminders."
        case .profileAndNorms: "Update your profile, norms, and theme."
        case .guidanceAndRules: "Open food guidance, norms, and sources."
        case .historyOfFasting: "Learn how Catholic fasting developed through the ages."
        case .privacyAndData: "Review consent, exports, backups, and reset tools."
        }
    }

    var iconName: String {
        switch self {
        case .supportAndPremium: "heart.circle"
        case .setupAndReminders: "bell.badge"
        case .profileAndNorms: "person.crop.circle"
        case .guidanceAndRules: "book.closed"
        case .historyOfFasting: "clock.arrow.circlepath"
        case .privacyAndData: "lock.shield"
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
        case .upgrade: "Upgrade"
        case .tools: "Premium Tools"
        }
    }
}

enum PremiumToolDestination: String, CaseIterable, Hashable, Identifiable {
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
        case .planner: "Planner"
        case .reminders: "Reminders"
        case .analytics: "Analytics"
        case .journal: "Journal"
        case .export: "Export"
        }
    }

    var subtitle: String {
        switch self {
        case .planner: "Build your season plan and rule template."
        case .reminders: "Apply smart reminder recommendations."
        case .analytics: "Review completion trends and recovery guidance."
        case .journal: "Write reflections and log virtue check-ins."
        case .export: "Share summaries and household packets."
        }
    }

    var iconName: String {
        switch self {
        case .planner: "calendar.badge.clock"
        case .reminders: "bell.badge.waveform"
        case .analytics: "chart.bar.xaxis"
        case .journal: "book.pages"
        case .export: "square.and.arrow.up"
        }
    }
}
