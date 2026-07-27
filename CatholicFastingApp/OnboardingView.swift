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
    @State private var legalRequirementReviewRequest = 0

    private static let legalAcknowledgmentAnchor = "onboarding.legal_acknowledgment.anchor"

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
            .appRootBackground()
            .safeAreaInset(edge: .top, spacing: 0) {
                if didConfirmLanguage, !acceptedLegalNotice {
                    onboardingLegalRequirementBar
                }
            }
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
                        .accessibilityHint(
                            localized(
                                acceptedLegalNotice
                                    ? "onboarding.trust.finish_enabled_hint"
                                    : "onboarding.trust.finish_disabled_hint",
                                default: acceptedLegalNotice
                                    ? "Completes setup and opens Today."
                                    : "Review and accept the independent-app notice below to finish setup."))
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

    private var onboardingLegalRequirementBar: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: 12) {
                onboardingLegalRequirementSummary
                Spacer(minLength: 12)
                onboardingLegalRequirementReviewButton
            }

            VStack(alignment: .leading, spacing: 10) {
                onboardingLegalRequirementSummary
                onboardingLegalRequirementReviewButton
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(CatholicTheme.parchment.opacity(0.96))
        .overlay(alignment: .bottom) {
            Divider()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("onboarding.legal_requirement")
    }

    private var onboardingLegalRequirementSummary: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.shield")
                .foregroundStyle(CatholicTheme.primary)
                .padding(.top, 2)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(localized(
                    "onboarding.trust.finish_requirement_title",
                    default: "Finish Setup needs one acknowledgment"))
                    .font(.subheadline.weight(.semibold))
                    .accessibilityIdentifier("onboarding.legal_requirement.title")
                Text(localized(
                    "onboarding.trust.finish_requirement_detail",
                    default: "Review and accept the independent-app notice below."))
                    .appSupportingTextStyle()
            }
        }
    }

    private var onboardingLegalRequirementReviewButton: some View {
        Button(localized("onboarding.trust.review", default: "Review notice")) {
            legalRequirementReviewRequest += 1
        }
        .appSecondaryButtonStyle()
        .accessibilityHint(
            localized(
                "onboarding.trust.review_hint",
                default: "Moves to the acknowledgment required to finish setup."))
        .accessibilityIdentifier("onboarding.legal_requirement.review")
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
        .listStyle(.plain)
        .listSectionSpacing(SacredEditorialTokens.sectionSpacing)
        .appListBackground()
    }

    private var mainOnboardingList: some View {
        ScrollViewReader { proxy in
            mainOnboardingListContent
                .onChange(of: legalRequirementReviewRequest) { _, _ in
                    proxy.scrollTo(Self.legalAcknowledgmentAnchor, anchor: .center)
                }
        }
    }

    private var mainOnboardingListContent: some View {
        List {
            Section {
                SacredEditorialSectionHeader(
                    eyebrow: localized("onboarding.basics.eyebrow", default: "A calm beginning"),
                    title: localized("onboarding.basics.intro_title", default: "Set the guidance that applies to you"),
                    detail: localized("onboarding.basics.intro_detail", default: "Your answers stay on this device and can be changed later."))
            }

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
                        default: "I am between 18 and 59 (fasting age)"),
                    isOn: $age18OrOlderForFasting)
                    .accessibilityIdentifier("onboarding.age18_toggle")
                Text(localized(
                    "onboarding.step1.age_helper",
                    default: "Confirm both age statements that apply. People 60 and older remain bound by abstinence, but not by the Church fasting-age rule."))
                    .appSupportingTextStyle()
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
                        default: "I understand that this is an independent devotional app, not an official app of the Catholic Church"),
                    isOn: $acceptedLegalNotice)
                    .id(Self.legalAcknowledgmentAnchor)
                    .accessibilityIdentifier("onboarding.accept_legal_notice")

                Text(localized(
                    "onboarding.trust.finish_hint",
                    default: "After accepting this notice, Finish Setup becomes available."))
                    .appSupportingTextStyle()
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(SacredEditorialTokens.sectionSpacing)
        .appListBackground()
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
