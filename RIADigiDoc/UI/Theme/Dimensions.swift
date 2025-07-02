import SwiftUI

enum Dimensions {
    enum Corner {
        static let XXSCornerRadius: CGFloat = 4
        static let MSCornerRadius: CGFloat = 12
    }

    enum Height {
        static let XSBorder: CGFloat = 1
        static let SBorder: CGFloat = 2
    }

    enum Icon {
        static let IconSizeXXS: CGFloat = 24
        static let IconSizeXS: CGFloat = 48
        static let IconSizeM: CGFloat = 72
        static let IconSizeXXL: CGFloat = 144
    }

    enum Padding {
        static let ZeroPadding: CGFloat = 0
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
        static let opacity: Double = 0.15
    }
}
