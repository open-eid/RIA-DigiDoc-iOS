/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

import CommonsLib
import ConfigLib
import FactoryKit
import Foundation
import UtilsLib

extension Container {
    @MainActor
    var librarySetup: Factory<LibrarySetup> {
        self { @MainActor in
            LibrarySetup(
                configurationLoader: self.configurationLoader(),
                configurationRepository: self.configurationRepository(),
                fileManager: self.fileManager(),
                tslUtil: self.tslUtil(),
                dataStore: self.dataStore(),
                advancedSettingsRepository: self.advancedSettingsRepository(),
                keychainStore: self.keychainStore(),
                proxyUtil: self.proxyUtil()
            )
        }
        .shared
    }

    @MainActor
    var fileOpeningService: Factory<FileOpeningServiceProtocol> {
        self { @MainActor in
            FileOpeningService(
                fileUtil: self.fileUtil(),
                fileInspector: self.fileInspector(),
                fileManager: self.fileManager()
            )
        }
    }

    @MainActor
    var fileOpeningRepository: Factory<FileOpeningRepositoryProtocol> {
        self { @MainActor in
            FileOpeningRepository(
                fileOpeningService: self.fileOpeningService(),
                sivaService: self.sivaService()
            )
        }
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
                sivaRepository: self.sivaRepository(),
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
                mimeTypeDecoder: self.mimeTypeDecoder(),
                fileUtil: self.fileUtil(),
                fileManager: self.fileManager(),
                sivaRepository: self.sivaRepository()
            )
        }
    }

    public var certificateUtil: Factory<CertificateUtilProtocol> {
        self { @MainActor in CertificateUtil() }
    }

    public var proxyUtil: Factory<ProxyUtilProtocol> {
        self { @MainActor in ProxyUtil(
            dataStore: self.dataStore(),
            keychainStore: self.keychainStore()
        ) }
    }

    @MainActor
    var languageSettings: Factory<LanguageSettings> {
        self { @MainActor in LanguageSettings(dataStore: self.dataStore()) }.singleton
    }

    @MainActor
    var themeSettings: Factory<ThemeSettings> {
        self { @MainActor in ThemeSettings(dataStore: self.dataStore()) }.singleton
    }

    @MainActor
    var dataStore: Factory<DataStore> {
        self { @MainActor in DataStore() }.singleton
    }

    @MainActor
    var keychainStore: Factory<KeychainStore> {
        self { @MainActor in KeychainStore() }.singleton
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
                tslUtil: self.tslUtil(),
                dataStore: self.dataStore(),
                proxyUtil: self.proxyUtil()
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

    @MainActor
    var advancedSettingsRepository: Factory<AdvancedSettingsRepositoryProtocol> {
        self { @MainActor in
            AdvancedSettingsRepository(
                fileManager: self.fileManager(),
                certificateUtil: self.certificateUtil()
            )
        }
    }

    @MainActor
    var validationSettingsViewModel: Factory<ValidationSettingsViewModel> {
        self { @MainActor in
            ValidationSettingsViewModel(
                configurationRepository: self.configurationRepository(),
                dataStore: self.dataStore(),
                fileManager: self.fileManager(),
                advancedSettingsRepository: self.advancedSettingsRepository(),
                certificateUtil: self.certificateUtil()
            )
        }
    }

    @MainActor
    var encryptionSettingsViewModel: Factory<EncryptionSettingsViewModel> {
        self { @MainActor in
            EncryptionSettingsViewModel(
                configurationRepository: self.configurationRepository(),
                dataStore: self.dataStore(),
                advancedSettingsRepository: self.advancedSettingsRepository(),
                certificateUtil: self.certificateUtil()
            )
        }
    }

    @MainActor
    var proxySettingsViewModel: Factory<ProxySettingsViewModel> {
        self { @MainActor in
            ProxySettingsViewModel(
                proxyUtil: self.proxyUtil()
            )
        }
    }

    @MainActor
    var timeStampSettingsViewModel: Factory<TimeStampSettingsViewModel> {
        self { @MainActor in
            TimeStampSettingsViewModel(
                configurationRepository: self.configurationRepository(),
                dataStore: self.dataStore(),
                fileManager: self.fileManager(),
                advancedSettingsRepository: self.advancedSettingsRepository(),
                certificateUtil: self.certificateUtil()
            )
        }
    }

    @MainActor
    var mobileIDSmartIDSettingsViewModel: Factory<MobileIDSmartIDSettingsViewModel> {
        self { @MainActor in
            MobileIDSmartIDSettingsViewModel(
                dataStore: self.dataStore()
            )
        }
    }

    var signatureUtil: Factory<SignatureUtilProtocol> {
        self { SignatureUtil() }
    }

    @MainActor
    var sivaService: Factory<SivaServiceProtocol> {
        self { @MainActor in
            SivaService(
                mimeTypeResolver: self.mimeTypeResolver(),
                fileManager: self.fileManager(),
                containerUtil: self.containerUtil(),
                fileUtil: self.fileUtil()
            )
        }
    }

    @MainActor
    var sivaRepository: Factory<SivaRepositoryProtocol> {
        self { @MainActor in
            SivaRepository(sivaService: self.sivaService())
        }
    }

    @MainActor
    var mobileIdViewModel: Factory<MobileIdViewModel> {
        self { @MainActor in
            MobileIdViewModel(
                configurationRepository: self.configurationRepository(),
                mobileIdSignService: self.mobileIdSignService(),
                certificateUtil: self.certificateUtil(),
                dataStore: self.dataStore()
            )
        }
    }

    @MainActor
    var smartIdViewModel: Factory<SmartIdViewModel> {
        self { @MainActor in
            SmartIdViewModel()
        }
    }

    @MainActor
    var signingMethodSelectionViewModel: Factory<SigningMethodSelectionViewModel> {
        self { @MainActor in
            SigningMethodSelectionViewModel(
                dataStore: self.dataStore()
            )
        }
    }

    @MainActor
    var signingRootViewModel: Factory<SigningRootViewModel> {
        self { @MainActor in
            SigningRootViewModel(
                dataStore: self.dataStore()
            )
        }
    }
}
