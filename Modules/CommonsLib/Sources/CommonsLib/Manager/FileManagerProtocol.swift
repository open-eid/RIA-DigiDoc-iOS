import Foundation

/// @mockable
public protocol FileManagerProtocol: Sendable {
    var currentDirectoryPath: String { get }
    var temporaryDirectory: URL { get }

    func fileExists(atPath path: String) -> Bool
    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
    func isReadableFile(atPath path: String) -> Bool
    func isWritableFile(atPath path: String) -> Bool
    func isExecutableFile(atPath path: String) -> Bool
    func isDeletableFile(atPath path: String) -> Bool

    func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?) throws
    func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey: Any]?) -> Bool

    func removeItem(at URL: URL) throws
    func removeItem(atPath path: String) throws
    func copyItem(at srcURL: URL, to dstURL: URL) throws
    func moveItem(at srcURL: URL, to dstURL: URL) throws
    func linkItem(at srcURL: URL, to dstURL: URL) throws

    func contentsOfDirectory(atPath path: String) throws -> [String]
    func contentsOfDirectory(at url: URL,
                             includingPropertiesForKeys keys: [URLResourceKey]?,
                             options mask: FileManager.DirectoryEnumerationOptions) throws -> [URL]
    func enumerator(atPath path: String) -> FileManager.DirectoryEnumerator?
    func enumerator(at url: URL,
                    includingPropertiesForKeys keys: [URLResourceKey]?,
                    options mask: FileManager.DirectoryEnumerationOptions,
                    errorHandler handler: ((URL, Error) -> Bool)?) -> FileManager.DirectoryEnumerator?

    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any]
    func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtPath path: String) throws
    func attributesOfFileSystem(forPath path: String) throws -> [FileAttributeKey: Any]

    func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL]
    func url(for directory: FileManager.SearchPathDirectory,
             in domain: FileManager.SearchPathDomainMask,
             appropriateFor url: URL?,
             create shouldCreate: Bool) throws -> URL
    func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL?

    func trashItem(at url: URL, resultingItemURL outResultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) throws
    func contentsEqual(atPath path1: String, andPath path2: String) -> Bool
    func linkItem(atPath srcPath: String, toPath dstPath: String) throws
    func moveItem(atPath srcPath: String, toPath dstPath: String) throws
    func copyItem(atPath srcPath: String, toPath dstPath: String) throws
    func replaceItem(
        at originalItemURL: URL,
        withItemAt newItemURL: URL,
        backupItemName: String?,
        options: FileManager.ItemReplacementOptions,
        resultingItemURL resultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?
    ) throws
    func createSymbolicLink(atPath path: String, withDestinationPath destPath: String) throws
    func destinationOfSymbolicLink(atPath path: String) throws -> String

    func createSymbolicLink(at url: URL, withDestinationURL destURL: URL) throws

    func startDownloadingUbiquitousItem(at url: URL) throws
    func evictUbiquitousItem(at url: URL) throws
    func isUbiquitousItem(at url: URL) -> Bool
    func url(forUbiquityContainerIdentifier containerIdentifier: String?) -> URL?
}

public struct FileManagerWrapper: FileManagerProtocol {

    public var currentDirectoryPath: String {
        FileManager.default.currentDirectoryPath
    }

    public var temporaryDirectory: URL {
        FileManager.default.temporaryDirectory
    }

    public func fileExists(atPath path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }

    public func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        FileManager.default.fileExists(atPath: path, isDirectory: isDirectory)
    }

    public func isReadableFile(atPath path: String) -> Bool {
        FileManager.default.isReadableFile(atPath: path)
    }

    public func isWritableFile(atPath path: String) -> Bool {
        FileManager.default.isWritableFile(atPath: path)
    }

    public func isExecutableFile(atPath path: String) -> Bool {
        FileManager.default.isExecutableFile(atPath: path)
    }

    public func isDeletableFile(atPath path: String) -> Bool {
        FileManager.default.isDeletableFile(atPath: path)
    }

    public func createDirectory(
        at url: URL,
        withIntermediateDirectories: Bool,
        attributes: [FileAttributeKey: any Sendable]?
    ) throws {
        try FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: withIntermediateDirectories,
            attributes: attributes
        )
    }

    public func createDirectory(
        at url: URL,
        withIntermediateDirectories createIntermediates: Bool,
        attributes: [FileAttributeKey: Any]?
    ) throws {
        try FileManager.default
            .createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes)
    }

    public func createFile(
        atPath path: String,
        contents: Data?,
        attributes: [FileAttributeKey: any Sendable]?
    ) -> Bool {
        FileManager.default.createFile(atPath: path, contents: contents, attributes: attributes)
    }

    public func createFile(
        atPath path: String,
        contents data: Data?,
        attributes attr: [FileAttributeKey: Any]?
    ) -> Bool {
        FileManager.default.createFile(atPath: path, contents: data, attributes: attr)
    }

    public func removeItem(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }

    public func removeItem(atPath path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }

    public func copyItem(at srcURL: URL, to dstURL: URL) throws {
        try FileManager.default.copyItem(at: srcURL, to: dstURL)
    }

    public func moveItem(at srcURL: URL, to dstURL: URL) throws {
        try FileManager.default.moveItem(at: srcURL, to: dstURL)
    }

    public func linkItem(at srcURL: URL, to dstURL: URL) throws {
        try FileManager.default.linkItem(at: srcURL, to: dstURL)
    }

    public func contentsOfDirectory(atPath path: String) throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: path)
    }

    public func contentsOfDirectory(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options: FileManager.DirectoryEnumerationOptions
    ) throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: keys, options: options)
    }

    public func enumerator(atPath path: String) -> FileManager.DirectoryEnumerator? {
        FileManager.default.enumerator(atPath: path)
    }

    public func enumerator(
        at url: URL,
        includingPropertiesForKeys keys: [URLResourceKey]?,
        options mask: FileManager.DirectoryEnumerationOptions,
        errorHandler handler: ((URL, any Error) -> Bool)?
    ) -> FileManager.DirectoryEnumerator? {
        FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys, options: mask, errorHandler: handler)
    }

    public func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: Any] {
        try FileManager.default.attributesOfItem(atPath: path)
    }

    public func setAttributes(_ attributes: [FileAttributeKey: Any], ofItemAtPath path: String) throws {
        try FileManager.default.setAttributes(attributes, ofItemAtPath: path)
    }

    public func attributesOfFileSystem(forPath path: String) throws -> [FileAttributeKey: Any] {
        try FileManager.default.attributesOfFileSystem(forPath: path)
    }

    public func attributesOfItem(atPath path: String) throws -> [FileAttributeKey: any Sendable] {
        let attributes = try FileManager.default.attributesOfItem(atPath: path)

        return attributes.compactMapValues { value -> (any Sendable)? in
            if let stringValue = value as? String { return stringValue }
            if let numberValue = value as? NSNumber { return numberValue }
            if let dateValue = value as? Date { return dateValue }
            if let dataValue = value as? Data { return dataValue }
            if let urlValue = value as? URL { return urlValue }
            if let boolValue = value as? Bool { return boolValue }

            return nil
        }
    }

    public func setAttributes(_ attributes: [FileAttributeKey: any Sendable], ofItemAtPath path: String) throws {
        try FileManager.default.setAttributes(attributes, ofItemAtPath: path)
    }

    public func attributesOfFileSystem(forPath path: String) throws -> [FileAttributeKey: any Sendable] {
        let attributes = try FileManager.default.attributesOfFileSystem(forPath: path)

        return attributes.compactMapValues { value -> (any Sendable)? in
            if let numberValue = value as? NSNumber { return numberValue }
            if let stringValue = value as? String { return stringValue }
            if let dataValue = value as? Data { return dataValue }

            return nil
        }
    }

    public func urls(
        for directory: FileManager.SearchPathDirectory,
        in domainMask: FileManager.SearchPathDomainMask
    ) -> [URL] {
        FileManager.default.urls(for: directory, in: domainMask)
    }

    public func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL?,
        create: Bool
    ) throws -> URL {
        try FileManager.default.url(for: directory, in: domain, appropriateFor: url, create: create)
    }

    public func containerURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
    }

    public func trashItem(at url: URL) throws {
        var resultItemURL: NSURL?
        _ = try FileManager.default.trashItem(at: url, resultingItemURL: &resultItemURL)
    }

    public func trashItem(
        at url: URL,
        resultingItemURL outResultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?
    ) throws {
        try FileManager.default.trashItem(at: url, resultingItemURL: outResultingURL)
    }

    public func contentsEqual(atPath path1: String, andPath path2: String) -> Bool {
        FileManager.default.contentsEqual(atPath: path1, andPath: path2)
    }

    public func linkItem(atPath srcPath: String, toPath dstPath: String) throws {
        try FileManager.default.linkItem(atPath: srcPath, toPath: dstPath)
    }

    public func moveItem(atPath srcPath: String, toPath dstPath: String) throws {
        try FileManager.default.moveItem(atPath: srcPath, toPath: dstPath)
    }

    public func copyItem(atPath srcPath: String, toPath dstPath: String) throws {
        try FileManager.default.copyItem(atPath: srcPath, toPath: dstPath)
    }

    public func replaceItem(
        at originalItemURL: URL,
        withItemAt newItemURL: URL,
        backupItemName: String?,
        options: FileManager.ItemReplacementOptions
    ) throws {
        var resultItemURL: NSURL?
        try FileManager.default.replaceItem(
            at: originalItemURL,
            withItemAt: newItemURL,
            backupItemName: backupItemName,
            options: options,
            resultingItemURL: &resultItemURL
        )
    }

    public func replaceItem(
        at originalItemURL: URL,
        withItemAt newItemURL: URL,
        backupItemName: String?,
        options: FileManager.ItemReplacementOptions,
        resultingItemURL _: AutoreleasingUnsafeMutablePointer<NSURL?>?
    ) throws {
        var resultItemURL: NSURL?
        try FileManager.default.replaceItem(
            at: originalItemURL,
            withItemAt: newItemURL,
            backupItemName: backupItemName,
            options: options,
            resultingItemURL: &resultItemURL
        )
    }

    public func createSymbolicLink(atPath path: String, withDestinationPath destPath: String) throws {
        try FileManager.default.createSymbolicLink(atPath: path, withDestinationPath: destPath)
    }

    public func destinationOfSymbolicLink(atPath path: String) throws -> String {
        try FileManager.default.destinationOfSymbolicLink(atPath: path)
    }

    public func createSymbolicLink(at url: URL, withDestinationURL destURL: URL) throws {
        try FileManager.default.createSymbolicLink(at: url, withDestinationURL: destURL)
    }

    public func startDownloadingUbiquitousItem(at url: URL) throws {
        try FileManager.default.startDownloadingUbiquitousItem(at: url)
    }

    public func evictUbiquitousItem(at url: URL) throws {
        try FileManager.default.evictUbiquitousItem(at: url)
    }

    public func isUbiquitousItem(at url: URL) -> Bool {
        FileManager.default.isUbiquitousItem(at: url)
    }

    public func url(forUbiquityContainerIdentifier containerIdentifier: String?) -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier)
    }
}
