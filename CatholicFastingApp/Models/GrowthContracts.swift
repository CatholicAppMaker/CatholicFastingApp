@preconcurrency import Foundation

struct SubscriptionOfferCatalog {
    struct Offer: Hashable, Identifiable {
        let id: String
        let displayTitle: String
        let durationLabel: String
        let billingCadenceLabel: String
        let outcomeSummary: String
        let isPrimaryAnchor: Bool
    }

    struct Pillar: Hashable, Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let outcomes: [String]
        let requiredSurface: PremiumEntitlementSurface
    }

    let title: String
    let subtitle: String
    let pillars: [Pillar]
    let offers: [Offer]

    static let catholicFasting = SubscriptionOfferCatalog(
        title: "Formation Toolkit",
        subtitle: "Premium keeps a guided seasonal journey, reminders, review, and reflection in one steady Catholic workflow.",
        pillars: [
            Pillar(
                id: "planning",
                title: "Guided Journey",
                subtitle: "Follow one weekly seasonal path instead of guessing what to do next.",
                outcomes: [
                    "Move through Lent, Advent, and Ordinary Time with one weekly rhythm",
                    "Keep fasting, prayer, charity, and review tied together in the same plan",
                    "Protect celebration days so personal discipline does not overreach",
                ],
                requiredSurface: .planning),
            Pillar(
                id: "accountability",
                title: "Accountability",
                subtitle: "Recover quickly and keep momentum when discipline slips.",
                outcomes: [
                    "Turn reminders into a steadier rule of life",
                    "Spot slippage early with completion trends and recovery guidance",
                    "Review longer intermittent history with milestone feedback",
                ],
                requiredSurface: .accountability),
            Pillar(
                id: "reflection",
                title: "Reflection",
                subtitle: "Connect fasting to prayer, virtue, and honest review.",
                outcomes: [
                    "Use guided prompts to examine intention, not just completion",
                    "Keep a private local journal with virtue notes",
                    "Export a fasting summary for spiritual direction or personal review",
                ],
                requiredSurface: .reflection),
        ],
        offers: [
            Offer(
                id: "com.kevpierce.catholicfasting.premium.yearly.v3",
                displayTitle: "Premium Yearly",
                durationLabel: "1 year",
                billingCadenceLabel: "Billed once per year",
                outcomeSummary: "Best value for one steady rhythm through the full liturgical year.",
                isPrimaryAnchor: true),
            Offer(
                id: "com.kevpierce.catholicfasting.premium.monthly.v3",
                displayTitle: "Premium Monthly",
                durationLabel: "1 month",
                billingCadenceLabel: "Billed monthly",
                outcomeSummary: "Lower-friction way to begin premium planning and review habits.",
                isPrimaryAnchor: false),
        ])

    var canonicalSubscriptionProductIDs: Set<String> {
        Set(offers.map(\.id))
    }

    func offer(for productID: String) -> Offer? {
        offers.first(where: { $0.id == productID })
    }
}

enum PremiumEntitlementSurface: String, CaseIterable, Identifiable {
    case planning
    case accountability
    case reflection
    case export

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .planning:
            "Planning"
        case .accountability:
            "Accountability"
        case .reflection:
            "Reflection"
        case .export:
            "Export"
        }
    }

    var guidance: String {
        switch self {
        case .planning:
            "Build a realistic discipline plan that respects feast and holy days."
        case .accountability:
            "Stay steady with reminders, trends, and recovery guidance."
        case .reflection:
            "Reflect with guided prompts, journal entries, and virtue notes."
        case .export:
            "Share clean summaries for personal review or spiritual direction."
        }
    }
}

struct LaunchFunnelSnapshot: Codable, Equatable {
    var startedAt: Date
    var completedOnboardingAt: Date?
    var selectedRegionRaw: String
    var selectedReminderTierRaw: String
    var firstActionCompletedAt: Date?
    var paywallSeenAt: Date?
    var paywallViewCount: Int
    var lockedUpgradeTapCount: Int
    var premiumPreviewSeenAt: Date?
    var purchaseStartedAt: Date?
    var premiumUnlockedAt: Date?

    static let `default` = LaunchFunnelSnapshot(
        startedAt: Date(),
        completedOnboardingAt: nil,
        selectedRegionRaw: RuleSettings.RegionProfile.us.rawValue,
        selectedReminderTierRaw: ReminderTier.balanced.rawValue,
        firstActionCompletedAt: nil,
        paywallSeenAt: nil,
        paywallViewCount: 0,
        lockedUpgradeTapCount: 0,
        premiumPreviewSeenAt: nil,
        purchaseStartedAt: nil,
        premiumUnlockedAt: nil)

    var selectedRegion: RuleSettings.RegionProfile {
        RuleSettings.RegionProfile(rawValue: selectedRegionRaw) ?? .us
    }

    var selectedReminderTier: ReminderTier {
        ReminderTier(rawValue: selectedReminderTierRaw) ?? .balanced
    }
}

enum ReminderTier: String, CaseIterable, Identifiable {
    case minimal
    case balanced
    case guided

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .minimal: "Minimal"
        case .balanced: "Balanced"
        case .guided: "Guided"
        }
    }

    var summary: String {
        switch self {
        case .minimal:
            "Required-day reminders only."
        case .balanced:
            "Required days plus one daily support reminder."
        case .guided:
            "Morning + evening support cadence for habit building."
        }
    }

    var morningEnabled: Bool {
        switch self {
        case .minimal: false
        case .balanced, .guided: true
        }
    }

    var eveningEnabled: Bool {
        switch self {
        case .minimal, .balanced: false
        case .guided: true
        }
    }

    var supportEnabled: Bool {
        self != .minimal
    }

    static func infer(
        supportEnabled: Bool,
        morningEnabled: Bool,
        eveningEnabled: Bool) -> ReminderTier
    {
        if supportEnabled, morningEnabled, eveningEnabled {
            return .guided
        }
        if supportEnabled, morningEnabled {
            return .balanced
        }
        return .minimal
    }
}

struct SeasonalContentPack: Hashable {
    struct RotatingQuote: Hashable {
        let text: String
        let author: String
        let source: String
        let tradition: String
    }

    let season: LiturgicalSeason
    let locale: ContentLocale
    let heroAssetNames: [String]
    let campaignTitle: String
    let campaignSubtitle: String
    let formationLines: [String]
    let quotes: [RotatingQuote]
}

struct DailyQuoteReminderContent: Equatable {
    let title: String
    let body: String
    let quote: SeasonalContentPack.RotatingQuote
}

enum DailyQuoteReminderContentProvider {
    private static let fallbackQuote = SeasonalContentPack.RotatingQuote(
        text: "Fast with fidelity, pray with humility, and give with charity.",
        author: "Catholic Fasting",
        source: "In-app formation",
        tradition: "Pastoral")

    static func quote(
        for date: Date,
        locale: ContentLocale,
        calendar: Calendar = .gregorian) -> SeasonalContentPack.RotatingQuote
    {
        let season = LiturgicalSeasonThemeEngine.season(for: date, calendar: calendar)
        let pack = SeasonalContentPackCatalog.pack(for: season, locale: locale)
        let quotes = pack.quotes
        guard !quotes.isEmpty else { return fallbackQuote }

        let ordinal = max(1, calendar.ordinality(of: .day, in: .year, for: date) ?? 1)
        return quotes[(ordinal - 1) % quotes.count]
    }

    static func reminderBody(
        for date: Date,
        locale: ContentLocale,
        calendar: Calendar = .gregorian,
        characterLimit: Int = 160) -> String
    {
        let quote = quote(for: date, locale: locale, calendar: calendar)
        let attributed = "“\(quote.text)” — \(quote.author)"
        if attributed.count <= characterLimit {
            return attributed
        }

        let compact = "\(quote.text) — \(quote.author)"
        if compact.count <= characterLimit {
            return compact
        }

        let reservedForAuthor = quote.author.count + 4
        let maxTextCount = max(24, characterLimit - reservedForAuthor)
        let trimmedText = String(quote.text.prefix(maxTextCount)).trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(trimmedText)… — \(quote.author)"
    }

    static func content(
        title: String,
        for date: Date,
        locale: ContentLocale,
        calendar: Calendar = .gregorian,
        characterLimit: Int = 160) -> DailyQuoteReminderContent
    {
        let quote = quote(for: date, locale: locale, calendar: calendar)
        return DailyQuoteReminderContent(
            title: title,
            body: reminderBody(
                for: date,
                locale: locale,
                calendar: calendar,
                characterLimit: characterLimit),
            quote: quote)
    }
}

enum ContentLocale: String, Codable {
    case english
    case spanish
    case frenchCanadian
}

enum SeasonalContentPackCatalog {
    static func pack(for season: LiturgicalSeason, locale: ContentLocale) -> SeasonalContentPack {
        let packs: [LiturgicalSeason: SeasonalContentPack] = switch locale {
        case .english:
            englishPacks
        case .spanish:
            spanishPacks
        case .frenchCanadian:
            frenchCanadianPacks
        }
        return packs[season] ?? packs[.ordinary]!
    }

    private static let englishPacks: [LiturgicalSeason: SeasonalContentPack] = [
        .lent: SeasonalContentPack(
            season: .lent,
            locale: .english,
            heroAssetNames: ["SacredAshWednesday", "SacredMonstrance", "SacredPalmSunday", "SacredDesertPilgrimage"],
            campaignTitle: "Lenten Discipline",
            campaignSubtitle: "Pray, fast, and give alms with consistency.",
            formationLines: [
                "Keep required days visible and plan Friday penance before the week starts.",
                "Pair each fast with one concrete act of mercy.",
                "Use hunger as a cue for prayer, not frustration.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "Prayer joined to sacrifice constitutes the most powerful force in human history.",
                    author: "Pope St. John Paul II",
                    source: "Address on Prayer and Sacrifice",
                    tradition: "Pope"),
                SeasonalContentPack.RotatingQuote(
                    text: "Fasting is the soul of prayer, and mercy is the lifeblood of fasting.",
                    author: "St. Peter Chrysologus",
                    source: "Sermon 43",
                    tradition: "Church Father"),
                SeasonalContentPack.RotatingQuote(
                    text: "Do you wish your prayer to fly toward God? Give it two wings: fasting and almsgiving.",
                    author: "St. Augustine",
                    source: "Sermon on Prayer and Fasting",
                    tradition: "Church Father"),
                SeasonalContentPack.RotatingQuote(
                    text: "True fasting is not only abstinence from food, but withdrawal from evil.",
                    author: "St. Basil the Great",
                    source: "Homily on Fasting",
                    tradition: "Church Father"),
            ]),
        .advent: SeasonalContentPack(
            season: .advent,
            locale: .english,
            heroAssetNames: ["SacredScriptureCandle", "SacredMarianMonogram", "SacredCathedralLight"],
            campaignTitle: "Advent Watchfulness",
            campaignSubtitle: "Practice hopeful discipline while awaiting Christ.",
            formationLines: [
                "Keep disciplines modest and sustainable.",
                "Use fasting to create room for prayer and silence.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "Denying material food helps us listen to Christ and be nourished by his saving word.",
                    author: "Pope Benedict XVI",
                    source: "Lenten Message",
                    tradition: "Pope"),
                SeasonalContentPack.RotatingQuote(
                    text: "True fasting is not only abstinence from food, but withdrawal from evil.",
                    author: "St. Basil the Great",
                    source: "Homily on Fasting",
                    tradition: "Church Father"),
                SeasonalContentPack.RotatingQuote(
                    text: "Choose a modest discipline that keeps your heart awake and ready for the Lord.",
                    author: "Catholic Fasting",
                    source: "In-app formation",
                    tradition: "Pastoral"),
            ]),
        .christmas: SeasonalContentPack(
            season: .christmas,
            locale: .english,
            heroAssetNames: ["SacredChaliceVine", "SacredCathedralLight", "HeroSacred"],
            campaignTitle: "Christmas Sobriety and Joy",
            campaignSubtitle: "Celebrate faithfully while keeping Friday discipline.",
            formationLines: [
                "Practice gratitude at meals.",
                "Keep penitential practice with gentleness and charity.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "Penance without love is heavy, but penance with love becomes joy.",
                    author: "St. Bernard of Clairvaux",
                    source: "Sermons",
                    tradition: "Doctor of the Church"),
                SeasonalContentPack.RotatingQuote(
                    text: "Practice mortification with prudence and perseverance, not with haste.",
                    author: "St. Francis de Sales",
                    source: "Introduction to the Devout Life",
                    tradition: "Doctor of the Church"),
                SeasonalContentPack.RotatingQuote(
                    text: "Keep your celebration grateful, simple, and attentive to the needs of others.",
                    author: "Catholic Fasting",
                    source: "In-app formation",
                    tradition: "Pastoral"),
            ]),
        .easter: SeasonalContentPack(
            season: .easter,
            locale: .english,
            heroAssetNames: ["SacredChaliceVine", "SacredJerusalemCross", "HeroSacred"],
            campaignTitle: "Easter Fidelity",
            campaignSubtitle: "Carry Lenten discipline into ordinary life.",
            formationLines: [
                "Maintain Friday penance intentionally.",
                "Use gratitude and mercy as your primary acts.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "The abstinence of one should become the refreshment of another.",
                    author: "St. Gregory the Great",
                    source: "Homilies on the Gospels",
                    tradition: "Pope & Doctor"),
                SeasonalContentPack.RotatingQuote(
                    text: "When you give up something for love, let someone poorer than you receive what you spared.",
                    author: "St. Teresa of Calcutta",
                    source: "Lenten Reflection",
                    tradition: "Saint"),
                SeasonalContentPack.RotatingQuote(
                    text: "Carry the freedom learned in fasting into ordinary days with gratitude and mercy.",
                    author: "Catholic Fasting",
                    source: "In-app formation",
                    tradition: "Pastoral"),
            ]),
        .ordinary: SeasonalContentPack(
            season: .ordinary,
            locale: .english,
            heroAssetNames: ["SacredChiRho", "SacredRosaryCross", "SacredConceptHeart", "HeroSacred"],
            campaignTitle: "Ordinary Time Consistency",
            campaignSubtitle: "Small faithful habits form long-term discipline.",
            formationLines: [
                "Plan your weekly fast day in advance.",
                "Review completed and missed days each week.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "A faithful small sacrifice is better than a dramatic one you cannot sustain.",
                    author: "Catholic Fasting",
                    source: "In-app formation",
                    tradition: "Pastoral"),
                SeasonalContentPack.RotatingQuote(
                    text: "By fasting, the body learns obedience and the soul learns freedom.",
                    author: "St. Ambrose",
                    source: "On Elijah and Fasting",
                    tradition: "Church Father"),
                SeasonalContentPack.RotatingQuote(
                    text: "Measure and steadiness in discipline help sustain a faithful life of prayer.",
                    author: "St. Benedict",
                    source: "Rule of St. Benedict",
                    tradition: "Saint"),
            ]),
    ]

    private static let spanishPacks: [LiturgicalSeason: SeasonalContentPack] = [
        .lent: SeasonalContentPack(
            season: .lent,
            locale: .spanish,
            heroAssetNames: ["SacredAshWednesday", "SacredMonstrance", "SacredPalmSunday"],
            campaignTitle: "Disciplina Cuaresmal",
            campaignSubtitle: "Orar, ayunar y dar limosna con constancia.",
            formationLines: [
                "Planea los dias obligatorios con anticipacion.",
                "Une cada ayuno con una obra concreta de misericordia.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "El ayuno es el alma de la oracion y la misericordia es su vida.",
                    author: "San Pedro Crisologo",
                    source: "Sermon 43",
                    tradition: "Padre de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "La oracion que vuela hacia Dios necesita dos alas: el ayuno y la limosna.",
                    author: "San Agustin",
                    source: "Sermon sobre la oracion y el ayuno",
                    tradition: "Padre de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "El verdadero ayuno no es solo abstenerse de la comida, sino apartarse del mal.",
                    author: "San Basilio Magno",
                    source: "Homilia sobre el ayuno",
                    tradition: "Padre de la Iglesia"),
            ]),
        .advent: SeasonalContentPack(
            season: .advent,
            locale: .spanish,
            heroAssetNames: ["SacredScriptureCandle", "SacredMarianMonogram", "SacredCathedralLight"],
            campaignTitle: "Vigilia de Adviento",
            campaignSubtitle: "Practique una disciplina esperanzada mientras espera a Cristo.",
            formationLines: [
                "Mantenga una disciplina modesta y sostenible.",
                "Deje que el ayuno abra espacio para la oracion y el silencio.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "Renunciar al alimento material nos ayuda a escuchar a Cristo y a nutrirnos de su palabra salvadora.",
                    author: "Papa Benedicto XVI",
                    source: "Mensaje de Cuaresma",
                    tradition: "Papa"),
                SeasonalContentPack.RotatingQuote(
                    text: "El verdadero ayuno no es solo abstenerse de la comida, sino apartarse del mal.",
                    author: "San Basilio Magno",
                    source: "Homilia sobre el ayuno",
                    tradition: "Padre de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Elija una disciplina sobria que mantenga el corazon despierto y atento al Senor.",
                    author: "Catholic Fasting",
                    source: "Formacion integrada",
                    tradition: "Pastoral"),
            ]),
        .christmas: SeasonalContentPack(
            season: .christmas,
            locale: .spanish,
            heroAssetNames: ["SacredChaliceVine", "SacredCathedralLight", "HeroSacred"],
            campaignTitle: "Sobriedad y alegria en Navidad",
            campaignSubtitle: "Celebre con fidelidad mientras mantiene la disciplina del viernes.",
            formationLines: [
                "Practique la gratitud en la mesa.",
                "Mantenga la penitencia con suavidad y caridad.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "La penitencia sin amor es pesada, pero con amor se vuelve alegria.",
                    author: "San Bernardo de Claraval",
                    source: "Sermones",
                    tradition: "Doctor de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Practique la mortificacion con prudencia y perseverancia, no con apresuramiento.",
                    author: "San Francisco de Sales",
                    source: "Introduccion a la vida devota",
                    tradition: "Doctor de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Celebre con gratitud, sencillez y atencion a las necesidades de los demas.",
                    author: "Catholic Fasting",
                    source: "Formacion integrada",
                    tradition: "Pastoral"),
            ]),
        .easter: SeasonalContentPack(
            season: .easter,
            locale: .spanish,
            heroAssetNames: ["SacredChaliceVine", "SacredJerusalemCross", "HeroSacred"],
            campaignTitle: "Fidelidad pascual",
            campaignSubtitle: "Lleve la disciplina cuaresmal a la vida ordinaria.",
            formationLines: [
                "Mantenga con intencion la penitencia del viernes.",
                "Haga de la gratitud y la misericordia sus primeros actos.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "La abstinencia de uno debe convertirse en alivio para otro.",
                    author: "San Gregorio Magno",
                    source: "Homilias sobre los Evangelios",
                    tradition: "Papa y doctor"),
                SeasonalContentPack.RotatingQuote(
                    text: "Cuando renuncie a algo por amor, deje que alguien mas necesitado reciba lo que usted ahorro.",
                    author: "Santa Teresa de Calcuta",
                    source: "Reflexion cuaresmal",
                    tradition: "Santa"),
                SeasonalContentPack.RotatingQuote(
                    text: "Lleve a los dias ordinarios la libertad aprendida en el ayuno, con gratitud y misericordia.",
                    author: "Catholic Fasting",
                    source: "Formacion integrada",
                    tradition: "Pastoral"),
            ]),
        .ordinary: SeasonalContentPack(
            season: .ordinary,
            locale: .spanish,
            heroAssetNames: ["SacredChiRho", "SacredRosaryCross", "HeroSacred"],
            campaignTitle: "Constancia en Tiempo Ordinario",
            campaignSubtitle: "La fidelidad diaria forma el corazon.",
            formationLines: [
                "Manten una disciplina semanal realista.",
                "Revisa cada semana tus avances y tus omisiones.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "La penitencia con amor se vuelve alegria.",
                    author: "San Bernardo",
                    source: "Sermones",
                    tradition: "Doctor de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Por el ayuno, el cuerpo aprende obediencia y el alma aprende libertad.",
                    author: "San Ambrosio",
                    source: "Sobre Elias y el ayuno",
                    tradition: "Padre de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "La medida y la constancia en la disciplina ayudan a sostener una vida fiel de oracion.",
                    author: "San Benito",
                    source: "Regla de San Benito",
                    tradition: "Santo"),
            ]),
    ]

    private static let frenchCanadianPacks: [LiturgicalSeason: SeasonalContentPack] = [
        .lent: SeasonalContentPack(
            season: .lent,
            locale: .frenchCanadian,
            heroAssetNames: ["SacredAshWednesday", "SacredMonstrance", "SacredPalmSunday", "SacredDesertPilgrimage"],
            campaignTitle: "Discipline du Carême",
            campaignSubtitle: "Priez, jeûnez et donnez l’aumône avec constance.",
            formationLines: [
                "Gardez les jours obligatoires bien visibles et planifiez la pénitence du vendredi avant le début de la semaine.",
                "Associez chaque jeûne à une œuvre concrète de miséricorde.",
                "Laissez la faim vous rappeler la prière plutôt que la frustration.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "La prière unie au sacrifice constitue la force la plus puissante de l’histoire humaine.",
                    author: "Saint Jean-Paul II",
                    source: "Discours sur la prière et le sacrifice",
                    tradition: "Pape"),
                SeasonalContentPack.RotatingQuote(
                    text: "Le jeûne est l’âme de la prière, et la miséricorde est le sang même du jeûne.",
                    author: "Saint Pierre Chrysologue",
                    source: "Sermon 43",
                    tradition: "Père de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "La prière qui s’élève vers Dieu a besoin de deux ailes : le jeûne et l’aumône.",
                    author: "Saint Augustin",
                    source: "Sermon sur la prière et le jeûne",
                    tradition: "Père de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Le vrai jeûne n’est pas seulement l’abstinence de nourriture, mais aussi le retrait du mal.",
                    author: "Saint Basile le Grand",
                    source: "Homélie sur le jeûne",
                    tradition: "Père de l’Église"),
            ]),
        .advent: SeasonalContentPack(
            season: .advent,
            locale: .frenchCanadian,
            heroAssetNames: ["SacredScriptureCandle", "SacredMarianMonogram", "SacredCathedralLight"],
            campaignTitle: "Veille de l’Avent",
            campaignSubtitle: "Pratiquez une discipline pleine d’espérance dans l’attente du Christ.",
            formationLines: [
                "Gardez vos disciplines modestes et durables.",
                "Que le jeûne crée de l’espace pour la prière et le silence.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "Le renoncement à la nourriture matérielle nous aide à écouter le Christ et à être nourris par sa parole de salut.",
                    author: "Benoît XVI",
                    source: "Message de Carême",
                    tradition: "Pape"),
                SeasonalContentPack.RotatingQuote(
                    text: "Le vrai jeûne n’est pas seulement l’abstinence de nourriture, mais aussi le retrait du mal.",
                    author: "Saint Basile le Grand",
                    source: "Homélie sur le jeûne",
                    tradition: "Père de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Choisissez une discipline simple qui garde le cœur éveillé dans l’attente du Seigneur.",
                    author: "Catholic Fasting",
                    source: "Formation intégrée",
                    tradition: "Pastorale"),
            ]),
        .christmas: SeasonalContentPack(
            season: .christmas,
            locale: .frenchCanadian,
            heroAssetNames: ["SacredChaliceVine", "SacredCathedralLight", "HeroSacred"],
            campaignTitle: "Sobriété et joie de Noël",
            campaignSubtitle: "Célébrez fidèlement tout en gardant la discipline du vendredi.",
            formationLines: [
                "Pratiquez la gratitude à table.",
                "Gardez la pénitence avec douceur et charité.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "La pénitence sans amour est lourde, mais avec l’amour elle devient joie.",
                    author: "Saint Bernard de Clairvaux",
                    source: "Sermons",
                    tradition: "Docteur de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Pratiquez la mortification avec prudence et persévérance, non dans la précipitation.",
                    author: "Saint François de Sales",
                    source: "Introduction à la vie dévote",
                    tradition: "Docteur de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Célébrez avec gratitude, simplicité et attention envers les personnes dans le besoin.",
                    author: "Catholic Fasting",
                    source: "Formation intégrée",
                    tradition: "Pastorale"),
            ]),
        .easter: SeasonalContentPack(
            season: .easter,
            locale: .frenchCanadian,
            heroAssetNames: ["SacredChaliceVine", "SacredJerusalemCross", "HeroSacred"],
            campaignTitle: "Fidélité pascale",
            campaignSubtitle: "Portez la discipline du Carême dans la vie ordinaire.",
            formationLines: [
                "Gardez la pénitence du vendredi avec intention.",
                "Faites de la gratitude et de la miséricorde vos premiers gestes.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "L’abstinence de l’un devrait devenir le réconfort de l’autre.",
                    author: "Saint Grégoire le Grand",
                    source: "Homélies sur les Évangiles",
                    tradition: "Pape et docteur"),
                SeasonalContentPack.RotatingQuote(
                    text: "Lorsque vous renoncez à quelque chose par amour, laissez une personne plus pauvre recevoir ce que vous avez épargné.",
                    author: "Sainte Teresa de Calcutta",
                    source: "Réflexion de Carême",
                    tradition: "Sainte"),
                SeasonalContentPack.RotatingQuote(
                    text: "Portez dans les jours ordinaires la liberté apprise dans le jeûne, avec gratitude et miséricorde.",
                    author: "Catholic Fasting",
                    source: "Formation intégrée",
                    tradition: "Pastorale"),
            ]),
        .ordinary: SeasonalContentPack(
            season: .ordinary,
            locale: .frenchCanadian,
            heroAssetNames: ["SacredChiRho", "SacredRosaryCross", "SacredConceptHeart", "HeroSacred"],
            campaignTitle: "Constance du temps ordinaire",
            campaignSubtitle: "Les petites habitudes fidèles forment une discipline durable.",
            formationLines: [
                "Planifiez votre jour de jeûne hebdomadaire d’avance.",
                "Passez en revue chaque semaine les jours accomplis et manqués.",
            ],
            quotes: [
                SeasonalContentPack.RotatingQuote(
                    text: "Un petit sacrifice fidèle vaut mieux qu’un grand geste impossible à soutenir.",
                    author: "Catholic Fasting",
                    source: "Formation intégrée",
                    tradition: "Pastorale"),
                SeasonalContentPack.RotatingQuote(
                    text: "Par le jeûne, le corps apprend l’obéissance et l’âme apprend la liberté.",
                    author: "Saint Ambroise",
                    source: "Sur Élie et le jeûne",
                    tradition: "Père de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "La mesure et la constance dans la discipline soutiennent une vie fidèle de prière.",
                    author: "Saint Benoît",
                    source: "Règle de saint Benoît",
                    tradition: "Saint"),
            ]),
    ]
}
