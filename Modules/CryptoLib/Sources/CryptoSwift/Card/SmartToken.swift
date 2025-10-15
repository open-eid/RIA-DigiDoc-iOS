import Foundation
import IdCardLib

@MainActor
public class SmartToken: AbstractSmartToken {
    let pin1: String
    let card: CardCommands

    public init(card: CardCommands, pin1: String) {
        self.card = card
        self.pin1 = pin1
    }

    func blocking<Data>(_ body: @escaping @Sendable () async throws -> Data) throws -> Data {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Data, Error>!

        Task { @MainActor in
            do {
                let output = try await body()
                result = .success(output)
            } catch {
                result = .failure(error)
            }
            semaphore.signal()
        }

        semaphore.wait()
        return try result.get()
    }

    public func getCertificate() throws -> Data {
        try blocking { try await self.getCertificate() }
    }

    public func getCertificate() async throws -> Data {
        return try await self.card.readAuthenticationCertificate()
    }

    public func decrypt(_ data: Data) throws -> Data {
        try blocking { try await self.card.decryptData(data, withPin1: self.pin1) }
    }

    public func derive(_ data: Data) throws -> Data {
        try blocking { try await self.card.decryptData(data, withPin1: self.pin1) }
    }

    public func authenticate(_ data: Data) throws -> Data {
        try blocking { try await self.card.authenticate(for: data, withPin1: self.pin1) }
    }
}
