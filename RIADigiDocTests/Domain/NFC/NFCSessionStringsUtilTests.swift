// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Testing

struct NFCSessionStringsUtilTests {

    @Test
    func makeForSigning_setsCourierMessageToActivateToSign() {
        let strings = makeStringsUtil().makeForSigning(pinName: "PIN2")

        #expect(strings.courierCardErrorMessage == "ID card courier must activate to sign")
    }

    @Test
    func makeForDecrypt_setsCourierMessageToActivateToDecrypt() {
        let strings = makeStringsUtil().makeForDecrypt(pinName: "PIN1")

        #expect(strings.courierCardErrorMessage == "ID card courier must activate to decrypt")
    }

    private func makeStringsUtil() -> NFCSessionStringsUtil {
        NFCSessionStringsUtil { key, _ in
            return key
        }
    }
}
