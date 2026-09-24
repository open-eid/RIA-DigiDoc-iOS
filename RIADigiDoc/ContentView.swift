// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import FactoryKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
