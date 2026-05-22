import Foundation
import IOKit.ps
import PowerModeCore

final class SystemStateProvider {
    func snapshot() -> SystemPowerSnapshot {
        SystemPowerSnapshot(
            powerSource: currentPowerSource(),
            lidState: currentLidState()
        )
    }

    private func currentPowerSource() -> PowerSource {
        guard let adapter = IOPSCopyExternalPowerAdapterDetails()?.takeRetainedValue() as? [String: Any] else {
            return .battery
        }

        return adapter.isEmpty ? .battery : .ac
    }

    private func currentLidState() -> LidState {
        let output = runProcess(path: "/usr/sbin/ioreg", arguments: ["-r", "-k", "AppleClamshellState"])

        if output.contains("\"AppleClamshellState\" = Yes") {
            return .closed
        }

        if output.contains("\"AppleClamshellState\" = No") {
            return .open
        }

        return .unknown
    }

    private func runProcess(path: String, arguments: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ""
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
