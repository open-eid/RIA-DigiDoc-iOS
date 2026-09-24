// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import ActivityKit

// A Live Activity is updated by the system in the background, not on the app's main screen.
// `nonisolated` marks this data as safe to use away from the main screen
public nonisolated struct WidgetExtensionAttributes: ActivityAttributes {
    public nonisolated struct ContentState: Codable, Hashable {
        var title: String
        var compactTitle: String
        var controlCode: String
    }
}
