import Foundation
import Testing
import CommonsTestShared

final class SignatureDetailViewModelTests {

    private var viewModel: SignatureDetailViewModel!

    init() async throws {
        viewModel = await SignatureDetailViewModel()
    }

    deinit {
        viewModel = nil
    }

    @Test
    func getIssuerName_ValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let issuerName = await viewModel.getIssuerName(cert: sampleCert)

        #expect("TestCommonName" == issuerName)
    }

    @Test
    func getSubjectName_ValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let subjectName = await viewModel.getSubjectName(cert: sampleCert)

        #expect("SubjectCommonName" == subjectName)
    }

    @Test
    func getIssuerName_InvalidCertificate() async {
        let invalidCert = Data([0x00, 0x01, 0x02])

        let issuerName = await viewModel.getIssuerName(cert: invalidCert)

        #expect("" == issuerName)
    }

    @Test
    func getSubjectName_InvalidCertificate() async {
        let invalidCert = Data([0x00, 0x01, 0x02])

        let subjectName = await viewModel.getSubjectName(cert: invalidCert)

        #expect("" == subjectName)
    }
}
