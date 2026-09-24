// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public struct MimeTypeDecoder: MimeTypeDecoderProtocol {

    public func parse(xmlData: Data) async -> ContainerType {
        await withCheckedContinuation { continuation in
            let parser = XMLParser(data: xmlData)
            let handler = XMLParserHandler(continuation: continuation)

            parser.delegate = handler

            let success = parser.parse()

            if !success {
                handler.finishIfNeeded()
            }
        }
    }

}
