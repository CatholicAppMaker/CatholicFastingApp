import AppKit
import SwiftUI

final class CatholicFastingMacAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct CatholicFastingMacCommands: Commands {
    @ObservedObject var model: CatholicFastingMacModel

    var body: some Commands {
        CommandMenu("Catholic Fasting") {
            Button("Today") {
                model.selectedSurface = .today
                model.bringAppToFront()
            }
            .keyboardShortcut("1", modifiers: [.command])

            Button("Fasting Calendar") {
                model.selectedSurface = .calendar
                model.bringAppToFront()
            }
            .keyboardShortcut("2", modifiers: [.command])

            Button("Intermittent Fast") {
                model.selectedSurface = .intermittent
                model.bringAppToFront()
            }
            .keyboardShortcut("3", modifiers: [.command])

            Button("Premium Toolkit") {
                model.selectedSurface = .premium
                model.bringAppToFront()
            }
            .keyboardShortcut("4", modifiers: [.command])

            Button("Guidance") {
                model.selectedSurface = .guidance
                model.bringAppToFront()
            }
            .keyboardShortcut("5", modifiers: [.command])

            Divider()

            if model.intermittentTracker.activeStart == nil {
                Button("Start Fast") {
                    model.startFast()
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
            } else {
                Button("End Fast") {
                    model.endFast()
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
            }

            SettingsLink {
                Text("Settings")
            }
            .keyboardShortcut(",", modifiers: [.command])
        }
    }
}

@main
struct CatholicFastingMacApp: App {
    @NSApplicationDelegateAdaptor(CatholicFastingMacAppDelegate.self) private var appDelegate
    @StateObject private var model: CatholicFastingMacModel

    init() {
        CatholicFastingMacUITestBootstrap.applyLaunchOverridesIfNeeded()
        _model = StateObject(wrappedValue: CatholicFastingMacModel())
    }

    var body: some Scene {
        WindowGroup("Catholic Fasting", id: "main") {
            CatholicFastingMacRootView(model: model)
        }
        .commands {
            CatholicFastingMacCommands(model: model)
        }

        Settings {
            CatholicFastingMacSettingsView(model: model)
        }

        MenuBarExtra(model.menuBarTitle, systemImage: "cross.case.fill") {
            CatholicFastingMacMenuBarView(model: model)
        }
    }
}
