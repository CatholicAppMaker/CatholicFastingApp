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
    let onComplete: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        SacredHeroCard(
                            assetName: "HeroSacred",
                            title: localized("onboarding.hero.title", default: "Catholic Fasting"),
                            subtitle: localized("onboarding.hero.subtitle", default: "Set language, region, and reminders once so the app can stay calm and clear each day."),
                            height: 162,
                            cornerRadius: 18,
                            accessibilityIdentifier: "onboarding.hero")

                        CatholicFastingQuoteCard(quote: onboardingQuote, compact: true)
                            .accessibilityIdentifier("onboarding.quote")
                    }
                }

                Section(localized("onboarding.step1.title", default: "Step 1 of 4: Eligibility Profile")) {
                    Text(
                        localized(
                            "onboarding.step1.intro",
                            default: "Use simple eligibility toggles to keep guidance accurate without sharing your birthday."))
                        .appLeadTextStyle()

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
                }

                Section(localized("onboarding.step2.title", default: "Step 2 of 4: Language and Region")) {
                    Picker(localized("onboarding.step2.language", default: "Language"), selection: $languageModeRaw) {
                        ForEach(LanguageMode.allCases) { option in
                            Text(option.label).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("onboarding.language")

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

                    Picker(
                        localized(
                            "onboarding.step2.friday_mode",
                            default: "Friday practice outside Lent"),
                        selection: $fridayModeRaw)
                    {
                        ForEach(RuleSettings.FridayOutsideLentMode.allCases) { option in
                            Text(localizedFridayModeLabel(option)).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("onboarding.friday_mode")
                    Text(
                        localized(
                            "onboarding.step2.helper",
                            default: "You can change all of this later in Profile & Norms."))
                        .appSupportingTextStyle()
                }

                Section(localized("onboarding.step3.title", default: "Step 3 of 4: Reminder Strategy")) {
                    Picker(localized("onboarding.step3.reminder_style", default: "Reminder style"), selection: $reminderTierRaw) {
                        ForEach(ReminderTier.allCases) { tier in
                            Text("\(localizedReminderTierLabel(tier)) - \(localizedReminderTierSummary(tier))").tag(tier.rawValue)
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

                    Text(
                        localized(
                            "onboarding.step3.helper",
                            default: "Reminders can be changed any time in Setup & Reminders."))
                        .appSupportingTextStyle()

                    Toggle(
                        localized(
                            "onboarding.step3.quote_toggle",
                            default: "Add one daily devotional quote reminder"),
                        isOn: $dailyQuoteReminderEnabled)
                        .accessibilityIdentifier("onboarding.reminder_quote_toggle")

                    if dailyQuoteReminderEnabled {
                        DatePicker(
                            localized("onboarding.step3.quote_time", default: "Quote reminder time"),
                            selection: dailyQuoteReminderTimeBinding,
                            displayedComponents: .hourAndMinute)
                            .accessibilityIdentifier("onboarding.reminder_quote_time")

                        Text(
                            localized(
                                "onboarding.step3.quote_helper",
                                default: "Use one daily fasting quote from saints, popes, and Catholic teachers."))
                            .appSupportingTextStyle()
                    }
                }

                Section(localized("onboarding.step4.title", default: "Step 4 of 4: Premium Preview")) {
                    Text(
                        localized(
                            "onboarding.step4.intro",
                            default: "Free core gives required fasting guidance. Premium adds a focused Formation Toolkit."))
                        .appLeadTextStyle()

                    ForEach(SubscriptionOfferCatalog.catholicFasting.pillars) { pillar in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(pillar.title)
                                .font(.headline)
                            Text(pillar.subtitle)
                                .appSupportingTextStyle()
                            ForEach(pillar.outcomes, id: \.self) { outcome in
                                Text("• \(outcome)")
                                    .appSupportingTextStyle()
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section(localized("onboarding.trust.title", default: "Why This Is Trustworthy")) {
                    Text(
                        localized(
                            "onboarding.trust.independent",
                            default: "This is an independent Catholic devotional app with cited guidance references."))
                        .appLeadTextStyle()
                    Text(
                        localized(
                            "onboarding.trust.sources",
                            default: "Sources: USCCB liturgical calendar and fast/abstinence guidance, with in-app citation links."))
                        .appSupportingTextStyle()
                    Text(
                        localized(
                            "onboarding.trust.unofficial",
                            default: "This is an independent devotional app and not an official app of the Catholic Church, USCCB, Vatican, or any diocese/parish."))
                        .appSupportingTextStyle()
                    Text(
                        localized(
                            "onboarding.trust.follow_guidance",
                            default: "Always follow your pastor, local Church norms, and medical guidance."))
                        .appSupportingTextStyle()
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
                    Button(localized("onboarding.finish", default: "Finish Setup")) {
                        onComplete()
                    }
                    .appPrimaryButtonStyle()
                    .accessibilityIdentifier("onboarding.continue")
                }
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

    private func localizedFridayModeLabel(_ option: RuleSettings.FridayOutsideLentMode) -> String {
        switch option {
        case .abstainFromMeat:
            localized("onboarding.friday.abstain", default: option.label)
        case .substitutePenance:
            localized("onboarding.friday.substitute", default: option.label)
        }
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

    private func localizedReminderTierSummary(_ tier: ReminderTier) -> String {
        switch tier {
        case .minimal:
            localized("onboarding.reminder.minimal.summary", default: tier.summary)
        case .balanced:
            localized("onboarding.reminder.balanced.summary", default: tier.summary)
        case .guided:
            localized("onboarding.reminder.guided.summary", default: tier.summary)
        }
    }

    private var onboardingQuote: CatholicFastingQuote {
        let language = LanguageMode(rawValue: languageModeRaw) ?? DefaultValues.language
        let season = LiturgicalSeasonThemeEngine.season(for: Date())
        return CatholicFastingQuoteSelector.seasonalQuote(
            locale: language.contentLocale,
            season: season,
            date: Date())
    }

    private var dailyQuoteReminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.gregorian.date(
                    from: DateComponents(
                        hour: dailyQuoteReminderHour,
                        minute: dailyQuoteReminderMinute))
                    ?? Calendar.gregorian.date(from: DateComponents(hour: 12, minute: 0))
                    ?? Date()
            },
            set: { newValue in
                let components = Calendar.gregorian.dateComponents([.hour, .minute], from: newValue)
                dailyQuoteReminderHour = components.hour ?? DefaultValues.dailyQuoteReminderHour
                dailyQuoteReminderMinute = components.minute ?? DefaultValues.dailyQuoteReminderMinute
            })
    }
}
