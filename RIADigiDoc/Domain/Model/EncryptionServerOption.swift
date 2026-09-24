// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

struct EncryptionServerOption: Identifiable, Equatable, Hashable {
    let id: String
    let titleKey: String
    let accessibilityInputLabel: String
}
