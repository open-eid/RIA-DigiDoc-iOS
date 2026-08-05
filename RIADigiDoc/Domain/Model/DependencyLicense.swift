/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
            ),
            DependencyLicense(
                name: "zlib",
                license: "zlib License",
                url: URL(string: "https://zlib.net/zlib_license.html")
            )
        ]
    }
}
