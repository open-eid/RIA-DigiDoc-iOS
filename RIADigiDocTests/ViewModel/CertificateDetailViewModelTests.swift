import Foundation
import Testing
import CryptoKit
import X509
import SwiftASN1
import Security
import CommonsTestShared

struct CertificateDetailViewModelTests {

    private var viewModel: CertificateDetailViewModel!

    init() async throws {
        viewModel = CertificateDetailViewModel()
    }

    @Test
    func getSerialNumber_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let serialNumber = await viewModel.getSerialNumber(cert: sampleCert)

        #expect(serialNumber == "79:80:a8:17:21:7:5:fa:da:36:7b:29:e0:10:a0:2b:25:58:7f:2c")
    }

    @Test
    func getVersion_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let version = await viewModel.getVersion(cert: sampleCert)

        #expect(version == "X509v3")
    }

    @Test
    func getSubjectAttribute_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let subjectCN = await viewModel.getSubjectAttribute(
            cert: sampleCert,
            attribute: ASN1ObjectIdentifier.NameAttributes.commonName
        )

        #expect(subjectCN == "SubjectCommonName")
    }

    @Test
    func getIssuerAttribute_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let issuerCN = await viewModel.getIssuerAttribute(
            cert: sampleCert,
            attribute: ASN1ObjectIdentifier.NameAttributes.commonName
        )

        #expect(issuerCN == "TestCommonName")
    }

    @Test
    func getSignatureAlgorithm_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let signatureAlgorithm = await viewModel.getSignatureAlgorithm(cert: sampleCert)

        #expect(signatureAlgorithm == "SignatureAlgorithm.sha256WithRSAEncryption")
    }

    @Test
    func getNotValidBefore_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let notValidBefore = await viewModel.getNotValidBefore(cert: sampleCert)

        #expect(notValidBefore == "2025-01-31 17:02:12 +0000")
    }

    @Test
    func getNotValidAfter_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let notValidAfter = await viewModel.getNotValidAfter(cert: sampleCert)

        #expect(notValidAfter == "2027-05-06 17:02:12 +0000")
    }

    @Test
    func getSHA256Fingerprint_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let fingerprint = await viewModel.getSHA256Fingerprint(cert: sampleCert)

        #expect(fingerprint.count == 95)
    }

    @Test
    func getSHA1Fingerprint_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let fingerprint = await viewModel.getSHA1Fingerprint(cert: sampleCert)

        #expect(fingerprint.count == 59)
    }

    @Test
    func getPublicKeyAlgorithm_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let algorithm = await viewModel.getPublicKeyAlgorithm(cert: sampleCert)

        #expect(algorithm == "RSA")
    }

    @Test
    func getPublicKeyHexString_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        // swiftlint:disable line_length
        let expectedPublicKey = """
            30 82 01 0A 02 82 01 01 00 E3 38 1F F9 2C C4 D8 EC 76 88 0D 0B 4F 23 4A CD B3 3C 8E D4 6C 0D 7A 97 F6 3A 5E 97 6B 23 89 38 FD D5 F1 8D DB 0B 7A 5C 52 86 E7 95 F5 DF A6 14 EA A0 DC E7 60 A2 EE 57 64 F3 F5 BC C0 2C 8D 47 08 AF 53 B2 20 05 03 D0 C0 26 A1 08 23 E0 61 84 AD 04 8B 92 E5 68 7C 0E 48 75 8F 06 DE 53 9F C4 98 BC FB 77 EE 17 08 CF F7 D0 AD 14 7B 13 36 F1 8F CB A4 5B A3 55 EC B3 1C 56 BD AB B1 14 45 9E F3 CD 0A 47 84 8C 6C BB 9A 9C C9 3F 65 3B 61 AE 32 88 16 90 A6 87 65 70 B9 58 C2 CF 50 9C CA F0 C2 73 D5 E4 DA 4F 4C 9F A4 A3 A5 B0 28 A7 AA 72 EC 4E 52 41 F5 8F 79 49 6F 93 1D 35 A5 2D 2E 31 D5 5B EF 84 A5 E6 06 46 7F 48 6F 3D 71 75 AF 4C 80 11 53 E0 93 06 86 08 CB C7 B0 98 51 6B 7E 0C 3E 24 70 BE 4D E5 DA 43 1A CE 76 79 1C C6 FE D9 CE 72 4D F3 AD 61 E5 3B 75 5F E9 05 AB 0D 7E B3 02 03 01 00 01
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        // swiftlint:enable line_length

        let publicKeyHex = await viewModel.getPublicKeyHexString(cert: sampleCert)

        #expect(expectedPublicKey == publicKeyHex)
    }

    @Test
    func getKeyUsage_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let keyUsage = await viewModel.getKeyUsage(cert: sampleCert)

        #expect(keyUsage == "digitalSignature, keyEncipherment")
    }

    @Test
    func getSignature_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        // swiftlint:disable line_length
        let expectedSignature = """
            00 70 AD AB 74 EC E1 5A 8E A6 9E 56 13 8E 06 D9 77 20 A4 D6 72 AC E3 F8 EF 99 BC 78 31 F4 F2 FE D2 8C AB E3 88 98 4B C2 F1 35 20 DA 6C 94 CF 12 F6 F3 8A 74 58 20 95 5A 80 0B A3 68 70 B1 87 98 2D 26 E5 7E 70 C0 B2 3F 74 44 C6 50 94 3C 80 EE B2 04 AA B7 D7 BA 0A 9A 9A 3F A1 3C BC 0F A0 4C 99 2A 2A 53 90 89 93 D2 60 06 A9 A9 04 EB 70 64 88 FF 92 48 4C 2F 79 9F 18 52 BD 17 1B 7E BD 80 7C 9A 3F CC EF E9 74 EA 0E 44 18 1F 1E E4 25 00 87 23 CE FE C0 DF B7 5C F2 22 60 DE 6C AA B7 F4 67 5E 3B C3 F2 CE F1 AF 97 90 E0 83 E4 9B D3 6C 06 41 EA C2 C8 F5 D0 AF A1 E8 9F 77 7E 25 F4 98 43 9E 59 DB E1 28 E7 B3 30 B6 93 98 31 EF C0 8D 33 5A 45 F6 30 13 4B 70 3B 99 DC FE 4F 2B 6D 1B 89 2C FE 2E 7F 32 8A F8 D7 A7 E8 5E EA C8 12 1D 68 65 32 8E A3 1A 69 32 8C 2A EF 77 3A EA BA C7 D6
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        // swiftlint:enable line_length

        let signature = await viewModel.getSignature(cert: sampleCert)

        #expect(expectedSignature == signature)
    }

    @Test
    func getExtensions_successWithValidCertificate() async {
        let sampleCert = TestCertificateUtil.getSampleCertificate()

        let extensions = await viewModel.getExtensions(cert: sampleCert)

        #expect(extensions.count == 6)
    }

    @Test
    func certificateDataWithInvalidCertificateReturnsDefaultValues() async {
        let invalidCert = Data([0x00, 0x01, 0x02])

        #expect(await viewModel.getSerialNumber(cert: invalidCert).isEmpty)
        #expect(await viewModel.getVersion(cert: invalidCert).isEmpty)
        #expect(await viewModel.getSubjectAttribute(
                    cert: invalidCert,
                    attribute: ASN1ObjectIdentifier.NameAttributes.commonName).isEmpty
        )
        #expect(await viewModel.getIssuerAttribute(
                    cert: invalidCert,
                    attribute: ASN1ObjectIdentifier.NameAttributes.commonName).isEmpty
        )
        #expect(await viewModel.getSignatureAlgorithm(cert: invalidCert).isEmpty)
        #expect(await viewModel.getNotValidBefore(cert: invalidCert).isEmpty)
        #expect(await viewModel.getNotValidAfter(cert: invalidCert).isEmpty)
        #expect(await viewModel.getPublicKeyAlgorithm(cert: invalidCert).isEmpty)
        #expect(await viewModel.getPublicKeyHexString(cert: invalidCert).isEmpty)
        #expect(await viewModel.getKeyUsage(cert: invalidCert).isEmpty)
        #expect(await viewModel.getSignature(cert: invalidCert).isEmpty)
        #expect(await viewModel.getExtensions(cert: invalidCert).count == 0)
        #expect(await viewModel.getSHA256Fingerprint(cert: invalidCert) == SHA256.hash(data: invalidCert).hexString())
        #expect(
            await viewModel.getSHA1Fingerprint(cert: invalidCert) == Insecure.SHA1.hash(data: invalidCert).hexString()
        )
    }
}
