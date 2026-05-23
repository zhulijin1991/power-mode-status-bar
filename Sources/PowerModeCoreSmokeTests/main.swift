import Foundation
import PowerModeCore

enum SmokeTestFailure: Error, CustomStringConvertible {
    case expectationFailed(String)

    var description: String {
        switch self {
        case .expectationFailed(let message):
            return message
        }
    }
}

func expect(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    guard condition() else {
        throw SmokeTestFailure.expectationFailed(message)
    }
}

func testRuleSummaryDisplayLines() throws {
    try expect(
        PowerMode.extreme.ruleSummary.lidLine == "Lid close: sleep off, auto-lock off",
        "extreme lid line mismatch"
    )
    try expect(
        PowerMode.extreme.ruleSummary.unpluggedLine == "On battery: sleep off, auto-lock off",
        "extreme unplugged line mismatch"
    )
    try expect(
        PowerMode.office.ruleSummary.lidLine == "Lid close: sleep off, auto-lock on",
        "office lid line mismatch"
    )
    try expect(
        PowerMode.office.ruleSummary.unpluggedLine == "On battery: sleep off, auto-lock off",
        "office unplugged line mismatch"
    )
    try expect(
        PowerMode.standby.ruleSummary.lidLine == "Lid close: sleep on, auto-lock on",
        "standby lid line mismatch"
    )
    try expect(
        PowerMode.standby.ruleSummary.unpluggedLine == "On battery: sleep on, auto-lock off",
        "standby unplugged line mismatch"
    )
}

func testCoreFeatureSummaries() throws {
    try expect(
        PowerMode.extreme.coreFeatureSummary == "Never sleeps or auto-locks",
        "extreme core feature summary mismatch"
    )
    try expect(
        PowerMode.office.coreFeatureSummary == "Never sleeps; locks on lid close",
        "office core feature summary mismatch"
    )
    try expect(
        PowerMode.standby.coreFeatureSummary == "Lid close locks and sleeps",
        "standby core feature summary mismatch"
    )
}

func testSystemCommandPlans() throws {
    try expect(
        SystemCommandPlanner.plan(for: .extreme).privilegedCommands == [
            "/usr/bin/pmset -a sleep 0 displaysleep 0 disksleep 0 disablesleep 1"
        ],
        "extreme command plan mismatch"
    )
    try expect(
        SystemCommandPlanner.plan(for: .office).privilegedCommands == [
            "/usr/bin/pmset -a sleep 0 displaysleep 0 disksleep 0 disablesleep 1"
        ],
        "office command plan mismatch"
    )
    try expect(
        SystemCommandPlanner.plan(for: .standby).privilegedCommands == [
            "/usr/bin/pmset -c sleep 0 displaysleep 0 disksleep 0 disablesleep 1",
            "/usr/bin/pmset -b sleep 1 disablesleep 0"
        ],
        "standby command plan mismatch"
    )
}

func testRuntimePolicies() throws {
    for powerSource in [PowerSource.ac, .battery] {
        for lidState in [LidState.open, .closed] {
            let policy = PowerPolicy.runtimePolicy(
                for: .extreme,
                snapshot: SystemPowerSnapshot(powerSource: powerSource, lidState: lidState)
            )
            try expect(policy.preventSystemSleep, "extreme should prevent system sleep")
            try expect(policy.preventDisplaySleep, "extreme should prevent display sleep")
            try expect(!policy.lockOnCurrentLidClosure, "extreme should not lock on lid close")
            try expect(!policy.sleepOnCurrentLidClosure, "extreme should not sleep on lid close")
        }
    }

    let officeClosedAC = PowerPolicy.runtimePolicy(
        for: .office,
        snapshot: SystemPowerSnapshot(powerSource: .ac, lidState: .closed)
    )
    try expect(officeClosedAC.preventSystemSleep, "office AC closed should prevent sleep")
    try expect(!officeClosedAC.preventDisplaySleep, "office AC closed should allow display lock")
    try expect(officeClosedAC.lockOnCurrentLidClosure, "office AC closed should lock")
    try expect(!officeClosedAC.sleepOnCurrentLidClosure, "office AC closed should not sleep")

    let officeClosedBattery = PowerPolicy.runtimePolicy(
        for: .office,
        snapshot: SystemPowerSnapshot(powerSource: .battery, lidState: .closed)
    )
    try expect(officeClosedBattery.preventSystemSleep, "office battery closed should prevent sleep")
    try expect(!officeClosedBattery.preventDisplaySleep, "office battery closed should allow display lock")
    try expect(officeClosedBattery.lockOnCurrentLidClosure, "office battery closed should lock")
    try expect(!officeClosedBattery.sleepOnCurrentLidClosure, "office battery closed should not sleep")

    let officeOpenBattery = PowerPolicy.runtimePolicy(
        for: .office,
        snapshot: SystemPowerSnapshot(powerSource: .battery, lidState: .open)
    )
    try expect(officeOpenBattery.preventSystemSleep, "office battery open should prevent sleep")
    try expect(officeOpenBattery.preventDisplaySleep, "office battery open should prevent display sleep")
    try expect(!officeOpenBattery.lockOnCurrentLidClosure, "office battery open should not lock")
    try expect(!officeOpenBattery.sleepOnCurrentLidClosure, "office battery open should not sleep")

    let standbyACClosed = PowerPolicy.runtimePolicy(
        for: .standby,
        snapshot: SystemPowerSnapshot(powerSource: .ac, lidState: .closed)
    )
    try expect(!standbyACClosed.preventSystemSleep, "standby AC closed should release sleep prevention")
    try expect(!standbyACClosed.preventDisplaySleep, "standby AC closed should release display prevention")
    try expect(standbyACClosed.lockOnCurrentLidClosure, "standby AC closed should lock")
    try expect(standbyACClosed.sleepOnCurrentLidClosure, "standby AC closed should sleep")

    let standbyACOpen = PowerPolicy.runtimePolicy(
        for: .standby,
        snapshot: SystemPowerSnapshot(powerSource: .ac, lidState: .open)
    )
    try expect(standbyACOpen.preventSystemSleep, "standby AC open should prevent sleep")
    try expect(standbyACOpen.preventDisplaySleep, "standby AC open should prevent display sleep")
    try expect(!standbyACOpen.lockOnCurrentLidClosure, "standby AC open should not lock")
    try expect(!standbyACOpen.sleepOnCurrentLidClosure, "standby AC open should not sleep")

    let standbyBatteryOpen = PowerPolicy.runtimePolicy(
        for: .standby,
        snapshot: SystemPowerSnapshot(powerSource: .battery, lidState: .open)
    )
    try expect(!standbyBatteryOpen.preventSystemSleep, "standby battery open should release sleep prevention")
    try expect(!standbyBatteryOpen.preventDisplaySleep, "standby battery open should release display prevention")
    try expect(!standbyBatteryOpen.lockOnCurrentLidClosure, "standby battery open should not lock")
    try expect(!standbyBatteryOpen.sleepOnCurrentLidClosure, "standby battery open should not sleep")

    let standbyBatteryClosed = PowerPolicy.runtimePolicy(
        for: .standby,
        snapshot: SystemPowerSnapshot(powerSource: .battery, lidState: .closed)
    )
    try expect(!standbyBatteryClosed.preventSystemSleep, "standby battery closed should release sleep prevention")
    try expect(!standbyBatteryClosed.preventDisplaySleep, "standby battery closed should release display prevention")
    try expect(standbyBatteryClosed.lockOnCurrentLidClosure, "standby battery closed should lock")
    try expect(standbyBatteryClosed.sleepOnCurrentLidClosure, "standby battery closed should sleep")
}

do {
    try testRuleSummaryDisplayLines()
    try testCoreFeatureSummaries()
    try testSystemCommandPlans()
    try testRuntimePolicies()
    print("PowerModeCoreSmokeTests passed")
} catch {
    fputs("PowerModeCoreSmokeTests failed: \(error)\n", stderr)
    exit(1)
}
