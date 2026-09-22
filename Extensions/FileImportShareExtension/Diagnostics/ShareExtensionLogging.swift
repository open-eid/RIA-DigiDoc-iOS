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
