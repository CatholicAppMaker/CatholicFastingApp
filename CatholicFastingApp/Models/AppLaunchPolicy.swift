import Foundation

struct AppLaunchPolicy: Equatable {
    let didCompleteOnboarding: Bool
    let acceptedLegalNotice: Bool

    var shouldPrepareLocalLaunchState: Bool {
        true
    }

    var shouldRunDeferredPlatformStartup: Bool {
        didCompleteOnboarding
    }

    var shouldRefreshStoreCatalog: Bool {
        didCompleteOnboarding
    }

    var shouldConfigureTips: Bool {
        didCompleteOnboarding
    }

    var shouldRefreshReminderIntegrations: Bool {
        didCompleteOnboarding && acceptedLegalNotice
    }

    var shouldDelayInitialPlatformStartup: Bool {
        didCompleteOnboarding
    }
}
