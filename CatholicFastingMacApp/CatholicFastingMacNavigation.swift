import Foundation

enum CatholicFastingMacSurface: String, CaseIterable, Identifiable {
    case today
    case calendar
    case intermittent
    case premium
    case guidance

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .today:
            "Today"
        case .calendar:
            "Fasting Calendar"
        case .intermittent:
            "Intermittent Fast"
        case .premium:
            "Premium Toolkit"
        case .guidance:
            "Guidance"
        }
    }

    var subtitle: String {
        switch self {
        case .today:
            "See today, next required observance, and your current momentum."
        case .calendar:
            "Review the liturgical year and record each observance."
        case .intermittent:
            "Track active fasts, saved schedules, and recent sessions."
        case .premium:
            "Keep planning, reflection, reminders, and subscriptions together."
        case .guidance:
            "Read food guidance, regional norms, and source context."
        }
    }

    var systemImage: String {
        switch self {
        case .today:
            "sun.max"
        case .calendar:
            "calendar"
        case .intermittent:
            "timer"
        case .premium:
            "star.circle"
        case .guidance:
            "book.closed"
        }
    }
}

enum CatholicFastingMacSettingsPane: String, CaseIterable, Identifiable {
    case profile
    case reminders
    case privacy

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .profile:
            "Profile & Norms"
        case .reminders:
            "Reminders"
        case .privacy:
            "Privacy & Data"
        }
    }

    var systemImage: String {
        switch self {
        case .profile:
            "person.crop.circle"
        case .reminders:
            "bell.badge"
        case .privacy:
            "lock.shield"
        }
    }
}
