// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

public struct NFCSessionStrings: Sendable {
    let initialMessage: String
    let step1Message: String
    let step2Message: String
    let step3Message: String
    let step4Message: String
    let successMessage: String
    let canErrorMessage: String
    let pinWrongMultipleErrorMessage: String
    let pinWrongErrorMessage: String
    let pinBlockedErrorMessage: String
    let pinLockedErrorMessage: String
    let wrongCardErrorMessage: String
    let courierCardErrorMessage: String
    let technicalErrorMessage: String
    let sessionErrorMessage: String
    let ocspTimeslotErrorMessage: String
    let certificateRevokedErrorMessage: String
    let tooManyRequestsErrorMessage: String
    let networkErrorMessage: String
    let sslErrorMessage: String
}
