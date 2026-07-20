import Foundation

enum LanguageMode: String, CaseIterable, Identifiable {
    case english
    case spanish
    case frenchCanadian

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .english: "English"
        case .spanish: "Español"
        case .frenchCanadian: "Français (Canada)"
        }
    }

    var localizationCode: String {
        switch self {
        case .english: "en"
        case .spanish: "es"
        case .frenchCanadian: "fr-CA"
        }
    }

    var contentLocale: ContentLocale {
        switch self {
        case .english: .english
        case .spanish: .spanish
        case .frenchCanadian: .frenchCanadian
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

    static func currentLanguageMode(userDefaults: UserDefaults = .standard) -> LanguageMode {
        let rawValue = userDefaults.string(forKey: StorageKeys.languageMode) ?? DefaultValues.language.rawValue
        return LanguageMode(rawValue: rawValue) ?? .english
    }

    static func currentLanguageCode(userDefaults: UserDefaults = .standard) -> String {
        currentLanguageMode(userDefaults: userDefaults).rawValue
    }

    static func currentLocale(userDefaults: UserDefaults = .standard) -> Locale {
        Locale(identifier: currentLanguageMode(userDefaults: userDefaults).localizationCode)
    }

    static func localizedCurrent(
        _ key: String,
        default defaultValue: String,
        userDefaults: UserDefaults = .standard) -> String
    {
        localized(key, default: defaultValue, languageCode: currentLanguageCode(userDefaults: userDefaults))
    }

    static func localizedCurrentFormat(
        _ key: String,
        default defaultValue: String,
        _ arguments: CVarArg...,
        userDefaults: UserDefaults = .standard) -> String
    {
        let format = localizedCurrent(key, default: defaultValue, userDefaults: userDefaults)
        return String(format: format, locale: currentLocale(userDefaults: userDefaults), arguments: arguments)
    }
}

enum ObservanceContentLocalizer {
    static func localizedTitle(_ title: String, languageCode: String) -> String {
        guard let identifier = ObservanceLocalizationCatalog.titleIdentifier(for: title) else { return title }
        return AppLocalizer.localized(
            localizationKey(section: "title", identifier: identifier),
            default: title,
            languageCode: languageCode)
    }

    static func localizedDetail(_ detail: String?, languageCode: String) -> String? {
        guard let detail, !detail.isEmpty else { return detail }
        guard let identifier = ObservanceLocalizationCatalog.detailIdentifier(for: detail) else { return detail }
        return AppLocalizer.localized(
            localizationKey(section: "detail", identifier: identifier),
            default: detail,
            languageCode: languageCode)
    }

    static func localizedRationale(_ observance: Observance, languageCode: String) -> String {
        guard let identifier = ObservanceLocalizationCatalog.rationaleIdentifier(for: observance.rationale) else {
            return observance.rationale
        }
        let key = "observance.rationale.\(identifier)"
        let localizedDefault = ObservanceLocalizationCatalog.rationaleDefaultsByIdentifier[identifier]
            ?? observance.rationale
        let format = AppLocalizer.localized(key, default: localizedDefault, languageCode: languageCode)
        if identifier.hasSuffix("_format") {
            return String(
                format: format,
                locale: Locale(identifier: (LanguageMode(rawValue: languageCode) ?? .english).localizationCode),
                localizedTitle(observance.title, languageCode: languageCode))
        }
        return format
    }

    static func localizedCurrentTitle(
        _ title: String,
        userDefaults: UserDefaults = .standard) -> String
    {
        localizedTitle(title, languageCode: AppLocalizer.currentLanguageCode(userDefaults: userDefaults))
    }

    static func localizedCurrentDetail(
        _ detail: String?,
        userDefaults: UserDefaults = .standard) -> String?
    {
        localizedDetail(detail, languageCode: AppLocalizer.currentLanguageCode(userDefaults: userDefaults))
    }

    static func localizedCurrentRationale(
        _ observance: Observance,
        userDefaults: UserDefaults = .standard) -> String
    {
        localizedRationale(observance, languageCode: AppLocalizer.currentLanguageCode(userDefaults: userDefaults))
    }

    private static func localizationKey(section: String, identifier: String) -> String {
        ["observance", section, identifier].joined(separator: ".")
    }
}

enum ObservanceTitleLocalizer {
    static func localizedCurrent(_ title: String, userDefaults: UserDefaults = .standard) -> String {
        ObservanceContentLocalizer.localizedCurrentTitle(title, userDefaults: userDefaults)
    }
}

enum ObservancePresentationLocalizer {
    static func kindLabel(_ kind: Observance.Kind, languageCode: String) -> String {
        let key: String
        let defaultValue: String
        switch kind {
        case .fastAndAbstinence:
            (key, defaultValue) = ("observance.kind.fast_and_abstinence", "Fast + Abstinence")
        case .abstinence:
            (key, defaultValue) = ("observance.kind.abstinence", "Abstinence")
        case .fridayPenance:
            (key, defaultValue) = ("observance.kind.friday_penance", "Friday Penance")
        case .holyDay:
            (key, defaultValue) = ("observance.kind.holy_day", "Holy Day")
        case .feastDay:
            (key, defaultValue) = ("observance.kind.feast_day", "Feast Day")
        case .memorialDay:
            (key, defaultValue) = ("observance.kind.memorial", "Memorial")
        case .optionalEmber:
            (key, defaultValue) = ("observance.kind.optional_ember", "Optional Ember Day")
        }
        return AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }

    static func dispositionLabel(_ observance: Observance, languageCode: String) -> String {
        switch observance.kind {
        case .feastDay, .memorialDay:
            return AppLocalizer.localized(
                "observance.disposition.celebrate", default: "Celebrate", languageCode: languageCode)
        case .fridayPenance:
            switch observance.obligation {
            case .mandatory:
                return AppLocalizer.localized(
                    "observance.disposition.penance_required", default: "Penance Required", languageCode: languageCode)
            case .optional:
                return AppLocalizer.localized(
                    "observance.disposition.penance_optional", default: "Penance Optional", languageCode: languageCode)
            case .notApplicable:
                return obligationLabel(.notApplicable, languageCode: languageCode)
            }
        default:
            return obligationLabel(observance.obligation, languageCode: languageCode)
        }
    }

    static func completionLabel(_ status: CompletionStatus, languageCode: String) -> String {
        let key: String
        let defaultValue: String
        switch status {
        case .notStarted:
            (key, defaultValue) = ("observance.completion.not_started", "Not Started")
        case .completed:
            (key, defaultValue) = ("observance.completion.completed", "Completed")
        case .substituted:
            (key, defaultValue) = ("observance.completion.substituted", "Substituted")
        case .dispensed:
            (key, defaultValue) = ("observance.completion.dispensed", "Dispensed")
        case .missed:
            (key, defaultValue) = ("observance.completion.missed", "Missed")
        }
        return AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }

    static func currentKindLabel(_ kind: Observance.Kind) -> String {
        kindLabel(kind, languageCode: AppLocalizer.currentLanguageCode())
    }

    static func currentDispositionLabel(_ observance: Observance) -> String {
        dispositionLabel(observance, languageCode: AppLocalizer.currentLanguageCode())
    }

    static func currentCompletionLabel(_ status: CompletionStatus) -> String {
        completionLabel(status, languageCode: AppLocalizer.currentLanguageCode())
    }

    private static func obligationLabel(_ obligation: Observance.Obligation, languageCode: String) -> String {
        switch obligation {
        case .mandatory:
            AppLocalizer.localized("observance.obligation.required", default: "Required", languageCode: languageCode)
        case .optional:
            AppLocalizer.localized("observance.obligation.optional", default: "Optional", languageCode: languageCode)
        case .notApplicable:
            AppLocalizer.localized("observance.obligation.not_required", default: "Not Required", languageCode: languageCode)
        }
    }
}
