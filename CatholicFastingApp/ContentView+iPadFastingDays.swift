import SwiftUI

extension ContentView {
    var ipadFastingDaysWorkspace: some View {
        let items = fastingDaysDisplayObservances
        let selected = selectedFastingObservance(from: items)
        let grouped = ipadFastingDayGroups(from: items)

        return ScrollView {
            if dynamicTypeSize.isAccessibilitySize {
                ipadFastingDaysStackedLayout(items: items, selected: selected, groups: grouped)
            } else {
                ViewThatFits(in: .horizontal) {
                    ipadFastingDaysWideLayout(items: items, selected: selected, groups: grouped)
                        .frame(minWidth: 1_280)
                    ipadFastingDaysMediumLayout(items: items, selected: selected, groups: grouped)
                        .frame(minWidth: 960)
                    ipadFastingDaysStackedLayout(items: items, selected: selected, groups: grouped)
                }
            }
        }
        .padding(28)
        .onAppear {
            selectDefaultFastingObservance(from: items)
        }
        .onChange(of: items.map(\.id)) { _, _ in
            selectDefaultFastingObservance(from: items)
        }
    }

    private func ipadFastingDaysWideLayout(
        items: [Observance],
        selected: Observance?,
        groups: [(String, [Observance])]) -> some View
    {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                ipadFastingDaysSummaryCards(for: items)
                ipadFastingDaysQuickDateStrip(from: items)
                ipadFastingDaysGroupedList(groups: groups)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)

            ipadFastingDaysDetailPane(selected: selected, compact: false)
                .frame(minWidth: 300, idealWidth: 360, maxWidth: 410)

            ipadFastingDaysFilterRail
                .frame(minWidth: 220, idealWidth: 260, maxWidth: 300)
        }
    }

    private func ipadFastingDaysMediumLayout(
        items: [Observance],
        selected: Observance?,
        groups: [(String, [Observance])]) -> some View
    {
        HStack(alignment: .top, spacing: 18) {
            ipadFastingDaysDetailPane(selected: selected, compact: true)
                .frame(minWidth: 260, idealWidth: 300, maxWidth: 340)

            VStack(alignment: .leading, spacing: 16) {
                ipadFastingDaysSummaryCards(for: items)
                ipadFastingDaysQuickDateStrip(from: items)
                ipadFastingDaysFilterRail
                ipadFastingDaysGroupedList(groups: groups)
                ipadFastingDaysHeroBand(compact: true)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
        }
    }

    private func ipadFastingDaysStackedLayout(
        items: [Observance],
        selected: Observance?,
        groups: [(String, [Observance])]) -> some View
    {
        VStack(alignment: .leading, spacing: 16) {
            ipadFastingDaysDetailPane(selected: selected, compact: true)
            ipadFastingDaysSummaryCards(for: items)
            ipadFastingDaysQuickDateStrip(from: items)
            ipadFastingDaysFilterRail
            ipadFastingDaysGroupedList(groups: groups)
            ipadFastingDaysHeroBand(compact: true)
        }
    }
}
