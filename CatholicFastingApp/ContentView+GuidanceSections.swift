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
        date: Date = AppClock.now()) -> CatholicFastingQuote
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
        date: Date = AppClock.now()) -> CatholicFastingQuote
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

    static func quote(for context: CatholicQuoteContext, date: Date = AppClock.now()) -> CatholicFastingQuote {
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
    var guidanceDevotionalGallerySection: some View {
        GuidanceDevotionalGallerySection(languageCode: languageModeRaw)
    }

    var devotionalPackSection: some View {
        DevotionalPackSection(
            entries: DevotionalPack.entries.filter { entry in
                guard let season = entry.season else { return true }
                return season == currentLiturgicalSeason
            },
            favoriteIDs: $profileSession.devotionalFavorites,
            languageCode: languageModeRaw)
    }

    var foodGuidanceSection: some View {
        FoodGuidanceSection(
            scenario: feedback.guidanceScenario,
            settings: settings,
            languageCode: languageModeRaw,
            selectedScenario: $feedback.guidanceScenario)
            .equatable()
    }

    var guidanceSeasonContextSection: some View {
        GuidanceSeasonContextSection(
            seasonLabel: localizedSeasonLabel(currentLiturgicalSeason),
            languageCode: languageModeRaw)
    }

    var fastDayQuickRulesSection: some View {
        FastDayQuickRulesSection(
            regionalNormSummary: regionalNormSummaryLine,
            languageCode: languageModeRaw)
    }

    var usccbGuidelinesSection: some View {
        OfficialGuidelinesSection(
            regionProfile: regionProfile,
            languageCode: languageModeRaw)
    }

    var pastoralGuidanceSection: some View {
        PastoralGuidanceSection(languageCode: languageModeRaw)
    }

    var faqSection: some View {
        GuidanceFAQSection(languageCode: languageModeRaw)
    }

    var sourcesSection: some View {
        GuidanceSourcesSection(languageCode: languageModeRaw)
    }
}
