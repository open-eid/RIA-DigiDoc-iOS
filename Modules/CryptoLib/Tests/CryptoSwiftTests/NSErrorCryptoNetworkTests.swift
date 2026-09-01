// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing

@testable import CryptoSwift

struct NSErrorCryptoNetworkTests {

    @Test
    func isCryptoNetworkError_trueForLibcdocNetworkErrorFromCryptoLib() {
        let error = NSError(domain: "ee.ria.digidoc.CryptoLib", code: -300)

        #expect(error.isCryptoNetworkError)
    }

    @Test
    func isCryptoNetworkError_falseForOtherCryptoLibCodes() {
        let error = NSError(domain: "ee.ria.digidoc.CryptoLib", code: 1000)

        #expect(!error.isCryptoNetworkError)
    }

    @Test
    func isCryptoNetworkError_falseForSameCodeFromAnotherDomain() {
        let error = NSError(domain: "LibdigidocLib", code: -300)

        #expect(!error.isCryptoNetworkError)
    }
}
