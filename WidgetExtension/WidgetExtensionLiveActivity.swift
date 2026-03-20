/*
 * Copyright 2017 - 2026 Riigi Infosüsteemi Amet
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

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
