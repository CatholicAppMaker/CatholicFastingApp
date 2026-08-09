import SwiftUI

struct IntermittentFastOverviewMetric: Identifiable {
    let id: String
    let title: String
    let value: String
    let detail: String
    let tone: AppSemanticTone
    var accessibilityIdentifier: String?
    var accessibilityLabel: String?
    var accessibilityValue: String?
}

struct IntermittentFastOverviewStatus: Identifiable {
    let id: String
    let text: String
    var emphasized = false
}

struct IntermittentFastRhythmMetric: Identifiable {
    let id: String
    let title: String
    let value: String
    let detail: String
}

struct IntermittentFastHeroSection: View {
    let assetName: String
    let title: String
    let subtitle: String

    var body: some View {
        Section {
            SacredSurfaceAnchorCard(
                assetName: assetName,
                title: title,
                subtitle: subtitle,
                imageHeight: 108,
                accessibilityIdentifier: "intermittent.hero")
        }
    }
}

struct IntermittentFastOverviewSection: View {
    let title: String
    let metrics: [IntermittentFastOverviewMetric]
    let status: [IntermittentFastOverviewStatus]
    let rhythmTitle: String
    let rhythmMetrics: [IntermittentFastRhythmMetric]

    var body: some View {
        Section(title) {
            ViewThatFits(in: .horizontal) {
                HStack {
                    metricTiles
                }
                VStack(spacing: 8) {
                    metricTiles
                }
            }

            ForEach(status) { message in
                statusText(message)
            }

            IntermittentFastRhythmStrip(
                title: rhythmTitle,
                metrics: rhythmMetrics)
        }
    }

    @ViewBuilder
    private func statusText(_ message: IntermittentFastOverviewStatus) -> some View {
        if message.emphasized {
            Text(message.text)
                .appSupportingTextStyle()
                .foregroundStyle(CatholicTheme.primary.opacity(0.9))
        } else {
            Text(message.text)
                .appSupportingTextStyle()
        }
    }

    private var metricTiles: some View {
        ForEach(metrics) { metric in
            metricTile(metric)
        }
    }

    @ViewBuilder
    private func metricTile(_ metric: IntermittentFastOverviewMetric) -> some View {
        let tile = MetricTile(
            title: metric.title,
            value: metric.value,
            detail: metric.detail,
            tone: metric.tone)

        if let accessibilityIdentifier = metric.accessibilityIdentifier {
            tile
                .accessibilityIdentifier(accessibilityIdentifier)
                .accessibilityLabel(metric.accessibilityLabel ?? metric.title)
                .accessibilityValue(metric.accessibilityValue ?? metric.value)
        } else {
            tile
        }
    }
}

private struct IntermittentFastRhythmStrip: View {
    let title: String
    let metrics: [IntermittentFastRhythmMetric]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    metricViews
                }
                VStack(spacing: 8) {
                    metricViews
                }
            }
            .accessibilityIdentifier("intermittent.rhythm_summary")
        }
    }

    private var metricViews: some View {
        ForEach(metrics) { metric in
            IntermittentFastRhythmInsight(metric: metric)
        }
    }
}

private struct IntermittentFastRhythmInsight: View {
    let metric: IntermittentFastRhythmMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(metric.title)
                .appEyebrowStyle()
                .textCase(.uppercase)
            Text(metric.value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
            Text(metric.detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(CatholicTheme.parchment.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(CatholicTheme.cardBorder.opacity(0.22), lineWidth: 1)
                .accessibilityHidden(true))
    }
}
