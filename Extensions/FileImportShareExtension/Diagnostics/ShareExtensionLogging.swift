// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import os

enum ShareExtensionLogging {
    static let subsystem = "ee.ria.digidoc.shareext.logging"
    static let category = "import"

    private static let log = Logger(subsystem: subsystem, category: category)

    static func emit(_ message: String) {
        log.info("\(message, privacy: .public)")
    }

    static func nameAttributes(_ name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        return "nameLen=\(name.count) ext=\(ext.isEmpty ? "none" : ext) dotLead=\(name.hasPrefix("."))"
    }

    static var availableMemoryMB: Int {
        #if os(iOS)
        os_proc_available_memory() / (1024 * 1024)
        #else
        -1
        #endif
    }

    static func fileSize(of url: URL) -> Int {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attributes?[.size] as? NSNumber)?.intValue ?? -1
    }

    static func streamState(_ label: String, _ stream: Stream?) -> String {
        guard let stream else {
            return "\(label)Nil=true"
        }
        let errorCode = (stream.streamError as NSError?)?.code ?? 0
        return "\(label)Nil=false \(label)Status=\(stream.streamStatus.rawValue) \(label)Err=\(errorCode)"
    }
}
