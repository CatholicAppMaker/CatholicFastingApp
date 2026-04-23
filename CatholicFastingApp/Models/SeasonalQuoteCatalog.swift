@preconcurrency import Foundation

// swiftlint:disable file_length

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

enum FastingHistoryEraID: String, CaseIterable, Identifiable {
    case earlyChurch
    case medieval
    case tridentine
    case preConciliar
    case postVaticanII

    var id: String {
        rawValue
    }
}

struct FastingHistorySourceNote: Hashable {
    let title: String
    let detail: String
}

struct FastingHistoryArticle: Identifiable, Hashable {
    let eraID: FastingHistoryEraID
    let locale: ContentLocale
    let title: String
    let dateRange: String
    let summary: String
    let body: String
    let sourceNotes: [FastingHistorySourceNote]

    var id: String {
        "\(locale.rawValue)-\(eraID.rawValue)"
    }
}

enum FastingHistoryCatalog {
    static let isPremiumFeature = false

    static func articles(locale: ContentLocale) -> [FastingHistoryArticle] {
        FastingHistoryEraID.allCases.map { article(for: $0, locale: locale) }
    }

    static func article(for eraID: FastingHistoryEraID, locale: ContentLocale) -> FastingHistoryArticle {
        let catalog = switch locale {
        case .english:
            english
        case .spanish:
            spanish
        case .frenchCanadian:
            frenchCanadian
        }

        guard let article = catalog[eraID] else {
            preconditionFailure("Missing fasting history article for \(locale.rawValue) \(eraID.rawValue)")
        }
        return article
    }

    // swiftlint:disable line_length
    private static let english: [FastingHistoryEraID: FastingHistoryArticle] = [
        .earlyChurch: FastingHistoryArticle(
            eraID: .earlyChurch,
            locale: .english,
            title: "Early Church foundations",
            dateRange: "1st-5th centuries",
            summary: "Fasting appears early as a weekly discipline, a preparation for baptism, and a way to join prayer with mercy.",
            body: """
            The earliest Christian fasting was not a single universal schedule. It grew from Jewish patterns of prayer and fasting, the example of Christ in the desert, and the Church's habit of preparing for solemn worship with bodily discipline.

            Early witnesses describe Christians fasting on particular weekdays, before baptism, and in connection with prayer for the needy. By the fourth and fifth centuries, Lent was becoming a recognizable season of preparation for Easter, though its length and exact customs varied by region.

            Eastern and Western churches already showed different rhythms. Both treated fasting as serious formation, but local churches differed in how many days were kept, how strictly food was limited, and how fasting related to almsgiving and catechesis.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Didache", detail: "Early Christian witness to weekly fasting days and communal discipline."),
                FastingHistorySourceNote(title: "St. Augustine", detail: "Notes regional diversity in fasting customs while defending unity in charity."),
                FastingHistorySourceNote(title: "Council of Nicaea", detail: "Shows Lent and Easter preparation becoming part of wider ecclesial order."),
            ]),
        .medieval: FastingHistoryArticle(
            eraID: .medieval,
            locale: .english,
            title: "Medieval development",
            dateRange: "6th-15th centuries",
            summary: "Medieval discipline became more structured, with Lent, Ember Days, vigils, and abstinence forming a shared penitential calendar.",
            body: """
            In the medieval West, fasting became more calendar-shaped. Lent held the central place, but Ember Days, Rogation days, vigils, and Fridays also carried penitential meaning. Abstinence from meat often stood alongside fasting from full meals.

            Monastic rules strongly influenced ordinary Catholic imagination. The discipline was not only about food; it trained obedience, humility, and solidarity with the poor. The exact burden varied by class, health, labor, and local custom, so pastoral judgment remained important.

            Eastern Christian churches continued developing stricter and more numerous fasting seasons than the Latin West. The shared root was ascetic preparation for prayer, but the calendars and food rules were not identical.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Rule of St. Benedict", detail: "Shows monastic fasting as ordered, communal discipline."),
                FastingHistorySourceNote(title: "Medieval penitentials", detail: "Witness regional detail around fasting, abstinence, and penance."),
                FastingHistorySourceNote(title: "St. Thomas Aquinas", detail: "Explains fasting as a virtue-serving act ordered toward prayer and restraint."),
            ]),
        .tridentine: FastingHistoryArticle(
            eraID: .tridentine,
            locale: .english,
            title: "Early modern and Tridentine discipline",
            dateRange: "16th-18th centuries",
            summary: "After Trent, Catholic discipline emphasized visible penitential practice, catechesis, and obedience to Church authority.",
            body: """
            The early modern period did not invent Catholic fasting, but it gave the practice sharper confessional visibility. In the wake of the Reformation, fasting and abstinence were taught as concrete acts of penance, obedience, and Catholic identity.

            Local calendars still mattered, but the Latin Church increasingly expressed fasting through a recognizable network of Lent, vigils, Ember Days, and meatless days. Dispensations were also part of the system, especially where health, poverty, climate, or labor made the full rule imprudent.

            The Tridentine era reminds modern readers that fasting was never merely a private wellness exercise. It was a public ecclesial discipline meant to shape repentance, worship, and charity.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Council of Trent", detail: "Reinforced sacramental penance and ecclesial discipline in Catholic life."),
                FastingHistorySourceNote(title: "Roman Catechism", detail: "Connects penance, discipline, and conversion in post-Tridentine catechesis."),
                FastingHistorySourceNote(title: "Local diocesan statutes", detail: "Show how universal discipline was applied through local calendars and dispensations."),
            ]),
        .preConciliar: FastingHistoryArticle(
            eraID: .preConciliar,
            locale: .english,
            title: "Pre-conciliar to mid-20th-century discipline",
            dateRange: "19th century-1965",
            summary: "The modern Latin discipline became codified and then gradually simplified before the post-conciliar reform.",
            body: """
            By the nineteenth and early twentieth centuries, Latin Catholic fasting and abstinence were highly structured. The 1917 Code of Canon Law preserved a broad penitential pattern, including fasting days, abstinence days, vigils, and seasonal observances.

            During the twentieth century, popes and bishops adjusted the discipline for changing circumstances. Eucharistic fasting was shortened, local dispensations became more common, and the burden of the calendar was gradually simplified.

            This period is important because many Catholics remember or inherit stories from it. Those memories are real, but they do not always describe the current law. The app keeps this history separate from today's rules for that reason.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "1917 Code of Canon Law", detail: "Codified fasting and abstinence obligations in the Latin Church."),
                FastingHistorySourceNote(title: "Pius XII reforms", detail: "Adjusted Eucharistic fasting and Holy Week practice in the mid-20th century."),
                FastingHistorySourceNote(title: "Mid-century episcopal norms", detail: "Show increased reliance on local application and dispensations."),
            ]),
        .postVaticanII: FastingHistoryArticle(
            eraID: .postVaticanII,
            locale: .english,
            title: "Post-Vatican II to current Latin Church practice",
            dateRange: "1966-present",
            summary: "Current Latin practice keeps fasting and abstinence, but with fewer universal days and more responsibility placed on local bishops.",
            body: """
            In 1966, Pope Paul VI's Paenitemini reframed penitential discipline for the modern Latin Church. Fasting and abstinence remained important, but the universal burden was simplified and episcopal conferences received a larger role in applying penitential practice locally.

            The 1983 Code of Canon Law continues to teach all the faithful to do penance. It names Fridays and Lent as penitential times, sets universal norms for fasting and abstinence, and allows conferences of bishops to determine more particular applications.

            For current practice, Catholics should follow the binding norms of their Church and region. This history explains how the discipline developed; Guidance and Rules remains the place for today's practical requirements.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Paenitemini", detail: "Paul VI's 1966 apostolic constitution on fasting and abstinence."),
                FastingHistorySourceNote(title: "1983 Code of Canon Law", detail: "Canons 1249-1253 state current Latin Church penitential norms."),
                FastingHistorySourceNote(title: "Episcopal conference norms", detail: "Local bishops apply universal law through regional guidance."),
            ]),
    ]

    private static let spanish: [FastingHistoryEraID: FastingHistoryArticle] = [
        .earlyChurch: FastingHistoryArticle(
            eraID: .earlyChurch,
            locale: .spanish,
            title: "Fundamentos de la Iglesia primitiva",
            dateRange: "Siglos I-V",
            summary: "El ayuno aparece pronto como disciplina semanal, preparación bautismal y forma de unir oración y misericordia.",
            body: """
            El ayuno cristiano más antiguo no tuvo un único calendario universal. Creció desde patrones judíos de oración y ayuno, desde el ejemplo de Cristo en el desierto y desde la costumbre de prepararse para el culto solemne con disciplina corporal.

            Los primeros testimonios describen cristianos que ayunaban ciertos días de la semana, antes del bautismo y junto con la oración por los necesitados. Para los siglos IV y V, la Cuaresma ya se reconocía como preparación para la Pascua, aunque su duración y sus costumbres variaban por región.

            Las Iglesias de Oriente y Occidente ya mostraban ritmos distintos. Ambas tomaban el ayuno como formación seria, pero las iglesias locales diferían en días, exigencia alimentaria y relación con limosna y catequesis.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Didaché", detail: "Testimonio temprano de días semanales de ayuno y disciplina comunitaria."),
                FastingHistorySourceNote(title: "San Agustín", detail: "Reconoce diversidad regional en las costumbres de ayuno y defiende la unidad en la caridad."),
                FastingHistorySourceNote(title: "Concilio de Nicea", detail: "Muestra la preparación cuaresmal y pascual dentro de un orden eclesial más amplio."),
            ]),
        .medieval: FastingHistoryArticle(
            eraID: .medieval,
            locale: .spanish,
            title: "Desarrollo medieval",
            dateRange: "Siglos VI-XV",
            summary: "La disciplina medieval se hizo más estructurada: Cuaresma, témporas, vigilias y abstinencia formaron un calendario penitencial compartido.",
            body: """
            En el Occidente medieval, el ayuno tomó una forma más marcada por el calendario. La Cuaresma ocupaba el centro, pero las témporas, rogativas, vigilias y viernes también tenían sentido penitencial. La abstinencia de carne solía acompañar al ayuno de comidas completas.

            Las reglas monásticas influyeron mucho en la imaginación católica común. La disciplina no trataba solo de alimentos; formaba obediencia, humildad y solidaridad con los pobres. La carga concreta variaba según clase social, salud, trabajo y costumbre local, por lo que el juicio pastoral seguía siendo importante.

            Las Iglesias cristianas orientales continuaron desarrollando temporadas de ayuno más estrictas y numerosas que las del Occidente latino. La raíz compartida era la preparación ascética para la oración, pero los calendarios y las reglas alimentarias no eran idénticos.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Regla de san Benito", detail: "Muestra el ayuno monástico como disciplina ordenada y comunitaria."),
                FastingHistorySourceNote(title: "Penitenciales medievales", detail: "Dan testimonio de detalles regionales sobre ayuno, abstinencia y penitencia."),
                FastingHistorySourceNote(title: "Santo Tomás de Aquino", detail: "Explica el ayuno como acto al servicio de la virtud, la oración y el dominio propio."),
            ]),
        .tridentine: FastingHistoryArticle(
            eraID: .tridentine,
            locale: .spanish,
            title: "Disciplina moderna temprana y tridentina",
            dateRange: "Siglos XVI-XVIII",
            summary: "Después de Trento, la disciplina católica destacó la práctica penitencial visible, la catequesis y la obediencia a la autoridad de la Iglesia.",
            body: """
            La época moderna temprana no inventó el ayuno católico, pero hizo la práctica más visible confesionalmente. Después de la Reforma, el ayuno y la abstinencia se enseñaron como actos concretos de penitencia, obediencia e identidad católica.

            Los calendarios locales seguían importando, pero la Iglesia latina expresaba cada vez más el ayuno mediante una red reconocible de Cuaresma, vigilias, témporas y días sin carne. Las dispensas también formaban parte del sistema, especialmente cuando salud, pobreza, clima o trabajo hacían imprudente la regla completa.

            La época tridentina recuerda al lector moderno que el ayuno nunca fue solo una práctica privada de bienestar. Era una disciplina eclesial pública destinada a formar arrepentimiento, culto y caridad.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Concilio de Trento", detail: "Reforzó la penitencia sacramental y la disciplina eclesial en la vida católica."),
                FastingHistorySourceNote(title: "Catecismo Romano", detail: "Relaciona penitencia, disciplina y conversión en la catequesis postridentina."),
                FastingHistorySourceNote(title: "Estatutos diocesanos locales", detail: "Muestran cómo la disciplina universal se aplicaba mediante calendarios y dispensas locales."),
            ]),
        .preConciliar: FastingHistoryArticle(
            eraID: .preConciliar,
            locale: .spanish,
            title: "Del periodo preconciliar a mediados del siglo XX",
            dateRange: "Siglo XIX-1965",
            summary: "La disciplina latina moderna se codificó y luego se simplificó gradualmente antes de la reforma posconciliar.",
            body: """
            Para los siglos XIX y XX, el ayuno y la abstinencia en la Iglesia latina estaban muy estructurados. El Código de Derecho Canónico de 1917 conservó un patrón penitencial amplio, con días de ayuno, días de abstinencia, vigilias y observancias estacionales.

            Durante el siglo XX, papas y obispos ajustaron la disciplina a circunstancias cambiantes. El ayuno eucarístico se acortó, las dispensas locales se hicieron más comunes y la carga del calendario se simplificó gradualmente.

            Este periodo importa porque muchos católicos lo recuerdan o reciben relatos familiares sobre él. Esos recuerdos son reales, pero no siempre describen la ley actual. Por eso la app mantiene esta historia separada de las reglas de hoy.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Código de Derecho Canónico de 1917", detail: "Codificó obligaciones de ayuno y abstinencia en la Iglesia latina."),
                FastingHistorySourceNote(title: "Reformas de Pío XII", detail: "Ajustaron el ayuno eucarístico y la Semana Santa a mediados del siglo XX."),
                FastingHistorySourceNote(title: "Normas episcopales de mediados de siglo", detail: "Muestran mayor recurso a la aplicación local y a las dispensas."),
            ]),
        .postVaticanII: FastingHistoryArticle(
            eraID: .postVaticanII,
            locale: .spanish,
            title: "Del Vaticano II a la práctica latina actual",
            dateRange: "1966-presente",
            summary: "La práctica latina actual conserva ayuno y abstinencia, pero con menos días universales y más responsabilidad para los obispos locales.",
            body: """
            En 1966, la Paenitemini de Pablo VI replanteó la disciplina penitencial para la Iglesia latina moderna. El ayuno y la abstinencia siguieron siendo importantes, pero la carga universal se simplificó y las conferencias episcopales recibieron un papel mayor en la aplicación local.

            El Código de Derecho Canónico de 1983 sigue enseñando que todos los fieles deben hacer penitencia. Nombra los viernes y la Cuaresma como tiempos penitenciales, establece normas universales de ayuno y abstinencia, y permite que las conferencias episcopales determinen aplicaciones particulares.

            Para la práctica actual, los católicos deben seguir las normas obligatorias de su Iglesia y región. Esta historia explica cómo se desarrolló la disciplina; Guía y reglas sigue siendo el lugar para los requisitos prácticos de hoy.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Paenitemini", detail: "Constitución apostólica de Pablo VI de 1966 sobre ayuno y abstinencia."),
                FastingHistorySourceNote(title: "Código de Derecho Canónico de 1983", detail: "Los cánones 1249-1253 establecen normas penitenciales latinas actuales."),
                FastingHistorySourceNote(title: "Normas de las conferencias episcopales", detail: "Los obispos locales aplican la ley universal mediante orientación regional."),
            ]),
    ]

    private static let frenchCanadian: [FastingHistoryEraID: FastingHistoryArticle] = [
        .earlyChurch: FastingHistoryArticle(
            eraID: .earlyChurch,
            locale: .frenchCanadian,
            title: "Fondements de l'Église primitive",
            dateRange: "Ier-Ve siècles",
            summary: "Le jeûne apparaît tôt comme discipline hebdomadaire, préparation au baptême et manière d'unir prière et miséricorde.",
            body: """
            Le jeûne chrétien le plus ancien n'avait pas un calendrier universel unique. Il a grandi à partir de pratiques juives de prière et de jeûne, de l'exemple du Christ au désert et de l'habitude de se préparer au culte solennel par une discipline corporelle.

            Les premiers témoins décrivent des chrétiens qui jeûnent certains jours de la semaine, avant le baptême et en lien avec la prière pour les pauvres. Aux IVe et Ve siècles, le Carême devient une préparation reconnaissable à Pâques, même si sa durée et ses coutumes varient selon les régions.

            Les Églises d'Orient et d'Occident montrent déjà des rythmes différents. Toutes deux prennent le jeûne comme une formation sérieuse, mais les Églises locales diffèrent par les jours, la rigueur alimentaire et le lien avec l'aumône et la catéchèse.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Didachè", detail: "Témoin ancien de jours hebdomadaires de jeûne et de discipline communautaire."),
                FastingHistorySourceNote(title: "Saint Augustin", detail: "Reconnaît la diversité régionale des coutumes de jeûne tout en défendant l'unité dans la charité."),
                FastingHistorySourceNote(title: "Concile de Nicée", detail: "Montre la préparation au Carême et à Pâques dans un ordre ecclésial plus large."),
            ]),
        .medieval: FastingHistoryArticle(
            eraID: .medieval,
            locale: .frenchCanadian,
            title: "Développement médiéval",
            dateRange: "VIe-XVe siècles",
            summary: "La discipline médiévale devient plus structurée : Carême, Quatre-Temps, vigiles et abstinence forment un calendrier pénitentiel partagé.",
            body: """
            Dans l'Occident médiéval, le jeûne prend une forme plus liée au calendrier. Le Carême occupe la place centrale, mais les Quatre-Temps, les Rogations, les vigiles et les vendredis portent aussi un sens pénitentiel. L'abstinence de viande accompagne souvent le jeûne de repas complets.

            Les règles monastiques influencent fortement l'imaginaire catholique ordinaire. La discipline ne concerne pas seulement la nourriture; elle forme l'obéissance, l'humilité et la solidarité avec les pauvres. La charge concrète varie selon la condition sociale, la santé, le travail et la coutume locale, de sorte que le jugement pastoral demeure important.

            Les Églises chrétiennes orientales continuent de développer des saisons de jeûne plus strictes et plus nombreuses que l'Occident latin. La racine commune est la préparation ascétique à la prière, mais les calendriers et les règles alimentaires ne sont pas identiques.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Règle de saint Benoît", detail: "Montre le jeûne monastique comme discipline ordonnée et communautaire."),
                FastingHistorySourceNote(title: "Pénitentiels médiévaux", detail: "Témoignent de détails régionaux sur le jeûne, l'abstinence et la pénitence."),
                FastingHistorySourceNote(title: "Saint Thomas d'Aquin", detail: "Explique le jeûne comme un acte au service de la vertu, de la prière et de la maîtrise de soi."),
            ]),
        .tridentine: FastingHistoryArticle(
            eraID: .tridentine,
            locale: .frenchCanadian,
            title: "Discipline moderne et tridentine",
            dateRange: "XVIe-XVIIIe siècles",
            summary: "Après Trente, la discipline catholique met l'accent sur la pratique pénitentielle visible, la catéchèse et l'obéissance à l'autorité de l'Église.",
            body: """
            L'époque moderne n'invente pas le jeûne catholique, mais elle rend la pratique plus visible comme marque catholique. Après la Réforme, le jeûne et l'abstinence sont enseignés comme des actes concrets de pénitence, d'obéissance et d'identité catholique.

            Les calendriers locaux demeurent importants, mais l'Église latine exprime de plus en plus le jeûne par un réseau reconnaissable : Carême, vigiles, Quatre-Temps et jours sans viande. Les dispenses font aussi partie du système, surtout lorsque la santé, la pauvreté, le climat ou le travail rendent la règle complète imprudente.

            L'époque tridentine rappelle au lecteur moderne que le jeûne n'a jamais été seulement une pratique privée de mieux-être. C'était une discipline ecclésiale publique destinée à former le repentir, le culte et la charité.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Concile de Trente", detail: "Renforce la pénitence sacramentelle et la discipline ecclésiale dans la vie catholique."),
                FastingHistorySourceNote(title: "Catéchisme romain", detail: "Relie pénitence, discipline et conversion dans la catéchèse post-tridentine."),
                FastingHistorySourceNote(title: "Statuts diocésains locaux", detail: "Montrent comment la discipline universelle est appliquée par calendriers et dispenses locales."),
            ]),
        .preConciliar: FastingHistoryArticle(
            eraID: .preConciliar,
            locale: .frenchCanadian,
            title: "Du préconcile au milieu du XXe siècle",
            dateRange: "XIXe siècle-1965",
            summary: "La discipline latine moderne se codifie, puis se simplifie graduellement avant la réforme postconciliaire.",
            body: """
            Aux XIXe et XXe siècles, le jeûne et l'abstinence dans l'Église latine sont très structurés. Le Code de droit canonique de 1917 conserve un large modèle pénitentiel, avec jours de jeûne, jours d'abstinence, vigiles et observances saisonnières.

            Au cours du XXe siècle, les papes et les évêques ajustent la discipline aux circonstances changeantes. Le jeûne eucharistique est raccourci, les dispenses locales deviennent plus courantes et la charge du calendrier se simplifie graduellement.

            Cette période compte parce que beaucoup de catholiques s'en souviennent ou en héritent par des récits familiaux. Ces souvenirs sont réels, mais ils ne décrivent pas toujours la loi actuelle. L'application garde donc cette histoire séparée des règles d'aujourd'hui.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Code de droit canonique de 1917", detail: "Codifie les obligations de jeûne et d'abstinence dans l'Église latine."),
                FastingHistorySourceNote(title: "Réformes de Pie XII", detail: "Ajustent le jeûne eucharistique et la Semaine sainte au milieu du XXe siècle."),
                FastingHistorySourceNote(title: "Normes épiscopales du milieu du siècle", detail: "Montrent un recours accru à l'application locale et aux dispenses."),
            ]),
        .postVaticanII: FastingHistoryArticle(
            eraID: .postVaticanII,
            locale: .frenchCanadian,
            title: "De Vatican II à la pratique latine actuelle",
            dateRange: "1966-aujourd'hui",
            summary: "La pratique latine actuelle garde le jeûne et l'abstinence, avec moins de jours universels et plus de responsabilité pour les évêques locaux.",
            body: """
            En 1966, Paenitemini de Paul VI reformule la discipline pénitentielle pour l'Église latine moderne. Le jeûne et l'abstinence demeurent importants, mais la charge universelle est simplifiée et les conférences épiscopales reçoivent un plus grand rôle dans l'application locale.

            Le Code de droit canonique de 1983 continue d'enseigner que tous les fidèles doivent faire pénitence. Il nomme les vendredis et le Carême comme temps pénitentiels, fixe des normes universelles de jeûne et d'abstinence, et permet aux conférences épiscopales de déterminer des applications particulières.

            Pour la pratique actuelle, les catholiques doivent suivre les normes obligatoires de leur Église et de leur région. Cette histoire explique le développement de la discipline; Conseils et règles demeure l'endroit pour les exigences pratiques d'aujourd'hui.
            """,
            sourceNotes: [
                FastingHistorySourceNote(title: "Paenitemini", detail: "Constitution apostolique de Paul VI en 1966 sur le jeûne et l'abstinence."),
                FastingHistorySourceNote(title: "Code de droit canonique de 1983", detail: "Les canons 1249-1253 énoncent les normes pénitentielles latines actuelles."),
                FastingHistorySourceNote(title: "Normes des conférences épiscopales", detail: "Les évêques locaux appliquent la loi universelle par des directives régionales."),
            ]),
    ]
}

// swiftlint:enable line_length

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
        guard let fallbackPack = packs[.ordinary] else {
            preconditionFailure("Seasonal content catalog is missing ordinary time for \(locale.rawValue)")
        }
        return packs[season] ?? fallbackPack
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
