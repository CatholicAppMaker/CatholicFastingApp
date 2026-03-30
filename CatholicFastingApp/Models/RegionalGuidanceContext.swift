@preconcurrency import Foundation

private enum RegionalGuidanceLinks {
    static let privacy = URL(string: "https://x.com/CatholicFasting/status/2026354531273945191")
    static let usccbFastAbstinence = URL(
        string:
        "https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar/lent/catholic-information-on-lenten-fast-and-abstinence")
    static let cccbKeepingFriday = URL(string: "https://www.cccb.ca/document/keeping-friday/")
}

enum RegionalSupportLevel: String, CaseIterable {
    case full
    case partial
    case informational

    var label: String {
        switch self {
        case .full:
            CoreLocalizer.localizedCurrent("regional.support.full", default: "Modeled")
        case .partial:
            CoreLocalizer.localizedCurrent("regional.support.partial", default: "Partial")
        case .informational:
            CoreLocalizer.localizedCurrent("regional.support.informational", default: "Informational")
        }
    }
}

struct RegionalRuleContext: Hashable {
    let regionProfile: RuleSettings.RegionProfile
    let supportLevel: RegionalSupportLevel
    let classificationLabel: String
    let authorityLabel: String
    let disclosureText: String
    let citations: [RuleCitation]
    let sourceURL: URL?
}

struct ObservancePresentationContext: Hashable {
    let observance: Observance
    let regionalContext: RegionalRuleContext
    let sourceSummary: String
    let nextActionText: String
}

enum PremiumWorkspaceSection: String, CaseIterable, Identifiable {
    case dashboard
    case planning
    case reminders
    case reflection
    case analytics
    case export

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .dashboard:
            "Dashboard"
        case .planning:
            "Planning"
        case .reminders:
            "Reminders"
        case .reflection:
            "Reflection"
        case .analytics:
            "Analytics"
        case .export:
            "Export"
        }
    }
}

enum IPadWorkspaceLayout: String {
    case dashboard
    case planningTriptych
    case controlCenter
    case settingsDetail
}

enum RegionalGuidanceContextFactory {
    static func generalContext(for settings: RuleSettings) -> RegionalRuleContext {
        switch settings.regionProfile {
        case .us:
            RegionalRuleContext(
                regionProfile: .us,
                supportLevel: .full,
                classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.us_profile", default: "U.S. profile"),
                authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.us", default: "USCCB + universal law"),
                disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.us_profile", default: "This profile models universal fasting norms together with U.S.-specific Friday and holy day handling used throughout the app."),
                citations: [
                    RuleCitation(authority: .universalLaw, title: "Code of Canon Law", shortReference: "Can. 1249-1253"),
                    RuleCitation(authority: .usccb, title: "USCCB Liturgical Guidance", shortReference: "U.S. conference norms"),
                ],
                sourceURL: RegionalGuidanceLinks.usccbFastAbstinence)
        case .canada:
            RegionalRuleContext(
                regionProfile: .canada,
                supportLevel: .full,
                classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.canada_baseline", default: "Canada baseline"),
                authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.canada", default: "Universal law + CCCB guidance"),
                disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.canada_profile", default: "The Canada profile models the national baseline directly: universal fasting law, CCCB Friday penitential guidance, and Canada-wide holy day obligations. Diocesan proper calendars are not included in this release."),
                citations: [
                    RuleCitation(authority: .universalLaw, title: "Code of Canon Law", shortReference: "Can. 1249-1253"),
                    RuleCitation(authority: .cccb, title: "Keeping Friday", shortReference: "CCCB Friday guidance"),
                ],
                sourceURL: RegionalGuidanceLinks.cccbKeepingFriday)
        case .other:
            RegionalRuleContext(
                regionProfile: .other,
                supportLevel: .informational,
                classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.local_guidance", default: "Local guidance"),
                authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.local", default: "Universal law + local conference law"),
                disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.other_profile", default: "Outside the U.S. and Canada profiles, the app treats regional norms as informational beyond universal fasting law. Users should follow local episcopal and diocesan guidance."),
                citations: [
                    RuleCitation(authority: .universalLaw, title: "Code of Canon Law", shortReference: "Can. 1249-1253"),
                    RuleCitation(authority: .pastoral, title: "Local Catholic Guidance", shortReference: "Consult local conference norms"),
                ],
                sourceURL: nil)
        }
    }

    static func context(for observance: Observance, settings: RuleSettings) -> RegionalRuleContext {
        switch observance.kind {
        case .fastAndAbstinence, .abstinence:
            RegionalRuleContext(
                regionProfile: settings.regionProfile,
                supportLevel: .full,
                classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.universal", default: "Universal"),
                authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.universal", default: "Universal law"),
                disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.universal_observance", default: "This observance is grounded in universal fasting and abstinence law. Regional profiles change supporting explanation and Friday practice, not the universal core."),
                citations: observance.citations,
                sourceURL: settings.regionProfile == .canada
                    ? RegionalGuidanceLinks.cccbKeepingFriday
                    : RegionalGuidanceLinks.usccbFastAbstinence)
        case .fridayPenance:
            switch settings.regionProfile {
            case .us:
                RegionalRuleContext(
                    regionProfile: .us,
                    supportLevel: .full,
                    classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.us_norm", default: "U.S. norm"),
                    authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.usccb", default: "USCCB guidance"),
                    disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.us_friday", default: "Outside Lent Friday practice follows the U.S. mode selected in your profile."),
                    citations: observance.citations,
                    sourceURL: RegionalGuidanceLinks.usccbFastAbstinence)
            case .canada:
                RegionalRuleContext(
                    regionProfile: .canada,
                    supportLevel: .full,
                    classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.canada_guidance", default: "Canada guidance"),
                    authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.cccb", default: "CCCB guidance"),
                    disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.canada_friday", default: "Friday remains penitential in the Canada profile. The app models abstinence or another charitable or pious practice based on CCCB guidance."),
                    citations: observance.citations,
                    sourceURL: RegionalGuidanceLinks.cccbKeepingFriday)
            case .other:
                RegionalRuleContext(
                    regionProfile: .other,
                    supportLevel: .informational,
                    classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.local_guidance", default: "Local guidance"),
                    authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.local_conference", default: "Local conference law"),
                    disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.other_friday", default: "Friday practice outside the U.S. and Canada profiles is shown for planning context only unless local law is modeled."),
                    citations: observance.citations,
                    sourceURL: nil)
            }
        case .holyDay:
            switch settings.regionProfile {
            case .us:
                RegionalRuleContext(
                    regionProfile: .us,
                    supportLevel: .full,
                    classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.us_norm", default: "U.S. norm"),
                    authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.us_holyday", default: "Universal + U.S. holy day law"),
                    disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.us_holyday", default: "U.S. holy day handling is modeled directly, including transferred or abrogated cases where applicable."),
                    citations: observance.citations,
                    sourceURL: RegionalGuidanceLinks.privacy)
            case .canada:
                RegionalRuleContext(
                    regionProfile: .canada,
                    supportLevel: .full,
                    classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.canada_baseline", default: "Canada baseline"),
                    authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.canada_holyday", default: "Universal law + Canada national baseline"),
                    disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.canada_holyday", default: "Canada holy day handling is modeled for the national baseline only. The app includes Canada-wide obligations and planning context, but not diocesan proper calendars."),
                    citations: observance.citations,
                    sourceURL: nil)
            case .other:
                RegionalRuleContext(
                    regionProfile: .other,
                    supportLevel: .informational,
                    classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.informational", default: "Informational"),
                    authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.local_conference", default: "Local conference law"),
                    disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.other_holyday", default: "Holy day handling is informational outside the U.S. profile unless a fully modeled local obligation rule exists."),
                    citations: observance.citations,
                    sourceURL: nil)
            }
        case .feastDay, .memorialDay:
            switch settings.regionProfile {
            case .us:
                RegionalRuleContext(
                    regionProfile: .us,
                    supportLevel: .full,
                    classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.calendar_context", default: "Calendar context"),
                    authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.liturgical_planning", default: "Liturgical planning"),
                    disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.celebration_us", default: "These celebration days are included for liturgical and devotional planning. They are not fasting obligations."),
                    citations: observance.citations,
                    sourceURL: RegionalGuidanceLinks.privacy)
            case .canada:
                RegionalRuleContext(
                    regionProfile: .canada,
                    supportLevel: .full,
                    classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.canada_baseline", default: "Canada baseline"),
                    authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.liturgical_planning", default: "Liturgical planning"),
                    disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.celebration_canada", default: "These celebration days are included for Canada-wide planning and devotion in the national baseline. Diocesan proper calendars are not included yet."),
                    citations: observance.citations,
                    sourceURL: nil)
            case .other:
                RegionalRuleContext(
                    regionProfile: .other,
                    supportLevel: .informational,
                    classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.calendar_context", default: "Calendar context"),
                    authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.liturgical_planning", default: "Liturgical planning"),
                    disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.celebration_other", default: "These celebration days are informational outside fully modeled regional calendars."),
                    citations: observance.citations,
                    sourceURL: nil)
            }
        case .optionalEmber:
            RegionalRuleContext(
                regionProfile: settings.regionProfile,
                supportLevel: .informational,
                classificationLabel: CoreLocalizer.localizedCurrent("regional.classification.devotional", default: "Devotional"),
                authorityLabel: CoreLocalizer.localizedCurrent("regional.authority.optional_practice", default: "Optional practice"),
                disclosureText: CoreLocalizer.localizedCurrent("regional.disclosure.ember", default: "Ember days are shown as devotional discipline and not as universal obligation days in this release."),
                citations: observance.citations,
                sourceURL: nil)
        }
    }

    static func presentationContext(for observance: Observance, settings: RuleSettings) -> ObservancePresentationContext {
        let regionalContext = context(for: observance, settings: settings)
        let sourceSummary = observance.citations.map { "\($0.authority.rawValue): \($0.shortReference)" }.joined(separator: " • ")
        let nextActionText: String = switch observance.kind {
        case .feastDay, .memorialDay:
            "Celebrate the day and avoid treating it like a required fast."
        case .optionalEmber:
            "Use this only as a voluntary devotional discipline if it is prudent for your state in life."
        case .fridayPenance:
            observance.obligation == .mandatory
                ? "Choose the Friday penitential act you will actually keep, then log it here."
                : "Review local custom and choose a prudent Friday practice."
        case .holyDay:
            regionalContext.supportLevel == .full
                ? "Plan Mass attendance and log your observance clearly."
                : "Use this as planning context and confirm local obligation if certainty matters."
        case .fastAndAbstinence, .abstinence:
            observance.obligation == .mandatory
                ? "Protect this day on your calendar and log the discipline you actually kept."
                : "Review the day and use it for planning or moderated discipline if prudent."
        }

        return ObservancePresentationContext(
            observance: observance,
            regionalContext: regionalContext,
            sourceSummary: sourceSummary,
            nextActionText: nextActionText)
    }
}
