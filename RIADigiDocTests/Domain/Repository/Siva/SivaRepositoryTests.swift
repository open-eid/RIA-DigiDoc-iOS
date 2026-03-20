/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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
import Testing
import LibdigidocLibSwift
import LibdigidocLibSwiftMocks

struct SivaRepositoryTests {
    private let mockSivaService: SivaServiceProtocolMock

    private let repository: SivaRepositoryProtocol

    init() async throws {
        mockSivaService = SivaServiceProtocolMock()

        repository = SivaRepository(sivaService: mockSivaService)
    }

    @Test
    func isSivaConfirmationNeeded_returnTrue() async throws {
        let testFiles = [URL(fileURLWithPath: "/tmp/mockFile.pdf")]

        mockSivaService.isSivaConfirmationNeededHandler = { files in
            #expect(files == testFiles)
            return true
        }

        let isSivaConfirmationNeeded = await repository.isSivaConfirmationNeeded(files: testFiles)

        #expect(isSivaConfirmationNeeded)
        #expect(mockSivaService.isSivaConfirmationNeededCallCount == 1)
        #expect(mockSivaService.isSivaConfirmationNeededArgValues.first == testFiles)
    }

    @Test
    func isSivaConfirmationNeeded_returnFalse() async throws {
        let testFiles = [URL(fileURLWithPath: "/tmp/mockFile.pdf")]

        mockSivaService.isSivaConfirmationNeededHandler = { _ in false }

        let isSivaConfirmationNeeded = await repository.isSivaConfirmationNeeded(files: testFiles)

        #expect(!isSivaConfirmationNeeded)
        #expect(mockSivaService.isSivaConfirmationNeededCallCount == 1)
        #expect(mockSivaService.isSivaConfirmationNeededArgValues.first == testFiles)
    }

    @Test
    func isTimestampedContainer_returnTrue() async {
        let signedContainer = SignedContainerProtocolMock()

        mockSivaService.isTimestampedContainerHandler = { container in
            #expect(container === signedContainer)
            return true
        }

        let isTimestampedContainer = await repository.isTimestampedContainer(signedContainer: signedContainer)

        #expect(isTimestampedContainer)
        #expect(mockSivaService.isTimestampedContainerCallCount == 1)
        #expect(mockSivaService.isTimestampedContainerArgValues.first === signedContainer)
    }

    @Test
    func isTimestampedContainer_returnFalse() async {
        let signedContainer = SignedContainerProtocolMock()

        mockSivaService.isTimestampedContainerHandler = { _ in false }

        let isTimestampedContainer = await repository.isTimestampedContainer(signedContainer: signedContainer)

        #expect(!isTimestampedContainer)
        #expect(mockSivaService.isTimestampedContainerCallCount == 1)
        #expect(mockSivaService.isTimestampedContainerArgValues.first === signedContainer)
    }

    @Test
    func getTimestampedContainer_success() async throws {
        let mainContainer = SignedContainerProtocolMock()
        let nestedContainer = SignedContainerProtocolMock()

        mockSivaService.getTimestampedContainerHandler = { container in
            #expect(container === mainContainer)
            return nestedContainer
        }

        let getTimestampedContainer = try await repository.getTimestampedContainer(parentContainer: mainContainer)

        #expect(getTimestampedContainer === nestedContainer)
        #expect(mockSivaService.getTimestampedContainerCallCount == 1)
        #expect(mockSivaService.getTimestampedContainerArgValues.first === mainContainer)
    }

    @Test
    func getTimestampedContainer_throwErrorWhenContainerOpeningDidNotSucceed() async {
        mockSivaService.getTimestampedContainerHandler = { _ in
            throw DigiDocError.containerOpeningFailed(
                ErrorDetail(message: "Unable to open nested timestamped container")
            )
        }

        do {
            _ = try await repository.getTimestampedContainer(parentContainer: SignedContainerProtocolMock())
            Issue.record("Expected DigiDocError.containerOpeningFailed but no error was thrown")
            return
        } catch let error as DigiDocError {
            if case .containerOpeningFailed = error {
                #expect(true)
            } else {
                Issue.record("Unexpected DigiDocError case: \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
            return
        }

        #expect(mockSivaService.getTimestampedContainerCallCount == 1)
    }
}
