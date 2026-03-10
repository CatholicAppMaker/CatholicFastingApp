import SwiftUI

extension ContentView {
    var ipadFastingDaysWorkspace: some View {
        GeometryReader { geometry in
            let items = fastingDaysDisplayObservances
            let selected = selectedFastingObservance(from: items)
            let grouped = ipadFastingDayGroups(from: items)
            let layout = ipadFastingDaysLayout(for: geometry.size.width)

            ScrollView {
                switch layout {
                case .wide:
                    HStack(alignment: .top, spacing: 20) {
                        ipadFastingDaysFilterRail
                            .frame(width: 260)

                        VStack(alignment: .leading, spacing: 16) {
                            ipadFastingDaysHeroBand(compact: false)
                            ipadFastingDaysSummaryCards(for: items)
                            ipadFastingDaysQuickDateStrip(from: items)
                            ipadFastingDaysGroupedList(groups: grouped)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)

                        ipadFastingDaysDetailPane(selected: selected, compact: false)
                            .frame(width: 340)
                    }
                case .medium:
                    HStack(alignment: .top, spacing: 18) {
                        ipadFastingDaysFilterRail
                            .frame(width: 250)

                        VStack(alignment: .leading, spacing: 16) {
                            ipadFastingDaysHeroBand(compact: true)
                            ipadFastingDaysSummaryCards(for: items)
                            ipadFastingDaysQuickDateStrip(from: items)
                            ipadFastingDaysDetailPane(selected: selected, compact: true)
                            ipadFastingDaysGroupedList(groups: grouped)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                    }
                case .stacked:
                    VStack(alignment: .leading, spacing: 16) {
                        ipadFastingDaysFilterRail
                        ipadFastingDaysHeroBand(compact: true)
                        ipadFastingDaysSummaryCards(for: items)
                        ipadFastingDaysQuickDateStrip(from: items)
                        ipadFastingDaysDetailPane(selected: selected, compact: true)
                        ipadFastingDaysGroupedList(groups: grouped)
                    }
                }
            }
            .padding(20)
            .onAppear {
                selectDefaultFastingObservance(from: items)
            }
            .onChange(of: items.map(\.id)) { _, _ in
                selectDefaultFastingObservance(from: items)
            }
        }
    }

    func ipadFastingDaysLayout(for width: CGFloat) -> IPadFastingDaysLayoutMode {
        switch width {
        case ..<960:
            .stacked
        case ..<1280:
            .medium
        default:
            .wide
        }
    }
}

enum IPadFastingDaysLayoutMode {
    case wide
    case medium
    case stacked
}
