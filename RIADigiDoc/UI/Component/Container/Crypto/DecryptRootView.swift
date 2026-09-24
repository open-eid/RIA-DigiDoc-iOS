// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import FactoryKit
import CryptoSwift
import nfclib
import CommonsLib

struct DecryptRootView: View {
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(LanguageSettings.self) private var languageSettings

    private let cryptoContainer: GeneralContainer?

    private let sharedContainerViewModel: SharedContainerViewModelProtocol

    private var containerSuccessfullyDecryptedMessage: String {
        languageSettings.localized("Container successfully decrypted")
    }

    init() {
        self.sharedContainerViewModel = Container.shared.sharedContainerViewModel()
        self.cryptoContainer = sharedContainerViewModel.currentContainer()
    }

    var body: some View {
        ZStack {
            if let container = cryptoContainer as? CryptoContainerProtocol {
                NFCView(
                    actionType: .decrypt,
                    actionMethods: [.idCardViaNFC],
                    pinType: CodeType.pin1,
                    isWebEidAuthenticating: .constant(false),
                    cryptoContainer: container,
                    onSuccessDecrypt: { container in
                        sharedContainerViewModel.removeLastContainer()
                        sharedContainerViewModel.setCryptoContainer(container)

                        showContainerSuccessfullyDecryptedMessage()
                    }
                )
            }
        }
    }

    func showContainerSuccessfullyDecryptedMessage() {
        Toast.show(languageSettings.localized(
            containerSuccessfullyDecryptedMessage
        ), type: .success)

        if voiceOverEnabled {
            AccessibilityUtil.announceMessage(containerSuccessfullyDecryptedMessage)
        }
    }
}

#Preview {
    DecryptRootView()
}
