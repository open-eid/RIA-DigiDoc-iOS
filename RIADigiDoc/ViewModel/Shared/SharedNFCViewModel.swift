import Foundation
import nfclib

@MainActor
class SharedNFCViewModel: SharedNFCViewModelProtocol, ObservableObject {
    let cardOperator = Operator()
    @Published var cardInfo: CardInfo?
    @Published var webEidData: WebEidData?
    @Published var authCert: String?
    @Published var signingCert: String?
    @Published var signingResult: String?
    @Published var hashedData: Data?
    @Published var hashedDataString: String?
    
    func readSigningCertificate(can: String) async {
        do {
            let cert = try await cardOperator.readSigningCertificate(CAN: can)
            guard let certSummary = SecCertificateCopySubjectSummary(cert) as? String else {
                self.signingCert = "Failed!"
                return
            }
            self.signingCert = "summary: \(certSummary)"
        } catch {
            // Handle error here
        }
    }
}
