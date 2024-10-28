import Testing
import Cuckoo

struct SomeServiceTests {

    var mockSomeRepository: MockSomeRepositoryProtocol
    var someService: SomeServiceProtocol

    init() async throws {
        mockSomeRepository = MockSomeRepositoryProtocol()
        someService = SomeService(someRepository: mockSomeRepository)
    }

    @Test func fetchSomeObject_success() async {
        stub(mockSomeRepository) { someRepo in
            when(someRepo.fetchSomeObject()).then {
                return SomeObject(id: 2, name: "Mock Name")
          }
        }

        let someObject = await someService.fetchSomeObject()

        #expect(someObject.id == 2)
        #expect(someObject.name == "Mock Name")
    }
}
