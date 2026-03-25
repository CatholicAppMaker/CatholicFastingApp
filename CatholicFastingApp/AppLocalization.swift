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
}
