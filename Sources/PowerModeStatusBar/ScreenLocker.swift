import Foundation

enum ScreenLocker {
    static func lock() {
        let process = Process()
        process.executableURL = URL(
            fileURLWithPath: "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"
        )
        process.arguments = ["-suspend"]

        do {
            try process.run()
        } catch {
            print("[PowerModeStatusBar] failed to lock screen: \(error.localizedDescription)")
        }
    }
}
