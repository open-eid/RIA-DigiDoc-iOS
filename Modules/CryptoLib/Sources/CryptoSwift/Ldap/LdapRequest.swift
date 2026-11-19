// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import CryptoTokenKit
import Foundation
import Network
import Security

enum LdapFilter: Equatable, CustomStringConvertible {
    case equals(attribute: String, value: String)
    case contains(attribute: String, value: String)

    var description: String {
        switch self {
        case let .equals(attribute, value): "(\(attribute)=\(value))"
        case let .contains(attribute, value): "(\(attribute)=*\(value)*)"
        }
    }
}

enum LdapError: Error, Equatable {
    case invalidURL
    case noCACertificates
    case untrustedServer
    case connection(String)
    case timeout
    case cancelled
    case invalidResponse
    case result(code: Int, message: String)

    var isNetworkError: Bool {
        switch self {
        case .noCACertificates, .untrustedServer, .connection, .timeout: true
        default: false
        }
    }
}

struct LdapResponse: Equatable {
    var certificates: [Data] = []
    var entryCount = 0
}

// RFC 4511 messages for an anonymous search of userCertificate;binary
enum LdapMessage {
    enum Tag {
        static let boolean: TKTLVTag = 0x01
        static let integer: TKTLVTag = 0x02
        static let octetString: TKTLVTag = 0x04
        static let enumerated: TKTLVTag = 0x0A
        static let sequence: TKTLVTag = 0x30
        static let unbindRequest: TKTLVTag = 0x42
        static let searchRequest: TKTLVTag = 0x63
        static let searchResultEntry: TKTLVTag = 0x64
        static let searchResultDone: TKTLVTag = 0x65
        static let searchResultReference: TKTLVTag = 0x73
        static let filterEquality: TKTLVTag = 0xA3
        static let filterSubstrings: TKTLVTag = 0xA4
        static let substringAny: TKTLVTag = 0x81
    }

    static let messageID: UInt8 = 1
    static let sizeLimit: UInt8 = 50
    static let resultSuccess = 0
    static let resultSizeLimitExceeded = 4
    static let maxResponseSize = 10 * 1024 * 1024
    static let certificateAttributes = ["userCertificate;binary", "userCertificate"]

    // Values below 0x80 encode as a single byte
    private static func integer(_ value: UInt8, tag: TKTLVTag = Tag.integer) -> TKBERTLVRecord {
        TKBERTLVRecord(tag: tag, value: Data([value]))
    }

    private static func string(_ value: String, tag: TKTLVTag = Tag.octetString) -> TKBERTLVRecord {
        TKBERTLVRecord(tag: tag, value: Data(value.utf8))
    }

    private static func message(_ operation: TKBERTLVRecord) -> Data {
        TKBERTLVRecord(tag: Tag.sequence, records: [integer(messageID), operation]).data
    }

    static func searchRequest(base: String, filter: LdapFilter) -> Data {
        let filterRecord = switch filter {
        case let .equals(attribute, value):
            TKBERTLVRecord(tag: Tag.filterEquality, records: [string(attribute), string(value)])
        case let .contains(attribute, value):
            TKBERTLVRecord(tag: Tag.filterSubstrings, records: [
                string(attribute),
                TKBERTLVRecord(tag: Tag.sequence, records: [string(value, tag: Tag.substringAny)])
            ])
        }
        return message(TKBERTLVRecord(tag: Tag.searchRequest, records: [
            string(base),
            integer(2, tag: Tag.enumerated), // scope: wholeSubtree
            integer(0, tag: Tag.enumerated), // derefAliases: neverDerefAliases
            integer(sizeLimit),
            integer(0), // timeLimit: none
            integer(0, tag: Tag.boolean), // typesOnly: false
            filterRecord,
            TKBERTLVRecord(tag: Tag.sequence, records: [string(certificateAttributes[0])])
        ]))
    }

    static let unbindRequest = message(TKBERTLVRecord(tag: Tag.unbindRequest, value: Data()))

    struct Reader {
        private(set) var response = LdapResponse()
        private var buffer = Data()
        private var receivedSize = 0

        // Returns true once SearchResultDone arrives. Parsing fails until the buffer ends on a message
        // boundary, which the response always reaches because SearchResultDone is sent last
        mutating func read(_ data: Data) throws(LdapError) -> Bool {
            receivedSize += data.count
            guard receivedSize <= maxResponseSize else { throw .invalidResponse }
            buffer += data
            guard let messages = TKBERTLVRecord.sequenceOfRecords(from: buffer) else { return false }
            buffer.removeAll()
            for message in messages {
                guard message.tag == Tag.sequence,
                      let fields = TKBERTLVRecord.sequenceOfRecords(from: message.value), fields.count >= 2,
                      fields[0].tag == Tag.integer, Self.intValue(fields[0].value) == Int(messageID) else {
                    throw .invalidResponse
                }
                let operation = fields[1]
                switch operation.tag {
                case Tag.searchResultEntry:
                    guard response.entryCount < Int(sizeLimit) else { continue }
                    readEntry(operation.value)
                case Tag.searchResultReference:
                    continue // Not followed, RFC 4511 4.5.3
                case Tag.searchResultDone:
                    try Self.complete(operation.value)
                    return true
                default:
                    throw .invalidResponse
                }
            }
            return false
        }

        private mutating func readEntry(_ entry: Data) {
            response.entryCount += 1
            guard let fields = TKBERTLVRecord.sequenceOfRecords(from: entry), fields.count >= 2,
                  let attributes = TKBERTLVRecord.sequenceOfRecords(from: fields[1].value) else { return }
            for attribute in attributes {
                guard let typeAndValues = TKBERTLVRecord.sequenceOfRecords(from: attribute.value),
                      typeAndValues.count >= 2,
                      certificateAttributes.contains(where: {
                          String(decoding: typeAndValues[0].value, as: UTF8.self)
                              .caseInsensitiveCompare($0) == .orderedSame
                      }) else { continue }
                let values = TKBERTLVRecord.sequenceOfRecords(from: typeAndValues[1].value) ?? []
                response.certificates += values.map(\.value)
            }
        }

        private static func complete(_ result: Data) throws(LdapError) {
            guard let fields = TKBERTLVRecord.sequenceOfRecords(from: result), let resultCode = fields.first else {
                throw .invalidResponse
            }
            let code = resultCode.tag == Tag.enumerated ? intValue(resultCode.value) ?? -1 : -1
            guard code == resultSuccess || code == resultSizeLimitExceeded else {
                let diagnosticMessage = fields.count > 2 ? fields[2].value : Data() // skip matchedDN
                throw .result(code: code, message: String(decoding: diagnosticMessage, as: UTF8.self))
            }
        }

        private static func intValue(_ data: Data) -> Int? {
            guard !data.isEmpty, data.count <= MemoryLayout<Int32>.size else { return nil }
            return data.reduce(0) { $0 << 8 | Int($1) }
        }
    }
}

final class LdapRequest: @unchecked Sendable {
    private let queue = DispatchQueue(label: "ee.ria.digidoc.ldap")
    private let connection: NWConnection
    private let request: Data
    private let timeout: DispatchTimeInterval
    private var reader = LdapMessage.Reader()
    private var continuation: CheckedContinuation<LdapResponse, Error>?
    private var finished = false

    // The server must chain to one of caCertificates; system trust anchors are not used
    init(
        url: URL,
        filter: LdapFilter,
        caCertificates: [Data],
        timeout: DispatchTimeInterval = .seconds(30)
    ) throws(LdapError) {
        guard let scheme = url.scheme?.lowercased(), scheme == "ldaps" || scheme == "ldap",
              let host = url.host(), !host.isEmpty else { throw .invalidURL }
        let tls = scheme == "ldaps"
        guard let portNumber = UInt16(exactly: url.port ?? (tls ? 636 : 389)),
              let port = NWEndpoint.Port(rawValue: portNumber) else { throw .invalidURL }
        if tls && caCertificates.isEmpty { throw .noCACertificates }

        let base = String(url.path().removingPercentEncoding?.dropFirst() ?? "")
        request = LdapMessage.searchRequest(base: base.isEmpty ? "c=EE" : base, filter: filter)
        self.timeout = timeout

        let tcp = NWProtocolTCP.Options()
        guard tls else {
            connection = NWConnection(host: .init(host), port: port, using: .init(tls: nil, tcp: tcp))
            return
        }
        let tlsOptions = NWProtocolTLS.Options()
        // A resumed session skips the verify block and with it the CA pinning
        sec_protocol_options_set_tls_resumption_enabled(tlsOptions.securityProtocolOptions, false)
        sec_protocol_options_set_tls_tickets_enabled(tlsOptions.securityProtocolOptions, false)
        sec_protocol_options_set_verify_block(tlsOptions.securityProtocolOptions, { _, trust, complete in
            let secTrust = sec_trust_copy_ref(trust).takeRetainedValue()
            let anchors = caCertificates.compactMap { SecCertificateCreateWithData(nil, $0 as CFData) }
            SecTrustSetAnchorCertificates(secTrust, anchors as CFArray)
            SecTrustSetAnchorCertificatesOnly(secTrust, true)
            complete(SecTrustEvaluateWithError(secTrust, nil))
        }, queue)
        connection = NWConnection(host: .init(host), port: port, using: .init(tls: tlsOptions, tcp: tcp))
    }

    func run() async throws -> LdapResponse {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                queue.async { self.start(continuation) }
            }
        } onCancel: {
            queue.async { self.finish(.failure(LdapError.cancelled)) }
        }
    }

    private func start(_ continuation: CheckedContinuation<LdapResponse, Error>) {
        guard !finished else { return continuation.resume(throwing: LdapError.cancelled) }
        self.continuation = continuation
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                self.connection.send(content: self.request, completion: .contentProcessed { error in
                    if let error { self.finish(.failure(LdapError.connection(error.localizedDescription))) }
                })
                self.receive()
            case .waiting(let error), .failed(let error):
                if case .tls = error {
                    self.finish(.failure(LdapError.untrustedServer))
                } else {
                    self.finish(.failure(LdapError.connection(error.localizedDescription)))
                }
            default:
                break
            }
        }
        connection.start(queue: queue)
        queue.asyncAfter(deadline: .now() + timeout) { self.finish(.failure(LdapError.timeout)) }
    }

    private func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { data, _, isComplete, error in
            guard !self.finished else { return }
            do {
                if let data, try self.reader.read(data) {
                    return self.finish(.success(self.reader.response))
                }
            } catch {
                return self.finish(.failure(error))
            }
            if let error { return self.finish(.failure(LdapError.connection(error.localizedDescription))) }
            if isComplete { return self.finish(.failure(LdapError.invalidResponse)) }
            self.receive()
        }
    }

    private func finish(_ result: Result<LdapResponse, Error>) {
        guard !finished else { return }
        finished = true
        connection.stateUpdateHandler = nil
        if case .success = result {
            connection.send(content: LdapMessage.unbindRequest, completion: .contentProcessed { _ in
                self.connection.cancel()
            })
        } else {
            connection.cancel()
        }
        continuation?.resume(with: result)
        continuation = nil
    }
}
