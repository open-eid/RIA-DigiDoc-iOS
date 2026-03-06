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

import SwiftUI

enum Dimensions {
    enum Corner {
        static let XXSCornerRadius: CGFloat = 4
        static let XSCornerRadius: CGFloat = 8
        static let MSCornerRadius: CGFloat = 12
        static let MCornerRadius: CGFloat = 24
    }

    enum Height {
        static let XSBorder: CGFloat = 1
        static let SBorder: CGFloat = 2
    }

    enum Icon {
        static let IconSizeMicro: CGFloat = 12
        static let IconSizeXXXS: CGFloat = 20
        static let IconSizeXXS: CGFloat = 24
        static let IconSizeXS: CGFloat = 48
        static let IconSizeM: CGFloat = 72
        static let IconSizeXXL: CGFloat = 144
    }

    enum Padding {
        static let ZeroPadding: CGFloat = 0
        static let XXXSPadding: CGFloat = 2
        static let XXSPadding: CGFloat = 4
        static let XSPadding: CGFloat = 8
        static let MSPadding: CGFloat = 12
        static let SPadding: CGFloat = 16
        static let MPadding: CGFloat = 24
        static let LPadding: CGFloat = 32
        static let XLPadding: CGFloat = 48
    }

    enum Shadow {
        static let radius: CGFloat = Dimensions.Corner.XXSCornerRadius
        static let xOffset: CGFloat = 0
        static let yOffset: CGFloat = 4
        static let SOpacity: Double = 0.15
        static let LOpacity: Double = 0.7
    }

    enum Duration {
        static let focusAnimation: CGFloat = 0.1
    }

    enum Scaling {
        static let DefaultScaling: CGFloat = 1.0
        static let SmallScaling: CGFloat = 1.1
        static let WideScaling: CGFloat = 1.2
    }

    enum TextField {
        static let lineHeightMultiplier: CGFloat = 1.2
        static let paddingMultiplier: CGFloat = 0.4
        static let accessibilityPaddingMultiplier: CGFloat = 0.3
    }
}
