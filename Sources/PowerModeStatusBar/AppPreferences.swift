import Foundation
import PowerModeCore

final class AppPreferences {
    private let defaults: UserDefaults

    private enum Key {
        static let selectedMode = "selectedMode"
        static let openAtLoginEnabled = "openAtLoginEnabled"
        static let didSeedOpenAtLogin = "didSeedOpenAtLogin"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        seedDefaultsIfNeeded()
    }

    var selectedMode: PowerMode {
        get {
            guard
                let rawValue = defaults.string(forKey: Key.selectedMode),
                let mode = PowerMode(rawValue: rawValue)
            else {
                return .office
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: Key.selectedMode)
        }
    }

    var openAtLoginEnabled: Bool {
        get {
            defaults.bool(forKey: Key.openAtLoginEnabled)
        }
        set {
            defaults.set(newValue, forKey: Key.openAtLoginEnabled)
        }
    }

    private func seedDefaultsIfNeeded() {
        guard !defaults.bool(forKey: Key.didSeedOpenAtLogin) else {
            return
        }

        defaults.set(true, forKey: Key.openAtLoginEnabled)
        defaults.set(true, forKey: Key.didSeedOpenAtLogin)
    }
}
