// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

import ActivityKit
import WidgetKit
import SwiftUI

struct WidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WidgetExtensionAttributes.self) { context in
            let controlCode = context.state.controlCode
            HStack {
                Image("image_id_ee")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48)
                    .accessibilityLabel("DigiDoc")

                let text = controlCode.isEmpty ?
                context.state.title :
                "\(context.state.title): \(context.state.controlCode)"

                Text(verbatim: text)
                    .padding()
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        Text(verbatim: context.state.title)
                        Text(verbatim: context.state.controlCode)
                            .bold()
                    }
                }
            } compactLeading: {
                Image("image_id_ee")
                    .resizable()
                    .scaledToFit()
                    .padding(2)
                    .accessibilityLabel("DigiDoc")
            }
            compactTrailing: {
                Text(verbatim: context.state.controlCode)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            minimal: {
                Text(verbatim: context.state.controlCode)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }
}
