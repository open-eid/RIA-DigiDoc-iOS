public enum ContainerNotificationType: Sendable, Hashable {
    case xadesFile
    case cadesFile
    case emptyFile
    case unsupportedContainer
    case unknownSignatures(count: Int)
    case invalidSignatures(count: Int)
}
