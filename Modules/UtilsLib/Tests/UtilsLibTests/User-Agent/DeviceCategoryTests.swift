// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Testing

@testable import UtilsLib

struct DeviceCategoryTests {

    @Test(
        "iPad models map to tablet/iPadOS",
        arguments: ["ipad13,4", "ipad8,12", "ipad14,1", "ipad"]
    )
    func tabletModels(model: String) {
        let category = DeviceCategory(modelIdentifier: model)

        #expect(category == .tablet)
        #expect(category.rawValue == "tablet")
        #expect(category.osName == "iPadOS")
    }

    @Test(
        "Non-iPad models map to mobile/iOS",
        arguments: ["iphone15,2", "iphone16,2", "ipod9,1", "", "x86_64"]
    )
    func mobileModels(model: String) {
        let category = DeviceCategory(modelIdentifier: model)

        #expect(category == .mobile)
        #expect(category.rawValue == "mobile")
        #expect(category.osName == "iOS")
    }
}
