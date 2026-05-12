import SwiftUI

struct CatholicFastingMacGuidanceView: View {
    @ObservedObject var model: CatholicFastingMacModel

    var body: some View {
        MacSurfaceContainer(
            title: "Guidance",
            subtitle: "Keep food guidance, regional context, and citations easy to read in a pointer-and-keyboard workflow.",
            accessibilityID: "mac.surface.guidance.ready")
        {
            MacCard(title: model.guidanceDecision.obligationLine, subtitle: model.guidanceDecision.sourceLine) {
                if !model.guidanceDecision.allowed.isEmpty {
                    Text("Allowed")
                        .font(.caption.weight(.semibold))
                    ForEach(model.guidanceDecision.allowed, id: \.self) { item in
                        Label(item, systemImage: "checkmark.circle")
                    }
                }
                if !model.guidanceDecision.avoid.isEmpty {
                    Divider()
                    Text("Avoid")
                        .font(.caption.weight(.semibold))
                    ForEach(model.guidanceDecision.avoid, id: \.self) { item in
                        Label(item, systemImage: "xmark.circle")
                    }
                }
                Divider()
                Text(model.guidanceDecision.rationale)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("mac.guidance.rationale")
            }

            MacAdaptiveColumns {
                MacCard(title: "Regional Framing", subtitle: model.generalRegionalContext.authorityLabel) {
                    Text("Profile: \(model.localizedRegionLabel(model.regionProfile))")
                    Text("Support level: \(model.generalRegionalContext.supportLevel.label)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(model.regionPastoralGuidanceText)
                    Divider()
                    Text(model.generalRegionalContext.disclosureText)
                    if let url = model.generalRegionalContext.sourceURL {
                        Link("Open primary source", destination: url)
                    }
                    ForEach(model.generalRegionalContext.citations, id: \.title) { citation in
                        Text("\(citation.title) • \(citation.shortReference)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } trailing: {
                MacCard(
                    title: "Trust & Explainability",
                    subtitle: model.currentPresentationContext?.regionalContext.classificationLabel ?? model.generalRegionalContext.classificationLabel)
                {
                    Text("Current season: \(model.localizedSeasonLabel(model.currentLiturgicalSeason))")
                    if let today = model.todayPrimaryObservance {
                        Text("Today: \(model.localizedObservanceTitle(today.title))")
                    }
                    if let upcoming = model.upcomingMandatoryObservance {
                        Text("Next required day: \(model.localizedObservanceTitle(upcoming.title)) on \(model.localizedDate(upcoming.date))")
                    }
                    if let context = model.currentPresentationContext {
                        Divider()
                        Text(context.regionalContext.disclosureText)
                            .foregroundStyle(.secondary)
                        Text(context.nextActionText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if !context.sourceSummary.isEmpty {
                            Text(context.sourceSummary)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
