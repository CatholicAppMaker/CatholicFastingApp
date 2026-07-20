import Foundation

/// Owns one-shot launch gates that coordinate work but never drive the interface.
@MainActor
final class AppLaunchExecutionState {
    private(set) var hasPreparedLocalState = false
    private(set) var hasAppliedUITestInitialNavigation = false
    private(set) var hasRunDeferredStartup = false
    private(set) var hasConfiguredTips = false
    private(set) var hasRefreshedStoreCatalog = false

    func beginLocalPreparation() -> Bool {
        guard !hasPreparedLocalState else { return false }
        hasPreparedLocalState = true
        return true
    }

    func beginUITestInitialNavigation() -> Bool {
        guard !hasAppliedUITestInitialNavigation else { return false }
        hasAppliedUITestInitialNavigation = true
        return true
    }

    func beginDeferredStartup() -> Bool {
        guard !hasRunDeferredStartup else { return false }
        hasRunDeferredStartup = true
        return true
    }

    func markTipsConfigured() {
        hasConfiguredTips = true
    }

    func beginStoreCatalogRefresh(force: Bool) -> Bool {
        guard force || !hasRefreshedStoreCatalog else { return false }
        hasRefreshedStoreCatalog = true
        return true
    }
}
