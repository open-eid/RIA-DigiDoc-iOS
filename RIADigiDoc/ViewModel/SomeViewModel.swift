import Foundation
import LibdigidoclibSwift

@MainActor
class SomeViewModel: ObservableObject {
    @Published var someObject: SomeObject?

    private let someRepository: SomeRepositoryProtocol

    init(someRepository: SomeRepositoryProtocol) {
        self.someRepository = someRepository
    }

    func getSomeObject() async {
        someObject = await someRepository.fetchSomeObject()
    }
}
