// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import nfclib

struct MyEidRootView: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(NavigationPathManager.self) private var pathManager

    var body: some View {
        NFCView(
            actionType: .myeid,
            actionMethods: [.idCardViaNFC],
            isWebEidAuthenticating: .constant(false),
            onSuccess: { _ in }
        )
    }
}

#Preview {
    MyEidRootView()
        .environment(Container.shared.languageSettings())
        .environment(Container.shared.themeSettings())
        .environment(NavigationPathManager())
}
