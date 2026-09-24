// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import SwiftUI

@propertyWrapper
struct AppTypography: DynamicProperty {
    @Environment(\.typography) private var typography
    var wrappedValue: Typography { typography }
}
