import SwiftUI

struct GuidanceDevotionalGallerySection: View {
    let languageCode: String

    var body: some View {
        Section(localized("guidance.symbol_gallery.title", default: "Catholic Symbol Gallery")) {
            Text(
                localized(
                    "guidance.symbol_gallery.intro",
                    default: "A visual prayer companion for fasting, abstinence, and penitential Fridays."))
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SacredImageryCatalog.fastingGallery) { item in
                        SacredImageryCard(item: item, width: 184, height: 238)
                    }
                }
                .padding(.vertical, 2)
            }
            .accessibilityIdentifier("guidance.sacred_gallery")
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

struct DevotionalPackSection: View {
    let entries: [DevotionalEntry]
    @Binding var favoriteIDs: Set<String>
    let languageCode: String

    var body: some View {
        Section(localized("guidance.devotional_pack.title", default: "Offline Devotional Pack")) {
            Text(
                localized(
                    "guidance.devotional_pack.intro",
                    default: "These prayers are bundled in-app and available fully offline."))
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(entries) { entry in
                DevotionalPackEntryRow(
                    entry: entry,
                    isFavorite: favoriteIDs.contains(entry.id),
                    saveLabel: localized("guidance.devotional_pack.save", default: "Save"),
                    savedLabel: localized("guidance.devotional_pack.saved", default: "Saved"),
                    onToggleFavorite: { toggleFavorite(entry.id) })
            }
        }
    }

    private func toggleFavorite(_ entryID: String) {
        if favoriteIDs.contains(entryID) {
            favoriteIDs.remove(entryID)
        } else {
            favoriteIDs.insert(entryID)
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

private struct DevotionalPackEntryRow: View {
    let entry: DevotionalEntry
    let isFavorite: Bool
    let saveLabel: String
    let savedLabel: String
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(isFavorite ? savedLabel : saveLabel, action: onToggleFavorite)
                    .appSecondaryButtonStyle()
            }
            Text(entry.prayer)
                .font(.body)
            Text(entry.context)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct GuidanceSeasonContextSection: View {
    let seasonLabel: String
    let languageCode: String

    var body: some View {
        Section(localized("guidance.seasonal.title", default: "Seasonal Intention")) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "leaf")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CatholicTheme.accentForeground)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 4) {
                    Text(
                        localizedFormat(
                            "guidance.seasonal.current_format",
                            default: "Current season: %@",
                            seasonLabel))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CatholicTheme.primary)
                    Text(
                        localized(
                            "guidance.seasonal.intro",
                            default: "Let your food discipline match the Church’s prayer in this season."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }

    private func localizedFormat(_ key: String, default defaultValue: String, _ arguments: CVarArg...) -> String {
        String(
            format: localized(key, default: defaultValue),
            locale: Locale.current,
            arguments: arguments)
    }
}

struct FastDayQuickRulesSection: View {
    let regionalNormSummary: String
    let languageCode: String

    var body: some View {
        Section(localized("guidance.quick_rules.title", default: "Fast Day Quick Rules")) {
            Text(regionalNormSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
            Label(
                localized(
                    "guidance.quick_rules.abstinence",
                    default: "Abstinence means no meat from land animals (beef, pork, chicken, turkey)."),
                systemImage: "xmark.circle")
            Label(
                localized("guidance.quick_rules.fish", default: "Fish and shellfish are generally permitted."),
                systemImage: "checkmark.circle")
            Label(
                localized(
                    "guidance.quick_rules.fasting",
                    default: "Fasting usually means one full meal plus up to two small meals."),
                systemImage: "fork.knife")
            Label(
                localized(
                    "guidance.quick_rules.health",
                    default: "If health or duty makes fasting unsafe, speak with your pastor."),
                systemImage: "cross.case")
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

struct OfficialGuidelinesSection: View {
    let regionProfile: RuleSettings.RegionProfile
    let languageCode: String

    var body: some View {
        Section(localized("guidance.usccb.title", default: "USCCB Fast & Abstinence (Official)")) {
            Text(
                localized(
                    "guidance.usccb.disclaimer",
                    default: "This app references USCCB materials but is not affiliated with or published by the USCCB."))
                .foregroundStyle(.secondary)
            if regionProfile == .canada {
                Text(
                    localized(
                        "guidance.usccb.canada_note",
                        default: "Canada profile selected: the app models the Canada national baseline and CCCB Friday guidance. Diocesan proper calendars are not included yet."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(
                localized(
                    "guidance.usccb.summary",
                    default:
                    "USCCB states that Ash Wednesday and Good Friday are obligatory days of fasting and abstinence for Latin Catholics."))
            Label(
                localized(
                    "guidance.usccb.fast_rule",
                    default: "Fasting applies from age 18 until age 59."),
                systemImage: "calendar.badge.clock")
            Label(
                localized(
                    "guidance.usccb.abstinence_rule",
                    default: "Abstinence from meat applies from age 14 onward."),
                systemImage: "fork.knife.circle")
            Label(
                localized(
                    "guidance.usccb.friday_rule",
                    default: "Fridays in Lent are days of abstinence."),
                systemImage: "calendar")
            Label(
                localized(
                    "guidance.usccb.outside_lent_rule",
                    default:
                    "Fridays outside Lent remain penitential days in the U.S.; choose abstinence or another penitential act."),
                systemImage: "calendar.badge.minus")
            Text(
                localized(
                    "guidance.usccb.dispensation_note",
                    default: "Pastors and local bishops may give legitimate dispensations and local norms."))
                .foregroundStyle(.secondary)
            Link(
                localized(
                    "guidance.usccb.link_label", default: "Read Full USCCB Fast & Abstinence Guidelines"),
                destination: UIConstants.usccbFastAbstinenceURL)
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

struct PastoralGuidanceSection: View {
    let languageCode: String

    var body: some View {
        Section(localized("guidance.pastoral_guidance", default: "Pastoral Guidance")) {
            Text(
                localized(
                    "guidance.pastoral_line_1",
                    default:
                    "If you are pregnant, nursing, elderly, ill, under intense labor, or managing chronic conditions, seek pastoral and medical guidance before fasting."))
            Text(
                localized(
                    "guidance.pastoral_line_2",
                    default:
                    "Dispensations and substitutions are legitimate in many cases. This app is an aid, not your pastor."))
            Text(
                localized(
                    "guidance.pastoral_line_3",
                    default: "When in doubt, choose obedience, charity, and prudence over private rigor."))
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

struct GuidanceFAQSection: View {
    let languageCode: String

    var body: some View {
        Section(localized("guidance.faq.title", default: "FAQ (With Sources)")) {
            Text(
                localized(
                    "guidance.faq.q1",
                    default:
                    "Q: What are mandatory fast days in the Latin Church? A: Ash Wednesday and Good Friday."))
            Text(
                localized(
                    "guidance.faq.q2",
                    default:
                    "Q: What does abstinence mean? A: No meat from land animals; fish is generally permitted."))
            Text(
                localized(
                    "guidance.faq.q3",
                    default:
                    "Q: Do local bishops change rules? A: Yes, local norms and dispensations may apply."))
            Text(
                localized(
                    "guidance.faq.sources", default: "Sources: USCCB pastoral statements and universal norms."))
                .foregroundStyle(.secondary)
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

struct GuidanceSourcesSection: View {
    let languageCode: String

    var body: some View {
        Section(localized("guidance.sources.title", default: "Sources")) {
            Link(
                localized("guidance.sources.calendar_link", default: "USCCB Liturgical Calendar Guidance"),
                destination: UIConstants.legalPolicyURL)
            Link(
                localized(
                    "guidance.usccb.link_label", default: "Read Full USCCB Fast & Abstinence Guidelines"),
                destination: UIConstants.usccbFastAbstinenceURL)
            Link(
                localized("guidance.sources.feedback_link", default: "Send Feedback"),
                destination: UIConstants.supportEmail)
            Text(
                localized(
                    "guidance.sources.local_decrees_note",
                    default: "Always confirm local decrees for your location and year."))
                .foregroundStyle(.secondary)
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

struct FoodGuidanceSection: View, Equatable {
    let scenario: GuidanceScenario
    let settings: RuleSettings
    let languageCode: String
    @Binding var selectedScenario: GuidanceScenario

    private var snapshot: FoodGuidanceSnapshot {
        FoodGuidanceEngine.snapshot(for: scenario, settings: settings)
    }

    static func == (lhs: FoodGuidanceSection, rhs: FoodGuidanceSection) -> Bool {
        lhs.scenario == rhs.scenario
            && lhs.settings == rhs.settings
            && lhs.languageCode == rhs.languageCode
    }

    var body: some View {
        let snapshot = snapshot

        Section(localized("guidance.food_guidelines", default: "Food Guidance")) {
            Picker(localized("guidance.scenario", default: "Scenario"), selection: $selectedScenario) {
                ForEach(GuidanceScenario.allCases) { scenario in
                    Text(scenario.label).tag(scenario)
                }
            }
            .accessibilityIdentifier("guidance.scenario")

            FoodGuidanceSummaryView(
                summary: snapshot.summaryLine,
                commonQuestions: localized(
                    "guidance.food.common_questions",
                    default: "Use this for common food questions: meat, dairy, eggs, fish, broth, and gravies."))

            FoodGuidanceGroupView(group: snapshot.whatCountsAsMeat, icon: "xmark.circle", tint: .red)
            FoodGuidanceGroupView(group: snapshot.generallyPermitted, icon: "checkmark.circle", tint: .green)
            FoodGuidanceGroupView(
                group: snapshot.mealPattern,
                icon: "fork.knife",
                tint: CatholicTheme.accentForeground)
            FoodGuidanceGroupView(
                group: snapshot.extraGuidance,
                icon: "questionmark.circle",
                tint: CatholicTheme.warningForeground)

            FoodGuidanceLineGroupView(
                title: localized("guidance.food.stricter_title", default: "Stricter traditional practice"),
                lines: snapshot.stricterTraditionalPractice,
                icon: "flame",
                accessibilityIdentifier: "guidance.food.stricter")

            FoodGuidanceLineGroupView(
                title: localized("guidance.food.if_unsure_title", default: "If unsure"),
                lines: snapshot.ifUnsure,
                icon: "arrow.forward.circle",
                footer: snapshot.caveatLine,
                accessibilityIdentifier: "guidance.food.if_unsure")

            Text(snapshot.sourceLine)
                .font(.caption)
                .foregroundStyle(.secondary)

            Link(
                settings.regionProfile == .canada
                    ? localized("guidance.food.cccb_link", default: "Read CCCB Friday guidance")
                    : localized(
                        "guidance.usccb.link_label",
                        default: "Read Full USCCB Fast & Abstinence Guidelines"),
                destination: settings.regionProfile == .canada
                    ? UIConstants.cccbKeepingFridayURL
                    : UIConstants.usccbFastAbstinenceURL)
                .accessibilityIdentifier("guidance.food.source_link")
        }
        .accessibilityIdentifier("guidance.food.section")
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

private struct FoodGuidanceSummaryView: View {
    let summary: String
    let commonQuestions: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(commonQuestions)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityIdentifier("guidance.food.summary")
    }
}

private struct FoodGuidanceLineGroupView: View {
    let title: String
    let lines: [String]
    let icon: String
    var footer: String?
    let accessibilityIdentifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(CatholicTheme.primary)
            ForEach(lines, id: \.self) { line in
                Label(line, systemImage: icon)
                    .font(.subheadline)
            }
            if let footer {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

private struct FoodGuidanceGroupView: View {
    let group: FoodGuidanceGroup
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.title)
                .font(.headline)
                .foregroundStyle(CatholicTheme.primary)
            Text(group.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(group.items, id: \.self) { item in
                VStack(alignment: .leading, spacing: 3) {
                    Label(item.title, systemImage: icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(tint)
                    Text(item.detail)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .padding(.leading, 28)
                }
            }
        }
    }
}
