// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

struct ProgressBar {
    let currentStep: Int
    let totalSteps: Int

    init(currentStep: Int, totalSteps: Int = 4) {
        self.currentStep = min(currentStep, totalSteps)
        self.totalSteps = totalSteps
    }

    func generate() -> String {
        let filled = String(repeating: "●", count: currentStep)
        let empty = String(repeating: "○", count: max(0, totalSteps - currentStep))
        return filled + empty
    }
}
