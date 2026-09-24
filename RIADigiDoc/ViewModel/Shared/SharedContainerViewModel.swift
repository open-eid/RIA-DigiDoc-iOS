// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib
import CryptoSwift
import LibdigidocLibSwift

@Observable
@MainActor
class SharedContainerViewModel: SharedContainerViewModelProtocol {
    private var signedContainer: SignedContainerProtocol?
    private var cryptoContainer: CryptoContainerProtocol?
    private var fileOpeningResult: Result<[URL], Error>?
    private var addedFilesCount: Int = 0
    private var nestedContainers: [GeneralContainer] = []
    private var isSignatureAdded: Bool = false
    private var fileOpeningMethod: FileOpeningMethod = .all

    func setSignedContainer(_ signedContainer: SignedContainerProtocol?) {
        self.signedContainer = signedContainer
        addNestedContainer(signedContainer)
    }

    func setCryptoContainer(_ cryptoContainer: CryptoContainerProtocol?) {
        self.cryptoContainer = cryptoContainer
        addNestedContainer(cryptoContainer)
    }

    func setFileOpeningResult(fileOpeningResult: Result<[URL], Error>?) {
        self.fileOpeningResult = fileOpeningResult
    }

    func getFileOpeningResult() -> Result<[URL], Error>? {
        return fileOpeningResult
    }

    func setAddedFilesCount(addedFiles: Int) {
        self.addedFilesCount = addedFiles
    }

    func getAddedFilesCount() -> Int {
        return addedFilesCount
    }

    func setFileOpeningMethod(_ method: FileOpeningMethod) {
        self.fileOpeningMethod = method
    }

    func getFileOpeningMethod() -> FileOpeningMethod {
        return fileOpeningMethod
    }

    private func addNestedContainer(_ container: GeneralContainer?) {
        guard let container else { return }
        if !nestedContainers.contains(where: { $0 === container }) {
            nestedContainers.append(container)
        }
    }

    @discardableResult
    func removeLastContainer() -> GeneralContainer? {
        nestedContainers.popLast()
    }

    func clearContainers() {
        nestedContainers.removeAll()
    }

    func currentContainer() -> GeneralContainer? {
        nestedContainers.last
    }

    func isNestedContainer(_ container: GeneralContainer?) -> Bool {
        guard let container else { return false }
        return nestedContainers.count > 1 && currentContainer().map { $0 === container } == true
    }

    func containers() -> [GeneralContainer] {
        return nestedContainers
    }

    func setIsSignatureAdded(_ isAdded: Bool) {
        isSignatureAdded = isAdded
    }

    func getIsSignatureAdded() -> Bool {
        isSignatureAdded
    }
}
