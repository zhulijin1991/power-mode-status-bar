import Foundation

enum SystemSleeper {
    static func sleepNow() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["sleepnow"]

        do {
            try process.run()
        } catch {
            print("[PowerModeStatusBar] failed to sleep now: \(error.localizedDescription)")
        }
    }
}
