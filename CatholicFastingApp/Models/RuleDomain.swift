@preconcurrency import Foundation
import SwiftUI
#if canImport(CryptoKit)
  import CryptoKit
#endif

struct RuleSettings: Hashable {
  enum CalendarMode: String, CaseIterable, Identifiable {
    case usccb
    case traditional1962

    var id: String { rawValue }

    var label: String {
      switch self {
      case .usccb:
        return "USCCB (Ordinary Form)"
      case .traditional1962:
        return "Traditional (1962-inspired)"
      }
    }
  }

  enum USProvincePreset: String, CaseIterable, Identifiable {
    case custom
    case boston
    case hartford
    case newYork
    case newark
    case omaha
    case philadelphia
    case otherUSProvince

    var id: String { rawValue }

    var label: String {
      switch self {
      case .custom:
        return "Custom"
      case .boston:
        return "Boston"
      case .hartford:
        return "Hartford"
      case .newYork:
        return "New York"
      case .newark:
        return "Newark"
      case .omaha:
        return "Omaha"
      case .philadelphia:
        return "Philadelphia"
      case .otherUSProvince:
        return "Other U.S. Province"
      }
    }

    var suggestedAscension: AscensionObservance? {
      switch self {
      case .custom:
        return nil
      case .boston, .hartford, .newYork, .newark, .omaha, .philadelphia:
        return .thursday
      case .otherUSProvince:
        return .sunday
      }
    }
  }

  enum AscensionObservance: String, CaseIterable, Identifiable {
    case thursday
    case sunday

    var id: String { rawValue }

    var label: String {
      switch self {
      case .thursday:
        return "Thursday (traditional)"
      case .sunday:
        return "Sunday (transferred)"
      }
    }
  }

  enum FridayOutsideLentMode: String, CaseIterable, Identifiable {
    case abstainFromMeat
    case substitutePenance

    var id: String { rawValue }

    var label: String {
      switch self {
      case .abstainFromMeat:
        return "Abstain from meat"
      case .substitutePenance:
        return "Another penitential act"
      }
    }
  }

  let birthYear: Int
  let hasMedicalDispensation: Bool
  let ascensionObservance: AscensionObservance
  let fridayOutsideLentMode: FridayOutsideLentMode
  let calendarMode: CalendarMode
}

struct RuleBundleMetadata: Hashable {
  let id: String
  let displayName: String
  let version: String
  let effectiveDate: Date
  let reviewedDate: Date
}

struct RuleBundleChange: Hashable, Identifiable {
  let id: String
  let date: Date
  let title: String
  let detail: String
}

struct RuleBundleAudit: Hashable {
  let source: String
  let isVerified: Bool
  let warnings: [String]
}

struct RuleCitation: Hashable {
  enum Authority: String {
    case universalLaw = "Universal Law"
    case usccb = "USCCB"
    case pastoral = "Pastoral Guidance"
  }

  let authority: Authority
  let title: String
  let shortReference: String
}

struct Observance: Identifiable, Hashable {
  enum Kind: String {
    case fastAndAbstinence
    case abstinence
    case fridayPenance
    case holyDay
    case feastDay
    case optionalEmber

    var label: String {
      switch self {
      case .fastAndAbstinence:
        return "Fast + Abstinence"
      case .abstinence:
        return "Abstinence"
      case .fridayPenance:
        return "Friday Penance"
      case .holyDay:
        return "Holy Day"
      case .feastDay:
        return "Feast Day"
      case .optionalEmber:
        return "Optional Ember Day"
      }
    }

    var color: Color {
      switch self {
      case .fastAndAbstinence:
        return .red
      case .abstinence:
        return .orange
      case .fridayPenance:
        return .brown
      case .holyDay:
        return .indigo
      case .feastDay:
        return .blue
      case .optionalEmber:
        return .purple
      }
    }
  }

  enum Obligation: String {
    case mandatory
    case optional
    case notApplicable

    var label: String {
      switch self {
      case .mandatory:
        return "Required"
      case .optional:
        return "Optional"
      case .notApplicable:
        return "Not Required"
      }
    }
  }

  let id: String
  let title: String
  let date: Date
  let kind: Kind
  let obligation: Obligation
  let detail: String?
  let rationale: String
  let citations: [RuleCitation]
  let ruleVersion: String
}

enum ObservanceFilter: String, CaseIterable, Identifiable {
  case all
  case requiredOnly
  case trackedOnly

  var id: String { rawValue }

  var label: String {
    switch self {
    case .all:
      return "All"
    case .requiredOnly:
      return "Required"
    case .trackedOnly:
      return "Tracked"
    }
  }
}

enum CalendarWindow: String, CaseIterable, Identifiable {
  case allYear
  case thisMonth
  case next30Days

  var id: String { rawValue }

  var label: String {
    switch self {
    case .allYear:
      return "All Year"
    case .thisMonth:
      return "This Month"
    case .next30Days:
      return "Next 30 Days"
    }
  }
}

enum ObservanceSortOrder: String, CaseIterable, Identifiable {
  case chronological
  case requiredFirst

  var id: String { rawValue }

  var label: String {
    switch self {
    case .chronological:
      return "By Date"
    case .requiredFirst:
      return "Required First"
    }
  }
}
