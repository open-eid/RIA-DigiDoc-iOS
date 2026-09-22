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

import CommonsLib
import Foundation
import OSLog

public struct LogCollector: Sendable, Loggable {
    // Move the log in small pieces so a large log never has to be held in memory all at once.
    private static let chunkSize = 64 * 1024
    private static let logWindow: TimeInterval = 24 * 60 * 60 // 24 hours

    public init() {}

    @concurrent
    public func writeLogFile(
        to destination: URL,
        libdigidocLog: URL?,
        subsystemPrefix: String
    ) async throws {
        try await write(to: destination) { handle in
            try append("===== File: \(CommonsLib.Constants.File.LibDigidocLog) =====\n\n", to: handle)
            try copyContents(of: libdigidocLog, to: handle)
            try append("\n\n===== File: \(CommonsLib.Constants.File.AppLog) =====\n\n", to: handle)
            try appendLogEntries(matching: subsystemPrefix, to: handle)
        }
    }

    @concurrent
    public func write(_ text: String, to destination: URL) async throws {
        try Task.checkCancellation()
        try text.write(to: destination, atomically: true, encoding: .utf8)
    }

    private func write(
        to destination: URL,
        body: (FileHandle) throws -> Void
    ) async throws {
        try Task.checkCancellation()

        let fileManager = FileManager.default
        let partial = destination.appendingPathExtension("partial")
        try? fileManager.removeItem(at: partial)

        try Data().write(to: partial)
        let handle = try FileHandle(forWritingTo: partial)

        do {
            try body(handle)
            try handle.close()
            try Task.checkCancellation()
        } catch {
            try? handle.close()
            try? fileManager.removeItem(at: partial)
            throw error
        }

        if fileManager.fileExists(atPath: destination.resolvedPath) {
            _ = try fileManager.replaceItemAt(destination, withItemAt: partial)
        } else {
            try fileManager.moveItem(at: partial, to: destination)
        }
    }

    private func append(_ text: String, to handle: FileHandle) throws {
        try handle.write(contentsOf: Data(text.utf8))
    }

    private func copyContents(of url: URL?, to handle: FileHandle) throws {
        guard let url else {
            LogCollector.logger().error("No libdigidocpp log location to copy from")
            try append("<could not determine the libdigidocpp log location>\n", to: handle)
            return
        }

        let name = url.lastPathComponent
        guard FileManager.default.fileExists(atPath: url.resolvedPath) else {
            LogCollector.logger().info("No \(name, privacy: .public) to copy - not created this session")
            try append("<\(name) was not created during this session>\n", to: handle)
            return
        }

        let reader: FileHandle
        do {
            reader = try FileHandle(forReadingFrom: url)
        } catch {
            let reason = String(reflecting: error)
            LogCollector.logger().error("Unable to read \(name, privacy: .public): \(reason, privacy: .public)")
            try append("<unable to read \(name): \(error.localizedDescription)>\n", to: handle)
            return
        }
        defer { try? reader.close() }

        var copiedBytes = 0
        while let chunk = try reader.read(upToCount: Self.chunkSize), !chunk.isEmpty {
            try Task.checkCancellation()
            try handle.write(contentsOf: chunk)
            copiedBytes += chunk.count
        }

        LogCollector.logger().info("Copied \(copiedBytes, privacy: .public) bytes from \(name, privacy: .public)")
    }

    private func appendLogEntries(matching subsystemPrefix: String, to handle: FileHandle) throws {
        let entries: AnySequence<OSLogEntry>
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let window = Date(timeIntervalSinceNow: -Self.logWindow)
            let predicate = NSPredicate(format: "subsystem BEGINSWITH %@", subsystemPrefix)
            entries = try store.getEntries(at: store.position(date: window), matching: predicate)
        } catch {
            let reason = String(reflecting: error)
            LogCollector.logger().error("Unable to read the application log: \(reason, privacy: .public)")
            try append("<unable to read the application log: \(error.localizedDescription)>\n", to: handle)
            return
        }

        var batch = ""
        var appendedEntries = 0
        for entry in entries {
            try Task.checkCancellation()
            batch.append(line(for: entry))
            batch.append("\n")
            appendedEntries += 1

            if batch.utf8.count >= Self.chunkSize {
                try append(batch, to: handle)
                batch.removeAll(keepingCapacity: true)
            }
        }

        if !batch.isEmpty {
            try append(batch, to: handle)
        }

        LogCollector.logger().info("Appended \(appendedEntries, privacy: .public) application log entries")
    }

    private func line(for entry: OSLogEntry) -> String {
        guard let log = entry as? OSLogEntryLog else {
            return "\(entry.date): \(entry.composedMessage)"
        }
        return "\(entry.date) [\(log.subsystem):\(log.category)] - \(entry.composedMessage)"
    }
}
