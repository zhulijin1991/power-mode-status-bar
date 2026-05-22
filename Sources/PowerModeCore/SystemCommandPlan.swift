import Foundation

public struct SystemCommandPlan: Equatable, Sendable {
    public let privilegedCommands: [String]

    public init(privilegedCommands: [String]) {
        self.privilegedCommands = privilegedCommands
    }
}

public enum SystemCommandPlanner {
    public static func plan(for mode: PowerMode) -> SystemCommandPlan {
        switch mode {
        case .extreme, .office:
            return SystemCommandPlan(privilegedCommands: [
                "/usr/bin/pmset -a sleep 0 displaysleep 0 disksleep 0 disablesleep 1"
            ])
        case .standby:
            return SystemCommandPlan(privilegedCommands: [
                "/usr/bin/pmset -c sleep 0 displaysleep 0 disksleep 0 disablesleep 1",
                "/usr/bin/pmset -b sleep 1 disablesleep 0"
            ])
        }
    }
}
