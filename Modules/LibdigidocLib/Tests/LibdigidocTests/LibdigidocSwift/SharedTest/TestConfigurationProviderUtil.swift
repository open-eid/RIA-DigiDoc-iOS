import Foundation
import ConfigLib

public struct TestConfigurationProviderUtil {

    public init() {}

    public static func getConfigurationProvider() -> ConfigurationProvider {
        return ConfigurationProvider(
            metaInf: ConfigurationProvider.MetaInf.init(
                url: "https://metaInfUrl.example.abc",
                date: Date().ISO8601Format(),
                serial: 100,
                version: 123
            ),
            sivaUrl: "https://siva.example.abc",
            tslUrl: "https://tsl.example.abc",
            tslCerts: [],
            tsaUrl: "https://tsa.example.abc",
            ocspUrls: [:],
            ldapPersonUrl: "https://ldapPerson.example.abc",
            ldapCorpUrl: "https://ldapCorp.example.abc",
            midRestUrl: "https://midRest.example.abc",
            midSkRestUrl: "https://midSkRest.example.abc",
            sidV2RestUrl: "https://sidv2Rest.example.abc",
            sidV2SkRestUrl: "https://sidv2SkRest.example.abc",
            certBundle: [],
            ldapCerts: [],
            configurationLastUpdateCheckDate: Date(),
            configurationUpdateDate: Date()
        )
    }
}
