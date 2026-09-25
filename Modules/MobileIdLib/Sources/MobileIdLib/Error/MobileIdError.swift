// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum MobileIdError: Error {
    case generalError
    case uninitializedSession
    case explicitlyCancelled
    case noInternetConnection
    case incorrectParameters
    case timeout
    case notMidClient
    case userCancelled
    case signatureHashMismatch
    case phoneAbsent
    case deliveryError
    case simError
    case tooManyRequests
    case exceededUnsuccessfulRequests
    case invalidAccessRights
    case technicalError
}
