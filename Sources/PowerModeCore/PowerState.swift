import Foundation

public enum PowerSource: Equatable, Sendable {
    case ac
    case battery
    case unknown

    public var isPluggedIn: Bool {
        switch self {
        case .ac:
            return true
        case .battery, .unknown:
            return false
        }
    }
}

public enum LidState: Equatable, Sendable {
    case open
    case closed
    case unknown

    public var isClosed: Bool {
        switch self {
        case .closed:
            return true
        case .open, .unknown:
            return false
        }
    }
}

public struct SystemPowerSnapshot: Equatable, Sendable {
    public let powerSource: PowerSource
    public let lidState: LidState

    public init(powerSource: PowerSource, lidState: LidState) {
        self.powerSource = powerSource
        self.lidState = lidState
    }
}
