/*
 * Copyright 2017 - 2025 Riigi Infosüsteemi Amet
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

struct HomeMenuBottomSheetActions {
    static func actions(
        onInfoClick: @escaping () -> Void,
        onAccessibilityClick: @escaping () -> Void,
        onDiagnosticsClick: @escaping () -> Void
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_info_48pt_wght400",
                title: "Main home menu about",
                accessibilityLabel: "Main home menu about",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onInfoClick,
            ),
            BottomSheetButton(
                icon: "ic_m3_accessibility_new_48pt_wght400",
                title: "Main home menu accessibility",
                accessibilityLabel: "Main home menu accessibility",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onAccessibilityClick
            ),
            BottomSheetButton(
                icon: "ic_m3_show_chart_48pt_wght400",
                title: "Main home menu diagnostics",
                accessibilityLabel: "Main home menu diagnostics",
                showExtraIcon: true,
                extraIcon: "ic_m3_arrow_right_48pt_wght400",
                onClick: onDiagnosticsClick
            )
        ]
    }
}
