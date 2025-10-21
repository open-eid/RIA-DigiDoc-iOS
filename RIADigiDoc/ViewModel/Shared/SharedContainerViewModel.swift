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
import LibdigidocLibSwift

@MainActor
class SharedContainerViewModel: SharedContainerViewModelProtocol, ObservableObject {
    private var signedContainer: SignedContainerProtocol?
    private var fileOpeningResult: Result<[URL], Error>?
    private var addedFilesCount: Int = 0
    private var nestedContainers: [SignedContainerProtocol] = []

    func setSignedContainer(_ signedContainer: SignedContainerProtocol?) {
        self.signedContainer = signedContainer
        addNestedContainer(signedContainer)
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

    private func addNestedContainer(_ container: SignedContainerProtocol?) {
        guard let container else { return }
        if !nestedContainers.contains(where: { $0 === container }) {
            nestedContainers.append(container)
        }
    }

    @discardableResult
    func removeLastContainer() -> SignedContainerProtocol? {
        nestedContainers.popLast()
    }

    func clearContainers() {
        nestedContainers.removeAll()
    }

    func currentContainer() -> SignedContainerProtocol? {
        nestedContainers.last
    }

    func isNestedContainer(_ container: SignedContainerProtocol?) -> Bool {
        guard let container else { return false }
        return nestedContainers.count > 1 && currentContainer().map { $0 === container } == true
    }

    func containers() -> [SignedContainerProtocol] {
        return nestedContainers
    }
}
