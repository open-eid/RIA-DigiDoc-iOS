/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

struct ConfigurationUtil {

    static func isSerialNewerThanCached(cachedSerial: Int?, newSerial: Int) -> Bool {
        guard let cachedSerial = cachedSerial else {
            return true
        }
        return newSerial > cachedSerial
    }

    static func isBase64(encoded: String) -> Bool {
        guard !encoded.isEmpty, let decodedData = Data(base64Encoded: encoded) else {
            return false
        }

        return encoded == decodedData.base64EncodedString()
    }
}
