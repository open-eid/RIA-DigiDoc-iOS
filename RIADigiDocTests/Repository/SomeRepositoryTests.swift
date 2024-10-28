import Testing

struct SomeRepositoryTests {

    var someRepository: SomeRepositoryProtocol

    init() async throws {
        someRepository = SomeRepository()
    }

    @Test func fetchSomeObject_success() async throws {
        let someObject = await someRepository.fetchSomeObject()

        #expect(someObject.id == 1)
        #expect(someObject.name == "Some Name")
    }
}
