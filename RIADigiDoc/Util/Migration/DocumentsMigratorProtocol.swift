// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

protocol DocumentsMigratorProtocol: Sendable {
    func migrateRecentDocuments() async throws
}
