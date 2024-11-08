import Testing
import Cuckoo

@MainActor
final class SomeViewModelTests {
    var mockSomeRepository: MockSomeRepositoryProtocol
    var someViewModel: SomeViewModel

    init() async throws {
        mockSomeRepository = MockSomeRepositoryProtocol()
        someViewModel = SomeViewModel(someRepository: mockSomeRepository)
    }

    @Test
    func getSomeObject_success() async {
        let expectedObject = SomeObject(id: 3, name: "Test Object")

        stub(mockSomeRepository) { mock in
            when(mock.fetchSomeObject()).thenReturn(expectedObject)
        }

        await someViewModel.getSomeObject()

        #expect(someViewModel.someObject?.id == expectedObject.id)
        #expect(someViewModel.someObject?.name == expectedObject.name)

        verify(mockSomeRepository).fetchSomeObject()
    }
}
