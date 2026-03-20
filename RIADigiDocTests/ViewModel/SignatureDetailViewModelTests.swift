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
import CommonsTestShared

@MainActor
struct SignatureDetailViewModelTests {

    private let viewModel: SignatureDetailViewModel!

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
