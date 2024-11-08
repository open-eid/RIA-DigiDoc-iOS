import Testing

struct SomeServiceTests {
    var someService: SomeServiceProtocol

    init() async throws {
        someService = SomeService()
    }

    @Test func fetchSomeObject_success() async {
        let someObject = await someService.fetchSomeObject()

        #expect(someObject.id == 1)
        #expect(someObject.name == "Some Name")
    }
}
