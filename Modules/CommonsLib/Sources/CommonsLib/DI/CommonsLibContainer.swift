// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import FactoryKit

public extension Container {

    var fileManager: Factory<FileManagerProtocol> {
        self { FileManagerWrapper() }
            .singleton
    }

    var urlResourceChecker: Factory<URLResourceCheckerProtocol> {
        self { URLResourceChecker() }
    }

    var isLoggingEnabled: Factory<Bool> {
        // Default value, will be overridden on app initialization
        self { false }
            .singleton
    }
}
