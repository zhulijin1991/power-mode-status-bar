import Foundation

public enum PowerMode: String, CaseIterable, Codable, Equatable, Sendable {
    case extreme
    case office
    case standby

    public var title: String {
        switch self {
        case .extreme:
            return "极限模式"
        case .office:
            return "办公模式"
        case .standby:
            return "待机模式"
        }
    }

    public var symbolName: String {
        switch self {
        case .extreme:
            return "bolt.circle.fill"
        case .office:
            return "laptopcomputer"
        case .standby:
            return "moon.circle.fill"
        }
    }

    public var coreFeatureSummary: String {
        switch self {
        case .extreme:
            return "合盖/不插电都不睡眠、不锁屏"
        case .office:
            return "始终不睡眠，不插电合盖锁屏"
        case .standby:
            return "不插电合盖自动锁屏、睡眠"
        }
    }
}

public struct RuleSummary: Equatable, Sendable {
    public let lidTriggersSleep: Bool
    public let lidTriggersAutoLock: Bool
    public let unpluggedTriggersSleep: Bool
    public let unpluggedTriggersAutoLock: Bool

    public init(
        lidTriggersSleep: Bool,
        lidTriggersAutoLock: Bool,
        unpluggedTriggersSleep: Bool,
        unpluggedTriggersAutoLock: Bool
    ) {
        self.lidTriggersSleep = lidTriggersSleep
        self.lidTriggersAutoLock = lidTriggersAutoLock
        self.unpluggedTriggersSleep = unpluggedTriggersSleep
        self.unpluggedTriggersAutoLock = unpluggedTriggersAutoLock
    }

    public var lidLine: String {
        "合盖：进入睡眠 \(lidTriggersSleep.displayText)，自动锁屏 \(lidTriggersAutoLock.displayText)"
    }

    public var unpluggedLine: String {
        "不插电：进入睡眠 \(unpluggedTriggersSleep.displayText)，自动锁屏 \(unpluggedTriggersAutoLock.displayText)"
    }
}

public extension PowerMode {
    var ruleSummary: RuleSummary {
        switch self {
        case .extreme:
            return RuleSummary(
                lidTriggersSleep: false,
                lidTriggersAutoLock: false,
                unpluggedTriggersSleep: false,
                unpluggedTriggersAutoLock: false
            )
        case .office:
            return RuleSummary(
                lidTriggersSleep: false,
                lidTriggersAutoLock: true,
                unpluggedTriggersSleep: false,
                unpluggedTriggersAutoLock: false
            )
        case .standby:
            return RuleSummary(
                lidTriggersSleep: false,
                lidTriggersAutoLock: true,
                unpluggedTriggersSleep: true,
                unpluggedTriggersAutoLock: false
            )
        }
    }
}

private extension Bool {
    var displayText: String {
        self ? "开启" : "关闭"
    }
}
