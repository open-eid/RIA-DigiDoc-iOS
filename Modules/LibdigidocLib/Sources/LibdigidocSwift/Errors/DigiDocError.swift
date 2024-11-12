public enum DigiDocError: Error {
    case initializationFailed(String)
    case containerCreationFailed(String)
    case containerOpeningFailed(String)
    case addingFilesToContainerFailed(String)
    case containerSavingFailed(String)
}
