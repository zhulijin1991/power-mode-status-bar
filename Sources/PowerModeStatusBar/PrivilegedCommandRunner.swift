import Foundation

final class PrivilegedCommandRunner {
    enum RunnerError: LocalizedError {
        case commandFailed(String)

        var errorDescription: String? {
            switch self {
            case .commandFailed(let output):
                return output.isEmpty ? "系统命令执行失败" : output
            }
        }
    }

    private let isDryRun: Bool

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        isDryRun = environment["POWER_MODE_DRY_RUN"] == "1"
    }

    func runPrivileged(_ commands: [String]) -> Result<Void, Error> {
        guard !commands.isEmpty else {
            return .success(())
        }

        if isDryRun {
            print("[PowerModeStatusBar] dry-run privileged commands: \(commands.joined(separator: " && "))")
            return .success(())
        }

        let joinedCommand = commands.joined(separator: " && ")
        let script = "do shell script \(joinedCommand.appleScriptLiteral) with administrator privileges"
        let result = runProcess(path: "/usr/bin/osascript", arguments: ["-e", script])

        if result.exitCode == 0 {
            return .success(())
        } else {
            return .failure(RunnerError.commandFailed(result.output))
        }
    }

    private func runProcess(path: String, arguments: [String]) -> (exitCode: Int32, output: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = arguments

        let output = Pipe()
        process.standardOutput = output
        process.standardError = output

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return (1, error.localizedDescription)
        }

        let data = output.fileHandleForReading.readDataToEndOfFile()
        return (process.terminationStatus, String(data: data, encoding: .utf8) ?? "")
    }
}

private extension String {
    var appleScriptLiteral: String {
        let escaped = replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }
}
