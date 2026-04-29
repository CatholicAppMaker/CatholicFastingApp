import SwiftUI

extension ContentView {
    var historyOfFastingOverviewSection: some View {
        Section {
            AppSectionLeadCard(
                eyebrow: localized("history.overview.eyebrow", default: "Formation Reference"),
                title: localized("history.overview.title", default: "How Catholic fasting developed"),
                detail: localized(
                    "history.overview.detail",
                    default: "A readable timeline of fasting from the early Church to current Latin Church practice. This is historical formation, separate from today's rules."))
        }
    }

    var historyOfFastingTimelineSection: some View {
        Section {
            ForEach(FastingHistoryCatalog.articles(locale: languageMode.contentLocale)) { article in
                NavigationLink(value: article) {
                    FastingHistoryEraRow(article: article)
                }
                .accessibilityIdentifier("history.article.\(article.eraID.rawValue)")
            }
        } header: {
            Text(localized("history.timeline.section", default: "Timeline and Articles"))
        } footer: {
            Text(localized(
                "history.timeline.footer",
                default: "Use Guidance & Rules for current obligations. This section explains how the discipline developed over time."))
        }
    }

    func fastingHistoryArticleDetail(_ article: FastingHistoryArticle) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text(article.dateRange)
                        .appEyebrowStyle()
                        .textCase(.uppercase)
                    Text(article.title)
                        .appDisplayTitleStyle(serif: true)
                    Text(article.summary)
                        .appLeadTextStyle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }

            Section(localized("history.article.body", default: "Article")) {
                Text(article.body)
                    .font(.body)
                    .lineSpacing(4)
                    .foregroundStyle(CatholicTheme.primary.opacity(0.92))
                    .padding(.vertical, 4)
                    .accessibilityIdentifier("history.article.body.\(article.eraID.rawValue)")
            }

            Section(localized("history.article.sources", default: "Source Notes")) {
                ForEach(article.sourceNotes, id: \.self) { sourceNote in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sourceNote.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CatholicTheme.primary)
                        Text(sourceNote.detail)
                            .appSupportingTextStyle()
                    }
                    .padding(.vertical, 3)
                }
            }
        }
        .listStyle(.insetGrouped)
        .appListBackground()
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FastingHistoryEraRow: View {
    let article: FastingHistoryArticle

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 5) {
                Circle()
                    .fill(CatholicTheme.accent.opacity(0.22))
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: "book.closed")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CatholicTheme.primary))
                Rectangle()
                    .fill(CatholicTheme.cardBorder.opacity(0.32))
                    .frame(width: 2, height: 38)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(article.dateRange)
                    .appEyebrowStyle()
                    .textCase(.uppercase)
                Text(article.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CatholicTheme.primary)
                Text(article.summary)
                    .appSupportingTextStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 5)
    }
}
