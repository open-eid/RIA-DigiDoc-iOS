import Foundation
import UtilsLib

public struct ConfigurationProvider: Codable, Sendable {

    public struct MetaInf: Codable, Sendable {
        let url: String
        let date: String
        let serial: Int
        let version: Int

        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case url = "URL"
            case date = "DATE"
            case serial = "SERIAL"
            case version = "VER"
        }

        public init(url: String, date: String, serial: Int, version: Int) {
            self.url = url
            self.date = date
            self.serial = serial
            self.version = version
        }
    }

    public let metaInf: MetaInf
    public let sivaUrl: String
    public let tslUrl: String
    public let tslCerts: [String]
    public let tsaUrl: String
    public let ocspUrls: [String: String]
    public let ldapPersonUrl: String
    public let ldapCorpUrl: String
    public let midRestUrl: String
    public let midSkRestUrl: String
    public let sidV2RestUrl: String
    public let sidV2SkRestUrl: String
    public let certBundle: [String]
    public let ldapCerts: [String]
    public var configurationLastUpdateCheckDate: Date?
    public var configurationUpdateDate: Date?

    private enum CodingKeys: String, CodingKey {
        case metaInf = "META-INF"
        case sivaUrl = "SIVA-URL"
        case tslUrl = "TSL-URL"
        case tslCerts = "TSL-CERTS"
        case tsaUrl = "TSA-URL"
        case ocspUrls = "OCSP-URL-ISSUER"
        case ldapPersonUrl = "LDAP-PERSON-URL"
        case ldapCorpUrl = "LDAP-CORP-URL"
        case midRestUrl = "MID-PROXY-URL"
        case midSkRestUrl = "MID-SK-URL"
        case sidV2RestUrl = "SIDV2-PROXY-URL"
        case sidV2SkRestUrl = "SIDV2-SK-URL"
        case certBundle = "CERT-BUNDLE"
        case ldapCerts = "LDAP-CERTS"
        case configurationLastUpdateCheckDate = "configurationLastUpdateCheckDate"
        case configurationUpdateDate = "configurationUpdateDate"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container
            .encodeIfPresent(
                configurationLastUpdateCheckDate?.formatted(),
                forKey: .configurationLastUpdateCheckDate
            )
        try container.encodeIfPresent(configurationUpdateDate?.formatted(), forKey: .configurationUpdateDate)

        try container.encode(metaInf, forKey: .metaInf)
        try container.encode(sivaUrl, forKey: .sivaUrl)
        try container.encode(tslUrl, forKey: .tslUrl)
        try container.encode(tslCerts, forKey: .tslCerts)
        try container.encode(tsaUrl, forKey: .tsaUrl)
        try container.encode(ocspUrls, forKey: .ocspUrls)
        try container.encode(ldapPersonUrl, forKey: .ldapPersonUrl)
        try container.encode(ldapCorpUrl, forKey: .ldapCorpUrl)
        try container.encode(midRestUrl, forKey: .midRestUrl)
        try container.encode(midSkRestUrl, forKey: .midSkRestUrl)
        try container.encode(sidV2RestUrl, forKey: .sidV2RestUrl)
        try container.encode(sidV2SkRestUrl, forKey: .sidV2SkRestUrl)
        try container.encode(certBundle, forKey: .certBundle)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        metaInf = try container.decode(MetaInf.self, forKey: .metaInf)
        sivaUrl = try container.decode(String.self, forKey: .sivaUrl)
        tslUrl = try container.decode(String.self, forKey: .tslUrl)
        tslCerts = try container.decode([String].self, forKey: .tslCerts)
        tsaUrl = try container.decode(String.self, forKey: .tsaUrl)
        ocspUrls = try container.decode([String: String].self, forKey: .ocspUrls)
        ldapPersonUrl = try container.decode(String.self, forKey: .ldapPersonUrl)
        ldapCorpUrl = try container.decode(String.self, forKey: .ldapCorpUrl)
        midRestUrl = try container.decode(String.self, forKey: .midRestUrl)
        midSkRestUrl = try container.decode(String.self, forKey: .midSkRestUrl)
        sidV2RestUrl = try container.decode(String.self, forKey: .sidV2RestUrl)
        sidV2SkRestUrl = try container.decode(String.self, forKey: .sidV2SkRestUrl)
        certBundle = try container.decode([String].self, forKey: .certBundle)
        ldapCerts = try container.decode([String].self, forKey: .ldapCerts)

        let lastUpdateCheckString = try container.decodeIfPresent(
            String.self,
            forKey: .configurationLastUpdateCheckDate
        )
        let updateDateString = try container.decodeIfPresent(String.self, forKey: .configurationUpdateDate)

        configurationLastUpdateCheckDate = lastUpdateCheckString.flatMap { DateUtil.dateFormatter.date(from: $0) }
        configurationUpdateDate = updateDateString.flatMap { DateUtil.dateFormatter.date(from: $0) }
    }

    public init(
        metaInf: MetaInf,
        sivaUrl: String,
        tslUrl: String,
        tslCerts: [String],
        tsaUrl: String,
        ocspUrls: [String: String],
        ldapPersonUrl: String,
        ldapCorpUrl: String,
        midRestUrl: String,
        midSkRestUrl: String,
        sidV2RestUrl: String,
        sidV2SkRestUrl: String,
        certBundle: [String],
        ldapCerts: [String],
        configurationLastUpdateCheckDate: Date?,
        configurationUpdateDate: Date?
    ) {
        self.metaInf = metaInf
        self.sivaUrl = sivaUrl
        self.tslUrl = tslUrl
        self.tslCerts = tslCerts
        self.tsaUrl = tsaUrl
        self.ocspUrls = ocspUrls
        self.ldapPersonUrl = ldapPersonUrl
        self.ldapCorpUrl = ldapCorpUrl
        self.midRestUrl = midRestUrl
        self.midSkRestUrl = midSkRestUrl
        self.sidV2RestUrl = sidV2RestUrl
        self.sidV2SkRestUrl = sidV2SkRestUrl
        self.certBundle = certBundle
        self.ldapCerts = ldapCerts
        self.configurationLastUpdateCheckDate = configurationLastUpdateCheckDate
        self.configurationUpdateDate = configurationUpdateDate
    }
}
