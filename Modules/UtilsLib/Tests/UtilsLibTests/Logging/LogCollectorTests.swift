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
import CommonsTestShared
import Foundation
import OSLog
import Testing

@testable import UtilsLib

final class LogCollectorTests: Sendable {

    private let directory: URL
    private let collector = LogCollector()

    init() throws {
        directory = try TestFileUtil.getTemporaryDirectory(
            subfolder: "LogCollectorTests-\(UUID().uuidString)"
        )
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }

    @Test
    func write_createsFileWithGivenText() async throws {
        let destination = directory.appending(path: "diagnostics.log")

        try await collector.write("hello\nworld", to: destination)

        #expect(try String(contentsOf: destination, encoding: .utf8) == "hello\nworld")
    }

    @Test
    func write_replacesExistingFile() async throws {
        let destination = directory.appending(path: "diagnostics.log")
        try "stale".write(to: destination, atomically: true, encoding: .utf8)

        try await collector.write("fresh", to: destination)

        #expect(try String(contentsOf: destination, encoding: .utf8) == "fresh")
    }

    @Test
    func write_leavesNoPartialFileBehind() async throws {
        let destination = directory.appending(path: "diagnostics.log")

        try await collector.write("done", to: destination)

        let partial = destination.appendingPathExtension("partial")
        #expect(!FileManager.default.fileExists(atPath: partial.path))
    }

    @Test
    func writeLogFile_includesBothSectionHeadersAndLibdigidocContents() async throws {
        let libdigidocLog = directory.appending(path: Constants.File.LibDigidocLog)
        try "libdigidoc line one\nlibdigidoc line two".write(to: libdigidocLog, atomically: true, encoding: .utf8)
        let destination = directory.appending(path: "ria_digidoc.log")

        try await collector.writeLogFile(
            to: destination,
            libdigidocLog: libdigidocLog,
            subsystemPrefix: "ee.ria.digidoc.LogCollectorTests"
        )

        let contents = try String(contentsOf: destination, encoding: .utf8)
        #expect(contents.contains("===== File: \(Constants.File.LibDigidocLog) ====="))
        #expect(contents.contains("===== File: \(Constants.File.AppLog) ====="))
        #expect(contents.contains("libdigidoc line one"))
        #expect(contents.contains("libdigidoc line two"))
    }

    @Test
    func writeLogFile_stillWritesHeadersWhenLibdigidocLogIsMissing() async throws {
        let destination = directory.appending(path: "ria_digidoc.log")

        try await collector.writeLogFile(
            to: destination,
            libdigidocLog: directory.appending(path: "does-not-exist.log"),
            subsystemPrefix: "ee.ria.digidoc.LogCollectorTests"
        )

        let contents = try String(contentsOf: destination, encoding: .utf8)
        #expect(contents.contains("===== File: \(Constants.File.LibDigidocLog) ====="))
        #expect(contents.contains("===== File: \(Constants.File.AppLog) ====="))
    }

    @Test
    func writeLogFile_leavesNoFileWhenCancelledBeforeCompletion() async throws {
        let libdigidocLog = directory.appending(path: Constants.File.LibDigidocLog)
        try String(repeating: "a line of libdigidoc output\n", count: 50)
            .write(to: libdigidocLog, atomically: true, encoding: .utf8)
        let destination = directory.appending(path: "ria_digidoc.log")

        let task = Task {
            try await collector.writeLogFile(
                to: destination,
                libdigidocLog: libdigidocLog,
                subsystemPrefix: "ee.ria.digidoc.LogCollectorTests"
            )
        }
        task.cancel()

        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(!FileManager.default.fileExists(atPath: destination.path))
        #expect(!FileManager.default.fileExists(atPath: destination.appendingPathExtension("partial").path))
    }

    @Test
    func writeLogFile_keepsPreviousFileWhenCancelled() async throws {
        let libdigidocLog = directory.appending(path: Constants.File.LibDigidocLog)
        try String(repeating: "a line of libdigidoc output\n", count: 50)
            .write(to: libdigidocLog, atomically: true, encoding: .utf8)
        let destination = directory.appending(path: "ria_digidoc.log")
        try "previous log".write(to: destination, atomically: true, encoding: .utf8)

        let task = Task {
            try await collector.writeLogFile(
                to: destination,
                libdigidocLog: libdigidocLog,
                subsystemPrefix: "ee.ria.digidoc.LogCollectorTests"
            )
        }
        task.cancel()

        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(try String(contentsOf: destination, encoding: .utf8) == "previous log")
    }

    @Test
    func writeLogFile_throwsWhenDestinationDirectoryDoesNotExist() async throws {
        let destination = directory.appending(path: "missing").appending(path: "ria_digidoc.log")

        await #expect(throws: (any Error).self) {
            try await collector.writeLogFile(
                to: destination,
                libdigidocLog: nil,
                subsystemPrefix: "ee.ria.digidoc.LogCollectorTests"
            )
        }
    }

    @Test
    func writeLogFile_includesMatchingOSLogEntries() async throws {
        let subsystem = "ee.ria.digidoc.LogCollectorTests.\(UUID().uuidString.prefix(8))"
        let marker = "collector-marker-\(UUID().uuidString)"
        Logger(subsystem: subsystem, category: "OSLogPath").info("\(marker, privacy: .public)")

        let destination = directory.appending(path: "ria_digidoc.log")
        var contents = ""

        for attempt in 0..<3 where !contents.contains(marker) {
            if attempt > 0 { try await Task.sleep(for: .milliseconds(200)) }
            try await collector.writeLogFile(to: destination, libdigidocLog: nil, subsystemPrefix: subsystem)
            contents = try String(contentsOf: destination, encoding: .utf8)
        }

        #expect(contents.contains(marker))
        #expect(contents.contains("[\(subsystem):OSLogPath]"))
    }

    @Test
    func writeLogFile_excludesEntriesFromOtherSubsystems() async throws {
        let marker = "excluded-marker-\(UUID().uuidString)"
        Logger(subsystem: "ee.ria.digidoc.SomeOtherSubsystem", category: "Other")
            .info("\(marker, privacy: .public)")

        let destination = directory.appending(path: "ria_digidoc.log")
        try await collector.writeLogFile(
            to: destination,
            libdigidocLog: nil,
            subsystemPrefix: "ee.ria.digidoc.LogCollectorTests.NoSuchSubsystem"
        )

        #expect(try !String(contentsOf: destination, encoding: .utf8).contains(marker))
    }

    @Test
    func writeLogFile_notesWhenLibdigidocLogWasNeverCreated() async throws {
        let destination = directory.appending(path: "ria_digidoc.log")

        try await collector.writeLogFile(
            to: destination,
            libdigidocLog: directory.appending(path: Constants.File.LibDigidocLog),
            subsystemPrefix: "ee.ria.digidoc.LogCollectorTests.NoSuchSubsystem"
        )

        let contents = try String(contentsOf: destination, encoding: .utf8)
        #expect(contents.contains("was not created during this session"))
    }

    @Test
    func writeLogFile_notesWhenLibdigidocLogCannotBeRead() async throws {
        let libdigidocLog = directory.appending(path: Constants.File.LibDigidocLog)
        try "unreadable content".write(to: libdigidocLog, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0], ofItemAtPath: libdigidocLog.path)
        defer { try? FileManager.default.setAttributes([.posixPermissions: 0o644],
                                                       ofItemAtPath: libdigidocLog.path) }

        let destination = directory.appending(path: "ria_digidoc.log")
        try await collector.writeLogFile(
            to: destination,
            libdigidocLog: libdigidocLog,
            subsystemPrefix: "ee.ria.digidoc.LogCollectorTests.NoSuchSubsystem"
        )

        let contents = try String(contentsOf: destination, encoding: .utf8)
        #expect(contents.contains("unable to read \(Constants.File.LibDigidocLog)"))
        #expect(!contents.contains("unreadable content"))
    }

    @Test
    func writeLogFile_notesWhenLibdigidocLogLocationIsUnknown() async throws {
        let destination = directory.appending(path: "ria_digidoc.log")

        try await collector.writeLogFile(
            to: destination,
            libdigidocLog: nil,
            subsystemPrefix: "ee.ria.digidoc.LogCollectorTests.NoSuchSubsystem"
        )

        let contents = try String(contentsOf: destination, encoding: .utf8)
        #expect(contents.contains("could not determine the libdigidocpp log location"))
    }

    @Test
    func write_throwsWhenAlreadyCancelled() async throws {
        let destination = directory.appending(path: "diagnostics.log")

        let task = Task { try await collector.write("some text", to: destination) }
        task.cancel()

        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(!FileManager.default.fileExists(atPath: destination.path))
    }

    @Test
    func writeLogFile_throwsWhenAlreadyCancelledWithNothingToCopy() async throws {
        let destination = directory.appending(path: "ria_digidoc.log")

        let task = Task {
            try await collector.writeLogFile(
                to: destination,
                libdigidocLog: nil,
                subsystemPrefix: "ee.ria.digidoc.LogCollectorTests.NoSuchSubsystem"
            )
        }
        task.cancel()

        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(!FileManager.default.fileExists(atPath: destination.path))
    }
}
