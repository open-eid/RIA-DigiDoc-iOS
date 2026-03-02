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
import IdCardLib

extension Container {
    @MainActor
    var librarySetup: Factory<LibrarySetup> {
        self { @MainActor in
            LibrarySetup(
                configurationLoader: self.configurationLoader(),
                configurationRepository: self.configurationRepository(),
                fileManager: self.fileManager(),
                fileUtil: self.fileUtil(),
                tslUtil: self.tslUtil(),
                dataStore: self.dataStore(),
                advancedSettingsRepository: self.advancedSettingsRepository(),
                keychainStore: self.keychainStore(),
                proxyUtil: self.proxyUtil(),
                cryptoSetup: self.cryptoSetup(),
                userAgentUtil: self.userAgentUtil()
            )
        }
        .shared
    }

    @MainActor
    var cryptoSetup: Factory<CryptoSetupProtocol> {
        self { @MainActor in
            CryptoSetup(
                dataStore: self.dataStore(),
                proxyUtil: self.proxyUtil(),
                ldapConfiguration: self.ldapConfiguration()
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

    @MainActor
    var sharedContainerViewModel: Factory<SharedContainerViewModelProtocol> {
        self { @MainActor in SharedContainerViewModel() }
            .shared
    }

    @MainActor
    var homeViewModel: Factory<HomeViewModel> {
        self { @MainActor in
            HomeViewModel(
                sharedContainerViewModel: self.sharedContainerViewModel(),
                fileManager: self.fileManager(),
                fileUtil: self.fileUtil()
            )
        }
    }

    @MainActor
    var cryptoHomeViewModel: Factory<CryptoHomeViewModel> {
        self { @MainActor in
            CryptoHomeViewModel(
                sharedContainerViewModel: self.sharedContainerViewModel(),
                fileManager: self.fileManager()
            )
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
    var cryptoFileOpeningViewModel: Factory<CryptoFileOpeningViewModel> {
        self {
            @MainActor in
            CryptoFileOpeningViewModel(
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
                fileInspector: self.fileInspector(),
                sivaRepository: self.sivaRepository(),
                containerUtil: self.containerUtil()
            )
        }
    }

    @MainActor
    var encryptViewModel: Factory<EncryptViewModel> {
        self {
            @MainActor in
            EncryptViewModel(
                sharedContainerViewModel: self.sharedContainerViewModel(),
                fileOpeningService: self.fileOpeningService(),
                mimeTypeCache: self.mimeTypeCache(),
                mimeTypeDecoder: self.mimeTypeDecoder(),
                fileUtil: self.fileUtil(),
                fileManager: self.fileManager(),
                fileInspector: self.fileInspector(),
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
    var initViewModel: Factory<InitViewModel> {
        self {
            @MainActor in
            InitViewModel(
                languageSettings: self.languageSettings(),
                dataStore: self.dataStore()
            )
        }
    }

    @MainActor
    var recentDocumentsViewModel: Factory<RecentDocumentsViewModel> {
        self {
            @MainActor in
            RecentDocumentsViewModel(
                sharedContainerViewModel: self.sharedContainerViewModel(),
                fileManager: self.fileManager(),
                fileInspector: self.fileInspector()
            )
        }
    }

    @MainActor
    var encryptRecipientViewModel: Factory<EncryptRecipientViewModel> {
        self {
            @MainActor in
            EncryptRecipientViewModel(
                sharedContainerViewModel: self.sharedContainerViewModel(),
                openLdap: self.openLdap()
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
                proxyUtil: self.proxyUtil(),
                userAgentUtil: self.userAgentUtil(),
                fileUtil: self.fileUtil(),
                cryptoSetup: self.cryptoSetup()
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
    var fileInspector: Factory<FileInspectorProtocol> {
        self { @MainActor in FileInspector() }
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
                certificateUtil: self.certificateUtil(),
                cryptoSetup: self.cryptoSetup()
            )
        }
    }

    @MainActor
    var proxySettingsViewModel: Factory<ProxySettingsViewModel> {
        self { @MainActor in
            ProxySettingsViewModel(
                proxyUtil: self.proxyUtil(),
                userAgentUtil: self.userAgentUtil(),
                dataStore: self.dataStore(),
                cryptoSetup: self.cryptoSetup()
            )
        }
    }

    @MainActor
    var advancedSettingsViewModel: Factory<AdvancedSettingsViewModel> {
        self { @MainActor in
            AdvancedSettingsViewModel(
                dataStore: self.dataStore(),
                keychainStore: self.keychainStore(),
                advancedSettingsRepository: self.advancedSettingsRepository(),
                configurationRepository: self.configurationRepository(),
                cryptoSetup: self.cryptoSetup()
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

    var recipientUtil: Factory<RecipientUtilProtocol> {
        self { RecipientUtil() }
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
                dataStore: self.dataStore(),
                proxyUtil: self.proxyUtil(),
                userAgentUtil: self.userAgentUtil()
            )
        }
    }

    @MainActor
    var smartIdViewModel: Factory<SmartIdViewModel> {
        self { @MainActor in
            SmartIdViewModel(
                configurationRepository: self.configurationRepository(),
                smartIdSignService: self.smartIdSignService(),
                certificateUtil: self.certificateUtil(),
                notificationUtil: self.notificationUtil(),
                dataStore: self.dataStore(),
                proxyUtil: self.proxyUtil(),
                userAgentUtil: self.userAgentUtil()
            )
        }
    }

    @MainActor
    var idCardViewModel: Factory<IdCardViewModel> {
        self { @MainActor in
            IdCardViewModel(
                idCardRepository: self.idCardRepository(),
                sharedMyEidSession: self.sharedMyEidSession(),
                certificateUtil: self.certificateUtil(),
                nameUtil: self.nameUtil(),
                dataStore: self.dataStore(),
                userAgentUtil: self.userAgentUtil()
            )
        }
    }

    @MainActor
    var idCardService: Factory<IdCardServiceProtocol> {
        self { @MainActor in
            IdCardService(usbReaderConnection: self.usbReaderConnection())
        }
    }

    @MainActor
    var idCardRepository: Factory<IdCardRepositoryProtocol> {
        self { @MainActor in
            IdCardRepository(idCardService: self.idCardService())
        }
        .shared
    }

    @MainActor
    var sharedMyEidSession: Factory<SharedMyEidSessionProtocol> {
        self { @MainActor in
            SharedMyEidSession(idCardRepository: self.idCardRepository())
        }
        .shared
    }

    @MainActor
    var myEidViewModel: Factory<MyEidViewModel> {
        self { @MainActor in
            MyEidViewModel(
                idCardRepository: self.idCardRepository(),
                sharedMyEidSession: self.sharedMyEidSession()
            )
        }
        .shared
    }
    
    @MainActor
    var webEidViewModel: Factory<WebEidViewModel> {
        self { @MainActor in
            WebEidViewModel(
                // TODO: implement me
                //webEidRepository: self.webEidRepository(),
                //sharedWebEidSession: self.sharedWebEidSession()
            )
        }
        .shared
    }

    @MainActor
    var actionMethodSelectionViewModel: Factory<ActionMethodSelectionViewModel> {
        self { @MainActor in
            ActionMethodSelectionViewModel(
                dataStore: self.dataStore()
            )
        }
    }

    @MainActor
    var decryptRootViewModel: Factory<DecryptRootViewModel> {
        self { @MainActor in
            DecryptRootViewModel(
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

    @MainActor
    var roleViewModel: Factory<RoleViewModel> {
        self { @MainActor in
            RoleViewModel(
                dataStore: self.dataStore()
            )
        }
    }

    @MainActor
    var nfcViewModel: Factory<NFCViewModel> {
        self { @MainActor in
            NFCViewModel(
                dataStore: self.dataStore(),
                userAgentUtil: self.userAgentUtil(),
                certificateUtil: self.certificateUtil(),
                sharedMyEidSession: self.sharedMyEidSession(),
                keychainStore: self.keychainStore(),
                encryptedDataUtil: self.encryptedDataUtil(),
                operationReadCertAndSign: self.operationReadCertAndSign(),
                operationReadCardData: self.operationReadCardData(),
                operationDecrypt: self.operationDecrypt()
            )
        }
    }

    @MainActor
    var operationReadCertAndSign: Factory<OperationReadCertAndSign> {
        self { @MainActor in
            OperationReadCertAndSign()
        }
    }

    @MainActor
    var operationReadCardData: Factory<OperationReadCardData> {
        self { @MainActor in
            OperationReadCardData()
        }
    }

    @MainActor
    var operationDecrypt: Factory<OperationDecrypt> {
        self { @MainActor in
            OperationDecrypt()
        }
    }

    @MainActor
    var operationChangePin: Factory<OperationChangePin> {
        self { @MainActor in
            OperationChangePin()
        }
    }

    @MainActor
    var operationUnblockPin: Factory<OperationUnblockPin> {
        self { @MainActor in
            OperationUnblockPin()
        }
    }

    @MainActor
    var myEidRootViewModel: Factory<MyEidRootViewModel> {
        self { @MainActor in
            MyEidRootViewModel(
                dataStore: self.dataStore()
            )
        }
    }

    // swiftlint:disable closure_parameter_position
    // swiftlint:disable large_tuple
    @MainActor
    var myEidPinChangeViewModel: ParameterFactory<(
        MyEidPinCodeAction,
        CodeType,
        String,
        ActionMethod
    ), MyEidPinChangeViewModel> {
        self { @MainActor (
            pinAction: MyEidPinCodeAction,
            codeType: CodeType,
            personalCode: String,
            actionMethod: ActionMethod
        ) -> MyEidPinChangeViewModel in
            MyEidPinChangeViewModel(
                pinAction: pinAction,
                codeType: codeType,
                personalCode: personalCode,
                actionMethod: actionMethod,
                idCardRepository: self.idCardRepository(),
                sharedMyEidSession: self.sharedMyEidSession(),
                operationChangePin: self.operationChangePin(),
                operationUnblockPin: self.operationUnblockPin()
            )
        }
    }
    // swiftlint:enable closure_parameter_position
    // swiftlint:enable large_tuple

    @MainActor
    var encryptedDataUtil: Factory<EncryptedDataUtilProtocol> {
        self { @MainActor in
            EncryptedDataUtil(
                fileManager: self.fileManager()
            )
        }
    }

    @MainActor
    var crashReportManager: Factory<CrashReportManager> {
        self { @MainActor in
            CrashReportManager(
                dataStore: self.dataStore(),
                crashReportClient: self.crashReportClient()
            )
        }
        .singleton
    }

    @MainActor
    var crashReportClient: Factory<CrashReportClient> {
        self { @MainActor in
            CrashReportClient()
        }
        .singleton
    }

    @MainActor
    var documentsMigrator: Factory<DocumentsMigratorProtocol> {
        self { @MainActor in
            DocumentsMigrator(
                containerUtil: self.containerUtil(),
                fileManager: self.fileManager()
            )
        }
    }
}
