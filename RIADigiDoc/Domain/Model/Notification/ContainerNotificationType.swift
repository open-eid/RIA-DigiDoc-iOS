// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

public enum ContainerNotificationType: Sendable, Hashable {
    case xadesFile
    case cadesFile
    case emptyFile
    case unsupportedContainer
    case unknownSignatures(count: Int)
    case invalidSignatures(count: Int)
}
