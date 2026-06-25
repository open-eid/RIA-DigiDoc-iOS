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
import UIKit
import ExternalAccessory

public struct UserAgentUtil: UserAgentUtilProtocol {

    private static let schemaVersion = 1

    private let libdigidocppVersion: String

    public init(libdigidocppVersion: String = "") {
        self.libdigidocppVersion = libdigidocppVersion
    }

    public func userAgent(
        diagnostics: UserAgentDiagnostics = .none,
        language: String
    ) -> String {
        let info = appInfo(diagnostics: diagnostics, language: language)

        guard !libdigidocppVersion.isEmpty else { return "APP \(info)" }
        return "LIB libdigidocpp/\(libdigidocppVersion) (\(architecture())) APP \(info)"
    }

    public func appInfo(
        diagnostics: UserAgentDiagnostics = .none,
        language: String
    ) -> String {
        let metadata = metadataFields(diagnostics: diagnostics, language: language)
            .joined(separator: "; ")
        return "\(appIdentifier()) (\(metadata))"
    }

    private func metadataFields(
        diagnostics: UserAgentDiagnostics,
        language: String
    ) -> [String] {
        let model = SystemUtil.getDeviceModelIdentifier()
        let category = DeviceCategory(modelIdentifier: model)

        let diagnosticsField: String? = switch diagnostics {
        case .none: nil
        case .devices: devicesInfo().map { "devices=\($0)" }
        case .nfc: "nfc=true"
        }

        return [
            "schema=\(Self.schemaVersion)",
            "os=\(category.osName) \(SystemUtil.getOSVersion())",
            "lang=\(sanitizeField(language))",
            "devicetype=\(category.rawValue)/\(sanitizeField(model))",
            diagnosticsField
        ].compactMap { $0 }
    }

    private func appIdentifier() -> String {
        "riadigidoc/\(BundleUtil.getAppVersion())"
    }

    private func architecture() -> String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #elseif arch(arm)
        return "arm"
        #elseif arch(i386)
        return "i386"
        #else
        return "unknown"
        #endif
    }

    private func devicesInfo() -> String? {
        let devices = EAAccessoryManager.shared()
            .connectedAccessories
            .map {
                sanitizeField("\($0.manufacturer) \($0.name) \($0.modelNumber)")
            }
            .filter { !$0.isEmpty }

        guard !devices.isEmpty else { return nil }
        return devices.joined(separator: ", ")
    }

    // Remove delimiters and line breaks so a field can't break the header structure.
    private func sanitizeField(_ value: String) -> String {
        let forbidden = CharacterSet(charactersIn: ";()\u{2028}\u{2029}").union(.controlCharacters)
        let cleaned = String.UnicodeScalarView(value.unicodeScalars.filter { !forbidden.contains($0) })
        return String(cleaned).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
