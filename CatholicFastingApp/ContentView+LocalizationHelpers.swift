import Foundation

extension ContentView {
    func localizedObservanceTitle(_ title: String) -> String {
        ObservanceContentLocalizer.localizedTitle(title, languageCode: languageModeRaw)
    }

    func localizedObservanceDetail(_ observance: Observance) -> String? {
        ObservanceContentLocalizer.localizedDetail(observance.detail, languageCode: languageModeRaw)
    }

    func localizedObservanceRationale(_ observance: Observance) -> String {
        ObservanceContentLocalizer.localizedRationale(observance, languageCode: languageModeRaw)
    }

    func localizedObservanceKindLabel(_ kind: Observance.Kind) -> String {
        ObservancePresentationLocalizer.kindLabel(kind, languageCode: languageModeRaw)
    }

    func localizedObservanceDispositionLabel(_ observance: Observance) -> String {
        ObservancePresentationLocalizer.dispositionLabel(observance, languageCode: languageModeRaw)
    }

    func localizedCompletionStatusLabel(_ status: CompletionStatus) -> String {
        ObservancePresentationLocalizer.completionLabel(status, languageCode: languageModeRaw)
    }

    var liturgicalCalendar: Calendar {
        .gregorian
    }

    var contentLocale: Locale {
        AppLocalizer.currentLocale()
    }

    func localizedAbbreviatedDate(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(date: .abbreviated, time: .omitted)
                .locale(contentLocale))
    }

    func localizedCompleteDate(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(date: .complete, time: .omitted)
                .locale(contentLocale))
    }

    func localizedAbbreviatedDateTime(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(date: .abbreviated, time: .shortened)
                .locale(contentLocale))
    }

    func localizedMonthYear(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle()
                .month(.wide)
                .year()
                .locale(contentLocale))
    }

    var regionProfile: RuleSettings.RegionProfile {
        RuleSettings.RegionProfile(rawValue: regionProfileRaw) ?? .us
    }
}
