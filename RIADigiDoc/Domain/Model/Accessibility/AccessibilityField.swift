import Foundation

enum AccessibilityField: Hashable, Sendable {
    case topBar(TopBarField)
    case container(ContainerField)
    case dataFile(DataFileField)
    case signature(SignatureField)
    case myEid(MyEidField)

    enum TopBarField: Hashable {
        case rightPrimaryButton
        case rightSecondaryButton
        case extraButton
    }

    enum ContainerField: Hashable {
        case openContainerOptionsButton
    }

    enum DataFileField: Hashable {
        case openDataFileOptionsButton
    }

    enum SignatureField: Hashable {
        case openSignatureOptionsButton
    }

    enum MyEidField: Hashable {
        case unblockPin1Button
        case changePin1Button
        case unblockPin2Button
        case changePin2Button
        case changePukButton
    }
}
