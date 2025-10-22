import Foundation

enum AccessibilityField: Hashable {
    case topBar(TopBarField)
    case container(ContainerField)
    case dataFile(DataFileField)
    case signature(SignatureField)

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
}
