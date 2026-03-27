@preconcurrency import Foundation

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
                SeasonalContentPack.RotatingQuote(
                    text: "Fasting is practiced to restrain the flesh, lift the mind to contemplation, and make satisfaction for sin.",
                    author: "St. Thomas Aquinas",
                    source: "Summa Theologiae II-II, q.147, a.1",
                    tradition: "Doctor of the Church"),
                SeasonalContentPack.RotatingQuote(
                    text: "What we deny ourselves by fasting should be given to the poor.",
                    author: "St. Leo the Great",
                    source: "Sermons on Lent",
                    tradition: "Pope & Doctor of the Church"),
                SeasonalContentPack.RotatingQuote(
                    text: "Do you fast? Give me proof by your works of mercy.",
                    author: "St. John Chrysostom",
                    source: "Homilies on Fasting",
                    tradition: "Church Father"),
                SeasonalContentPack.RotatingQuote(
                    text: "No one can enter into the joy of Easter unless he first passes through the labor of penance.",
                    author: "St. Bonaventure",
                    source: "Lenten Conferences",
                    tradition: "Doctor of the Church"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "Measure and steadiness in discipline help sustain a faithful life of prayer.",
                    author: "St. Benedict",
                    source: "Rule of St. Benedict",
                    tradition: "Saint"),
                SeasonalContentPack.RotatingQuote(
                    text: "Wise fasting keeps the body in service of prayer, not in collapse.",
                    author: "St. John Cassian",
                    source: "Conferences",
                    tradition: "Church Father"),
                SeasonalContentPack.RotatingQuote(
                    text: "Detachment from comforts makes more room for friendship with God.",
                    author: "St. Teresa of Avila",
                    source: "The Way of Perfection",
                    tradition: "Doctor of the Church"),
                SeasonalContentPack.RotatingQuote(
                    text: "The soul grows clearer when lesser appetites are quieted.",
                    author: "St. John of the Cross",
                    source: "Ascent of Mount Carmel",
                    tradition: "Doctor of the Church"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "Simplicity at table can train the heart for holiness.",
                    author: "St. Clement of Alexandria",
                    source: "Paedagogus",
                    tradition: "Church Father"),
                SeasonalContentPack.RotatingQuote(
                    text: "Hidden sacrifices done for love delight the Heart of Jesus.",
                    author: "St. Therese of Lisieux",
                    source: "Story of a Soul",
                    tradition: "Doctor of the Church"),
                SeasonalContentPack.RotatingQuote(
                    text: "Choose small sacrifices with love, and they will become a school of holiness.",
                    author: "St. Josemaria Escriva",
                    source: "The Way",
                    tradition: "Saint"),
                SeasonalContentPack.RotatingQuote(
                    text: "Let your penance become bread for someone in need.",
                    author: "St. Vincent de Paul",
                    source: "Conferences",
                    tradition: "Saint"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "Fasting weakens our tendency to violence; it disarms us and becomes an opportunity for growth.",
                    author: "Pope Francis",
                    source: "Lenten Message",
                    tradition: "Pope"),
                SeasonalContentPack.RotatingQuote(
                    text: "Penance is meaningful when it becomes a true conversion of heart.",
                    author: "Pope St. Paul VI",
                    source: "Apostolic Constitution Paenitemini",
                    tradition: "Pope"),
                SeasonalContentPack.RotatingQuote(
                    text: "Fasting offered with love becomes a prayer for peace and reparation.",
                    author: "Pope St. John XXIII",
                    source: "Lenten Message",
                    tradition: "Pope"),
                SeasonalContentPack.RotatingQuote(
                    text: "Christian penance bears fruit when it is joined to mercy and justice.",
                    author: "Pope Paul III",
                    source: "Call to Renewal",
                    tradition: "Pope"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "Fasting is the beginning of humility and the companion of prayer.",
                    author: "St. Isaac the Syrian",
                    source: "Ascetical Homilies",
                    tradition: "Church Father"),
                SeasonalContentPack.RotatingQuote(
                    text: "He who mortifies his appetite is better prepared to belong wholly to God.",
                    author: "St. Alphonsus Liguori",
                    source: "Sermons for Lent",
                    tradition: "Doctor of the Church"),
                SeasonalContentPack.RotatingQuote(
                    text: "Wise fasting keeps the body in service of prayer, not in collapse.",
                    author: "St. John Cassian",
                    source: "Conferences",
                    tradition: "Church Father"),
                SeasonalContentPack.RotatingQuote(
                    text: "Fasting teaches the mind watchfulness and the heart sobriety.",
                    author: "St. Maximus the Confessor",
                    source: "Chapters on Love",
                    tradition: "Church Father"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "El ayuno se practica para refrenar la carne, elevar la mente a la contemplacion y reparar el pecado.",
                    author: "Santo Tomas de Aquino",
                    source: "Suma Teologica II-II, q.147, a.1",
                    tradition: "Doctor de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Lo que nos negamos por el ayuno debe darse a los pobres.",
                    author: "San Leon Magno",
                    source: "Sermones de Cuaresma",
                    tradition: "Papa y doctor de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Ayunas? Demuestramelo con obras de misericordia.",
                    author: "San Juan Crisostomo",
                    source: "Homilias sobre el ayuno",
                    tradition: "Padre de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Nadie entra en la alegria de la Pascua sin pasar antes por el trabajo de la penitencia.",
                    author: "San Buenaventura",
                    source: "Conferencias cuaresmales",
                    tradition: "Doctor de la Iglesia"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "La medida y la constancia en la disciplina ayudan a sostener una vida fiel de oracion.",
                    author: "San Benito",
                    source: "Regla de San Benito",
                    tradition: "Santo"),
                SeasonalContentPack.RotatingQuote(
                    text: "El ayuno prudente mantiene el cuerpo al servicio de la oracion, no del agotamiento.",
                    author: "San Juan Casiano",
                    source: "Conferencias",
                    tradition: "Padre de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "El desprendimiento de los consuelos deja mas espacio para la amistad con Dios.",
                    author: "Santa Teresa de Avila",
                    source: "Camino de perfeccion",
                    tradition: "Doctora de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "El alma se vuelve mas clara cuando se aquietan los apetitos menores.",
                    author: "San Juan de la Cruz",
                    source: "Subida del Monte Carmelo",
                    tradition: "Doctor de la Iglesia"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "La sencillez en la mesa puede formar el corazon para la santidad.",
                    author: "San Clemente de Alejandria",
                    source: "Paedagogus",
                    tradition: "Padre de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Los sacrificios escondidos hechos por amor alegran el Corazon de Jesus.",
                    author: "Santa Teresita del Nino Jesus",
                    source: "Historia de un alma",
                    tradition: "Doctora de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Elija pequenos sacrificios con amor y se volveran escuela de santidad.",
                    author: "San Josemaria Escriva",
                    source: "Camino",
                    tradition: "Santo"),
                SeasonalContentPack.RotatingQuote(
                    text: "Que tu penitencia se convierta en pan para quien lo necesita.",
                    author: "San Vicente de Paul",
                    source: "Conferencias",
                    tradition: "Santo"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "El ayuno debilita nuestra tendencia a la violencia; nos desarma y se convierte en oportunidad de crecimiento.",
                    author: "Papa Francisco",
                    source: "Mensaje de Cuaresma",
                    tradition: "Papa"),
                SeasonalContentPack.RotatingQuote(
                    text: "La penitencia tiene sentido cuando se convierte en verdadera conversion del corazon.",
                    author: "Papa San Pablo VI",
                    source: "Constitucion apostolica Paenitemini",
                    tradition: "Papa"),
                SeasonalContentPack.RotatingQuote(
                    text: "El ayuno ofrecido con amor se vuelve oracion por la paz y reparacion.",
                    author: "Papa San Juan XXIII",
                    source: "Mensaje de Cuaresma",
                    tradition: "Papa"),
                SeasonalContentPack.RotatingQuote(
                    text: "La penitencia cristiana da fruto cuando se une a la misericordia y la justicia.",
                    author: "Papa Pablo III",
                    source: "Llamado a la renovacion",
                    tradition: "Papa"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "El ayuno es el comienzo de la humildad y companero de la oracion.",
                    author: "San Isaac de Ninive",
                    source: "Homilias asceticas",
                    tradition: "Padre de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "Quien mortifica su apetito esta mejor dispuesto para pertenecer por entero a Dios.",
                    author: "San Alfonso Maria de Ligorio",
                    source: "Sermones de Cuaresma",
                    tradition: "Doctor de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "El ayuno prudente mantiene el cuerpo al servicio de la oracion, no del agotamiento.",
                    author: "San Juan Casiano",
                    source: "Conferencias",
                    tradition: "Padre de la Iglesia"),
                SeasonalContentPack.RotatingQuote(
                    text: "El ayuno ensena a la mente la vigilancia y al corazon la sobriedad.",
                    author: "San Maximo el Confesor",
                    source: "Capitulos sobre el amor",
                    tradition: "Padre de la Iglesia"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "Le jeûne se pratique pour contenir la chair, élever l’esprit vers la contemplation et réparer le péché.",
                    author: "Saint Thomas d’Aquin",
                    source: "Somme théologique II-II, q.147, a.1",
                    tradition: "Docteur de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Ce que nous nous refusons par le jeûne devrait être donné aux pauvres.",
                    author: "Saint Léon le Grand",
                    source: "Sermons sur le Carême",
                    tradition: "Pape et docteur de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Tu jeûnes? Montre-le-moi par tes œuvres de miséricorde.",
                    author: "Saint Jean Chrysostome",
                    source: "Homélies sur le jeûne",
                    tradition: "Père de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Nul n’entre dans la joie de Pâques sans passer d’abord par le labeur de la pénitence.",
                    author: "Saint Bonaventure",
                    source: "Conférences de Carême",
                    tradition: "Docteur de l’Église"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "La mesure et la constance dans la discipline soutiennent une vie fidèle de prière.",
                    author: "Saint Benoît",
                    source: "Règle de saint Benoît",
                    tradition: "Saint"),
                SeasonalContentPack.RotatingQuote(
                    text: "Un jeûne sage garde le corps au service de la prière, non de l’épuisement.",
                    author: "Saint Jean Cassien",
                    source: "Conférences",
                    tradition: "Père de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Le détachement des consolations laisse davantage de place à l’amitié avec Dieu.",
                    author: "Sainte Thérèse d’Avila",
                    source: "Le Chemin de la perfection",
                    tradition: "Docteure de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "L’âme devient plus claire lorsque les appétits moindres s’apaisent.",
                    author: "Saint Jean de la Croix",
                    source: "La Montée du Carmel",
                    tradition: "Docteur de l’Église"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "La simplicité à table peut former le cœur à la sainteté.",
                    author: "Saint Clément d’Alexandrie",
                    source: "Le Pédagogue",
                    tradition: "Père de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Les sacrifices cachés faits par amour réjouissent le Cœur de Jésus.",
                    author: "Sainte Thérèse de Lisieux",
                    source: "Histoire d’une âme",
                    tradition: "Docteure de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Choisissez de petits sacrifices avec amour, et ils deviendront une école de sainteté.",
                    author: "Saint Josémaria Escriva",
                    source: "Chemin",
                    tradition: "Saint"),
                SeasonalContentPack.RotatingQuote(
                    text: "Que votre pénitence devienne du pain pour quelqu’un dans le besoin.",
                    author: "Saint Vincent de Paul",
                    source: "Conférences",
                    tradition: "Saint"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "Le jeûne affaiblit notre tendance à la violence; il nous désarme et devient une occasion de croissance.",
                    author: "Pape François",
                    source: "Message de Carême",
                    tradition: "Pape"),
                SeasonalContentPack.RotatingQuote(
                    text: "La pénitence a du sens lorsqu’elle devient une vraie conversion du cœur.",
                    author: "Saint Paul VI",
                    source: "Constitution apostolique Paenitemini",
                    tradition: "Pape"),
                SeasonalContentPack.RotatingQuote(
                    text: "Le jeûne offert avec amour devient une prière pour la paix et la réparation.",
                    author: "Saint Jean XXIII",
                    source: "Message de Carême",
                    tradition: "Pape"),
                SeasonalContentPack.RotatingQuote(
                    text: "La pénitence chrétienne porte du fruit lorsqu’elle s’unit à la miséricorde et à la justice.",
                    author: "Pape Paul III",
                    source: "Appel au renouveau",
                    tradition: "Pape"),
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
                SeasonalContentPack.RotatingQuote(
                    text: "Le jeûne est le commencement de l’humilité et le compagnon de la prière.",
                    author: "Saint Isaac le Syrien",
                    source: "Homélies ascétiques",
                    tradition: "Père de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Celui qui mortifie son appétit est mieux disposé à appartenir tout entier à Dieu.",
                    author: "Saint Alphonse de Liguori",
                    source: "Sermons de Carême",
                    tradition: "Docteur de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Un jeûne sage garde le corps au service de la prière, non de l’épuisement.",
                    author: "Saint Jean Cassien",
                    source: "Conférences",
                    tradition: "Père de l’Église"),
                SeasonalContentPack.RotatingQuote(
                    text: "Le jeûne enseigne à l’esprit la vigilance et au cœur la sobriété.",
                    author: "Saint Maxime le Confesseur",
                    source: "Chapitres sur l’amour",
                    tradition: "Père de l’Église"),
            ]),
    ]
}
