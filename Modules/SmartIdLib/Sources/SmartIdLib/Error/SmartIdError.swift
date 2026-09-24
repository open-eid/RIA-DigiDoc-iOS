// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum SmartIdError: Error {
    case generalError
    case uninitializedSession
    case explicitlyCancelled
    case noInternetConnection
    case incorrectParameters
    case timeout
    case documentUnusable
    case wrongVC
    case userRefused
    case accountNotFound
    case sessionNotFound
    case missingSessionId
    case tooManyRequests
    case exceededUnsuccessfulRequests
    case ocspInvalidTimeSlot
    case certificateRevoked
    case notQualified
    case invalidAccessRights
    case oldApi
    case underMaintenance
    case noResponse
    case invalidSslHandshake
    case technicalError
}
