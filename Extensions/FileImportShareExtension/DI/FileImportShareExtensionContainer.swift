// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit

extension Container {

    @MainActor
    var shareViewModel: Factory<ShareViewModel> {
        self {
            @MainActor in ShareViewModel(
                fileManager: self.fileManager(),
                resourceChecker: self.urlResourceChecker()
            )
        }
        .shared
    }
}
