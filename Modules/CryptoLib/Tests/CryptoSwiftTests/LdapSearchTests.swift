// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CryptoTokenKit
import Foundation
import Network
import Testing

@testable import CryptoSwift

struct LdapSearchTests {

    private static func bytes(_ hex: String) -> Data {
        Data(stride(from: 0, to: hex.count, by: 2).compactMap {
            let start = hex.index(hex.startIndex, offsetBy: $0)
            return UInt8(hex[start..<hex.index(start, offsetBy: 2)], radix: 16)
        })
    }

    // Vectors from an independent BER encoder
    private static let entry = bytes(
        "30820110020101648201090409636e3d582c633d45453081fb30090402636e31030401583081ed04167573657243657274" +
        "69666963" + "6174653b62696e6172793181d20481c8" +
        (0..<200).map { String(format: "%02x", $0) }.joined() + "04053003020105"
    )
    private static let done = bytes("300c02010165070a010004000400")

    @Test
    func searchRequest_equalityFilter() {
        let request = LdapMessage.searchRequest(
            base: "c=EE",
            filter: .equals(attribute: "serialNumber", value: "PNOEE-38001010001")
        )
        #expect(request == Self.bytes(
            "305702010163520404633d45450a01020a0100020132020100010100a321040c73657269616c4e756d6265720411504e4f4545" +
            "2d3338303031303130303031301804167573657243657274696669636174653b62696e617279"
        ))
    }

    @Test
    func searchRequest_substringFilterWithLongLength() {
        let request = LdapMessage.searchRequest(
            base: "ou=Authentication,o=Identity card of Estonian citizen,dc=ESTEID,c=EE",
            filter: .contains(attribute: "cn", value: "Riigi")
        )
        #expect(request == Self.bytes(
            "308183020101637e04446f753d41757468656e7469636174696f6e2c6f3d4964656e746974792063617264206f6620" +
            "4573746f6e69616e20636974697a656e2c64633d4553544549442c633d45450a01020a0100020132020100010100a40d" +
            "0402636e300781055269696769301804167573657243657274696669636174653b62696e617279"
        ))
    }

    @Test
    func unbindRequest() {
        #expect(LdapMessage.unbindRequest == Self.bytes("30050201014200"))
    }

    @Test
    func reader_collectsCertificatesFromEntries() throws {
        var reader = LdapMessage.Reader()
        #expect(try reader.read(Self.entry + Self.done))
        #expect(reader.response.entryCount == 1)
        #expect(reader.response.certificates == [Data(0..<200), Data([0x30, 0x03, 0x02, 0x01, 0x05])])
    }

    @Test
    func reader_waitsForCompleteMessages() throws {
        var reader = LdapMessage.Reader()
        let response = Self.entry + Self.done
        for byte in response.dropLast() {
            #expect(try !reader.read(Data([byte])))
        }
        #expect(try reader.read(Data(response.suffix(1))))
        #expect(reader.response.entryCount == 1)
        #expect(reader.response.certificates.count == 2)
    }

    @Test
    func reader_acceptsSizeLimitExceeded() throws {
        var reader = LdapMessage.Reader()
        #expect(try reader.read(Self.bytes("300c02010165070a010404000400")))
    }

    @Test
    func reader_acceptsMessageControls() throws {
        var reader = LdapMessage.Reader()
        #expect(try reader.read(Self.bytes("300e02010165070a010004000400a000")))
    }

    @Test
    func reader_throwsResultCodeAndDiagnosticMessage() {
        var reader = LdapMessage.Reader()
        #expect(throws: LdapError.result(code: 32, message: "no such object")) {
            try reader.read(Self.bytes("301a02010165150a01200400040e6e6f2073756368206f626a656374"))
        }
    }

    @Test
    func reader_keepsEntriesAlongsideContinuationReference() throws {
        var reader = LdapMessage.Reader()
        let reference = Self.bytes("3014020101730f040d6c6461703a2f2f6f746865722f")
        #expect(try reader.read(Self.entry + reference + Self.done))
        #expect(reader.response.entryCount == 1)
        #expect(reader.response.certificates.count == 2)
    }

    @Test
    func reader_limitsTotalResponseSizeAcrossMessages() throws {
        var reader = LdapMessage.Reader()
        let entry = TKBERTLVRecord(tag: LdapMessage.Tag.sequence, records: [
            TKBERTLVRecord(tag: LdapMessage.Tag.integer, value: Data([LdapMessage.messageID])),
            TKBERTLVRecord(tag: LdapMessage.Tag.searchResultEntry, value: Data(count: 1024 * 1024))
        ]).data
        for _ in 0..<9 {
            #expect(try !reader.read(entry))
        }
        #expect(throws: LdapError.invalidResponse) {
            try reader.read(entry)
        }
    }

    @Test
    func reader_ignoresEntriesBeyondSizeLimit() throws {
        var reader = LdapMessage.Reader()
        let entries = Array(repeating: Self.entry, count: Int(LdapMessage.sizeLimit) + 1).reduce(Data(), +)
        #expect(try reader.read(entries + Self.done))
        #expect(reader.response.entryCount == Int(LdapMessage.sizeLimit))
        #expect(reader.response.certificates.count == Int(LdapMessage.sizeLimit) * 2)
    }

    @Test
    func reader_rejectsOtherMessageID() {
        var reader = LdapMessage.Reader()
        #expect(throws: LdapError.invalidResponse) {
            try reader.read(Self.bytes("300c02010265070a010004000400"))
        }
    }

    @Test
    func searchType_filters() {
        #expect(LdapSearch.SearchType(from: "38001010001").filter ==
            .equals(attribute: "serialNumber", value: "PNOEE-38001010001"))
        #expect(LdapSearch.SearchType(from: "70006317").filter ==
            .equals(attribute: "serialNumber", value: "70006317"))
        #expect(LdapSearch.SearchType(from: "Riigi(*)").filter ==
            .contains(attribute: "cn", value: "Riigi(*)"))
    }

    @Test
    func init_ldapsRequiresCACertificates() throws {
        let ldaps = try #require(URL(string: "ldaps://esteid.ldap.sk.ee"))
        let https = try #require(URL(string: "https://esteid.ldap.sk.ee"))
        let filter = LdapFilter.contains(attribute: "cn", value: "x")
        #expect(throws: LdapError.noCACertificates) {
            try LdapRequest(url: ldaps, filter: filter, caCertificates: [])
        }
        #expect(throws: LdapError.invalidURL) {
            try LdapRequest(url: https, filter: filter, caCertificates: [])
        }
    }

    @Test
    func init_rejectsOutOfRangePort() throws {
        let url = try #require(URL(string: "ldap://esteid.ldap.sk.ee:65536"))
        #expect(throws: LdapError.invalidURL) {
            try LdapRequest(url: url, filter: .contains(attribute: "cn", value: "x"), caCertificates: [])
        }
    }

    @Test @MainActor
    func search_combinesResultsFromPersonEndpoints() async throws {
        let entries = Array(repeating: Self.entry, count: Int(LdapMessage.sizeLimit)).reduce(Data(), +)
        let server = try FakeLdapServer(response: [entries, Self.done])
        let port = try await server.start()
        let configuration = LdapConfiguration()
        await configuration.update(LdapSettings(personURLs: [
            try #require(URL(string: "ldap://127.0.0.1:\(port)")),
            try #require(URL(string: "ldap://127.0.0.1:1"))
        ]))

        let result = await LdapSearch(ldapConfiguration: configuration).search(identityCode: "38001010001")

        #expect(result.addressees.isEmpty)
        #expect(result.tooManyResults)
        #expect(result.isNetworkError)
    }

    @Test @MainActor
    func search_withoutCorporationURLReturnsNoResults() async {
        let result = await LdapSearch(ldapConfiguration: LdapConfiguration()).search(identityCode: "Riigi")

        #expect(result.addressees.isEmpty)
        #expect(!result.tooManyResults)
        #expect(!result.isNetworkError)
    }

    @Test
    func run_searchesLocalServerAndUnbinds() async throws {
        let server = try FakeLdapServer(response: [Self.entry, Self.done])
        let port = try await server.start()
        let response = try await LdapRequest(
            url: try #require(URL(string: "ldap://127.0.0.1:\(port)/dc=test")),
            filter: .equals(attribute: "serialNumber", value: "70006317"),
            caCertificates: []
        ).run()
        #expect(response.entryCount == 1)
        #expect(response.certificates.count == 2)
        let received = await server.received()
        #expect(received == LdapMessage.searchRequest(
            base: "dc=test",
            filter: .equals(attribute: "serialNumber", value: "70006317")
        ) + LdapMessage.unbindRequest)
    }

    @Test
    func run_timesOutWhenServerDoesNotAnswer() async throws {
        let server = try FakeLdapServer(response: [])
        let port = try await server.start()
        let url = try #require(URL(string: "ldap://127.0.0.1:\(port)"))
        await #expect(throws: LdapError.timeout) {
            try await LdapRequest(
                url: url,
                filter: .contains(attribute: "cn", value: "x"),
                caCertificates: [],
                timeout: .milliseconds(500)
            ).run()
        }
    }
}

// Accepts one connection, sends each response chunk separately and records what the client wrote
private final class FakeLdapServer: @unchecked Sendable {
    private let queue = DispatchQueue(label: "FakeLdapServer")
    private let listener: NWListener
    private let response: [Data]
    private var data = Data()
    private var closed: CheckedContinuation<Data, Never>?
    private var isClosed = false

    init(response: [Data]) throws {
        listener = try NWListener(using: .tcp, on: .any)
        self.response = response
    }

    deinit {
        listener.cancel()
    }

    func start() async throws -> UInt16 {
        try await withCheckedThrowingContinuation { continuation in
            listener.newConnectionHandler = { connection in
                connection.start(queue: self.queue)
                self.receive(connection, sent: false)
            }
            listener.stateUpdateHandler = { state in
                switch state {
                case .ready: continuation.resume(returning: self.listener.port?.rawValue ?? 0)
                case .failed(let error): continuation.resume(throwing: error)
                default: break
                }
            }
            listener.start(queue: queue)
        }
    }

    func received() async -> Data {
        await withCheckedContinuation { continuation in
            queue.async {
                if self.isClosed {
                    continuation.resume(returning: self.data)
                } else {
                    self.closed = continuation
                }
            }
        }
    }

    private func receive(_ connection: NWConnection, sent: Bool) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { content, _, isComplete, error in
            if let content {
                self.data += content
            }
            let hasRequest = TKBERTLVRecord.sequenceOfRecords(from: self.data) != nil
            if !sent, hasRequest {
                for chunk in self.response {
                    connection.send(content: chunk, completion: .idempotent)
                }
            }
            if isComplete || error != nil {
                connection.cancel()
                self.isClosed = true
                self.closed?.resume(returning: self.data)
                self.closed = nil
                return
            }
            self.receive(connection, sent: sent || hasRequest)
        }
    }
}
