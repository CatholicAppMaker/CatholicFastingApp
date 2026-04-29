@preconcurrency import Foundation

// swiftlint:disable line_length

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

        if let article = catalog[eraID] {
            return article
        }

        assertionFailure("Missing fasting history article for \(locale.rawValue) \(eraID.rawValue)")
        return english[eraID] ?? fallbackArticle(for: eraID, locale: locale)
    }

    private static func fallbackArticle(
        for eraID: FastingHistoryEraID,
        locale: ContentLocale) -> FastingHistoryArticle
    {
        FastingHistoryArticle(
            eraID: eraID,
            locale: locale,
            title: "History of Fasting",
            dateRange: "",
            summary: "This history article is temporarily unavailable.",
            body: "This history article is temporarily unavailable.",
            sourceNotes: [
                FastingHistorySourceNote(
                    title: "Catholic Fasting",
                    detail: "Fallback content shown because the local history catalog is incomplete."),
            ])
    }

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
