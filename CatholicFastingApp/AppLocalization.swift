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
