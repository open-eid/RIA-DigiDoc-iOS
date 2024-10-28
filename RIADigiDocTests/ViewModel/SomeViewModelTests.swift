import Testing
import Cuckoo

@MainActor
final class SomeViewModelTests {
    var mockSomeService: MockSomeServiceProtocol
    var someViewModel: SomeViewModel

    init() async throws {
        mockSomeService = MockSomeServiceProtocol()
        someViewModel = SomeViewModel(someService: mockSomeService)
    }

    @Test
    func getSomeObject_success() async {
        let expectedObject = SomeObject(id: 3, name: "Test Object")

        stub(mockSomeService) { mock in
            when(mock.fetchSomeObject()).thenReturn(expectedObject)
        }

        await someViewModel.getSomeObject()

        #expect(someViewModel.someObject?.id == expectedObject.id)
        #expect(someViewModel.someObject?.name == expectedObject.name)

        verify(mockSomeService).fetchSomeObject()
    }
}
