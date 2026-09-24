// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import CommonsLib
import CryptoSwift
import LibdigidocLibSwift

/// @mockable
@MainActor
public protocol SharedContainerViewModelProtocol: Sendable {
    func setSignedContainer(_ signedContainer: SignedContainerProtocol?)
    func setCryptoContainer(_ cryptoContainer: CryptoContainerProtocol?)
    func setFileOpeningResult(fileOpeningResult: Result<[URL], Error>?)
    func getFileOpeningResult() -> Result<[URL], Error>?
    func setAddedFilesCount(addedFiles: Int)
    func getAddedFilesCount() -> Int

    func currentContainer() -> GeneralContainer?
    func isNestedContainer(_ container: GeneralContainer?) -> Bool
    func containers() -> [GeneralContainer]
    @discardableResult func removeLastContainer() -> GeneralContainer?
    func clearContainers()

    func setIsSignatureAdded(_ isAdded: Bool)
    func getIsSignatureAdded() -> Bool

    func setFileOpeningMethod(_ method: FileOpeningMethod)
    func getFileOpeningMethod() -> FileOpeningMethod
}
