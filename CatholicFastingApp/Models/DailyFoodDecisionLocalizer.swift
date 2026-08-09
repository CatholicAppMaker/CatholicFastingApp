@preconcurrency import Foundation

enum DailyFoodDecisionLocalizer {
    static func localized(
        _ decision: DailyFoodDecision,
        languageMode: String,
        bundle: Bundle = .main) -> DailyFoodDecision
    {
        let localizationCode = localizationCode(for: languageMode)
        return localized(
            decision,
            value: { key, defaultValue in
                localizedValue(
                    key,
                    default: defaultValue,
                    localizationCode: localizationCode,
                    bundle: bundle)
            },
            format: { key, defaultFormat, argument in
                let format = localizedValue(
                    key,
                    default: defaultFormat,
                    localizationCode: localizationCode,
                    bundle: bundle)
                return String(format: format, locale: .current, argument)
            },
            observanceTitle: { title in
                localizedObservanceTitle(
                    title,
                    localizationCode: localizationCode,
                    bundle: bundle)
            })
    }

    static func localizedCurrent(
        _ decision: DailyFoodDecision,
        bundle: Bundle = .main,
        userDefaults: UserDefaults = .standard) -> DailyFoodDecision
    {
        localized(
            decision,
            value: { key, defaultValue in
                CoreLocalizer.localizedCurrent(
                    key,
                    default: defaultValue,
                    bundle: bundle,
                    userDefaults: userDefaults)
            },
            format: { key, defaultFormat, argument in
                CoreLocalizer.localizedCurrentFormat(
                    key,
                    default: defaultFormat,
                    argument,
                    bundle: bundle,
                    userDefaults: userDefaults)
            },
            observanceTitle: { title in
                localizedCurrentObservanceTitle(
                    title,
                    bundle: bundle,
                    userDefaults: userDefaults)
            })
    }

    static let textLocalizationKeys: [String: String] = [
        "Medical/pastoral dispensation is enabled in your profile.": "decision.dispensation.obligation",
        "Eat what is prudent and medically safe.": "decision.dispensation.allowed.safe",
        "Keep prayer/charity as substitute penance.": "decision.dispensation.allowed.prayer",
        "Avoid self-imposed rigor that harms health.": "decision.dispensation.avoid",
        "Today requires fasting and abstinence.": "decision.fast_and_abstinence.obligation",
        "One full meal with up to two smaller meals.": "decision.fast_and_abstinence.allowed.meals",
        "Fish, eggs, dairy, grains, fruits, and vegetables are generally permitted.": "decision.fast_and_abstinence.allowed.foods",
        "Meat from land animals (beef, pork, poultry).": "decision.fast_and_abstinence.avoid.meat",
        "Eating patterns that effectively become a second full meal.": "decision.fast_and_abstinence.avoid.second_meal",
        "Today requires abstinence from meat.": "decision.abstinence.obligation",
        "Normal meal quantity is generally permitted.": "decision.abstinence.allowed.quantity",
        "Today has a required observance but no mandatory food restriction.": "decision.required_no_food_restriction.obligation",
        "Normal meals are generally permitted.": "decision.required_no_food_restriction.allowed.meals",
        "Keep the day with prayer and Mass obligations.": "decision.required_no_food_restriction.allowed.prayer",
        "Today may include fasting/abstinence obligations (profile incomplete).": "decision.optional_unknown.obligation",
        "Today includes fasting/abstinence observance in your profile, but not mandatory.": "decision.optional_known.obligation",
        "Follow age/health and pastoral guidance for your situation.": "decision.optional.allowed.guidance",
        "If unsure, observe abstinence and a simpler meal pattern.": "decision.optional.allowed.unsure",
        "Do not assume no obligation without confirming your profile.": "decision.optional.avoid",
        "No mandatory food restriction today.": "decision.none.obligation",
        "You may choose a voluntary penance.": "decision.none.allowed.penance",
        "Today calls for Friday penance through abstinence from meat.": "decision.friday_abstinence.obligation",
        "Today calls for Friday penance, not mandatory fasting.": "decision.friday_penance.obligation",
        "Choose a penitential act, especially a work of charity or piety.": "decision.friday_penance.allowed.act",
        "Do not skip Friday penance entirely.": "decision.friday_penance.avoid",
        "Today requires Friday penance through abstinence from meat.": "decision.friday_abstinence.required_obligation",
        "Today requires Friday penance, but not mandatory fasting.": "decision.friday_penance.required_obligation",
        "Choose a penitential act (for example prayer, almsgiving, or another sacrifice).": "decision.friday_penance.required_act",
    ]

    static let sourceLocalizationKeys: [String: String] = [
        "Source: USCCB and pastoral guidance.": "decision.sources.us.general",
        "Source: USCCB Fast & Abstinence norms.": "decision.sources.us.fasting",
        "Source: USCCB Friday penance norms.": "decision.sources.us.friday",
        "Source: USCCB liturgical norms.": "decision.sources.us.holyday",
        "Source: CCCB Friday guidance and universal law.": "decision.sources.ca.general",
        "Source: universal fast/abstinence law with Canada Friday guidance.": "decision.sources.ca.fasting",
        "Source: CCCB Friday guidance.": "decision.sources.ca.friday",
        "Source: universal law and the Canada national baseline.": "decision.sources.ca.holyday",
        "Source: universal law and local pastoral guidance.": "decision.sources.other.general",
        "Source: universal fast/abstinence law.": "decision.sources.other.fasting",
        "Source: local Friday penance guidance.": "decision.sources.other.friday",
        "Source: local liturgical guidance.": "decision.sources.other.holyday",
    ]

    private static func localized(
        _ decision: DailyFoodDecision,
        value: (_ key: String, _ defaultValue: String) -> String,
        format: (_ key: String, _ defaultFormat: String, _ argument: String) -> String,
        observanceTitle: (_ title: String) -> String) -> DailyFoodDecision
    {
        DailyFoodDecision(
            category: decision.category,
            obligationLine: localizedText(decision.obligationLine, value: value),
            allowed: decision.allowed.map { localizedText($0, value: value) },
            avoid: decision.avoid.map { localizedText($0, value: value) },
            rationale: localizedRationale(
                decision.rationale,
                value: value,
                format: format,
                observanceTitle: observanceTitle),
            sourceLine: localizedSource(decision.sourceLine, value: value))
    }

    private static func localizedText(
        _ text: String,
        value: (_ key: String, _ defaultValue: String) -> String) -> String
    {
        guard let key = textLocalizationKeys[text] else { return text }
        return value(key, text)
    }

    private static func localizedRationale(
        _ rationale: String,
        value: (_ key: String, _ defaultValue: String) -> String,
        format: (_ key: String, _ defaultFormat: String, _ argument: String) -> String,
        observanceTitle: (_ title: String) -> String) -> String
    {
        if rationale == "Health and pastoral obedience take priority when obligations do not bind." {
            return value("decision.dispensation.rationale", rationale)
        }
        if rationale == "No mandatory fast/abstinence observance appears for today in your current profile." {
            return value("decision.none.rationale", rationale)
        }
        if rationale == "No specific mandatory observance was detected." {
            return value("decision.observance.none", rationale)
        }

        let unknownPrefix = "Review the age eligibility toggles in Settings so the app can determine whether "
        let knownPrefix = "Based on your current profile, "
        let unknownSuffix = " binds you."
        let knownSuffix = " does not strictly bind today."

        if rationale.hasPrefix(unknownPrefix), rationale.hasSuffix(unknownSuffix) {
            let titles = String(rationale.dropFirst(unknownPrefix.count).dropLast(unknownSuffix.count))
            return format(
                "decision.optional_unknown.rationale_format",
                "Review the age eligibility toggles in Settings so the app can determine whether %@ binds you.",
                localizedObservanceTitles(in: titles, observanceTitle: observanceTitle))
        }

        if rationale.hasPrefix(knownPrefix), rationale.hasSuffix(knownSuffix) {
            let titles = String(rationale.dropFirst(knownPrefix.count).dropLast(knownSuffix.count))
            return format(
                "decision.optional_known.rationale_format",
                "Based on your current profile, %@ does not strictly bind today.",
                localizedObservanceTitles(in: titles, observanceTitle: observanceTitle))
        }

        let singlePrefix = "This is based on "
        let singleSuffix = "."
        if rationale.hasPrefix(singlePrefix), rationale.hasSuffix(singleSuffix) {
            let titles = String(rationale.dropFirst(singlePrefix.count).dropLast(singleSuffix.count))
            let key = titles.contains(", ") ? "decision.observance.multi_format" : "decision.observance.single_format"
            return format(
                key,
                "This is based on %@.",
                localizedObservanceTitles(in: titles, observanceTitle: observanceTitle))
        }

        return rationale
    }

    private static func localizedObservanceTitles(
        in text: String,
        observanceTitle: (_ title: String) -> String) -> String
    {
        ObservanceLocalizationCatalog.titleDefaultsByIdentifier.values
            .sorted { $0.count > $1.count }
            .reduce(text) { result, defaultTitle in
                result.replacingOccurrences(
                    of: defaultTitle,
                    with: observanceTitle(defaultTitle))
            }
    }

    private static func localizedSource(
        _ sourceLine: String,
        value: (_ key: String, _ defaultValue: String) -> String) -> String
    {
        guard let key = sourceLocalizationKeys[sourceLine] else { return sourceLine }
        return value(key, sourceLine)
    }

    private static func localizationCode(for languageMode: String) -> String {
        switch languageMode {
        case "spanish":
            "es"
        case "frenchCanadian":
            "fr-CA"
        default:
            "en"
        }
    }

    private static func localizedValue(
        _ key: String,
        default defaultValue: String,
        localizationCode: String,
        bundle: Bundle) -> String
    {
        guard
            let path = bundle.path(forResource: localizationCode, ofType: "lproj"),
            let languageBundle = Bundle(path: path)
        else {
            return NSLocalizedString(
                key,
                tableName: "Localizable",
                bundle: bundle,
                value: defaultValue,
                comment: "")
        }

        return NSLocalizedString(
            key,
            tableName: "Localizable",
            bundle: languageBundle,
            value: defaultValue,
            comment: "")
    }

    private static func localizedObservanceTitle(
        _ title: String,
        localizationCode: String,
        bundle: Bundle) -> String
    {
        guard let identifier = ObservanceLocalizationCatalog.titleIdentifier(for: title) else { return title }
        return localizedValue(
            "observance.title.\(identifier)",
            default: title,
            localizationCode: localizationCode,
            bundle: bundle)
    }

    private static func localizedCurrentObservanceTitle(
        _ title: String,
        bundle: Bundle,
        userDefaults: UserDefaults) -> String
    {
        guard let identifier = ObservanceLocalizationCatalog.titleIdentifier(for: title) else { return title }
        return CoreLocalizer.localizedCurrent(
            "observance.title.\(identifier)",
            default: title,
            bundle: bundle,
            userDefaults: userDefaults)
    }
}
