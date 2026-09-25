// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI
import QuickLook

// swiftlint:disable unused_parameter
struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator

        let dismissAction = UIAction(
            title: "Done",
            handler: { [weak coordinator = context.coordinator] _ in
                coordinator?.dismiss()
            }
        )
        let doneButton = UIBarButtonItem(primaryAction: dismissAction)
        controller.navigationItem.leftBarButtonItem = doneButton

        let navController = UINavigationController(rootViewController: controller)

        let escCommand = UIKeyCommand(
            input: UIKeyCommand.inputEscape,
            modifierFlags: [],
            action: #selector(Coordinator.dismiss)
        )

        escCommand.wantsPriorityOverSystemBehavior = true

        navController.addKeyCommand(escCommand)

        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, url: url)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        @Binding var isPresented: Bool
        let url: URL

        init(isPresented: Binding<Bool>, url: URL) {
            self._isPresented = isPresented
            self.url = url
        }

        @objc func dismiss() {
            isPresented = false
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(
            _ controller: QLPreviewController,
            previewItemAt index: Int
        ) -> QLPreviewItem {
            url as NSURL
        }
    }
}

class PreviewQLController: QLPreviewController {
    var onEscape: (() -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addKeyCommand(UIKeyCommand(
            input: UIKeyCommand.inputEscape,
            modifierFlags: [],
            action: #selector(handleEscape)
        ))
    }

    @objc private func handleEscape() {
        onEscape?()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.key?.keyCode == .keyboardEscape }) {
            onEscape?()
            return
        }
        super.pressesBegan(presses, with: event)
    }
}
// swiftlint:enable unused_parameter
