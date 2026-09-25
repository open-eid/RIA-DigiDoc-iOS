// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct FileItem: Identifiable {
    public let id = UUID()
    public let name: String
    public let url: URL
    public let lastOpened: Date
}
