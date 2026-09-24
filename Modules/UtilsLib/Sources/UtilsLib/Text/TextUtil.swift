// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public class TextUtil {

    public static func removeSlashes(_ text: String) -> String {
        return text.replacing("\\", with: "")
    }

    public static func formatSerialNumber(_ serialNumber: String) -> String {
        let noColons = serialNumber.replacing(":", with: " ")
        return noColons.uppercased()
    }
}
