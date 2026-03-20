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

struct SignatureBottomSheetActions {
    static func actions(
        showRemoveSignatureButton: Bool,
        onDetailsButtonClick: @escaping () -> Void,
        onRemoveSignatureButtonClick: @escaping () -> Void,
    ) -> [BottomSheetButton] {
        [
            BottomSheetButton(
                icon: "ic_m3_edit_48pt_wght400",
                title: "Signature details",
                accessibilityLabel: "Signature details",
                onClick: onDetailsButtonClick
            ),
            BottomSheetButton(
                showButton: showRemoveSignatureButton,
                icon: "ic_m3_encrypted_48pt_wght400",
                title: "Remove signature",
                accessibilityLabel: "Remove signature",
                onClick: onRemoveSignatureButtonClick
            )
        ]
    }
}
