import Testing
import Cuckoo

struct SomeRepositoryTests {

    var mockSomeService: MockSomeServiceProtocol

    var someRepository: SomeRepositoryProtocol

    init() async throws {
        mockSomeService = MockSomeServiceProtocol()
        someRepository = SomeRepository(someService: mockSomeService)
    }

    @Test func fetchSomeObject_success() async {
        stub(mockSomeService) { someService in
            when(someService.fetchSomeObject()).then {
                return SomeObject(id: 2, name: "Mock Name")
          }
        }

        let someObject = await someRepository.fetchSomeObject()

        #expect(someObject.id == 2)
        #expect(someObject.name == "Mock Name")
    }
}
