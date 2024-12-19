import UIKit
import SwiftUI

class ShareViewController: UIViewController, Sendable {

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewModel = ShareViewModel()

        viewModel.status = .processing

        let shareView = ShareView(viewModel: viewModel, statusChanged: {
            Task {
                await viewModel.importFiles(extensionContext: self.extensionContext)
            }
        }, completeRequest: { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        })

        let hostingController = UIHostingController(rootView: shareView)
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
    }
}
