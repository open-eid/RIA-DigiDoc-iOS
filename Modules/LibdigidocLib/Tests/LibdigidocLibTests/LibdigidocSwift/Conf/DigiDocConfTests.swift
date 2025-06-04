import Foundation
import Testing
import LibdigidocLibObjC
import ConfigLib
import UtilsLib

@testable import LibdigidocLibSwift

final class DigiDocConfTests {

    private let configurationProvider: ConfigurationProvider

    init() async throws {
        await ConfigLibAssembler.shared.initialize()
        await LibDigidocLibAssembler.shared.initialize()

        configurationProvider = TestConfigurationProviderUtil.getConfigurationProvider()
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
