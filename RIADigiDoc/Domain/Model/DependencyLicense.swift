// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

struct DependencyLicense: Identifiable {
    let id = UUID()
    let name: String
    let license: String
    let url: URL?
}

struct DependencyLicenses {
    static func getPackages() -> [DependencyLicense] {
        return [
            DependencyLicense(
                name: "Alamofire",
                license: "MIT licence",
                url: URL(string: "https://github.com/Alamofire/Alamofire/blob/master/LICENSE")
            ),
            DependencyLicense(
                name: "ASN1Decoder",
                license: "MIT licence",
                url: URL(string: "https://github.com/filom/ASN1Decoder/blob/master/LICENSE")
            ),
            DependencyLicense(
                name: "Factory",
                license: "MIT licence",
                url: URL(string: "https://github.com/hmlongco/Factory/blob/main/LICENSE")
            ),
            DependencyLicense(
                name: "Firebase",
                license: "Apache License version 2.0",
                url: URL(string: "https://github.com/firebase/firebase-ios-sdk/blob/main/LICENSE")
            ),
            DependencyLicense(
                name: "libcdoc",
                license: "GNU Lesser General Public License v2.1",
                url: URL(string: "https://github.com/open-eid/libcdoc/blob/master/LICENSE.LGPL")
            ),
            DependencyLicense(
                name: "libdigidocpp",
                license: "GNU Lesser General Public License v2.1",
                url: URL(string: "https://github.com/open-eid/libdigidocpp/blob/master/LICENSE.LGPL")
            ),
            DependencyLicense(
                name: "mockolo",
                license: "Apache License version 2.0",
                url: URL(string: "https://github.com/uber/mockolo/blob/master/LICENSE.txt")
            ),
            DependencyLicense(
                name: "nfclib",
                license: "GNU Lesser General Public License v2.1 or later",
                url: URL(string: "https://github.com/open-eid/nfc-iOS-lib")
            ),
            DependencyLicense(
                name: "OpenLDAP",
                license: "The OpenLDAP Public License",
                url: URL(string: "https://www.openldap.org/software/release/license.html")
            ),
            DependencyLicense(
                name: "OpenSSL",
                license: "OpenSSL License",
                url: URL(string: "https://www.openssl.org/source/license.txt")
            ),
            DependencyLicense(
                name: "swift-asn1",
                license: "Apache License version 2.0",
                url: URL(string: "https://github.com/apple/swift-asn1/blob/main/LICENSE.txt")
            ),
            DependencyLicense(
                name: "swift-certificates",
                license: "Apache License version 2.0",
                url: URL(string: "https://github.com/apple/swift-certificates/blob/main/LICENSE.txt")
            ),
            DependencyLicense(
                name: "swift-crypto",
                license: "Apache License version 2.0",
                url: URL(string: "https://github.com/apple/swift-crypto/blob/main/LICENSE.txt")
            ),
            DependencyLicense(
                name: "ZipFoundation",
                license: "MIT licence",
                url: URL(string: "https://github.com/weichsel/ZIPFoundation/blob/development/LICENSE")
            ),
            DependencyLicense(
                name: "zlib",
                license: "zlib License",
                url: URL(string: "https://zlib.net/zlib_license.html")
            )
        ]
    }
}
