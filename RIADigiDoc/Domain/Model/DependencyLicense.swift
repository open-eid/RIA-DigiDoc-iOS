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
                name: "libcdoc",
                license: "AGNU Lesser General Public License v2.1",
                url: URL(string: "https://github.com/open-eid/libcdoc/blob/master/LICENSE.LGPL")
            ),
            DependencyLicense(
                name: "mockolo",
                license: "Apache License version 2.0",
                url: URL(string: "https://github.com/uber/mockolo/blob/master/LICENSE.txt")
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
                name: "SwCrypt",
                license: "MIT licence",
                url: URL(string: "https://github.com/soyersoyer/SwCrypt/blob/master/LICENSE.md")
            ),
            DependencyLicense(
                name: "SwiftyRSA",
                license: "MIT licence",
                url: URL(string: "https://github.com/TakeScoop/SwiftyRSA/blob/master/LICENSE")
            ),
            DependencyLicense(
                name: "SwiftLintPlugins",
                license: "MIT licence",
                url: URL(string: "https://github.com/SimplyDanny/SwiftLintPlugins/blob/main/LICENSE")
            ),
            DependencyLicense(
                name: "swift-certificates",
                license: "Apache License version 2.0",
                url: URL(string: "https://github.com/apple/swift-certificates/blob/main/LICENSE.txt")
            ),
            DependencyLicense(
                name: "ZipFoundation",
                license: "MIT licence",
                url: URL(string: "https://github.com/weichsel/ZIPFoundation/blob/development/LICENSE")
            )
        ]
    }
}
