// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

public enum KeychainKey: String, CaseIterable, Sendable {
    case proxyPassword = "proxy_password"
    case webEidSessionActive = "web_eid_session_active"
    case nfcCANKey = "nfc_can_key"
    case tempCANKey = "temp_can_key"
    case signingCertKey = "signing_cert_key"
}
