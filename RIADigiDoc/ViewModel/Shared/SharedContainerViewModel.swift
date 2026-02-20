/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
