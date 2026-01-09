#!/usr/bin/swift sh

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
import CryptoKit

// MARK: - Settings Configuration

class SettingsConfiguration {
    private let configBaseUrl: String
    private let configUpdateInterval: Int
    private let configTslUrl: String

    private let configurationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    init() {
        let args = CommandLine.arguments
        self.configBaseUrl = args.indices.contains(1) ? args[1] : "https://id.eesti.ee"
        self.configUpdateInterval = args.indices.contains(2) ? Int(args[2]) ?? 4 : 4
        self.configTslUrl = args.indices.contains(3) ? args[3] : "https://ec.europa.eu/tools/lotl/eu-lotl.xml"
    }

    func setupConfiguration() async throws {
        log("Starting configuration setup...")

        log("Config Base URL: \(configBaseUrl)")
        log("Update Interval: \(configUpdateInterval) hours")
        log("Config TSL URL: \(configTslUrl)")

        log("1 / 4 - Downloading configuration data...")
        let configData = try await fetchData(from: "\(configBaseUrl)/config.json")
        let publicKey = try await fetchData(from: "\(configBaseUrl)/config.ecpub")
        let signature = try await fetchData(from: "\(configBaseUrl)/config.ecc")

        log("2 / 4 - Verifying signature...")
        try verifySignature(configData: configData, publicKey: publicKey, signature: signature)

        log("3 / 4 -  Creating default configuration file...")
        let decodedData = try decodeMoppConfiguration(configData: configData)
        let defaultConfiguration = createDefaultConfiguration(versionSerial: decodedData.METAINF.SERIAL)

        log("4 / 4 - Saving and moving files...")
        try saveAndMoveConfigurationFiles(configData: configData, publicKey: publicKey, signature: signature, defaultConfiguration: defaultConfiguration)

        log("Default configuration initialized successfully!")
    }
}

// MARK: - Network Functions

extension SettingsConfiguration {
    private func fetchData(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else { throw ConfigurationError.invalidURL }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let stringData = String(data: data, encoding: .utf8) else { throw ConfigurationError.invalidData }

        return stringData
    }
}

// MARK: - Signature Verification

extension SettingsConfiguration {
    private func verifySignature(configData: String, publicKey: String, signature: String) throws {
        // Placeholder for actual verification logic
        guard !configData.isEmpty, !publicKey.isEmpty, !signature.isEmpty else {
            throw ConfigurationError.signatureVerificationFailed
        }
        guard let pubKey = Data(base64Encoded: publicKey
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: ""), options: .ignoreUnknownCharacters) else {
            log("Failed to parse key")
            throw ConfigurationError.signatureVerificationFailed
        }
        guard let sigData = Data(base64Encoded: signature, options: .ignoreUnknownCharacters) else {
            throw ConfigurationError.signatureVerificationFailed
        }

        let result: Bool
        switch pubKey.count {
        case 80...100:
            let key = try P256.Signing.PublicKey(derRepresentation: pubKey)
            let sig = try P256.Signing.ECDSASignature(derRepresentation: sigData)
            result = key.isValidSignature(sig, for: Data(configData.utf8))
        case 110...130:
            let key = try P384.Signing.PublicKey(derRepresentation: pubKey)
            let sig = try P384.Signing.ECDSASignature(derRepresentation: sigData)
            result = key.isValidSignature(sig, for: Data(configData.utf8))
        case 150...170:
            let key = try P521.Signing.PublicKey(derRepresentation: pubKey)
            let sig = try P521.Signing.ECDSASignature(derRepresentation: sigData)
            result = key.isValidSignature(sig, for: Data(configData.utf8))
        default:
            log("Unknown key size")
            throw ConfigurationError.signatureVerificationFailed
        }
        if !result {
            log("Signature verifying failed")
            throw ConfigurationError.signatureVerificationFailed
        }
        log("Signature verified successfully!")
    }
}

// MARK: - Configuration File Management

extension SettingsConfiguration {
    private func createDefaultConfiguration(versionSerial: Int) -> String {
        return """
        central-configuration-service.url=\(configBaseUrl)
        configuration.update-interval=\(configUpdateInterval)
        configuration.version-serial=\(versionSerial)
        configuration.download-date=\(configurationDateFormatter.string(from: Date()))
        """
    }

    private func saveAndMoveConfigurationFiles(configData: String, publicKey: String, signature: String, defaultConfiguration: String) throws {
        let files = [
            ("default-config.json", configData),
            ("default-config.ecpub", publicKey),
            ("default-config.ecc", signature),
            ("configuration.properties", defaultConfiguration)
        ]

        for (fileName, content) in files {
            try saveFile(named: fileName, content: content)
        }
    }

    private func saveFile(named fileName: String, content: String) throws {
        let components = ["Modules", "ConfigLib", "Sources", "ConfigLib", "Resources", "config"]
        let baseURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let directory = components.reduce(baseURL) { $0.appendingPathComponent($1) }
        let fileURL = directory.appendingPathComponent(fileName)

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        log("File saved: \(fileURL.path)")
    }
}

extension SettingsConfiguration {
    func decodeMoppConfiguration(configData: String) throws -> MOPPConfiguration {
          do {
              return try JSONDecoder().decode(MOPPConfiguration.self, from: configData.data(using: .utf8)!)
          } catch {
              fatalError("Error decoding data: \(error.localizedDescription)")
          }
      }

      struct MOPPConfiguration: Codable {
          let METAINF: MOPPMetaInf

          private enum MOPPConfigurationType: String, CodingKey {
              case METAINF = "META-INF"
          }

          init(from decoder: Decoder) throws {
              let container = try decoder.container(keyedBy: MOPPConfigurationType.self)
              METAINF = try container.decode(MOPPMetaInf.self, forKey: .METAINF)
          }
      }

      struct MOPPMetaInf: Codable {
          let URL: String
          let DATE: String
          let SERIAL: Int
          let VER: Int
      }
}

// MARK: - Error Handling

enum ConfigurationError: Error {
    case invalidURL
    case invalidData
    case signatureVerificationFailed
}

// MARK: - Logger

func log(_ message: String) {
    NSLog("[\(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))] \(message)")
}

// MARK: - Run Script

try await SettingsConfiguration().setupConfiguration()
