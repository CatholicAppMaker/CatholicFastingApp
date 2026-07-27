import Foundation

/// Stable localization identifiers for content emitted by `ObservanceCalculator`.
///
/// The English title remains part of `Observance.id` for storage compatibility. Presentation
/// code resolves that title through this catalog instead of embedding calendar-generation rules
/// or relying on an incomplete switch in a view layer.
enum ObservanceLocalizationCatalog {
    static let titleDefaultsByIdentifier: [String: String] = [
        "all_saints": "All Saints",
        "ascension": "Ascension",
        "ash_wednesday": "Ash Wednesday",
        "assumption": "Assumption of the Blessed Virgin Mary",
        "baptism_of_the_lord": "The Baptism of the Lord",
        "blessed_francis_xavier_seelos": "Blessed Francis Xavier Seelos, Priest",
        "blessed_marie_rose_durocher": "Blessed Marie Rose Durocher, Virgin",
        "blessed_virgin_mary_mother_of_the_church": "Blessed Virgin Mary, Mother of the Church",
        "christmas": "Christmas",
        "easter_sunday": "Easter Sunday",
        "ember_day": "Ember Day",
        "epiphany": "Epiphany of the Lord",
        "friday_of_lent": "Friday of Lent",
        "friday_penance_outside_lent": "Friday Penance (Outside Lent)",
        "good_friday": "Good Friday",
        "holy_family": "The Holy Family of Jesus, Mary, and Joseph",
        "holy_guardian_angels": "The Holy Guardian Angels",
        "holy_thursday": "Holy Thursday (Evening Mass of the Lord's Supper)",
        "immaculate_conception": "Immaculate Conception",
        "immaculate_conception_transferred": "Immaculate Conception (Transferred)",
        "immaculate_heart_of_mary": "The Immaculate Heart of the Blessed Virgin Mary",
        "mary_mother_of_god": "Mary, Mother of God",
        "most_holy_body_and_blood_of_christ": "The Most Holy Body and Blood of Christ",
        "most_holy_trinity": "The Most Holy Trinity",
        "most_sacred_heart_of_jesus": "The Most Sacred Heart of Jesus",
        "nativity_of_saint_john_the_baptist": "The Nativity of Saint John the Baptist",
        "our_lady_of_guadalupe": "Our Lady of Guadalupe",
        "our_lady_of_sorrows": "Our Lady of Sorrows",
        "our_lady_of_the_rosary": "Our Lady of the Rosary",
        "our_lord_jesus_christ_king": "Our Lord Jesus Christ, King of the Universe",
        "palm_sunday": "Palm Sunday of the Passion of the Lord",
        "passion_of_saint_john_the_baptist": "The Passion of Saint John the Baptist",
        "pentecost": "Pentecost",
        "presentation_of_mary": "The Presentation of the Blessed Virgin Mary",
        "presentation_of_the_lord": "The Presentation of the Lord",
        "queenship_of_mary": "Queenship of the Blessed Virgin Mary",
        "saint_agatha": "Saint Agatha, Virgin and Martyr",
        "saint_agnes": "Saint Agnes, Virgin and Martyr",
        "saint_aloysius_gonzaga": "Saint Aloysius Gonzaga, Religious",
        "saint_alphonsus_liguori": "Saint Alphonsus Liguori, Bishop and Doctor",
        "saint_ambrose": "Saint Ambrose, Bishop and Doctor",
        "saint_andrew_dung_lac_and_companions": "Saint Andrew Dung-Lac, Priest, and Companions, Martyrs",
        "saint_andre_bessette": "Saint André Bessette, Religious",
        "saint_anthony_abbot": "Saint Anthony, Abbot",
        "saint_anthony_of_padua": "Saint Anthony of Padua, Priest and Doctor",
        "saint_athanasius": "Saint Athanasius, Bishop and Doctor",
        "saint_augustine": "Saint Augustine, Bishop and Doctor",
        "saint_barnabas": "Saint Barnabas, Apostle",
        "saint_benedict": "Saint Benedict, Abbot",
        "saint_bernard": "Saint Bernard, Abbot and Doctor",
        "saint_bonaventure": "Saint Bonaventure, Bishop and Doctor",
        "saint_boniface": "Saint Boniface, Bishop and Martyr",
        "saint_camillus_de_lellis": "Saint Camillus de Lellis, Priest",
        "saint_catherine_of_siena": "Saint Catherine of Siena, Virgin and Doctor",
        "saint_cecilia": "Saint Cecilia, Virgin and Martyr",
        "saint_charles_borromeo": "Saint Charles Borromeo, Bishop",
        "saint_clare": "Saint Clare, Virgin",
        "saint_damien_de_veuster": "Saint Damien de Veuster, Priest",
        "saint_dominic": "Saint Dominic, Priest",
        "saint_elizabeth_ann_seton": "Saint Elizabeth Ann Seton, Religious",
        "saint_elizabeth_of_hungary": "Saint Elizabeth of Hungary, Religious",
        "saint_elizabeth_of_portugal": "Saint Elizabeth of Portugal",
        "saint_frances_xavier_cabrini": "Saint Frances Xavier Cabrini, Virgin",
        "saint_francis_de_sales": "Saint Francis de Sales, Bishop and Doctor",
        "saint_francis_of_assisi": "Saint Francis of Assisi",
        "saint_francis_xavier": "Saint Francis Xavier, Priest",
        "saint_gregory_the_great": "Saint Gregory the Great, Pope and Doctor",
        "saint_ignatius_of_antioch": "Saint Ignatius of Antioch, Bishop and Martyr",
        "saint_ignatius_of_loyola": "Saint Ignatius of Loyola, Priest",
        "saint_irenaeus": "Saint Irenaeus, Bishop and Martyr",
        "saint_isidore": "Saint Isidore",
        "saint_jerome": "Saint Jerome, Priest and Doctor",
        "saint_john_bosco": "Saint John Bosco, Priest",
        "saint_john_chrysostom": "Saint John Chrysostom, Bishop and Doctor",
        "saint_john_henry_newman": "Saint John Henry Newman, Priest",
        "saint_john_neumann": "Saint John Neumann, Bishop",
        "saint_john_of_the_cross": "Saint John of the Cross, Priest and Doctor",
        "saint_john_vianney": "Saint John Vianney, Priest",
        "saint_josaphat": "Saint Josaphat, Bishop and Martyr",
        "saint_joseph_spouse_of_mary": "Saint Joseph, Spouse of the Blessed Virgin Mary",
        "saint_junipero_serra": "Saint Junípero Serra, Priest",
        "saint_justin": "Saint Justin, Martyr",
        "saint_kateri_tekakwitha": "Saint Kateri Tekakwitha, Virgin",
        "saint_katharine_drexel": "Saint Katharine Drexel, Virgin",
        "saint_leo_the_great": "Saint Leo the Great, Pope and Doctor",
        "saint_lucy": "Saint Lucy, Virgin and Martyr",
        "saint_marianne_cope": "Saint Marianne Cope, Virgin",
        "saint_martin_of_tours": "Saint Martin of Tours, Bishop",
        "saint_maximilian_kolbe": "Saint Maximilian Kolbe, Priest and Martyr",
        "saint_miguel_agustin_pro": "Saint Miguel Agustín Pro, Priest and Martyr",
        "saint_monica": "Saint Monica",
        "saint_patrick": "Saint Patrick, Bishop",
        "saint_paul_of_the_cross": "Saint Paul of the Cross, Priest",
        "saint_peter_claver": "Saint Peter Claver, Priest",
        "saint_philip_neri": "Saint Philip Neri, Priest",
        "saint_pius_of_pietrelcina": "Saint Pius of Pietrelcina, Priest",
        "saint_pius_x": "Saint Pius X, Pope",
        "saint_polycarp": "Saint Polycarp, Bishop and Martyr",
        "saint_rose_philippine_duchesne": "Saint Rose Philippine Duchesne, Virgin",
        "saint_scholastica": "Saint Scholastica, Virgin",
        "saint_teresa_of_calcutta": "Saint Teresa of Calcutta, Virgin",
        "saint_teresa_of_jesus": "Saint Teresa of Jesus, Virgin and Doctor",
        "saint_therese_of_the_child_jesus": "Saint Therese of the Child Jesus, Virgin and Doctor",
        "saint_thomas_aquinas": "Saint Thomas Aquinas, Priest and Doctor",
        "saint_vincent_de_paul": "Saint Vincent de Paul, Priest",
        "saints_andrew_kim_and_companions": "Saints Andrew Kim Tae-gon, Priest, and Companions, Martyrs",
        "saints_basil_and_gregory": "Saints Basil the Great and Gregory Nazianzen",
        "saints_charles_lwanga_and_companions": "Saints Charles Lwanga and Companions, Martyrs",
        "saints_cornelius_and_cyprian": "Saints Cornelius, Pope, and Cyprian, Bishop",
        "saints_cyril_and_methodius": "Saints Cyril, Monk, and Methodius, Bishop",
        "saints_joachim_and_anne": "Saints Joachim and Anne",
        "saints_john_brebeuf_isaac_jogues_and_companions": "Saints John de Brébeuf and Isaac Jogues, Priests, and Companions, Martyrs",
        "saints_martha_mary_and_lazarus": "Saints Martha, Mary, and Lazarus",
        "saints_paul_miki_and_companions": "Saints Paul Miki and Companions, Martyrs",
        "saints_perpetua_and_felicity": "Saints Perpetua and Felicity, Martyrs",
        "saints_peter_and_paul": "Saints Peter and Paul, Apostles",
        "saints_timothy_and_titus": "Saints Timothy and Titus, Bishops",
        "the_annunciation": "The Annunciation of the Lord",
        "the_exaltation_of_the_holy_cross": "The Exaltation of the Holy Cross",
        "transfiguration": "The Transfiguration of the Lord",
    ]

    static let detailDefaultsByIdentifier: [String: String] = [
        "abstinence_meat_required_fast_age_exempt": "Abstinence from meat is required. Fasting does not bind for your age profile.",
        "age_not_required": "Not required for your age eligibility toggle settings.",
        "ascension_canada":
            "Ascension observance in Canada depends on the liturgical calendar in force locally. "
            + "This release treats the day as informational unless a fully modeled local obligation is known.",
        "ascension_other": "Ascension observance varies by conference and local law. This release treats the day as informational outside the U.S. profile.",
        "ascension_us": "Observed on Thursday or transferred to Sunday by province; obligation depends on local observance rules.",
        "canada_ascension_celebration": "Observed on Sunday in the Canada national baseline and shown here as a celebration rather than a separate weekday holy day obligation.",
        "canada_holy_day": "Holy Day of Obligation in the Canada national baseline. The app models the Canada-wide obligation and keeps diocesan proper calendars separate.",
        "canada_holy_day_context": "Celebration included for Canada-wide planning in the national baseline. It is not treated as a separate weekday holy day obligation here.",
        "canada_liturgical_planning": "Included for Canada-wide devotional planning in the national baseline. Diocesan proper calendars may add local celebrations.",
        "canada_memorial": "Memorial included for Canada-wide liturgical awareness in the national baseline. Diocesan proper calendars may differ.",
        "ember_traditional": "Traditional calendar mode: Ember day of prayer, fasting, and abstinence.",
        "ember_us_optional": "Optional observance in U.S. profile mode.",
        "dispensation_enabled": "Dispensation enabled in your profile. Follow your pastor and medical guidance.",
        "fast_age_rule": "For ages 18-59: one full meal and two smaller meals (not equal to a second full meal).",
        "friday_canada_abstain": "In Canada, Friday remains penitential throughout the year. You chose abstinence from meat for your Friday practice.",
        "friday_canada_substitute": "In Canada, Friday remains penitential throughout the year. You chose another act of charity or piety for your Friday practice.",
        "friday_other": "Friday remains penitential outside Lent, but the exact practice depends on local Church law.",
        "friday_us_abstain": "Outside Lent: abstain from meat as your Friday penance.",
        "friday_us_substitute": "Outside Lent: choose a penitential act (e.g., extra prayer, charity, or another sacrifice).",
        "local_calendar_context": "Shown for Catholic devotional planning. Local calendars may add or vary celebrations.",
        "local_holy_day_context": "Listed for planning context. Holy day obligations vary by episcopal conference and local law outside the U.S. profile.",
        "local_memorial": "Memorial included for liturgical awareness. Local calendars may differ.",
        "no_meat": "No meat from mammals or poultry.",
        "medical_not_required": "Not required due to medical dispensation setting.",
        "us_holy_day": "Holy Day of Obligation in the U.S.",
        "us_holy_day_abrogated": "In U.S. norms, obligation may be abrogated this year because this holy day falls on Saturday or Monday.",
        "us_holy_day_local_directives": "Holy Day of Obligation in the U.S., subject to local episcopal conference directives.",
        "us_immaculate_conception_transferred": "Transferred from Sunday, December 8. In U.S. usage, the Mass obligation does not transfer to Monday.",
        "us_liturgical_planning": "Included from the liturgical calendar used for U.S. devotional planning.",
        "us_memorial": "Memorial included for liturgical awareness in the U.S. calendar profile.",
        "us_proper": "U.S. Proper Calendar celebration day.",
        "us_proper_emendation": "U.S. Proper Calendar celebration day (emendation).",
    ]

    static let rationaleDefaultsByIdentifier: [String: String] = [
        "abstinence_lent": "Fridays in Lent are days of abstinence for those bound by age and health norms.",
        "abstinence_required_format": "%@ requires abstinence for those bound by age and health norms.",
        "ember_optional": "Ember days are optional in this mode and offered as devotional practice.",
        "fast_not_binding_format": "%@ is listed, but your profile indicates the obligation does not strictly bind.",
        "fast_required_format": "%@ is a universal fast/abstinence day for the Latin Church in this profile.",
        "feast_celebration": "Celebrate this feast day; it is not a fasting obligation.",
        "friday_canada": "Outside Lent Friday penance follows CCCB guidance: Friday remains penitential, with abstinence or another act of charity or piety.",
        "friday_other": "Outside Lent Friday penance depends on local episcopal law and pastoral guidance.",
        "friday_us": "Outside Lent Friday penance follows your selected U.S. profile mode.",
        "holy_day_canada": "Holy day obligation is modeled for the Canada national baseline. Diocesan proper calendars are not included in this release.",
        "holy_day_other": "Holy day listing is informational outside the U.S. profile unless local law is known.",
        "holy_day_us": "Holy day obligation may vary by universal, national, and local norms.",
        "memorial_celebration": "Celebrate this memorial day; it is not a fasting obligation.",
    ]

    private static let titleIdentifiersByDefault = inverted(titleDefaultsByIdentifier)
    private static let detailIdentifiersByDefault = inverted(detailDefaultsByIdentifier)
    private static let rationaleIdentifiersByDefault = inverted(rationaleDefaultsByIdentifier)

    static func titleIdentifier(for defaultValue: String) -> String? {
        titleIdentifiersByDefault[defaultValue]
    }

    static func localizedCurrentTitle(_ title: String) -> String {
        guard let identifier = titleIdentifier(for: title) else { return title }
        return CoreLocalizer.localizedCurrent(
            ["observance", "title", identifier].joined(separator: "."),
            default: title)
    }

    static func detailIdentifier(for defaultValue: String) -> String? {
        detailIdentifiersByDefault[defaultValue]
    }

    static func rationaleIdentifier(for defaultValue: String) -> String? {
        if rationaleIdentifiersByDefault[defaultValue] != nil {
            return rationaleIdentifiersByDefault[defaultValue]
        }
        if defaultValue.hasSuffix(" is a universal fast/abstinence day for the Latin Church in this profile.") {
            return "fast_required_format"
        }
        if defaultValue.hasSuffix(" is listed, but your profile indicates the obligation does not strictly bind.") {
            return "fast_not_binding_format"
        }
        if defaultValue.hasSuffix(" requires abstinence for those bound by age and health norms.") {
            return "abstinence_required_format"
        }
        return nil
    }

    private static func inverted(_ values: [String: String]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: values.map { ($0.value, $0.key) })
    }
}
