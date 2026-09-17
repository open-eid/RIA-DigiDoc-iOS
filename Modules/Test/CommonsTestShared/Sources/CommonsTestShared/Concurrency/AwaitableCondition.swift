// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public actor AwaitableCondition {
    private var waiter: CheckedContinuation<Void, Never>?
    private var isFulfilled = false

    public init() {}

    public func fulfill() {
        isFulfilled = true
        let waiter = self.waiter
        self.waiter = nil
        waiter?.resume()
    }

    public func wait() async {
        if isFulfilled { return }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            waiter = continuation
        }
    }
}
