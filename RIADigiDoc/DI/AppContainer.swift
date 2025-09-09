import CommonsLib
import ConfigLib
import FactoryKit
import Foundation
import UtilsLib

extension Container {
    var librarySetup: Factory<LibrarySetup> {
        self {
            LibrarySetup(
                configurationLoader: self.configurationLoader(),
                configurationRepository: self.configurationRepository(),
                fileManager: self.fileManager(),
                tslUtil: self.tslUtil()
            )
        }
        .shared
    }

    var fileOpeningService: Factory<FileOpeningServiceProtocol> {
        self {
            FileOpeningService(
                fileUtil: self.fileUtil(),
                fileInspector: self.fileInspector(),
                fileManager: self.fileManager()
            )
        }
    }

    var fileOpeningRepository: Factory<FileOpeningRepositoryProtocol> {
        self { FileOpeningRepository(fileOpeningService: self.fileOpeningService()) }
            .shared
    }

    var sharedContainerViewModel: Factory<SharedContainerViewModelProtocol> {
        self { SharedContainerViewModel() }
            .shared
    }

    @MainActor
    var homeViewModel: Factory<HomeViewModel> {
        self { @MainActor in
            HomeViewModel(sharedContainerViewModel: self.sharedContainerViewModel())
        }
    }

    @MainActor
    var fileOpeningViewModel: Factory<FileOpeningViewModel> {
        self {
            @MainActor in
            FileOpeningViewModel(
                fileOpeningRepository: self.fileOpeningRepository(),
                sharedContainerViewModel: self.sharedContainerViewModel(),
                fileUtil: self.fileUtil(),
                fileManager: self.fileManager()
            )
        }
    }

    @MainActor
    var signingViewModel: Factory<SigningViewModel> {
        self {
            @MainActor in
            SigningViewModel(
                sharedContainerViewModel: self.sharedContainerViewModel(),
                fileOpeningService: self.fileOpeningService(),
                mimeTypeCache: self.mimeTypeCache(),
                fileUtil: self.fileUtil(),
                fileManager: self.fileManager()
            )
        }
    }

    @MainActor
    var languageSettings: Factory<LanguageSettings> {
        self { @MainActor in LanguageSettings(dataStore: self.dataStore()) }.singleton
    }

    var dataStore: Factory<DataStore> {
        self { DataStore() }.singleton
    }

    @MainActor
    var contentViewModel: Factory<ContentViewModel> {
        self {
            @MainActor in
            ContentViewModel(
                fileUtil: self.fileUtil(),
                fileManager: self.fileManager()
            )
        }
    }

    @MainActor
    var recentDocumentsViewModel: Factory<RecentDocumentsViewModel> {
        self {
            @MainActor in
            RecentDocumentsViewModel(
                sharedContainerViewModel: self.sharedContainerViewModel(),
                fileManager: self.fileManager()
            )
        }
    }

    @MainActor
    var diagnosticsViewModel: Factory<DiagnosticsViewModel> {
        self { @MainActor in
            DiagnosticsViewModel(
                containerWrapper: self.containerWrapper(),
                fileManager: self.fileManager(),
                configurationLoader: self.configurationLoader(),
                configurationRepository: self.configurationRepository(),
                tslUtil: self.tslUtil()
            )
        }
    }

    @MainActor
    var languageChooserViewModel: Factory<LanguageChooserViewModel> {
        self { @MainActor in
            LanguageChooserViewModel(languageSettings: self.languageSettings())
        }
    }

    @MainActor
    var signatureDetailViewModel: Factory<SignatureDetailViewModel> {
        self { @MainActor in SignatureDetailViewModel() }
    }

    @MainActor
    var certificateDetailViewModel: Factory<CertificateDetailViewModel> {
        self { @MainActor in CertificateDetailViewModel() }
    }

    var signatureUtil: Factory<SignatureUtilProtocol> {
        self { SignatureUtil() }
    }
}
