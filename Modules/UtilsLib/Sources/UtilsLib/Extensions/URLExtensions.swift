import Foundation
import CryptoKit
import PDFKit
import UniformTypeIdentifiers
import OSLog
import System
import ZIPFoundation
import FactoryKit
import CommonsLib

public func fileUtil() -> FileUtilProtocol {
    Container.shared.fileUtil()
}

public func fileManager() -> FileManagerProtocol {
    Container.shared.fileManager()
}

public func mimeTypeDecoder() -> MimeTypeDecoderProtocol {
    Container.shared.mimeTypeDecoder()
}

extension URL {

    public var standardizedPathURL: URL {
        URL(fileURLWithPath: (path as NSString).standardizingPath)
    }

    public func mimeType(
        fileUtil: FileUtilProtocol = fileUtil(),
        fileManager: FileManagerProtocol = fileManager(),
        mimeTypeDecoder: MimeTypeDecoderProtocol = mimeTypeDecoder()
    ) async -> String {
        let defaultMimeType = Constants.MimeType.Default

        do {
            if try isZipFile(), let mimetype = try await fileUtil.getMimeTypeFromZipFile(
                from: self,
                fileNameToFind: "mimetype"
            ) {
                return mimetype
            }
        } catch {
            if let mimeType = mimeTypeForFileExtension() {
                return mimeType
            }
        }

        if await isDdoc(mimeTypeDecoder: mimeTypeDecoder) {
            return Constants.MimeType.Ddoc
        }

        return mimeTypeForFileExtension() ?? defaultMimeType
    }

    public func isContainer(
        fileUtil: FileUtilProtocol = fileUtil(),
        fileManager: FileManagerProtocol = fileManager(),
        mimeTypeDecoder: MimeTypeDecoderProtocol = mimeTypeDecoder()
    ) async -> Bool {
        let mimetype = await mimeType(
            fileUtil: fileUtil,
            fileManager: fileManager,
            mimeTypeDecoder: mimeTypeDecoder
        )

        if Constants.MimeType.SignatureContainers.contains(mimetype) {
            return true
        }

        return await isDdoc(mimeTypeDecoder: mimeTypeDecoder)
    }

    public func isDdoc(
        mimeTypeDecoder: MimeTypeDecoderProtocol = mimeTypeDecoder()
    ) async -> Bool {
        do {
            let xmlData = try Data(contentsOf: self)
            let result = await mimeTypeDecoder.parse(xmlData: xmlData)
            return result == .ddoc
        } catch {
            return false
        }
    }

    public func md5Hash() -> String {
        do {
            let fileData = try Data(contentsOf: self)
            let md5Digest = Insecure.MD5.hash(data: fileData)
            return md5Digest.hexString(separator: "")
        } catch {
            return ""
        }
    }

    public func isPDF(
        fileUtil: FileUtilProtocol = fileUtil(),
        fileManager: FileManagerProtocol = fileManager(),
        mimeTypeDecoder: MimeTypeDecoderProtocol = mimeTypeDecoder()
    ) async -> Bool {
        let mimeType = await self.mimeType(
            fileUtil: fileUtil,
            fileManager: fileManager,
            mimeTypeDecoder: mimeTypeDecoder
        )
        return mimeType == Constants.MimeType.Pdf
    }

    public func isSignedPDF() -> Bool {
        guard let document = CGPDFDocument(self as CFURL),
              let page = document.page(at: 1),
              let pageDictionary = page.dictionary else {
            return false
        }

        var pdfArray: CGPDFArrayRef?
        let hasAnnotations = CGPDFDictionaryGetArray(pageDictionary, "Annots", &pdfArray)

        if hasAnnotations {

            guard let pdfAnnots: CGPDFArrayRef = pdfArray else { return false }

            let annotationsCount = CGPDFArrayGetCount(pdfAnnots)

            var pdfDictionary: CGPDFDictionaryRef?
            for index in 0..<annotationsCount {

                let hasDictionary = CGPDFArrayGetDictionary(pdfAnnots, index, &pdfDictionary)

                guard let annotDictionary: CGPDFArrayRef = pdfDictionary else { return false }

                if hasDictionary {
                    var type: UnsafePointer<CChar>?
                    let hasType = CGPDFDictionaryGetName(annotDictionary, "Type", &type)

                    if hasType && strcmp(type, "Annot") == 0 {
                        var vArray: CGPDFDictionaryRef?
                        CGPDFDictionaryGetDictionary(annotDictionary, "V", &vArray)

                        guard let vInfo: CGPDFArrayRef = vArray else { return false }

                        var filterChar: UnsafePointer<CChar>?
                        CGPDFDictionaryGetName(vInfo, "Filter", &filterChar)

                        var subFilterChar: UnsafePointer<CChar>?
                        CGPDFDictionaryGetName(vInfo, "SubFilter", &subFilterChar)

                        var filter = ""
                        if let filterName = filterChar {
                            filter = String(cString: filterName)
                        }

                        var subFilter = ""
                        if let subFilterName = subFilterChar {
                            subFilter = String(cString: subFilterName)
                        }

                        return filter == "Adobe.PPKLite" || (
                            subFilter == "ETSI.CAdES.detached" || subFilter == "adbe.pkcs7.detached"
                        )
                    }
                }
            }
        }

        return false
    }

    public func validURL(
        fileUtil: FileUtilProtocol = fileUtil(),
        fileManager: FileManagerProtocol = fileManager()
    ) throws -> URL {
        _ = self.startAccessingSecurityScopedResource()

        defer {
            self.stopAccessingSecurityScopedResource()
        }
        let validFileInApp = try fileUtil.getValidFileInApp(currentURL: self)

        if let validFileURL = validFileInApp {
            return validFileURL
        }

        // Check if file is opened externally (outside of application)
        let appGroupURL = try Directories.getSharedFolder(fileManager: fileManager)
        let resolvedAppGroupURL = appGroupURL.deletingLastPathComponent().resolvingSymlinksInPath()

        let normalizedURL = FilePath(stringLiteral: self.resolvingSymlinksInPath().path).lexicallyNormalized()

        let resolvedAppGroupFilePath = FilePath(
            stringLiteral: resolvedAppGroupURL.deletingLastPathComponent().path
        )

        let isFromAppGroup = normalizedURL.starts(with: resolvedAppGroupFilePath)

        if isFromAppGroup {
            return self
        }

        // Check if file is opened from iCloud
        if fileUtil.isFileFromiCloud(fileURL: self) {
            if !fileUtil.isFileDownloadedFromiCloud(fileURL: self) {

                var fileLocationURL: URL?

                fileUtil.downloadFileFromiCloud(fileURL: self) { downloadedFileUrl in
                    if let fileUrl = downloadedFileUrl {
                        DispatchQueue.main.async {
                            fileLocationURL = fileUrl
                        }
                    } else {
                        return
                    }
                }

                guard let fileLocation = fileLocationURL else {
                    throw URLError(.badURL)
                }

                return fileLocation
            } else {
                return self
            }
        }

        throw URLError(.badURL)
    }

    public func isValidURL() -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

            let matches = detector.matches(
                in: self.absoluteString,
                options: [],
                range: NSRange(location: 0, length: self.absoluteString.utf16.count)
            )

            return matches.count > 0
        } catch {
            return false
        }
    }

    public func isFolder(
        fileManager: FileManagerProtocol = fileManager()
    ) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: self.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    public func folderContents(
        fileManager: FileManagerProtocol = fileManager()
    ) throws -> [URL] {
        if isFolder(fileManager: fileManager) {
            let fileURLs = try fileManager.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
            return fileURLs
        }
        return []
    }

    // Check if file is zip format
    private func isZipFile() throws -> Bool {
        guard let fileHandle = FileHandle(forReadingAtPath: self.path) else { return false }
        let fileData = fileHandle.readData(ofLength: 4)
        let isZip = fileData.starts(with: [0x50, 0x4b, 0x03, 0x04])
        try fileHandle.close()
        return isZip
    }

    private func mimeTypeForFileExtension() -> String? {
        guard let mimeTypeFromUTType = UTType(filenameExtension: self.pathExtension),
              let preferredMimeType = mimeTypeFromUTType.preferredMIMEType, !preferredMimeType.isEmpty else {
            return nil
        }
        return preferredMimeType.lowercased()
    }
}
