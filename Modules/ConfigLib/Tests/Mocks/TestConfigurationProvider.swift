import Foundation
import OSLog

@testable import ConfigLib

public class TestConfigurationProvider {
    private static let logger = Logger(subsystem: "ee.ria.digidoc.RIADigiDoc", category: "TestConfigurationProvider")

    public static func mockConfigurationProvider(
        metaInfUrl: String = "https://someUrl.abc",
        metaInfDate: String = "1970-01-01",
        metaInfSerial: Int = 1,
        metaInfVersion: Int = 1,
        sivaUrl: String = "https://siva.someUrl.abc",
        tslUrl: String = "https://tsl.someUrl.abc",
        tslCerts: [String] = ["cert1", "cert2"],
        tsaUrl: String = "https://tsa.someUrl.abc",
        ocspIssuers: [String: String] = ["url1": "issuer1"],
        ldapPersonUrl: String = "https://ldap-person.someUrl.abc",
        ldapCorpUrl: String = "https://ldap-corp.someUrl.abc",
        midRestUrl: String = "https://midrest.someUrl.abc",
        midSkRestUrl: String = "https://midskrest.someUrl.abc",
        sidV2RestUrl: String = "https://sidv2.someUrl.abc",
        sidV2SkRestUrl: String = "https://sidv2skrest.someUrl.abc",
        certBundle: [String] = ["certBundle1", "certBundle2"],
        ldapCerts: [String] = ["ldapCert1", "ldapCert2"],
        configurationLastUpdateCheckDate: Date? = Calendar(
            identifier: .gregorian)
            .date(from: DateComponents(year: 2025, month: 9, day: 2, hour: 15, minute: 22, second: 28)
        ),
        configurationUpdateDate: Date? = Calendar(
            identifier: .gregorian)
            .date(from: DateComponents(year: 2025, month: 9, day: 2, hour: 15, minute: 22, second: 28)
        ),
        cdoc2DefaultKeyserver: String = "https://cdoc2DefaultKeyserver.someUrl.abc",
        cdoc2UseKeyserver: Bool = false,
        cdoc2Conf: [String: [String: String]] = [
            "00000000-0000-0000-0000-000000000000": ["name": "test"]
        ]
    ) throws -> ConfigurationProvider {
        let metaInf = ConfigurationProvider.MetaInf(
            url: metaInfUrl,
            date: metaInfDate,
            serial: metaInfSerial,
            version: metaInfVersion
        )

        guard let sivaURL = URL(string: sivaUrl) else {
            TestConfigurationProvider.logger.error("'\(sivaUrl)' is not a valid URL")
            throw URLError(.badURL)
        }

        guard let tslURL = URL(string: tslUrl) else {
            TestConfigurationProvider.logger.error("'\(tslUrl)' is not a valid URL")
            throw URLError(.badURL)
        }

        let tslCertsData: [Data] = tslCerts.compactMap { $0.data(using: .utf8) }

        guard let tsaURL = URL(string: tsaUrl) else {
            TestConfigurationProvider.logger.error("'\(tsaUrl)' is not a valid URL")
            throw URLError(.badURL)
        }

        guard let ldapPersonURL = URL(string: ldapPersonUrl) else {
            TestConfigurationProvider.logger.error("'\(ldapPersonUrl)' is not a valid URL")
            throw URLError(.badURL)
        }

        guard let ldapCorpURL = URL(string: ldapCorpUrl) else {
            TestConfigurationProvider.logger.error("'\(ldapCorpUrl)' is not a valid URL")
            throw URLError(.badURL)
        }

        guard let midRestURL = URL(string: midRestUrl) else {
            TestConfigurationProvider.logger.error("'\(midRestUrl)' is not a valid URL")
            throw URLError(.badURL)
        }

        guard let midSkRestURL = URL(string: midSkRestUrl) else {
            TestConfigurationProvider.logger.error("'\(midSkRestUrl)' is not a valid URL")
            throw URLError(.badURL)
        }

        guard let sidV2RestURL = URL(string: sidV2RestUrl) else {
            TestConfigurationProvider.logger.error("'\(sidV2RestUrl)' is not a valid URL")
            throw URLError(.badURL)
        }

        guard let sidV2SkRestURL = URL(string: sidV2SkRestUrl) else {
            TestConfigurationProvider.logger.error("'\(sidV2SkRestUrl)' is not a valid URL")
            throw URLError(.badURL)
        }

        let certBundleData: [Data] = certBundle.compactMap { $0.data(using: .utf8) }

        let ldapCertsData: [Data] = ldapCerts.compactMap { $0.data(using: .utf8) }

        return ConfigurationProvider(
            metaInf: metaInf,
            sivaUrl: sivaURL,
            tslUrl: tslURL,
            tslCerts: tslCertsData,
            tsaUrl: tsaURL,
            ocspIssuers: ocspIssuers,
            ldapPersonUrl: ldapPersonURL,
            ldapCorpUrl: ldapCorpURL,
            midRestUrl: midRestURL,
            midSkRestUrl: midSkRestURL,
            sidV2RestUrl: sidV2RestURL,
            sidV2SkRestUrl: sidV2SkRestURL,
            certBundle: certBundleData,
            ldapCerts: ldapCertsData,
            configurationLastUpdateCheckDate: configurationLastUpdateCheckDate,
            configurationUpdateDate: configurationUpdateDate,
            cdoc2DefaultKeyserver: cdoc2DefaultKeyserver,
            cdoc2UseKeyserver: cdoc2UseKeyserver,
            cdoc2Conf: cdoc2Conf
        )
    }
}
