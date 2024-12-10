import Foundation
import Testing
import Cuckoo
import LibdigidocLibObjC

@testable import LibdigidocLibSwift

final class DigiDocConfTests {

    init() async throws {
        await LibDigidocAssembler.shared.initialize()
    }

    @Test
    func initDigiDoc_successAndReInitialization() async {
        do {
            try await DigiDocConf.initDigiDoc()
            #expect(true)

            try await DigiDocConf.initDigiDoc()

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
