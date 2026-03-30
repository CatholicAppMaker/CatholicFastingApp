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

enum ObservanceTitleLocalizer {
    static func localizedCurrent(_ title: String, userDefaults: UserDefaults = .standard) -> String {
        switch title {
        case "Ash Wednesday":
            AppLocalizer.localizedCurrent("observance.title.ash_wednesday", default: title, userDefaults: userDefaults)
        case "Good Friday":
            AppLocalizer.localizedCurrent("observance.title.good_friday", default: title, userDefaults: userDefaults)
        case "Friday of Lent":
            AppLocalizer.localizedCurrent("observance.title.friday_of_lent", default: title, userDefaults: userDefaults)
        case "Friday Penance (Outside Lent)":
            AppLocalizer.localizedCurrent("observance.title.friday_penance_outside_lent", default: title, userDefaults: userDefaults)
        case "Ember Day":
            AppLocalizer.localizedCurrent("observance.title.ember_day", default: title, userDefaults: userDefaults)
        case "Palm Sunday", "Palm Sunday of the Passion of the Lord":
            AppLocalizer.localizedCurrent("observance.title.palm_sunday", default: title, userDefaults: userDefaults)
        case "Holy Thursday (Evening Mass of the Lord's Supper)":
            AppLocalizer.localizedCurrent("observance.title.holy_thursday", default: title, userDefaults: userDefaults)
        case "Mary, Mother of God":
            AppLocalizer.localizedCurrent("observance.title.mary_mother_of_god", default: title, userDefaults: userDefaults)
        case "Ascension":
            AppLocalizer.localizedCurrent("observance.title.ascension", default: title, userDefaults: userDefaults)
        case "Assumption of the Blessed Virgin Mary":
            AppLocalizer.localizedCurrent("observance.title.assumption", default: title, userDefaults: userDefaults)
        case "All Saints":
            AppLocalizer.localizedCurrent("observance.title.all_saints", default: title, userDefaults: userDefaults)
        case "Immaculate Conception":
            AppLocalizer.localizedCurrent("observance.title.immaculate_conception", default: title, userDefaults: userDefaults)
        case "Immaculate Conception (Transferred)":
            AppLocalizer.localizedCurrent("observance.title.immaculate_conception_transferred", default: title, userDefaults: userDefaults)
        case "Christmas":
            AppLocalizer.localizedCurrent("observance.title.christmas", default: title, userDefaults: userDefaults)
        default:
            title
        }
    }
}
