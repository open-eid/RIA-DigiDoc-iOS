import Foundation
import Testing
import CommonsTestShared

@MainActor
struct SignatureDetailViewModelTests {

    private var viewModel: SignatureDetailViewModel!

    init() async throws {
        viewModel = SignatureDetailViewModel()
    }

    @Test
    func getIssuerName_ValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let issuerName = viewModel.getIssuerName(cert: sampleCert)

        #expect(issuerName == "TestCommonName")
    }

    @Test
    func getSubjectName_ValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let subjectName = viewModel.getSubjectName(cert: sampleCert)

        #expect(subjectName == "SubjectCommonName" )
    }

    @Test
    func getIssuerName_InvalidCertificate() async {
        let invalidCert = Data([0x00, 0x01, 0x02])

        let issuerName = viewModel.getIssuerName(cert: invalidCert)

        #expect(issuerName.isEmpty)
    }

    @Test
    func getSubjectName_InvalidCertificate() async {
        let invalidCert = Data([0x00, 0x01, 0x02])

        let subjectName = viewModel.getSubjectName(cert: invalidCert)

        #expect(subjectName.isEmpty)
    }
}
