import Foundation

public class SmartToken: NSObject, AbstractSmartToken {
    // TODO: Replace with real smartcard token implementation
    public func getCertificate() async throws -> Data {
        return Data()
    }
    
    public func decrypt(_ data: Data) throws -> Data {
        return Data()
    }
    
    public func derive(_ data: Data) throws -> Data {
        return Data()
    }
    
    public func authenticate(_ data: Data) throws -> Data {
        return Data()
    }
    
    public func getCertificateSync() throws -> Data {
        return Data()
    }
}
