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
import UtilsLib

public actor ConfigurationProperty {

    var centralConfigurationServiceUrl: String
    var updateInterval: Int
    var versionSerial: Int
    var downloadDate: Date

    public init(centralConfigurationServiceUrl: String, updateInterval: Int, versionSerial: Int, downloadDate: Date) {
        self.centralConfigurationServiceUrl = centralConfigurationServiceUrl
        self.updateInterval = updateInterval
        self.versionSerial = versionSerial
        self.downloadDate = downloadDate
    }

    func update(
        centralConfigurationServiceUrl: String,
        updateInterval: Int,
        versionSerial: Int,
        downloadDate: Date
    ) async {
        self.centralConfigurationServiceUrl = centralConfigurationServiceUrl
        self.updateInterval = updateInterval
        self.versionSerial = versionSerial
        self.downloadDate = downloadDate
    }

    static func fromProperties(properties: [String: String]) throws -> ConfigurationProperty {
        guard let url = properties["central-configuration-service.url"] else {
            throw ConfigurationPropertyError.missingOrInvalidProperty("central-configuration-service.url")
        }

        guard let updateIntervalString = properties["configuration.update-interval"],
              let updateInterval = Int(updateIntervalString) else {
            throw ConfigurationPropertyError.missingOrInvalidProperty("configuration.update-interval")
        }

        guard let versionSerialString = properties["configuration.version-serial"],
              let versionSerial = Int(versionSerialString) else {
            throw ConfigurationPropertyError.missingOrInvalidProperty("configuration.version-serial")
        }

        guard let downloadDateString = properties["configuration.download-date"],
              let downloadDate = DateUtil.configurationDateFormatter.date(from: downloadDateString) else {
            throw ConfigurationPropertyError.missingOrInvalidProperty("configuration.download-date")
        }

        return ConfigurationProperty(centralConfigurationServiceUrl: url,
                                     updateInterval: updateInterval,
                                     versionSerial: versionSerial,
                                     downloadDate: downloadDate)
    }
}
