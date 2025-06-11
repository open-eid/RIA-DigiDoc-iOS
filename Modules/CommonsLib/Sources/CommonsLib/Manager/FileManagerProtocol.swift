import Foundation

/// @mockable
public protocol FileManagerProtocol {
    var currentDirectoryPath: String { get }
    var delegate: FileManagerDelegate? { get set }
    var ubiquityIdentityToken: (NSCoding & NSCopying & NSObjectProtocol)? { get }
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

extension FileManager: FileManagerProtocol {}
