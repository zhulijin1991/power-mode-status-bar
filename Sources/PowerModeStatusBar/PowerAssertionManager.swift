import Foundation
import IOKit.pwr_mgt
import PowerModeCore

final class PowerAssertionManager {
    private var systemSleepAssertionID: IOPMAssertionID = 0
    private var displaySleepAssertionID: IOPMAssertionID = 0

    func apply(_ policy: RuntimePowerPolicy) {
        updateAssertion(
            isRequired: policy.preventSystemSleep,
            type: kIOPMAssertionTypeNoIdleSleep as String,
            name: "PowerModeStatusBar prevents automatic system sleep",
            assertionID: &systemSleepAssertionID
        )

        updateAssertion(
            isRequired: policy.preventDisplaySleep,
            type: kIOPMAssertionTypeNoDisplaySleep as String,
            name: "PowerModeStatusBar prevents automatic display sleep",
            assertionID: &displaySleepAssertionID
        )
    }

    func releaseAll() {
        release(&systemSleepAssertionID)
        release(&displaySleepAssertionID)
    }

    private func updateAssertion(
        isRequired: Bool,
        type: String,
        name: String,
        assertionID: inout IOPMAssertionID
    ) {
        if isRequired && assertionID == 0 {
            var newID = IOPMAssertionID(0)
            let result = IOPMAssertionCreateWithName(
                type as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                name as CFString,
                &newID
            )

            if result == kIOReturnSuccess {
                assertionID = newID
            }
        } else if !isRequired {
            release(&assertionID)
        }
    }

    private func release(_ assertionID: inout IOPMAssertionID) {
        guard assertionID != 0 else {
            return
        }

        IOPMAssertionRelease(assertionID)
        assertionID = 0
    }
}
