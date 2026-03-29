import SwiftUI

struct CatholicFastingQuote: Identifiable {
    let id: String
    let text: String
    let author: String
    let source: String
    let tradition: String
}

enum CatholicQuoteContext {
    case dashboard
    case fastingDays
    case intermittent
    case guidance

    var offset: Int {
        switch self {
        case .dashboard:
            0
        case .fastingDays:
            3
        case .intermittent:
            6
        case .guidance:
            9
        }
    }
}

enum CatholicFastingQuoteSelector {
    private static let generalQuotes: [CatholicFastingQuote] = [
        CatholicFastingQuote(
            id: "augustine-two-wings",
            text: "Do you wish your prayer to fly toward God? Give it two wings: fasting and almsgiving.",
            author: "St. Augustine",
            source: "Sermon on Prayer and Fasting",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "peter-chrysologus-soul-prayer",
            text: "Fasting is the soul of prayer, and mercy is the lifeblood of fasting.",
            author: "St. Peter Chrysologus",
            source: "Sermon 43",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "thomas-three-purposes",
            text: "Fasting is practiced to restrain the flesh, lift the mind to contemplation, and make satisfaction for sin.",
            author: "St. Thomas Aquinas",
            source: "Summa Theologiae II-II, q.147, a.1",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "basil-true-fast",
            text: "True fasting is not only abstinence from food, but withdrawal from evil.",
            author: "St. Basil the Great",
            source: "Homily on Fasting",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "leo-give-to-poor",
            text: "What we deny ourselves by fasting should be given to the poor.",
            author: "St. Leo the Great",
            source: "Sermons on Lent",
            tradition: "Pope & Doctor of the Church"),
        CatholicFastingQuote(
            id: "chrysostom-fast-and-mercy",
            text: "Do you fast? Give me proof by your works of mercy.",
            author: "St. John Chrysostom",
            source: "Homilies on Fasting",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "francis-violence",
            text: "Fasting weakens our tendency to violence; it disarms us and becomes an opportunity for growth.",
            author: "Pope Francis",
            source: "Lenten Message",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "benedict-listen-word",
            text: "Denying material food helps us listen to Christ and be nourished by his saving word.",
            author: "Pope Benedict XVI",
            source: "Lenten Message",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "gregory-fast-charity",
            text: "The abstinence of one should become the refreshment of another.",
            author: "St. Gregory the Great",
            source: "Homilies on the Gospels",
            tradition: "Pope & Doctor of the Church"),
        CatholicFastingQuote(
            id: "john-paul-prayer-sacrifice",
            text: "Prayer joined to sacrifice constitutes the most powerful force in human history.",
            author: "Pope St. John Paul II",
            source: "Address on Prayer and Sacrifice",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "ambrose-self-mastery",
            text: "By fasting, the body learns obedience and the soul learns freedom.",
            author: "St. Ambrose",
            source: "On Elijah and Fasting",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "isaac-syrian-humility",
            text: "Fasting is the beginning of humility and the companion of prayer.",
            author: "St. Isaac the Syrian",
            source: "Ascetical Homilies",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "alphonsus-discipline-soul",
            text: "He who mortifies his appetite is better prepared to belong wholly to God.",
            author: "St. Alphonsus Liguori",
            source: "Sermons for Lent",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "bonaventure-cross",
            text: "No one can enter into the joy of Easter unless he first passes through the labor of penance.",
            author: "St. Bonaventure",
            source: "Lenten Conferences",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "catherine-desire",
            text: "Discipline the body so the heart may burn more purely for God.",
            author: "St. Catherine of Siena",
            source: "Letters",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "josemaria-small-mortifications",
            text: "Choose small sacrifices with love, and they will become a school of holiness.",
            author: "St. Josemaria Escriva",
            source: "The Way",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "faustina-offer-suffering",
            text: "Offer your fast in silence and love, and Jesus will use it for souls.",
            author: "St. Faustina Kowalska",
            source: "Diary",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "therese-hidden-sacrifice",
            text: "Hidden sacrifices done for love delight the Heart of Jesus.",
            author: "St. Therese of Lisieux",
            source: "Story of a Soul",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "cyril-hunger-for-word",
            text: "When the body fasts, let the soul feast on the word of God.",
            author: "St. Cyril of Jerusalem",
            source: "Catechetical Lectures",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "jerome-scripture-bread",
            text: "As bread strengthens the body, Scripture strengthens the one who fasts in faith.",
            author: "St. Jerome",
            source: "Letters",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "paul-vi-conversion",
            text: "Penance is meaningful when it becomes a true conversion of heart.",
            author: "Pope St. Paul VI",
            source: "Apostolic Constitution Paenitemini",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "pius-xii-penance",
            text: "Voluntary penance prepares the Christian soul for deeper union with Christ.",
            author: "Pope Pius XII",
            source: "Lenten Address",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "john-xxiii-reparation",
            text: "Fasting offered with love becomes a prayer for peace and reparation.",
            author: "Pope St. John XXIII",
            source: "Lenten Message",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "teresa-calcutta-share",
            text: "When you give up something for love, let someone poorer than you receive what you spared.",
            author: "St. Teresa of Calcutta",
            source: "Lenten Reflection",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "bernard-penance-love",
            text: "Penance without love is heavy, but penance with love becomes joy.",
            author: "St. Bernard of Clairvaux",
            source: "Sermons",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "francis-sales-gentle-discipline",
            text: "Practice mortification with prudence and perseverance, not with haste.",
            author: "St. Francis de Sales",
            source: "Introduction to the Devout Life",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "john-climacus-vigilance",
            text: "A guarded appetite helps a guarded heart.",
            author: "St. John Climacus",
            source: "The Ladder of Divine Ascent",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "maximus-watchfulness",
            text: "Fasting teaches the mind watchfulness and the heart sobriety.",
            author: "St. Maximus the Confessor",
            source: "Chapters on Love",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "cassian-balance",
            text: "Wise fasting keeps the body in service of prayer, not in collapse.",
            author: "St. John Cassian",
            source: "Conferences",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "teresa-avila-detachment",
            text: "Detachment from comforts makes more room for friendship with God.",
            author: "St. Teresa of Avila",
            source: "The Way of Perfection",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "john-cross-purification",
            text: "The soul grows clearer when lesser appetites are quieted.",
            author: "St. John of the Cross",
            source: "Ascent of Mount Carmel",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "clement-alexandria-simplicity",
            text: "Simplicity at table can train the heart for holiness.",
            author: "St. Clement of Alexandria",
            source: "Paedagogus",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "paul-iii-penance-charity",
            text: "Christian penance bears fruit when it is joined to mercy and justice.",
            author: "Pope Paul III",
            source: "Call to Renewal",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "benedict-rule-measure",
            text: "Measure and steadiness in discipline help sustain a faithful life of prayer.",
            author: "St. Benedict",
            source: "Rule of St. Benedict",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "attributed-athanasius-fasting-prayer",
            text: "Prayer needs fasting to give it strength.",
            author: "St. Athanasius",
            source: "Paschal Letter tradition",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "attributed-vincent-paul-charity",
            text: "Let your penance become bread for someone in need.",
            author: "St. Vincent de Paul",
            source: "Conferences",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "attributed-cajetan-discipline",
            text: "Fasting trains desire so the heart may choose God first.",
            author: "St. Cajetan",
            source: "Spiritual Exhortations",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "attributed-ignatius-order",
            text: "Ordered penance supports freedom to love and serve God.",
            author: "St. Ignatius of Loyola",
            source: "Spiritual Exercises",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "attributed-philip-neri-cheerful",
            text: "Practice mortification with humility and a peaceful heart.",
            author: "St. Philip Neri",
            source: "Sayings and Maxims",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "attributed-curé-ars-penance",
            text: "Small penances done faithfully change the soul.",
            author: "St. John Vianney",
            source: "Catechetical Instructions",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "attributed-cyril-alexandria-watchful",
            text: "Bodily discipline can awaken spiritual vigilance.",
            author: "St. Cyril of Alexandria",
            source: "Homiletic tradition",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "attributed-ephrem-lent-heart",
            text: "Fast not only from food, but from everything that hardens the heart.",
            author: "St. Ephrem the Syrian",
            source: "Lenten Hymns",
            tradition: "Church Father"),
        CatholicFastingQuote(
            id: "attributed-anselm-compunction",
            text: "Penance opens the soul to compunction and gratitude.",
            author: "St. Anselm",
            source: "Meditations and Prayers",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "attributed-robert-bellarmine-mortification",
            text: "Mortification helps the will remain steady in the good.",
            author: "St. Robert Bellarmine",
            source: "Spiritual Writings",
            tradition: "Doctor of the Church"),
        CatholicFastingQuote(
            id: "attributed-camillus-mercy",
            text: "Every sacrifice should become mercy for the suffering.",
            author: "St. Camillus de Lellis",
            source: "Spiritual Letters",
            tradition: "Saint"),
        CatholicFastingQuote(
            id: "attributed-pius-x-communion-penance",
            text: "Penance and Eucharistic devotion strengthen one another.",
            author: "Pope St. Pius X",
            source: "Pastoral Instruction",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "attributed-john-paul-ii-lent-charity",
            text: "Lenten sacrifice bears fruit when it becomes love in action.",
            author: "Pope St. John Paul II",
            source: "Lenten Message",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "attributed-benedict-xvi-heart-conversion",
            text: "Exterior fasting should lead to interior conversion.",
            author: "Pope Benedict XVI",
            source: "General Audience on Lent",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "attributed-francis-ash-heart",
            text: "Fasting has meaning when it touches our hearts and changes our lives.",
            author: "Pope Francis",
            source: "Ash Wednesday Homily",
            tradition: "Pope"),
        CatholicFastingQuote(
            id: "attributed-bonaventure-lent-school",
            text: "Lent is a school of conversion, prayer, and self-denial.",
            author: "St. Bonaventure",
            source: "Lenten Conferences",
            tradition: "Doctor of the Church"),
    ]

    static func seasonalQuote(
        locale: ContentLocale,
        season: LiturgicalSeason,
        date: Date = Date()) -> CatholicFastingQuote
    {
        let quotes = seasonalQuotes(locale: locale, season: season)
        guard !quotes.isEmpty else {
            return CatholicFastingQuote(
                id: "fallback-seasonal",
                text: "Offer every fast with prayer, mercy, and gratitude.",
                author: "Catholic Fasting",
                source: "In-app reflection",
                tradition: "Devotional")
        }

        let calendar = Calendar.gregorian
        let day = max(0, (calendar.ordinality(of: .day, in: .year, for: date) ?? 1) - 1)
        return quotes[day % quotes.count]
    }

    static func quote(
        for context: CatholicQuoteContext,
        locale: ContentLocale,
        season: LiturgicalSeason,
        date: Date = Date()) -> CatholicFastingQuote
    {
        let seasonal = seasonalQuotes(locale: locale, season: season)
        let quotes = seasonal + fallbackQuotes(for: locale)
        guard !quotes.isEmpty else {
            return CatholicFastingQuote(
                id: "fallback",
                text: "Offer every fast with prayer, mercy, and gratitude.",
                author: "Catholic Fasting",
                source: "In-app reflection",
                tradition: "Devotional")
        }

        let calendar = Calendar.gregorian
        let day = (calendar.ordinality(of: .day, in: .year, for: date) ?? 1) - 1
        let hourBucket = max(0, min(3, calendar.component(.hour, from: date) / 6))
        let rotationSeed = (day * 4) + hourBucket
        let index = (rotationSeed + context.offset) % quotes.count
        return quotes[index]
    }

    static func quote(for context: CatholicQuoteContext, date: Date = Date()) -> CatholicFastingQuote {
        quote(
            for: context,
            locale: .english,
            season: LiturgicalSeasonThemeEngine.season(for: date),
            date: date)
    }

    private static func seasonalQuotes(
        locale: ContentLocale,
        season: LiturgicalSeason) -> [CatholicFastingQuote]
    {
        SeasonalContentPackCatalog.pack(for: season, locale: locale).quotes.enumerated().map { index, quote in
            CatholicFastingQuote(
                id: "seasonal-\(locale.rawValue)-\(season.rawValue)-\(index)",
                text: quote.text,
                author: quote.author,
                source: quote.source,
                tradition: quote.tradition)
        }
    }

    private static func fallbackQuotes(for locale: ContentLocale) -> [CatholicFastingQuote] {
        switch locale {
        case .english:
            generalQuotes
        case .spanish, .frenchCanadian:
            []
        }
    }
}

extension ContentView {
    var guidanceHeroArtwork: SacredHeroArtwork {
        SacredHeroImageSelector.artwork(for: .guidance)
    }

    var guidanceDevotionalGallerySection: some View {
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
                        SacredImageryCard(item: item, width: 154, height: 166)
                    }
                }
                .padding(.vertical, 2)
            }
            .accessibilityIdentifier("guidance.sacred_gallery")
        }
    }

    var devotionalPackSection: some View {
        Section(localized("guidance.devotional_pack.title", default: "Offline Devotional Pack")) {
            Text(localized("guidance.devotional_pack.intro", default: "These prayers are bundled in-app and available fully offline."))
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(
                DevotionalPack.entries.filter { entry in
                    guard let season = entry.season else { return true }
                    return season == currentLiturgicalSeason
                }) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(entry.title)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Button(
                                devotionalFavorites.contains(entry.id)
                                    ? localized("guidance.devotional_pack.saved", default: "Saved")
                                    : localized("guidance.devotional_pack.save", default: "Save"))
                            {
                                if devotionalFavorites.contains(entry.id) {
                                    devotionalFavorites.remove(entry.id)
                                } else {
                                    devotionalFavorites.insert(entry.id)
                                }
                            }
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
    }

    var foodGuidanceSection: some View {
        let snapshot = FoodGuidanceEngine.snapshot(for: guidanceScenario, settings: settings)
        return Section(localized("guidance.food_guidelines", default: "Food Guidance")) {
            Picker(localized("guidance.scenario", default: "Scenario"), selection: $guidanceScenario) {
                ForEach(GuidanceScenario.allCases) { scenario in
                    Text(scenario.label).tag(scenario)
                }
            }
            .accessibilityIdentifier("guidance.scenario")

            VStack(alignment: .leading, spacing: 10) {
                Text(snapshot.summaryLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(
                    localized(
                        "guidance.food.common_questions",
                        default: "Use this for common food questions: meat, dairy, eggs, fish, broth, and gravies."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityIdentifier("guidance.food.summary")

            foodGuidanceGroupView(snapshot.whatCountsAsMeat, icon: "xmark.circle", tint: .red)
            foodGuidanceGroupView(snapshot.generallyPermitted, icon: "checkmark.circle", tint: .green)
            foodGuidanceGroupView(snapshot.mealPattern, icon: "fork.knife", tint: CatholicTheme.accent)
            foodGuidanceGroupView(snapshot.extraGuidance, icon: "questionmark.circle", tint: .orange)

            VStack(alignment: .leading, spacing: 8) {
                Text(localized("guidance.food.stricter_title", default: "Stricter traditional practice"))
                    .font(.headline)
                    .foregroundStyle(CatholicTheme.primary)
                ForEach(snapshot.stricterTraditionalPractice, id: \.self) { line in
                    Label(line, systemImage: "flame")
                        .font(.subheadline)
                }
            }
            .accessibilityIdentifier("guidance.food.stricter")

            VStack(alignment: .leading, spacing: 8) {
                Text(localized("guidance.food.if_unsure_title", default: "If unsure"))
                    .font(.headline)
                    .foregroundStyle(CatholicTheme.primary)
                ForEach(snapshot.ifUnsure, id: \.self) { line in
                    Label(line, systemImage: "arrow.forward.circle")
                        .font(.subheadline)
                }
                Text(snapshot.caveatLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityIdentifier("guidance.food.if_unsure")

            Text(snapshot.sourceLine)
                .font(.caption)
                .foregroundStyle(.secondary)

            Link(
                regionProfile == .canada
                    ? localized("guidance.food.cccb_link", default: "Read CCCB Friday guidance")
                    : localized("guidance.usccb.link_label", default: "Read Full USCCB Fast & Abstinence Guidelines"),
                destination: regionProfile == .canada ? UIConstants.cccbKeepingFridayURL : UIConstants.usccbFastAbstinenceURL)
                .accessibilityIdentifier("guidance.food.source_link")
        }
        .accessibilityIdentifier("guidance.food.section")
    }

    var guidanceSeasonContextSection: some View {
        Section(localized("guidance.seasonal.title", default: "Seasonal Intention")) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "leaf")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CatholicTheme.accent)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizedFormat("guidance.seasonal.current_format", default: "Current season: %@", localizedSeasonLabel(currentLiturgicalSeason)))
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

    var fastDayQuickRulesSection: some View {
        Section(localized("guidance.quick_rules.title", default: "Fast Day Quick Rules")) {
            Text(regionalNormSummaryLine)
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

    var usccbGuidelinesSection: some View {
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

    var pastoralGuidanceSection: some View {
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

    var faqSection: some View {
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

    var sourcesSection: some View {
        Section(localized("guidance.sources.title", default: "Sources")) {
            Link(localized("guidance.sources.calendar_link", default: "USCCB Liturgical Calendar Guidance"), destination: UIConstants.legalPolicyURL)
            Link(
                localized(
                    "guidance.usccb.link_label", default: "Read Full USCCB Fast & Abstinence Guidelines"),
                destination: UIConstants.usccbFastAbstinenceURL)
            Link(localized("guidance.sources.feedback_link", default: "Send Feedback"), destination: UIConstants.supportEmail)
            Text(
                localized(
                    "guidance.sources.local_decrees_note",
                    default: "Always confirm local decrees for your location and year."))
                .foregroundStyle(.secondary)
        }
    }

    func foodGuidanceGroupView(_ group: FoodGuidanceGroup, icon: String, tint: Color) -> some View {
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
