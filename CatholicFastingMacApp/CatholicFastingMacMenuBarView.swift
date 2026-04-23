import SwiftUI

struct CatholicFastingMacMenuBarView: View {
    @ObservedObject var model: CatholicFastingMacModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.menuBarTitle)
                .font(.headline)
                .lineLimit(1)
            Text(model.menuBarSubtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if let upcoming = model.upcomingMandatoryObservance {
                Divider()
                Text("Next required")
                    .font(.caption.weight(.semibold))
                Text(model.localizedObservanceTitle(upcoming.title))
                    .lineLimit(1)
                Text(model.localizedDate(upcoming.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Button("Open Today") {
                openSurface(.today)
            }
            Button("Open Calendar") {
                openSurface(.calendar)
            }
            Button("Open Intermittent Fast") {
                openSurface(.intermittent)
            }
            Button("Open Guidance") {
                openSurface(.guidance)
            }
            SettingsLink {
                Label("Settings", systemImage: "gearshape")
            }

            Divider()

            if model.intermittentTracker.activeStart == nil {
                Button("Start Fast") {
                    model.startFast()
                }
            } else {
                Button("End Fast") {
                    model.endFast()
                }
                Button("Cancel Fast") {
                    model.cancelFast()
                }
            }
        }
        .padding(12)
        .frame(minWidth: 280)
    }

    private func openSurface(_ surface: CatholicFastingMacSurface) {
        model.selectedSurface = surface
        openWindow(id: "main")
        model.bringAppToFront()
    }
}
