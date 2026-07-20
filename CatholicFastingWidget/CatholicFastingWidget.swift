import SwiftUI
import WidgetKit

private struct FastingEntry: TimelineEntry {
    let date: Date
    let todayTitle: String
    let todayObligation: String
    let nextRequiredTitle: String
    let nextRequiredDate: Date?
    let completionRate: Double
    let hasActiveIntermittentFast: Bool
    let activeIntermittentFastStart: Date?
    let activeIntermittentTargetHours: Int
    let premiumMotivationLine: String
    let localizationCode: String
}

private struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> FastingEntry {
        fallbackEntry
    }

    func getSnapshot(in _: Context, completion: @escaping (FastingEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<FastingEntry>) -> Void) {
        let entry = loadEntry()
        let regularRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        let targetDate = entry.activeIntermittentFastStart?.addingTimeInterval(
            TimeInterval(entry.activeIntermittentTargetHours * 3600))
        let refresh = targetDate.map { min(regularRefresh, $0) } ?? regularRefresh
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func loadEntry() -> FastingEntry {
        guard
            let defaults = UserDefaults(suiteName: WidgetSnapshotContract.appGroupIdentifier),
            let data = defaults.data(forKey: WidgetSnapshotContract.snapshotKey),
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
            activeIntermittentFastStart: snapshot.activeIntermittentFastStart,
            activeIntermittentTargetHours: snapshot.activeIntermittentTargetHours,
            premiumMotivationLine: snapshot.premiumMotivationLine,
            localizationCode: snapshot.localizationCode)
    }

    private var fallbackEntry: FastingEntry {
        FastingEntry(
            date: .now,
            todayTitle: WidgetLocalization.text(
                "widget.fallback.today.title", default: "No observance today"),
            todayObligation: WidgetLocalization.text(
                "widget.fallback.today.obligation", default: "No obligation"),
            nextRequiredTitle: WidgetLocalization.text(
                "widget.fallback.next_required", default: "No upcoming required observance"),
            nextRequiredDate: nil,
            completionRate: 0,
            hasActiveIntermittentFast: false,
            activeIntermittentFastStart: nil,
            activeIntermittentTargetHours: 16,
            premiumMotivationLine: WidgetLocalization.text(
                "widget.fallback.motivation", default: "Stay faithful in small daily disciplines."),
            localizationCode: Locale.current.identifier)
    }
}

private enum WidgetLocalization {
    static func text(_ key: String, default defaultValue: String, code: String? = nil) -> String {
        let requestedCode = code ?? Locale.current.identifier
        let candidates = [requestedCode, Locale(identifier: requestedCode).language.languageCode?.identifier]
            .compactMap { $0 }
        for candidate in candidates {
            if let path = Bundle.main.path(forResource: candidate, ofType: "lproj"),
               let bundle = Bundle(path: path)
            {
                return NSLocalizedString(
                    key, tableName: "Localizable", bundle: bundle, value: defaultValue, comment: "")
            }
        }
        return NSLocalizedString(key, tableName: "Localizable", bundle: .main, value: defaultValue, comment: "")
    }
}

private struct CatholicFastingWidgetView: View {
    let entry: FastingEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                mediumContent
            default:
                smallContent
            }
        }
        .widgetURL(URL(string: entry.hasActiveIntermittentFast ? "catholicfasting://intermittent" : "catholicfasting://today"))
        .containerBackground(.fill.tertiary, for: .widget)
        .accessibilityElement(children: .contain)
    }

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(
                WidgetLocalization.text("widget.section.today", default: "Today", code: entry.localizationCode),
                systemImage: entry.hasActiveIntermittentFast ? "timer" : "cross.case.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(secondaryStyle)
                .widgetAccentable()
            Text(entry.todayObligation)
                .font(.system(.headline, design: .serif).weight(.bold))
                .lineLimit(3)
            Spacer(minLength: 0)
            if entry.hasActiveIntermittentFast {
                activeFastStatus
            } else {
                Text(entry.todayTitle)
                    .font(.caption)
                    .foregroundStyle(secondaryStyle)
                    .lineLimit(2)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(WidgetLocalization.text("widget.section.today", default: "Today", code: entry.localizationCode)): \(entry.todayObligation). \(entry.todayTitle)")
    }

    private var mediumContent: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text(WidgetLocalization.text("widget.section.today.upper", default: "TODAY", code: entry.localizationCode))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(secondaryStyle)
                Text(entry.todayObligation)
                    .font(.system(.headline, design: .serif).weight(.bold))
                    .lineLimit(3)
                Text(entry.todayTitle)
                    .font(.caption)
                    .foregroundStyle(secondaryStyle)
                    .lineLimit(2)
                if entry.hasActiveIntermittentFast {
                    activeFastStatus
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            VStack(alignment: .leading, spacing: 7) {
                Text(WidgetLocalization.text(
                    "widget.section.next_required.upper", default: "NEXT REQUIRED", code: entry.localizationCode))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(secondaryStyle)
                Text(entry.nextRequiredTitle)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(3)
                if let nextRequiredDate = entry.nextRequiredDate {
                    Text(nextRequiredDate, format: .dateTime.month(.abbreviated).day())
                        .font(.caption)
                        .foregroundStyle(secondaryStyle)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
    }

    private var secondaryStyle: AnyShapeStyle {
        if renderingMode == .fullColor, !isLuminanceReduced {
            AnyShapeStyle(.secondary)
        } else {
            AnyShapeStyle(.primary.opacity(0.82))
        }
    }

    @ViewBuilder
    private var activeFastStatus: some View {
        if let start = entry.activeIntermittentFastStart {
            let target = start.addingTimeInterval(TimeInterval(entry.activeIntermittentTargetHours * 3600))
            if target > Date() {
                HStack(spacing: 4) {
                    Text(WidgetLocalization.text(
                        "widget.fast.active", default: "Fast active", code: entry.localizationCode))
                    Text(target, style: .timer)
                        .monospacedDigit()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(secondaryStyle)
                .lineLimit(1)
            } else {
                Text(WidgetLocalization.text(
                    "widget.fast.target_reached", default: "Fast target reached", code: entry.localizationCode))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(secondaryStyle)
                    .lineLimit(1)
            }
        } else {
            Text(WidgetLocalization.text(
                "widget.fast.active", default: "Fast active", code: entry.localizationCode))
                .font(.caption.weight(.semibold))
                .foregroundStyle(secondaryStyle)
        }
    }
}

struct CatholicFastingWidget: Widget {
    let kind: String = WidgetSnapshotContract.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CatholicFastingWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.configuration.name")
        .description("widget.configuration.description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
