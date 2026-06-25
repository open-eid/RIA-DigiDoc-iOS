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
