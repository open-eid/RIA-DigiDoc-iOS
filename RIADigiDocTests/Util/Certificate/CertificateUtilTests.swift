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
import Testing

@MainActor
final class CertificateUtilTests {

    private let certificateUtil: CertificateUtilProtocol!

    init() async throws {
        certificateUtil = CertificateUtil()
    }

    @Test
    func pemToDerData_successWithMultiLinePEMData() {
        let pemString = """
                -----BEGIN CERTIFICATE-----
                MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7VX
                GqR7wJ8Z2Q1NxF3mP9K5L8M3nR6tY4uI7oP2qS8vW1X2Y3
                -----END CERTIFICATE-----
                """
        guard let pemData = pemString.data(using: .utf8) else { return }
        let expectedBase64 =
        "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7VXGqR7wJ8Z2Q1NxF3mP9K5L8M3nR6tY4uI7oP2qS8vW1X2Y3"
        let expectedDerData = Data(base64Encoded: expectedBase64)

        let result = certificateUtil.pemToDerData(fromPEM: pemData)

        #expect(result == expectedDerData)
    }

    @Test
    func pemToDerData_returnNilWithOnlyHeaders() {
        let pemString = """
                -----BEGIN CERTIFICATE-----
                -----END CERTIFICATE-----
                """
        guard let pemData = pemString.data(using: .utf8) else { return }

        let result = certificateUtil.pemToDerData(fromPEM: pemData)

        #expect(result == nil)
    }

    @Test
    func pemToDerData_successWithNoHeaders() {
        let pemString = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA7VX"
        guard let pemData = pemString.data(using: .utf8) else { return }
        let expectedDerData = Data(base64Encoded: pemString)

        let result = certificateUtil.pemToDerData(fromPEM: pemData)

        #expect(result == expectedDerData)
    }

    @Test
    func pemToDerData_returnNilWithEmptyData() {
        let emptyData = Data()

        let result = certificateUtil.pemToDerData(fromPEM: emptyData)

        #expect(result == nil)
    }

    @Test
    func pemToDerData_returnNilWhenDataIsNotUtf8() {
        let invalidUtf8 = Data([0xFF, 0xFF, 0xFF])

        let result = certificateUtil.pemToDerData(fromPEM: invalidUtf8)

        #expect(result == nil)
    }

    @Test
    func getNotValidAfterWithExpiredLabel_success() {
        let pemString = """
            -----BEGIN CERTIFICATE-----
            MIIEDTCCAvWgAwIBAgIUSqorLsfSI1K5t/9YhPnHqf3MBc4wDQYJKoZIhvcNAQEL
            BQAwgZUxCzAJBgNVBAYTAkVFMQ4wDAYDVQQIDAVIYXJqdTEQMA4GA1UEBwwHVGFs
            bGlubjEOMAwGA1UECgwFTXlPcmcxDzANBgNVBAsMBk15VW5pdDESMBAGA1UEAwwJ
            VGVzdCBDZXJ0MR8wHQYJKoZIhvcNAQkBFhB0ZXN0QGV4YW1wbGUuY29tMQ4wDAYD
            VQQFEwUxMjM0NTAeFw0yNTEwMTYxMDMyMjJaFw0yNjEwMTYxMDMyMjJaMIGVMQsw
            CQYDVQQGEwJFRTEOMAwGA1UECAwFSGFyanUxEDAOBgNVBAcMB1RhbGxpbm4xDjAM
            BgNVBAoMBU15T3JnMQ8wDQYDVQQLDAZNeVVuaXQxEjAQBgNVBAMMCVRlc3QgQ2Vy
            dDEfMB0GCSqGSIb3DQEJARYQdGVzdEBleGFtcGxlLmNvbTEOMAwGA1UEBRMFMTIz
            NDUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCWT6mHYaf1xuNus76z
            MpVfk3HjI/ZxmswhbPG2LvAxldY7hXaCH8I0qMKorrnUqq3PmWZqG7Wzt78Lu5x8
            SGCJ+fGKH4Fo3cXnGqXQpU1xnwARE08N/g3GlogDH3y0MsbUD/B7Vq218BrWqlEU
            BiYI/aO7yfal4tZjVWugBalMWYehHhEOeh0ss4bDjGvEmmPAvRa36UoVbLGrjG95
            vcZv2xCC8YlWyj11X4ci7RZHrbpNrZ21xWr59VU7dTxKIDJ64wfgddryXkiyPHJ3
            R5Syf89qNn0I9SeEuSS13QsF0UEmcT/+rvXf2o8JXNWpPe2AGYVzlWAPHboOKHLI
            2FILAgMBAAGjUzBRMB0GA1UdDgQWBBRLFCXwhwHQ2dmE3xocNJOtPB0DtzAfBgNV
            HSMEGDAWgBRLFCXwhwHQ2dmE3xocNJOtPB0DtzAPBgNVHRMBAf8EBTADAQH/MA0G
            CSqGSIb3DQEBCwUAA4IBAQB53+FGg8nzYBIq8K/C00GUB2R0XYxUvKsfvecMOcHy
            Sl7TKOVZRDaL7Ji3G5CqouAwLFgnXqlf7aKYn4YfWNNXoS9Zm+eFJmvvWYJ/j/C0
            Ntz2mfcMcElrXvCGVnCNiHmkAw193jnya+3JxgbgE8rHoxYMHGwNTZUzCe7QGqw/
            tLdAYRezgyOx5NqaCq1GsOIP3n3eU9k92bMaWM0qtYHroL3H+oIvO0Whdsi2H7Fz
            W+L77xnqmKNZDyWwyQ8MsShy8VAJt75TOLPrR6clKou1q3H77ELDtwUAHw7hJF7W
            HERHoea8LiuAkZCFBh6fTEd2Wetgble1vYsK/+t+0Y4J
            -----END CERTIFICATE-----
            """
        guard let pemData = pemString.data(using: .utf8) else { return }

        guard let derData = certificateUtil.pemToDerData(fromPEM: pemData) else { return }

        let notValidAfter = certificateUtil.getNotValidAfterWithExpiredLabel(cert: derData, expiredLabel: "Expired")

        #expect(!notValidAfter.isEmpty)
    }

    @Test
    func getNotValidAfterWithExpiredLabel_successWithExpiredCert() {
        let pemString = """
            -----BEGIN CERTIFICATE-----
            MIID0jCCArqgAwIBAgIBATANBgkqhkiG9w0BAQsFADCBgTELMAkGA1UEBhMCRUUx
            EzARBgNVBAgMClRlc3QgU3RhdGUxEjAQBgNVBAcMCVRlc3QgQ2l0eTEaMBgGA1UE
            CgwRVGVzdCBPcmdhbml6YXRpb24xEjAQBgNVBAsMCVRlc3QgVW5pdDEZMBcGA1UE
            AwwQVGVzdCBDZXJ0aWZpY2F0ZTAeFw03MDAxMDEwMDAwMDBaFw03MDAxMDEyMzU5
            NTlaMIGBMQswCQYDVQQGEwJFRTETMBEGA1UECAwKVGVzdCBTdGF0ZTESMBAGA1UE
            BwwJVGVzdCBDaXR5MRowGAYDVQQKDBFUZXN0IE9yZ2FuaXphdGlvbjESMBAGA1UE
            CwwJVGVzdCBVbml0MRkwFwYDVQQDDBBUZXN0IENlcnRpZmljYXRlMIIBIjANBgkq
            hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp0tlBYafLZ4prdlTC+acvl+Z+p8oGxry
            oRu3i/FIa8qAS/XHkL7DfmLdHkT3/N8Lclm1mQtVRtcmsMLbiPb6KiywlgZRWh4Z
            JHS9t4WtcspxTjLjJ5DilmSPD1lepxCTq2VWECFPVSvh0Uo2Jr2WEWR0Az8MB0g6
            2qfPz+ywNLKGjMMPOJEgEKpEylos/yU42qOja8r3Ocb2Bid7CbA8y3GzSZmIjS+X
            GzmWqTe+4WaBTqAF3Wa5hhcVjbv9uYebgiF3puxYRGnqXR3wjxdH1Dt8VuP/cvic
            ynDIEPltZbWIhLMkvIiJirtFQ2MWIJzyTgOg0EO1nFVzHBkn3OsUsQIDAQABo1Mw
            UTAdBgNVHQ4EFgQUPcWKjZU/rXkRLqpssv/fUwpCkLAwHwYDVR0jBBgwFoAUPcWK
            jZU/rXkRLqpssv/fUwpCkLAwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsF
            AAOCAQEAQbAPahc6zJ37VxBN4xDn3xXShCxVF+3qMBw7YYJDU39NSnBfCjpCZUbG
            QTZAXc3iMB6luO5yoBbUSjX0YT6hqwAyb5s/2Aucv5Y8nLIl/GOAYYCWpZrFVkD0
            fmMt+rR6H5jFTtILsdsfMzmGkJ8xKWyjLUrGGALAzM1VSv1GPV+EpVjLe+bnTJ+E
            mvPkvo7970DVF13AqjtE5929PJaMu4t7QHzUItdc74VOVkQ6OcC71nOWhPXlcVi2
            AzZ3Zprwro1aLDmCQRSjBi1git9957oxuQfCtGvoeaP497hWZ4wJK/HRHLlGx1cu
            HorK9eEA1jaJ/RRRefXzhjOVHLOuYw==
            -----END CERTIFICATE-----
            """
        guard let pemData = pemString.data(using: .utf8) else { return }
        guard let derData = certificateUtil.pemToDerData(fromPEM: pemData) else { return }
        let expiredLabel = "Expired"

        let notValidAfter = certificateUtil.getNotValidAfterWithExpiredLabel(cert: derData, expiredLabel: expiredLabel)

        #expect(notValidAfter.contains(expiredLabel))
    }

    @Test
    func getSubjectAttribute_success() {
        let pemString = """
            -----BEGIN CERTIFICATE-----
            MIIEDTCCAvWgAwIBAgIUSqorLsfSI1K5t/9YhPnHqf3MBc4wDQYJKoZIhvcNAQEL
            BQAwgZUxCzAJBgNVBAYTAkVFMQ4wDAYDVQQIDAVIYXJqdTEQMA4GA1UEBwwHVGFs
            bGlubjEOMAwGA1UECgwFTXlPcmcxDzANBgNVBAsMBk15VW5pdDESMBAGA1UEAwwJ
            VGVzdCBDZXJ0MR8wHQYJKoZIhvcNAQkBFhB0ZXN0QGV4YW1wbGUuY29tMQ4wDAYD
            VQQFEwUxMjM0NTAeFw0yNTEwMTYxMDMyMjJaFw0yNjEwMTYxMDMyMjJaMIGVMQsw
            CQYDVQQGEwJFRTEOMAwGA1UECAwFSGFyanUxEDAOBgNVBAcMB1RhbGxpbm4xDjAM
            BgNVBAoMBU15T3JnMQ8wDQYDVQQLDAZNeVVuaXQxEjAQBgNVBAMMCVRlc3QgQ2Vy
            dDEfMB0GCSqGSIb3DQEJARYQdGVzdEBleGFtcGxlLmNvbTEOMAwGA1UEBRMFMTIz
            NDUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCWT6mHYaf1xuNus76z
            MpVfk3HjI/ZxmswhbPG2LvAxldY7hXaCH8I0qMKorrnUqq3PmWZqG7Wzt78Lu5x8
            SGCJ+fGKH4Fo3cXnGqXQpU1xnwARE08N/g3GlogDH3y0MsbUD/B7Vq218BrWqlEU
            BiYI/aO7yfal4tZjVWugBalMWYehHhEOeh0ss4bDjGvEmmPAvRa36UoVbLGrjG95
            vcZv2xCC8YlWyj11X4ci7RZHrbpNrZ21xWr59VU7dTxKIDJ64wfgddryXkiyPHJ3
            R5Syf89qNn0I9SeEuSS13QsF0UEmcT/+rvXf2o8JXNWpPe2AGYVzlWAPHboOKHLI
            2FILAgMBAAGjUzBRMB0GA1UdDgQWBBRLFCXwhwHQ2dmE3xocNJOtPB0DtzAfBgNV
            HSMEGDAWgBRLFCXwhwHQ2dmE3xocNJOtPB0DtzAPBgNVHRMBAf8EBTADAQH/MA0G
            CSqGSIb3DQEBCwUAA4IBAQB53+FGg8nzYBIq8K/C00GUB2R0XYxUvKsfvecMOcHy
            Sl7TKOVZRDaL7Ji3G5CqouAwLFgnXqlf7aKYn4YfWNNXoS9Zm+eFJmvvWYJ/j/C0
            Ntz2mfcMcElrXvCGVnCNiHmkAw193jnya+3JxgbgE8rHoxYMHGwNTZUzCe7QGqw/
            tLdAYRezgyOx5NqaCq1GsOIP3n3eU9k92bMaWM0qtYHroL3H+oIvO0Whdsi2H7Fz
            W+L77xnqmKNZDyWwyQ8MsShy8VAJt75TOLPrR6clKou1q3H77ELDtwUAHw7hJF7W
            HERHoea8LiuAkZCFBh6fTEd2Wetgble1vYsK/+t+0Y4J
            -----END CERTIFICATE-----
            """
        guard let pemData = pemString.data(using: .utf8) else { return }

        guard let derData = certificateUtil.pemToDerData(fromPEM: pemData) else { return }

        let issuer = certificateUtil.getSubjectAttribute(
            cert: derData, attribute: .RDNAttributeType.commonName)

        #expect(!issuer.isEmpty)
    }

    @Test
        func getSubjectAttribute_doesNotThrowWhenAttributeMissing() {
            let pemString = """
                -----BEGIN CERTIFICATE-----
                MIICyjCCAbKgAwIBAgIBATANBgkqhkiG9w0BAQsFADAXMRUwEwYDVQQDDAxleHBp
                cmVkLnRlc3QwHhcNMjUxMDE2MTA0ODAzWhcNMjUxMTE1MTA0ODAzWjAXMRUwEwYD
                VQQDDAxleHBpcmVkLnRlc3QwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
                AQC/1uAraYIr0aBTLvVUd1eWx5X3zXaPJE6l+yeiXGE3vr8kDkFKuhImDl2XggpM
                dsCMxIwYxvVS4WOrfzZhvNdg7NUlRidPepZnbWn7RScR2QzT+aDYnfd4X5ov3lE5
                HcTNSfZ+k5ZWcdnGvcg4kgI60Hl7bngSjLKjAT+I2F/ucBjVIUH1CZgP1MZ6ve1H
                dWUK95yPwTk0Z6HDBoCcz9NvLEc2Y9PPkXPHi/hfoMu3RKslbuIHPzED7CNYvIVw
                Nonww2EYzVqrPlhcVwGUB7EqNhgmLKhhtyADdIv9fzyBPnyBp0hzEPr+VOpC8R+G
                yh8jl/Ku6zrRx7yV3BMcNe45AgMBAAGjITAfMB0GA1UdDgQWBBR/S/ectwqtnXl5
                p8WkysctnC20JDANBgkqhkiG9w0BAQsFAAOCAQEAlIVpwnrgtaN+wbkxfRPnaQlC
                R4A83/rLp0M9wnaVBkGSleTZZv4KZvhlpCur9bYVHs80sPJa0BoM3HiU55frXuut
                MkWudAtQYMBtfLVd7i0qhZfYiDEceq+nwWhzlrlmeNDMSrZnO14O9O22ZucqC8tg
                G4ktcx0B6qWju4Zk8DtDty/khCVgSAkailRY/RLQZStMzhYPCkG5+bwDl2gJS6Xe
                8OOMaaPDvTAn3tNpC2ql7kcDQEA1uzgvEdo/xBqf1U0XEPXzJS0f0GKPIPxLLIm5
                3vEfRF9Lf001QXyGNkBc9G4vTNT2MYrGz8Pxmb+uSK8ZEgyi0EQ4KEhCbeWvMA==
                -----END CERTIFICATE-----
                """
            guard let pemData = pemString.data(using: .utf8) else { return }
            guard let derData = certificateUtil.pemToDerData(fromPEM: pemData) else { return }

            #expect(throws: Never.self) {
                let missingAttributeResult = certificateUtil.getSubjectAttribute(
                    cert: derData, attribute: .RDNAttributeType.streetAddress)
                #expect(missingAttributeResult.isEmpty)
            }
        }

        @Test
        func getSubjectAttribute_doesNotThrowOnInvalidDer() {
            let invalidDer = Data([0x00, 0x01, 0x02])

            #expect(throws: Never.self) {
                let result = certificateUtil.getSubjectAttribute(
                    cert: invalidDer, attribute: .RDNAttributeType.commonName)
                #expect(result == "")
            }
        }

        @Test
        func getNotValidAfterWithExpiredLabel_doesNotThrowOnInvalidDer() {
            let invalidDer = Data([0x00, 0x01, 0x02])

            #expect(throws: Never.self) {
                let result = certificateUtil.getNotValidAfterWithExpiredLabel(
                    cert: invalidDer, expiredLabel: "Expired")
                #expect(result == "")
            }
        }

}
