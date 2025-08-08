import Foundation
import FactoryKit

public extension Container {

    var fileManager: Factory<FileManagerProtocol> {
        self { FileManagerWrapper() }
            .singleton
    }

    var fileInspector: Factory<FileInspectorProtocol> {
        self { FileInspector() }
    }

    var urlResourceChecker: Factory<URLResourceCheckerProtocol> {
        self { URLResourceChecker() }
    }

    var bundle: Factory<BundleProtocol> {
        self { Bundle.main }
    }
}
