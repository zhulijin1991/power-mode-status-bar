import Foundation

public struct RuntimePowerPolicy: Equatable, Sendable {
    public let preventSystemSleep: Bool
    public let preventDisplaySleep: Bool
    public let lockOnCurrentLidClosure: Bool

    public init(
        preventSystemSleep: Bool,
        preventDisplaySleep: Bool,
        lockOnCurrentLidClosure: Bool
    ) {
        self.preventSystemSleep = preventSystemSleep
        self.preventDisplaySleep = preventDisplaySleep
        self.lockOnCurrentLidClosure = lockOnCurrentLidClosure
    }
}

public enum PowerPolicy {
    public static func runtimePolicy(
        for mode: PowerMode,
        snapshot: SystemPowerSnapshot
    ) -> RuntimePowerPolicy {
        let pluggedIn = snapshot.powerSource.isPluggedIn
        let lidClosed = snapshot.lidState.isClosed

        switch mode {
        case .extreme:
            return RuntimePowerPolicy(
                preventSystemSleep: true,
                preventDisplaySleep: true,
                lockOnCurrentLidClosure: false
            )
        case .office:
            return RuntimePowerPolicy(
                preventSystemSleep: true,
                preventDisplaySleep: !(lidClosed && !pluggedIn),
                lockOnCurrentLidClosure: lidClosed && !pluggedIn
            )
        case .standby:
            if pluggedIn {
                return RuntimePowerPolicy(
                    preventSystemSleep: true,
                    preventDisplaySleep: true,
                    lockOnCurrentLidClosure: false
                )
            }

            return RuntimePowerPolicy(
                preventSystemSleep: false,
                preventDisplaySleep: false,
                lockOnCurrentLidClosure: lidClosed
            )
        }
    }
}
