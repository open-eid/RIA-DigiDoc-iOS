import Foundation
@testable import ConfigLib

public class TestConfigurationProvider {
    public static func mockConfigurationProvider(
        metaInfUrl: String = "https://someUrl.abc",
        metaInfDate: String = "1970-01-01",
        metaInfSerial: Int = 1,
        metaInfVersion: Int = 1,
        sivaUrl: String = "https://siva.someUrl.abc",
        tslUrl: String = "https://tsl.someUrl.abc",
        tslCerts: [String] = ["cert1", "cert2"],
        tsaUrl: String = "https://tsa.someUrl.abc",
        ocspUrls: [String: String] = ["url1": "issuer1"],
        ldapPersonUrl: String = "https://ldap-person.someUrl.abc",
        ldapCorpUrl: String = "https://ldap-corp.someUrl.abc",
        midRestUrl: String = "https://midrest.someUrl.abc",
        midSkRestUrl: String = "https://midskrest.someUrl.abc",
        sidV2RestUrl: String = "https://sidv2.someUrl.abc",
        sidV2SkRestUrl: String = "https://sidv2skrest.someUrl.abc",
        certBundle: [String] = ["certBundle1", "certBundle2"],
        ldapCerts: [String] = ["ldapCert1", "ldapCert2"],
        configurationLastUpdateCheckDate: Date? = Date(),
        configurationUpdateDate: Date? = Date()
    ) -> ConfigurationProvider {
        let metaInf = ConfigurationProvider.MetaInf(
            url: metaInfUrl,
            date: metaInfDate,
            serial: metaInfSerial,
            version: metaInfVersion
        )

        return ConfigurationProvider(
            metaInf: metaInf,
            sivaUrl: sivaUrl,
            tslUrl: tslUrl,
            tslCerts: tslCerts,
            tsaUrl: tsaUrl,
            ocspUrls: ocspUrls,
            ldapPersonUrl: ldapPersonUrl,
            ldapCorpUrl: ldapCorpUrl,
            midRestUrl: midRestUrl,
            midSkRestUrl: midSkRestUrl,
            sidV2RestUrl: sidV2RestUrl,
            sidV2SkRestUrl: sidV2SkRestUrl,
            certBundle: certBundle,
            ldapCerts: ldapCerts,
            configurationLastUpdateCheckDate: configurationLastUpdateCheckDate,
            configurationUpdateDate: configurationUpdateDate
        )
    }
}
