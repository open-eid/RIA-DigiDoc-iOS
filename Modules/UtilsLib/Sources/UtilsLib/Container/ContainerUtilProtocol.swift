// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

/// @mockable
public protocol ContainerUtilProtocol: Sendable {
    func getContainerFile(for fileURL: URL, in directory: URL) -> URL
    func getContainerDataFilesDir(containerFile: URL?) throws -> URL
    func getSignatureContainersDir() throws -> URL
}
