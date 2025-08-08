import Foundation
import Testing
import LibdigidocLibObjC
import ConfigLib
import UtilsLib
import CommonsLib
import ConfigLibMocks
import CommonsLibMocks

@testable import LibdigidocLibSwift

final class DigiDocConfTests {

    private let mockConfigurationRepository: ConfigurationRepositoryProtocolMock
    private let mockConfigurationLoader: ConfigurationLoaderProtocolMock
    private let configurationProvider: ConfigurationProvider

    init() async throws {
        mockConfigurationRepository = ConfigurationRepositoryProtocolMock()
        mockConfigurationLoader = ConfigurationLoaderProtocolMock()
        configurationProvider = TestConfigurationProviderUtil.getConfigurationProvider()

        try DigiDocConf.observeConfigurationUpdates(configurationRepository: mockConfigurationRepository)

        try await mockConfigurationLoader.initConfiguration(cacheDir: URL(fileURLWithPath: "/mock/path"))
    }

    @Test
    func initDigiDoc_successAndReInitialization() async {
        do {
            try await DigiDocConf.initDigiDoc(configuration: configurationProvider)
            #expect(true)

            try await DigiDocConf.initDigiDoc(configuration: configurationProvider)

            Issue.record("Expected DigiDocError.alreadyInitialized to be thrown")
            return
        } catch let error as DigiDocError {
            switch error {
            case .alreadyInitialized:
                #expect(true)
            default:
                Issue.record("Unexpected error: \(error.localizedDescription)")
                return
            }
        } catch {
            Issue.record("Initialization failed with error: \(error.localizedDescription)")
            return
        }
    }
}
