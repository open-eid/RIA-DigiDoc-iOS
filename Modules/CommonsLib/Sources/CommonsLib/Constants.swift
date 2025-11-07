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

public struct Constants {
    public struct Container {
        public static let SignedContainerFolder = "SignedContainers"
        public static let CryptoContainerFolder = "CryptoContainers"
        public static let DefaultName = "newFile"
        public static let ContainerExtensions = [
            Extension.Asice,
            Extension.Sce,
            Extension.Adoc,
            Extension.Bdoc,
            Extension.Ddoc,
            Extension.Edoc,
            Extension.Asics,
            Extension.Scs
        ]

        public static let CryptoContainerExtensions = [
            Extension.Cdoc,
            Extension.Cdoc2
        ]
    }

    public struct MimeType {
        public static let Asice = "application/vnd.etsi.asic-e+zip"  // Also .bdoc, .edoc, .sce
        public static let Asics = "application/vnd.etsi.asic-s+zip"  // Also .scs
        public static let Ddoc = "application/x-ddoc"
        public static let Bdoc = "application/vnd.bdoc-1.0"
        public static let Adoc = "application/vnd.lt.archyvai.adoc-2008"
        public static let SignatureContainers = [Asice, Asics, Ddoc, Bdoc, Adoc]
        public static let SivaContainers = [Ddoc, Asics]
        public static let UnsignableContainers = [Adoc, Ddoc, Asics]

        public static let Pdf = "application/pdf"

        public static let Container = "application/octet-stream"
        public static let Default = "text/plain"
    }

    public struct Extension {
        public static let Pdf = "pdf"
        public static let Asice = "asice"
        public static let Asics = "asics"
        public static let Ddoc = "ddoc"
        public static let Sce = "sce"
        public static let Adoc = "adoc"
        public static let Bdoc = "bdoc"
        public static let Edoc = "edoc"

        public static let Cdoc = "cdoc"
        public static let Cdoc2 = "cdoc2"

        public static let Scs = "scs"
        public static let Default = Asice

        public static let AsicsContainers = [Asics, Scs]
        public static let CryptoContainers = [Cdoc, Cdoc2]

        public static let UnsignableContainerExtensions = [Adoc, Ddoc] + AsicsContainers
    }

    public struct Identifier {
        public static let Group = "group.ee.ria.digidoc.ios"
        public static let GroupDownload = "group.ee.ria.digidoc.ios.download"
    }

    public struct Folder {
        public static let Temp = "tempfiles"
        public static let Shared = "shareddownloads"
        public static let SavedFiles = "savedfiles"
        public static let Logs = "logfiles"
        public static let SivaCert = "sivacert"
        public static let TSACert = "tsacert"
        public static let EncryptionKeyTransferCert = "keytransfercert"
    }

    public struct FileBaseName {
        public static let SiVaCert = "siva_cert"
        public static let TSACert = "tsa_cert"
        public static let EncryptionKeyTransferCert = "key_transfer_cert"
    }

    public struct Configuration {
        public static let CachedConfigJson = "active-config.json"
        public static let CachedConfigPub = "active-config.pub"
        public static let CachedConfigRsa = "active-config.rsa"
        public static let CacheConfigFolder = "config"

        public static let DefaultConfigJson = "\(CacheConfigFolder)/default-config.json"
        public static let DefaultConfigPub = "\(CacheConfigFolder)/default-config.pub"
        public static let DefaultConfigRsa = "\(CacheConfigFolder)/default-config.rsa"
        public static let DefaultConfigurationPropertiesFileName =
            "\(CacheConfigFolder)/configuration"

        public static let UpdateDatePropertyName = "configurationUpdateDate"
        public static let LastUpdateCheckDatePropertyName = "lastUpdateCheckDate"
        public static let VersionSerialPropertyName = "versionSerial"

        public static let TslFilesFolder = "tslFiles"

        public static let DefaultTimeout = 5.0
    }

    public struct MobileId {
        public static let DefaultCountryCode = "372"
        public static let DisplayTextFormat = "GSM-7"
    }

    public struct Validation {
        public static let MaximumPersonalCodeLength = 11
        public static let MaximumLatvianPersonalCodeLength = 12
        public static let MinimumPhoneNumberLength = 10
        public static let AllowedPhoneNumberCountryCodes = ["370", "372"]
    }

    public struct Signing {
        public static let RelyingPartyName = "RIA DigiDoc"
        public static let RelyingPartyUUID = "00000000-0000-0000-0000-000000000000"
        public static let HashType = "SHA256"
        public static let Timeout = 120 // Seconds
        public static let DefaultTimeout = 5 // Seconds
    }
}
