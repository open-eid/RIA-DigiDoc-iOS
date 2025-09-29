import Foundation
import CoreNFC
import CommonCrypto
import CryptoTokenKit
internal import SwiftECC
import BigInt
import Security

public enum UnblockPINError: Error {
    case missingRequiredParameter
    case failed
    case general
}

@MainActor
class OperationUnblockPin: NSObject {
    private var session: NFCTagReaderSession?
    private var CAN: String = ""
    private var codeType: CodeType?
    private var puk: String?
    private var newPin: String?
    private let nfcMessage: String = "Palun asetage oma ID-kaart vastu nutiseadet."
    private let connection = NFCConnection()
    private var continuation: CheckedContinuation<Void, Error>?

    public func startReading(CAN: String, codeType: CodeType, puk: String, newPin: String) async throws {

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            guard NFCTagReaderSession.readingAvailable else {
                continuation.resume(throwing: IdCardInternalError.nfcNotSupported)
                return
            }

            self.CAN = CAN
            self.codeType = codeType
            self.puk = puk
            self.newPin = newPin
            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
            session?.alertMessage = nfcMessage
            session?.begin()
        }
    }
}

extension OperationUnblockPin: @MainActor NFCTagReaderSessionDelegate {
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            defer {
                self.session = nil
            }

            guard let codeType = self.codeType, let puk = self.puk, let newPin = self.newPin else {
                self.continuation?.resume(throwing: UnblockPINError.missingRequiredParameter)
                session.invalidate(errorMessage: "PINi vahetamine ebaõnnestus")
                return
            }
            do {
                session.alertMessage = "Hoidke ID-kaarti vastu nutiseadet kuni andmeid loetakse."
                let tag = try await self.connection.setup(session, tags: tags)
                let cardCommands = try await self.connection.getCardCommands(session, tag: tag, CAN: self.CAN)
                do {
                    try await cardCommands.unblockCode(codeType, puk: puk, newCode: newPin)
                } catch {
                    throw UnblockPINError.failed
                }

                self.continuation?.resume(with: .success(()))
                session.alertMessage = "PIN vahetatud"
                session.invalidate()
            } catch {
                session.invalidate(errorMessage: "PINi vahetamine ebaõnnestus")
                self.continuation?.resume(throwing: error)
            }
        }
    }

    func tagReaderSessionDidBecomeActive(_: NFCTagReaderSession) { }

    func tagReaderSession(_: NFCTagReaderSession, didInvalidateWithError _: Error) {
        self.session = nil
    }
}
