// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

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
        static let XXLPadding: CGFloat = 80
    }

    enum Shadow {
        static let zeroRadius: CGFloat = 0
        static let radius: CGFloat = Dimensions.Corner.XXSCornerRadius
        static let xOffset: CGFloat = 0
        static let yOffset: CGFloat = 4
        static let ySOffset: CGFloat = 1
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
