import SwiftUI
import WidgetKit

private struct WidgetSnapshot: Decodable {
    let generatedAt: Date
    let todayTitle: String
    let todayObligation: String
    let nextRequiredTitle: String
    let nextRequiredDate: Date?
    let completionRate: Double
    let hasActiveIntermittentFast: Bool
    let activeIntermittentFastStart: Date?
    let activeIntermittentTargetHours: Int
    let premiumMotivationLine: String

    enum CodingKeys: String, CodingKey {
        case generatedAt
        case todayTitle
        case todayObligation
        case nextRequiredTitle
        case nextRequiredDate
        case completionRate
        case hasActiveIntermittentFast
        case activeIntermittentFastStart
        case activeIntermittentTargetHours
        case premiumMotivationLine
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        generatedAt = try container.decode(Date.self, forKey: .generatedAt)
        todayTitle = try container.decode(String.self, forKey: .todayTitle)
        todayObligation = try container.decode(String.self, forKey: .todayObligation)
        nextRequiredTitle = try container.decode(String.self, forKey: .nextRequiredTitle)
        nextRequiredDate = try container.decodeIfPresent(Date.self, forKey: .nextRequiredDate)
        completionRate = try container.decode(Double.self, forKey: .completionRate)
        hasActiveIntermittentFast = try container.decode(Bool.self, forKey: .hasActiveIntermittentFast)
        activeIntermittentFastStart = try container.decodeIfPresent(Date.self, forKey: .activeIntermittentFastStart)
        activeIntermittentTargetHours = try container.decode(Int.self, forKey: .activeIntermittentTargetHours)
        premiumMotivationLine =
            try container.decodeIfPresent(String.self, forKey: .premiumMotivationLine)
                ?? "Stay faithful in small daily disciplines."
    }
}

private struct FastingEntry: TimelineEntry {
    let date: Date
    let todayTitle: String
    let todayObligation: String
    let nextRequiredTitle: String
    let nextRequiredDate: Date?
    let completionRate: Double
    let hasActiveIntermittentFast: Bool
    let premiumMotivationLine: String
}

private struct Provider: TimelineProvider {
    private let appGroup = "group.com.kevpierce.CatholicFastingApp"
    private let snapshotKey = "widget_snapshot"

    func placeholder(in _: Context) -> FastingEntry {
        fallbackEntry
    }

    func getSnapshot(in _: Context, completion: @escaping (FastingEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<FastingEntry>) -> Void) {
        let entry = loadEntry()
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func loadEntry() -> FastingEntry {
        guard
            let defaults = UserDefaults(suiteName: appGroup),
            let data = defaults.data(forKey: snapshotKey),
            let snapshot = try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
        else {
            return fallbackEntry
        }

        return FastingEntry(
            date: snapshot.generatedAt,
            todayTitle: snapshot.todayTitle,
            todayObligation: snapshot.todayObligation,
            nextRequiredTitle: snapshot.nextRequiredTitle,
            nextRequiredDate: snapshot.nextRequiredDate,
            completionRate: snapshot.completionRate,
            hasActiveIntermittentFast: snapshot.hasActiveIntermittentFast,
            premiumMotivationLine: snapshot.premiumMotivationLine)
    }

    private var fallbackEntry: FastingEntry {
        FastingEntry(
            date: .now,
            todayTitle: "No observance today",
            todayObligation: "No obligation",
            nextRequiredTitle: "No upcoming required observance",
            nextRequiredDate: nil,
            completionRate: 0,
            hasActiveIntermittentFast: false,
            premiumMotivationLine: "Stay faithful in small daily disciplines.")
    }
}

private struct CatholicFastingMacWidgetView: View {
    let entry: FastingEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(entry.todayTitle)
                .font(.headline)
                .lineLimit(2)
            Text(entry.todayObligation)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text("Next Required")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(entry.nextRequiredTitle)
                .font(.subheadline)
                .lineLimit(2)

            Spacer(minLength: 0)

            HStack {
                Text("Progress")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int((entry.completionRate * 100).rounded()))%")
                    .font(.caption2.weight(.semibold))
            }

            if entry.hasActiveIntermittentFast {
                Label("Fast active", systemImage: "timer")
                    .font(.caption2)
                    .foregroundStyle(.green)
            } else {
                Text(entry.premiumMotivationLine)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .widgetURL(URL(string: "catholicfasting://today"))
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct CatholicFastingMacWidget: Widget {
    let kind = "CatholicFastingMacWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CatholicFastingMacWidgetView(entry: entry)
        }
        .configurationDisplayName("Catholic Fasting")
        .description("See today, the next required observance, and fasting progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
