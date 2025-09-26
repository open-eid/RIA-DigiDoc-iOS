//
//  OperationReadPublicData.swift
//  nfc-lib
//
//  Created by Timo Kallaste on 30.11.2023.
//

import Foundation
import CoreNFC
import CommonCrypto
import CryptoTokenKit
internal import SwiftECC
import BigInt

@MainActor final class OperationReadPublicData: NSObject {
    private var session: NFCTagReaderSession?
    private var CAN: String = ""
    private let nfcMessage: String = "Palun asetage oma ID-kaart vastu nutiseadet."
    private let connection = NFCConnection()
    private var continuation: CheckedContinuation<CardInfo, Error>?

    public func startReading(CAN: String) async throws -> CardInfo {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }

            self.CAN = CAN
            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
            session?.alertMessage = nfcMessage
            session?.begin()
        }
    }
}

extension OperationReadPublicData: @MainActor NFCTagReaderSessionDelegate {
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Task {
            do {
                session.alertMessage = "Hoidke ID-kaarti vastu nutiseadet kuni andmeid loetakse."
                let tag = try await connection.setup(session, tags: tags)
                let cardCommands = try await connection.getCardCommands(session, tag: tag, CAN: CAN)
                let cardInfo = try await cardCommands.readPublicData()

                continuation?.resume(with: .success(cardInfo))
                session.alertMessage = "Andmed loetud"
                session.invalidate()
            } catch {
                session.invalidate(errorMessage: "Andmete lugemine ebaõnnestus")
                continuation?.resume(throwing: error)
            }
        }
    }

    func tagReaderSessionDidBecomeActive(_: NFCTagReaderSession) { }

    func tagReaderSession(_: NFCTagReaderSession, didInvalidateWithError _: Error) {
        self.session = nil
    }
}
