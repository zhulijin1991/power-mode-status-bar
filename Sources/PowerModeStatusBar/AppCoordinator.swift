import AppKit
import Foundation
import PowerModeCore

@MainActor
final class AppCoordinator: NSObject {
    private let preferences = AppPreferences()
    private let stateProvider = SystemStateProvider()
    private let assertionManager = PowerAssertionManager()
    private let commandRunner = PrivilegedCommandRunner()
    private let loginItemManager = LoginItemManager()
    private let isDryRun = ProcessInfo.processInfo.environment["POWER_MODE_DRY_RUN"] == "1"
    private lazy var menuController = StatusMenuController(delegate: self)

    private var monitorTimer: Timer?
    private var lockedForCurrentLidClosure = false
    private(set) var selectedMode: PowerMode {
        didSet {
            preferences.selectedMode = selectedMode
        }
    }

    private(set) var openAtLoginEnabled: Bool {
        didSet {
            preferences.openAtLoginEnabled = openAtLoginEnabled
        }
    }

    private(set) var lastError: String? {
        didSet {
            menuController.update()
        }
    }

    override init() {
        selectedMode = preferences.selectedMode
        openAtLoginEnabled = preferences.openAtLoginEnabled
        super.init()
    }

    func start() {
        configureDefaultLoginItem()
        menuController.install()
        applySelectedMode(reason: "launch", applySystemSettings: false)
        startMonitoring()
    }

    private func configureDefaultLoginItem() {
        guard openAtLoginEnabled else {
            return
        }

        guard !isDryRun else {
            return
        }

        do {
            try loginItemManager.setEnabled(true)
        } catch {
            lastError = "开机自启动未启用：\(error.localizedDescription)"
        }
    }

    private func startMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = Timer(
            timeInterval: 3,
            target: self,
            selector: #selector(monitorTimerFired(_:)),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(monitorTimer!, forMode: .common)
    }

    @objc private func monitorTimerFired(_ timer: Timer) {
        applyRuntimePolicy()
    }

    private func applySelectedMode(reason: String, applySystemSettings: Bool) {
        menuController.update()
        applyRuntimePolicy()

        guard applySystemSettings else {
            return
        }

        let mode = selectedMode
        let plan = SystemCommandPlanner.plan(for: mode)

        let result = commandRunner.runPrivileged(plan.privilegedCommands)
        switch result {
        case .success:
            lastError = nil
        case .failure(let error):
            lastError = "策略应用失败：\(error.localizedDescription)"
        }
        applyRuntimePolicy()
    }

    private func applyRuntimePolicy() {
        let snapshot = stateProvider.snapshot()
        let runtimePolicy = PowerPolicy.runtimePolicy(for: selectedMode, snapshot: snapshot)
        assertionManager.apply(runtimePolicy)

        if snapshot.lidState == .open {
            lockedForCurrentLidClosure = false
        }

        if runtimePolicy.lockOnCurrentLidClosure && !lockedForCurrentLidClosure {
            lockedForCurrentLidClosure = true
            ScreenLocker.lock()
        }
    }
}

extension AppCoordinator: StatusMenuControllerDelegate {
    var currentMode: PowerMode {
        selectedMode
    }

    var currentRuleSummary: RuleSummary {
        selectedMode.ruleSummary
    }

    var isOpenAtLoginEnabled: Bool {
        openAtLoginEnabled
    }

    var statusError: String? {
        lastError
    }

    func selectMode(_ mode: PowerMode) {
        guard selectedMode != mode else {
            return
        }
        selectedMode = mode
        applySelectedMode(reason: "menu", applySystemSettings: false)
    }

    func toggleOpenAtLogin() {
        let nextValue = !openAtLoginEnabled
        guard !isDryRun else {
            openAtLoginEnabled = nextValue
            lastError = nil
            menuController.update()
            return
        }

        do {
            try loginItemManager.setEnabled(nextValue)
            openAtLoginEnabled = nextValue
            lastError = nil
        } catch {
            lastError = "开机自启动切换失败：\(error.localizedDescription)"
        }
        menuController.update()
    }

    func reapplyPolicy() {
        applySelectedMode(reason: "manual", applySystemSettings: true)
    }

    func quit() {
        assertionManager.releaseAll()
        NSApp.terminate(nil)
    }
}
