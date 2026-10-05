// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation
import Synchronization
import Testing
import LibdigidocLibObjC

private final class CompletionFlag: Sendable {
    private let completed = Mutex(false)

    var isCompleted: Bool {
        completed.withLock { $0 }
    }

    func markCompleted() {
        completed.withLock { $0 = true }
    }
}

struct DigiDocSigningWrapperTests {

    private func waitUntilCompleted(_ flag: CompletionFlag) async -> Bool {
        for _ in 0..<200 {
            if flag.isCompleted {
                return true
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return false
    }

    @Test
    func addSignature_runsItsWorkOnTheLibraryQueue() async {
        let wrapper = DigiDocSigningWrapper()
        let completed = CompletionFlag()
        let gate = DispatchSemaphore(value: 0)

        DigiDocContainerWrapper.libraryQueue().async { gate.wait() }

        wrapper.addSignature(Data([0x01, 0x02])) { _, _ in
            completed.markCompleted()
        }

        try? await Task.sleep(for: .milliseconds(200))
        #expect(!completed.isCompleted)

        gate.signal()

        #expect(await waitUntilCompleted(completed))
    }

    @Test
    func prepareSignature_runsItsWorkOnTheLibraryQueue() async {
        let wrapper = DigiDocSigningWrapper()
        let completed = CompletionFlag()
        let gate = DispatchSemaphore(value: 0)

        DigiDocContainerWrapper.libraryQueue().async { gate.wait() }

        wrapper.prepareSignature(
            Data([0x01, 0x02]),
            containerPath: "/nonexistent/container.asice",
            roleData: DigiDocRoleData(roles: nil, city: nil, state: nil, country: nil, zipcode: nil),
            userAgent: "DigiDocSigningWrapperTests"
        ) { _, _ in
            completed.markCompleted()
        }

        try? await Task.sleep(for: .milliseconds(200))
        #expect(!completed.isCompleted)

        gate.signal()

        #expect(await waitUntilCompleted(completed))
    }

    @Test
    func addSignature_deliversCompletionOnMainThreadWhenSignatureIsMissing() async {
        let wrapper = DigiDocSigningWrapper()

        let isMainThread: Bool = await withCheckedContinuation { continuation in
            wrapper.addSignature(Data([0x01, 0x02])) { _, _ in
                continuation.resume(returning: Thread.isMainThread)
            }
        }

        #expect(isMainThread)
    }

    @Test
    func prepareSignature_deliversCompletionOnMainThreadWhenContainerCannotBeOpened() async {
        let wrapper = DigiDocSigningWrapper()

        let isMainThread: Bool = await withCheckedContinuation { continuation in
            wrapper.prepareSignature(
                Data([0x01, 0x02]),
                containerPath: "/nonexistent/container.asice",
                roleData: DigiDocRoleData(roles: nil, city: nil, state: nil, country: nil, zipcode: nil),
                userAgent: "DigiDocSigningWrapperTests"
            ) { _, _ in
                continuation.resume(returning: Thread.isMainThread)
            }
        }

        #expect(isMainThread)
    }

    @Test
    func addSignature_reportsErrorWhenNoSignatureWasPrepared() async {
        let wrapper = DigiDocSigningWrapper()

        let error: NSError? = await withCheckedContinuation { continuation in
            wrapper.addSignature(Data([0x01, 0x02])) { _, error in
                continuation.resume(returning: error as NSError?)
            }
        }

        #expect(error?.domain == "LibdigidocLib")
        #expect(error?.code == 2)
    }

    @Test
    func prepareSignature_reportsErrorWhenContainerCannotBeOpened() async {
        let wrapper = DigiDocSigningWrapper()

        let result: (Data?, NSError?) = await withCheckedContinuation { continuation in
            wrapper.prepareSignature(
                Data([0x01, 0x02]),
                containerPath: "/nonexistent/container.asice",
                roleData: DigiDocRoleData(roles: nil, city: nil, state: nil, country: nil, zipcode: nil),
                userAgent: "DigiDocSigningWrapperTests"
            ) { dataToSign, error in
                continuation.resume(returning: (dataToSign, error as NSError?))
            }
        }

        #expect(result.0 == nil)
        #expect(result.1?.domain == "LibdigidocLib")
    }
}
