/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
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

import Foundation
import CryptoKit
import PDFKit
import UniformTypeIdentifiers
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

    public var resolvedPath: String {
        let path = isFileURL
        ? standardizedFileURL.path(percentEncoded: false)
        : path(percentEncoded: false)

        // Remove trailing slash except for root "/"
        if path.hasSuffix("/") && path.count > 1 {
            return String(path.dropLast())
        }

        return path
    }

    public func mimeType(
        fileUtil: FileUtilProtocol = fileUtil(),
        mimeTypeDecoder: MimeTypeDecoderProtocol = mimeTypeDecoder()
    ) async -> String {
        let defaultMimeType = Constants.MimeType.Default

        do {
            if try isZipFile(), let mimetypeFile = try await fileUtil.getFileFromZipFile(
                from: self,
                fileNameToFind: "mimetype"
            ) {
                let mimetypeContent = try String(contentsOf: mimetypeFile, encoding: .utf8)
                return mimetypeContent.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            if let mimeType = mimeTypeForFileExtension() {
                return mimeType
            }
        }

        if await isDdoc(mimeTypeDecoder: mimeTypeDecoder) {
            return Constants.MimeType.Ddoc
        }

        if await isCdoc(mimeTypeDecoder: mimeTypeDecoder) {
            return Constants.MimeType.Cdoc
        }

        return mimeTypeForFileExtension() ?? defaultMimeType
    }

    public func isContainer(
        fileUtil: FileUtilProtocol = fileUtil(),
        mimeTypeDecoder: MimeTypeDecoderProtocol = mimeTypeDecoder()
    ) async -> Bool {
        if await isAsicContainer(fileUtil: fileUtil) {
            return true
        }

        return await isDdoc(mimeTypeDecoder: mimeTypeDecoder)
    }

    public func isCryptoContainer(
        mimeTypeDecoder: MimeTypeDecoderProtocol = mimeTypeDecoder()
    ) async -> Bool {
        let isCdoc = await isCdoc(mimeTypeDecoder: mimeTypeDecoder)
        return isCdoc || Constants.Extension.CryptoContainers.contains(self.pathExtension)
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

    public func isCdoc(
        mimeTypeDecoder: MimeTypeDecoderProtocol = mimeTypeDecoder()
    ) async -> Bool {
        do {
            let xmlData = try Data(contentsOf: self)
            let result = await mimeTypeDecoder.parse(xmlData: xmlData)
            return result == .cdoc
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
        mimeTypeDecoder: MimeTypeDecoderProtocol = mimeTypeDecoder()
    ) async -> Bool {
        let mimeType = await self.mimeType(
            fileUtil: fileUtil,
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

                guard let annotDictionary = pdfDictionary else { return false }

                if hasDictionary {
                    var type: UnsafePointer<CChar>?
                    let hasType = CGPDFDictionaryGetName(annotDictionary, "Type", &type)

                    if hasType && strcmp(type, "Annot") == 0 {
                        var vArray: CGPDFDictionaryRef?
                        CGPDFDictionaryGetDictionary(annotDictionary, "V", &vArray)

                        guard let vInfo = vArray else { return false }

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
        fileUtil: FileUtilProtocol = fileUtil()
    ) async throws -> URL {
        _ = self.startAccessingSecurityScopedResource()

        defer {
            self.stopAccessingSecurityScopedResource()
        }
        let validFileInApp = await fileUtil.getValidPath(url: self)

        if let validFileURL = validFileInApp {
            return validFileURL
        }

        // Check if file is opened externally (outside of application)
        let fileFromAppGroup = fileUtil.getFileUrlFromAppGroup(
            self,
            appGroupIdentifier: Constants.Identifier.Group
        )

        if let fileUrl = fileFromAppGroup {
            return fileUrl
        }

        // Check if file is opened from iCloud
        if fileUtil.isFileFromiCloud(fileURL: self) {
            if !fileUtil.isFileDownloadedFromiCloud(fileURL: self) {
                let downloadedFileUrl = await fileUtil.downloadFileFromiCloud(fileURL: self)

                guard let fileLocation = downloadedFileUrl else {
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
        let exists = fileManager.fileExists(atPath: self.resolvedPath, isDirectory: &isDirectory)
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

    public func isAsicContainer(fileUtil: FileUtilProtocol = fileUtil()) async -> Bool {
        await containsZipEntry(named: "mimetype", fileUtil: fileUtil)
    }

    public func isCades(fileUtil: FileUtilProtocol = fileUtil()) async -> Bool {
        await containsZipEntry(named: "p7s", fileUtil: fileUtil)
    }

    public func isXades(fileUtil: FileUtilProtocol = fileUtil()) async -> Bool {
        await containsZipEntry(named: "signatures.xml", fileUtil: fileUtil)
    }

    public func containsDdoc(fileUtil: FileUtilProtocol = fileUtil()) async -> Bool {
        await containsZipEntry(named: ".\(Constants.Extension.Ddoc)", fileUtil: fileUtil)
    }

    private func containsZipEntry(named name: String, fileUtil: FileUtilProtocol) async -> Bool {
        do {
            guard try isZipFile() else { return false }
            return try await fileUtil.getFileFromZipFile(from: self, fileNameToFind: name) != nil
        } catch {
            return false
        }
    }

    // Check if file is zip format
    private func isZipFile() throws -> Bool {
        guard let fileHandle = FileHandle(forReadingAtPath: self.resolvedPath) else { return false }
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

extension URL {

    private var lastOpenedXattrName: String { Constants.Identifier.GroupLastOpenedAttribute }

    public func markAsOpened() throws {
        let accessing = self.startAccessingSecurityScopedResource()
        defer { if accessing { self.stopAccessingSecurityScopedResource() } }

        var timestamp = Date().timeIntervalSince1970
        let data = Data(bytes: &timestamp, count: MemoryLayout.size(ofValue: timestamp))

        let result = data.withUnsafeBytes { ptr in
            setxattr(
                self.path,
                lastOpenedXattrName,
                ptr.baseAddress,
                data.count,
                0,
                0
            )
        }
        guard result == 0 else { return }
    }

    public func lastOpened() throws -> Date? {
        var buffer = [UInt8](repeating: 0, count: MemoryLayout<Double>.size)
        let size = getxattr(self.path, lastOpenedXattrName, &buffer, buffer.count, 0, 0)

        guard size != -1 else {
            if errno == ENOATTR { return nil }
            throw FileLastOpenedError.readFailed(errno: errno)
        }
        guard size == buffer.count else { throw FileLastOpenedError.invalidData }

        let interval = buffer.withUnsafeBytes { $0.load(as: Double.self) }
        return Date(timeIntervalSince1970: interval)
    }

    public func removeLastOpenedXattr() throws {
        let result = removexattr(self.path, lastOpenedXattrName, 0)

        if result != 0 {
            if errno == ENOATTR { return } else {
                throw FileLastOpenedError.removeFailed(errno: errno)
            }
        }
    }
}

extension URL {
    public var isPlainText: Bool {
        guard let type = UTType(
            filenameExtension: pathExtension.lowercased()
        ) else { return false }
        return type.conforms(to: .text)
    }
}
