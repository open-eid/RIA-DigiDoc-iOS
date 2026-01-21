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
import IdCardLib
import CommonsLib
import X509
import UtilsLib

@Observable
@MainActor
class IdCardViewModel: IdCardViewModelProtocol, Loggable {

    private let idCardRepository: IdCardRepositoryProtocol
    private let sharedMyEidSession: SharedMyEidSessionProtocol
    private let certificateUtil: CertificateUtilProtocol

    var errorMessage: String?

    var usbReaderStatus: UsbReaderStatus {
        sharedMyEidSession.usbReaderStatus
    }

    init(
        idCardRepository: IdCardRepositoryProtocol,
        sharedMyEidSession: SharedMyEidSessionProtocol,
        certificateUtil: CertificateUtilProtocol
    ) {
        self.idCardRepository = idCardRepository
        self.sharedMyEidSession = sharedMyEidSession
        self.certificateUtil = certificateUtil
    }

    func startDiscoveringReaders() async {
        await idCardRepository.startDiscoveringReaders()
    }

    func stopDiscoveringReaders() async {
        await idCardRepository.stopDiscoveringReaders()
        sharedMyEidSession.stopStatusStream()
    }

    func getIdCardData() async -> IdCardData? {
        do {
            let publicData = try await getPublicData()
            let authCertNotValidDate = try await readAuthenticationCertificateNotValidDate()
            let signCertNotValidDate = try await readSignatureCertificateNotValidDate()
            let retryCount = try await readCodeTryCounterRecord()
            let isPUKChangeable = try await isPukChangeable()

            return IdCardData(
                publicData: publicData,
                authCertNotValidDate: authCertNotValidDate,
                signCertNotValidDate: signCertNotValidDate,
                retryCount: retryCount,
                isPUKChangeable: isPUKChangeable
            )
        } catch {
            IdCardViewModel.logger().error(
                "Unable to read ID-card data. \(error)"
            )

            errorMessage = "General error"
            return nil
        }
    }

    func resetErrors() {
        errorMessage = nil
    }

    private func getPublicData() async throws -> CardInfo {
        IdCardViewModel.logger().debug(
            "ID-CARD: Getting public data from ID-card with reader"
        )

        return try await idCardRepository.getPublicData()
    }

    private func readAuthenticationCertificateNotValidDate() async throws -> String? {
        IdCardViewModel.logger().debug(
            "Reading authentication certificate from ID-card with reader"
        )

        let authCertData = try await idCardRepository.readAuthenticationCertificate()
        let authCertificate = certificateUtil.certificate(from: authCertData)
        guard let authCert = authCertificate else { return nil }
        return try getNotValidDate(from: authCert)
    }

    private func readSignatureCertificateNotValidDate() async throws -> String? {
        IdCardViewModel.logger().debug(
            "ID-CARD: Reading signature certificate from ID-card with reader"
        )

        let signCertData = try await idCardRepository.readSignatureCertificate()
        let signCertificate = certificateUtil.certificate(from: signCertData)
        guard let signCert = signCertificate else { return nil }
        return try getNotValidDate(from: signCert)
    }

    private func readCodeTryCounterRecord() async throws -> RetryCount {
        IdCardViewModel.logger().debug(
            "ID-CARD: Reading retry counter record from ID-card with reader"
        )

        let pin1RetryCount = try await idCardRepository.readCodeTryCounterRecord(for: .pin1)
        let pin2RetryCount = try await idCardRepository.readCodeTryCounterRecord(for: .pin2)
        let pukRetryCount = try await idCardRepository.readCodeTryCounterRecord(for: .puk)
        return RetryCount(
            pin1: pin1RetryCount,
            pin2: pin2RetryCount,
            puk: pukRetryCount
        )
    }

    private func isPukChangeable() async throws -> Bool {
        IdCardViewModel.logger().debug(
            "ID-CARD: Reading if PUK is changeable for this ID-card with reader"
        )

        return try await idCardRepository.isPUKChangeable()
    }

    private func getNotValidDate(from certificate: SecCertificate) throws -> String? {
        let certificate = try Certificate(certificate)
        let notValidAfter = certificate.notValidAfter
        return DateUtil.getFormattedDateTime(
            date: notValidAfter,
            isUTC: false
        ).date
    }
}
