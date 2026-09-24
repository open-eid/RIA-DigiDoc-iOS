// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

@Observable
class NavigationPathManager {
    var path = NavigationPath()

    func navigate(to destination: NavigationDestination) {
        path.append(destination)
    }

    func replaceLast(_ numberOfValues: Int = 1, to destination: NavigationDestination) {
        path.removeLast(numberOfValues)
        navigate(to: destination)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
