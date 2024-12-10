import Foundation
import LibdigidocLibSwift
import Testing
import Cuckoo
import CommonsTestShared

final class SigningViewModelTests {
    private var mockSharedContainerViewModel: MockSharedContainerViewModel!
    private var viewModel: SigningViewModel!

    init() async throws {
        mockSharedContainerViewModel = MockSharedContainerViewModel()
        viewModel = await SigningViewModel(sharedContainerViewModel: mockSharedContainerViewModel)
    }

    deinit {
        viewModel = nil
        mockSharedContainerViewModel = nil
    }

    @Test
    func loadContainerData_successWithNewFile() async throws {
        let tempFile = TestFileUtil.createSampleFile()

        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [tempFile]
        )

        let containerDataFiles = await signedContainer.getDataFiles()
        let containerSignatures = await signedContainer.getSignatures()

        await viewModel.loadContainerData(signedContainer: signedContainer)

        let dataFiles = await viewModel.dataFiles
        let signatures = await viewModel.signatures

        #expect(containerDataFiles.count == dataFiles.count)
        #expect(containerSignatures.count == signatures.count)
    }

    @Test
    func loadContainerData_successWithExistingContainer() async throws {
        let containerFile = TestFileUtil.pathForResourceFile(fileName: "example", ext: "asice")

        guard let exampleContainer = containerFile else {
            Issue.record("Unable to get resource file")
            return
        }

        let signedContainer = try await SignedContainer.openOrCreate(
            dataFiles: [exampleContainer]
        )

        let containerDataFiles = await signedContainer.getDataFiles()
        let containerSignatures = await signedContainer.getSignatures()

        await viewModel.loadContainerData(signedContainer: signedContainer)

        let dataFiles = await viewModel.dataFiles
        let signatures = await viewModel.signatures

        #expect(containerDataFiles.count == dataFiles.count)
        #expect(containerSignatures.count == signatures.count)
    }

    @Test
    func loadContainerData_returnEmptyValuesWhenSignedContainerNil() async {
        await viewModel.loadContainerData(signedContainer: nil)

        let dataFiles = await viewModel.dataFiles
        let signatures = await viewModel.signatures

        #expect(dataFiles.isEmpty)
        #expect(signatures.isEmpty)
    }
}
