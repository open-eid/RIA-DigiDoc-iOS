// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import Foundation

public enum ActionMethod: String, Sendable, CaseIterable, Identifiable {
    case idCardViaNFC = "ID-card via NFC"
    case mobileId = "Mobile-ID"
    case smartId = "Smart-ID"

    public var id: String { rawValue }
}
