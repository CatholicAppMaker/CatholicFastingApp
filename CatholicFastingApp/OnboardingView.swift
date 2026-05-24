import SwiftUI

struct OnboardingView: View {
    @Binding var age14OrOlderForAbstinence: Bool
    @Binding var age18OrOlderForFasting: Bool
    @Binding var medicalDispensation: Bool
    @Binding var languageModeRaw: String
    @Binding var regionProfileRaw: String
    @Binding var fridayModeRaw: String
    @Binding var reminderTierRaw: String
    @Binding var dailyReminderSupportEnabled: Bool
    @Binding var morningReminderEnabled: Bool
    @Binding var eveningReminderEnabled: Bool
    @Binding var dailyQuoteReminderEnabled: Bool
    @Binding var dailyQuoteReminderHour: Int
    @Binding var dailyQuoteReminderMinute: Int
    @Binding var intermittentIntentionRaw: String
    @Binding var acceptedLegalNotice: Bool
    let onComplete: () -> Void
    @State private var didConfirmLanguage = false

    var body: some View {
        NavigationStack {
            Group {
                if didConfirmLanguage {
                    mainOnboardingList
                } else {
                    languageOnboardingList
                }
            }
            .navigationTitle(localized("onboarding.title", default: "Welcome"))
            .onAppear {
                let tier = ReminderTier(rawValue: reminderTierRaw) ?? .balanced
                dailyReminderSupportEnabled = tier.supportEnabled
                morningReminderEnabled = tier.morningEnabled
                eveningReminderEnabled = tier.eveningEnabled
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if didConfirmLanguage {
                        Button(localized("onboarding.finish", default: "Finish Setup")) {
                            onComplete()
                        }
                        .appPrimaryButtonStyle()
                        .disabled(!acceptedLegalNotice)
                        .accessibilityIdentifier("onboarding.continue")
                    } else {
                        Button(localized("onboarding.language_continue", default: "Continue")) {
                            didConfirmLanguage = true
                        }
                        .appPrimaryButtonStyle()
                        .accessibilityIdentifier("onboarding.language_continue")
                    }
                }
            }
        }
    }

    private var languageOnboardingList: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    SacredHeroCard(
                        assetName: "HeroSacred",
                        title: "",
                        subtitle: "",
                        height: 132,
                        cornerRadius: 14,
                        accessibilityIdentifier: "onboarding.hero")

                    Text(localized("onboarding.language_intro.title", default: "Choose your language"))
                        .appDisplayTitleStyle(serif: true)
                    Text(localized("onboarding.language_intro.detail", default: "English is selected by default. You can change this now or later in Profile & Norms."))
                        .appLeadTextStyle()
                }
            }

            Section {
                Picker(localized("onboarding.step2.language", default: "Language"), selection: $languageModeRaw) {
                    ForEach(LanguageMode.allCases) { option in
                        Text(option.label).tag(option.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("onboarding.language")
            }
        }
    }

    private var mainOnboardingList: some View {
        List {
            Section(localized("onboarding.basics.title", default: "Your Basics")) {
                Toggle(
                    localized(
                        "onboarding.step1.age14",
                        default: "I am 14 or older (abstinence age)"),
                    isOn: $age14OrOlderForAbstinence)
                    .accessibilityIdentifier("onboarding.age14_toggle")
                Toggle(
                    localized(
                        "onboarding.step1.age18",
                        default: "I am 18 or older (fasting age)"),
                    isOn: $age18OrOlderForFasting)
                    .accessibilityIdentifier("onboarding.age18_toggle")
                Toggle(
                    localized(
                        "onboarding.step1.dispensation",
                        default: "Health/pastoral dispensation (if needed)"),
                    isOn: $medicalDispensation)
                    .accessibilityIdentifier("onboarding.dispensation")

                Picker(
                    localized("onboarding.step2.region", default: "Region"),
                    selection: $regionProfileRaw)
                {
                    ForEach(RuleSettings.RegionProfile.allCases) { option in
                        Text(localizedRegionLabel(option)).tag(option.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("onboarding.region")
            }

            Section(localized("onboarding.rhythm.title", default: "Daily Rhythm")) {
                Picker(localized("onboarding.rhythm.reminder_tier", default: "Reminder style"), selection: $reminderTierRaw) {
                    ForEach(ReminderTier.allCases) { tier in
                        Text(localizedReminderTierLabel(tier)).tag(tier.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("onboarding.reminder_tier")
                .onChange(of: reminderTierRaw) { _, newValue in
                    let tier = ReminderTier(rawValue: newValue) ?? .balanced
                    dailyReminderSupportEnabled = tier.supportEnabled
                    morningReminderEnabled = tier.morningEnabled
                    eveningReminderEnabled = tier.eveningEnabled
                }

                Picker(localized("onboarding.rhythm.intention", default: "First fasting intention"), selection: $intermittentIntentionRaw) {
                    ForEach(onboardingIntentionOptions) { option in
                        Text(option.label).tag(option.id)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("onboarding.intention")

                Toggle(
                    localized("onboarding.rhythm.quote_toggle", default: "Daily fasting reflection reminder"),
                    isOn: $dailyQuoteReminderEnabled)
                    .accessibilityIdentifier("onboarding.quote_reminder")

                Text(localized("onboarding.rhythm.helper", default: "Start simple. The app will land on Today with your rule, tracker, and next action visible."))
                    .appSupportingTextStyle()
            }

            Section(localized("onboarding.trust.title", default: "Trust and Finish")) {
                Toggle(
                    localized(
                        "onboarding.trust.acknowledgement",
                        default: "I understand this is an independent app, not an official Church authority app"),
                    isOn: $acceptedLegalNotice)
                    .accessibilityIdentifier("onboarding.accept_legal_notice")
            }
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageModeRaw)
    }

    private func localizedRegionLabel(_ option: RuleSettings.RegionProfile) -> String {
        switch option {
        case .us:
            localized("onboarding.region.us", default: option.label)
        case .canada:
            localized("onboarding.region.canada", default: option.label)
        case .other:
            localized("onboarding.region.other", default: option.label)
        }
    }

    private var onboardingIntentionOptions: [FastingIntentionOption] {
        [
            FastingIntentionOption(
                id: "personal_discipline",
                label: localized("intermittent.intention.discipline.label", default: "Personal discipline"),
                detail: localized("intermittent.intention.discipline.detail", default: "Keep this fast focused on steady discipline, not pressure.")),
            FastingIntentionOption(
                id: "prayer",
                label: localized("intermittent.intention.prayer.label", default: "Prayer"),
                detail: localized("intermittent.intention.prayer.detail", default: "Offer this fast with a concrete prayer intention.")),
            FastingIntentionOption(
                id: "mercy",
                label: localized("intermittent.intention.mercy.label", default: "Mercy"),
                detail: localized("intermittent.intention.mercy.detail", default: "Pair the fast with a work of charity or mercy.")),
            FastingIntentionOption(
                id: "penance",
                label: localized("intermittent.intention.penance.label", default: "Penance"),
                detail: localized("intermittent.intention.penance.detail", default: "Use this as a voluntary penance when health and duty allow.")),
        ]
    }

    private func localizedReminderTierLabel(_ tier: ReminderTier) -> String {
        switch tier {
        case .minimal:
            localized("onboarding.reminder.minimal.label", default: tier.label)
        case .balanced:
            localized("onboarding.reminder.balanced.label", default: tier.label)
        case .guided:
            localized("onboarding.reminder.guided.label", default: tier.label)
        }
    }
}
