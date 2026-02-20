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
