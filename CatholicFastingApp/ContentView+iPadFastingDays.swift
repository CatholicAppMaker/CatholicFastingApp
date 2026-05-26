import SwiftUI

extension ContentView {
    var ipadFastingDaysWorkspace: some View {
        GeometryReader { geometry in
            let items = fastingDaysDisplayObservances
            let selected = selectedFastingObservance(from: items)
            let grouped = ipadFastingDayGroups(from: items)
            let layout = ipadFastingDaysLayout(for: geometry.size.width, dynamicTypeSize: dynamicTypeSize)

            ScrollView {
                switch layout {
                case .wide:
                    HStack(alignment: .top, spacing: 20) {
                        ipadFastingDaysDetailPane(selected: selected, compact: false)
                            .frame(minWidth: 300, idealWidth: 340, maxWidth: 390)

                        VStack(alignment: .leading, spacing: 16) {
                            ipadFastingDaysSummaryCards(for: items)
                            ipadFastingDaysQuickDateStrip(from: items)
                            ipadFastingDaysGroupedList(groups: grouped)
                            ipadFastingDaysHeroBand(compact: false)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)

                        ipadFastingDaysFilterRail
                            .frame(minWidth: 220, idealWidth: 260, maxWidth: 300)
                    }
                case .medium:
                    HStack(alignment: .top, spacing: 18) {
                        ipadFastingDaysDetailPane(selected: selected, compact: true)
                            .frame(minWidth: 260, idealWidth: 300, maxWidth: 340)

                        VStack(alignment: .leading, spacing: 16) {
                            ipadFastingDaysSummaryCards(for: items)
                            ipadFastingDaysQuickDateStrip(from: items)
                            ipadFastingDaysGroupedList(groups: grouped)
                            ipadFastingDaysFilterRail
                            ipadFastingDaysHeroBand(compact: true)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)
                    }
                case .stacked:
                    VStack(alignment: .leading, spacing: 16) {
                        ipadFastingDaysDetailPane(selected: selected, compact: true)
                        ipadFastingDaysSummaryCards(for: items)
                        ipadFastingDaysQuickDateStrip(from: items)
                        ipadFastingDaysGroupedList(groups: grouped)
                        ipadFastingDaysFilterRail
                        ipadFastingDaysHeroBand(compact: true)
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

    func ipadFastingDaysLayout(for width: CGFloat, dynamicTypeSize: DynamicTypeSize) -> IPadFastingDaysLayoutMode {
        if dynamicTypeSize.isAccessibilitySize {
            return .stacked
        }

        switch width {
        case ..<960:
            return .stacked
        case ..<1280:
            return .medium
        default:
            return .wide
        }
    }
}

enum IPadFastingDaysLayoutMode {
    case wide
    case medium
    case stacked
}
