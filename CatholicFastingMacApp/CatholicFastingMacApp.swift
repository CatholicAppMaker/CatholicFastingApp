import AppKit
import SwiftUI

@MainActor
enum MacApplicationActivationCoordinator {
    private static let isUITestMode: Bool = {
        let arguments = ProcessInfo.processInfo.arguments
        let environment = ProcessInfo.processInfo.environment
        return arguments.contains("-uitest-reset")
            || arguments.contains("-uitest-skip-onboarding")
            || arguments.contains("-uitest-seed-deterministic")
            || arguments.contains("-uitest-seed-missed")
            || environment["UITEST_MODE"] == "1"
    }()

    static func activateApp() {
        NSApp.setActivationPolicy(.regular)
        _ = NSRunningApplication.current.activate(options: [.activateAllWindows])
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows where window.isVisible {
            guard window.canBecomeKey else {
                continue
            }
            window.makeKeyAndOrderFront(nil)
        }
    }

    static func stabilizeLaunchActivationIfNeeded() {
        guard isUITestMode else {
            return
        }

        for attempt in 0 ..< 8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(attempt) * 0.35)) {
                activateApp()
            }
        }
    }
}

final class CatholicFastingMacAppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_: Notification) {
        MacApplicationActivationCoordinator.activateApp()
    }

    func applicationDidFinishLaunching(_: Notification) {
        MacApplicationActivationCoordinator.activateApp()
        MacApplicationActivationCoordinator.stabilizeLaunchActivationIfNeeded()
    }

    func applicationDidBecomeActive(_: Notification) {
        MacApplicationActivationCoordinator.activateApp()
    }
}

@MainActor
final class OpenSettingsPlatformService: SettingsOpeningPlatformServicing {
    private var action: (() -> Void)?

    func setAction(_ action: @escaping () -> Void) {
        self.action = action
    }

    func openSettings() {
        action?()
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
    private let openSettingsService: OpenSettingsPlatformService

    init() {
        CatholicFastingMacUITestBootstrap.applyLaunchOverridesIfNeeded()
        let openSettingsService = OpenSettingsPlatformService()
        self.openSettingsService = openSettingsService
        _model = StateObject(
            wrappedValue: CatholicFastingMacModel(
                services: CatholicFastingMacPlatformServices(
                    reminders: SystemReminderPlatformService(),
                    sharing: MacSharePayloadService(),
                    activeFastStatus: DefaultActiveFastStatusSurfaceService(),
                    seasonalAppearance: MacSeasonalAppearancePlatformService(),
                    settingsOpening: openSettingsService)))
    }

    var body: some Scene {
        WindowGroup("Catholic Fasting", id: "main") {
            CatholicFastingMacRootView(model: model, openSettingsService: openSettingsService)
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
