import SwiftUI

struct ContainerNameView: View {
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    @State private var showBottomSheetFromButton = false
    @State private var showBottomSheetFromTap = false
    @State private var tempContainerURL: URL?
    @State private var isShowingFileSaver = false
    @State private var alertMessage: String?
    @State private var isFileSaved: Bool = false
    @State private var showAlert: Bool = false

    let icon: String
    let containerNameTitle: String
    @Binding var name: String
    let isEditContainerButtonShown: Bool
    let isEncryptButtonShown: Bool
    let showLeftActionButton: Bool
    let showRightActionButton: Bool
    let leftActionButtonName: String
    let rightActionButtonName: String
    let leftActionButtonAccessibilityLabel: String
    let rightActionButtonAccessibilityLabel: String
    let onLeftActionButtonClick: () -> Void
    let onRightActionButtonClick: () -> Void
    let onSaveContainerButtonClick: () -> Void
    let onRenameContainerButtonClick: () -> Void

    private var bottomSheetActions: [BottomSheetButton] {
        ContainerNameBottomSheetActions.actions(
            languageSettings: languageSettings,
            isEditContainerButtonShown: isEditContainerButtonShown,
            isEncryptButtonShown: isEncryptButtonShown,
            onRenameContainerButtonClick: onRenameContainerButtonClick,
            onSaveContainerButtonClick: onSaveContainerButtonClick
        )
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: Dimensions.Padding.XSPadding) {
                HStack(alignment: .center) {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(theme.onPrimary)
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .padding(Dimensions.Padding.XSPadding)
                        .background(theme.primary)
                        .clipShape(Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: Dimensions.Padding.ZeroPadding) {
                        Text(languageSettings.localized(containerNameTitle))
                            .font(typography.labelMedium)
                            .foregroundStyle(theme.onSurface)
                        HStack {
                            Text(name)
                                .font(typography.titleMedium)
                                .foregroundStyle(theme.onSurface)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                                .multilineTextAlignment(TextAlignment.leading)
                        }
                    }

                    Spacer()

                    Button(action: {
                        showBottomSheetFromButton = true
                    }, label: {
                        Image("ic_m3_more_vert_48pt_wght400")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                            .foregroundStyle(theme.onBackground)
                            .accessibilityLabel(languageSettings.localized("More options"))
                    })
                    .bottomSheet(isPresented: $showBottomSheetFromButton, actions: bottomSheetActions)
                }

                if showLeftActionButton || showRightActionButton {
                    HStack {
                        Spacer()

                        if showLeftActionButton {
                            Button(languageSettings.localized(leftActionButtonName)) {
                                onLeftActionButtonClick()
                            }
                            .font(typography.labelLarge)
                            .foregroundStyle(theme.primary)
                            .accessibilityLabel(leftActionButtonAccessibilityLabel)
                        }

                        if showRightActionButton {
                            Button(languageSettings.localized(rightActionButtonName)) {
                                onRightActionButtonClick()
                            }
                            .font(typography.labelLarge)
                            .foregroundStyle(theme.primary)
                            .accessibilityLabel(rightActionButtonAccessibilityLabel)
                        }
                    }
                    .padding(.trailing, Dimensions.Padding.MSPadding)
                    .padding(.top, Dimensions.Padding.MSPadding)
                }
            }
            .padding(.horizontal, Dimensions.Padding.MSPadding)
            .padding(.vertical, Dimensions.Padding.MPadding)
            .background(theme.surfaceContainerHighest)
            .cornerRadius(Dimensions.Corner.MSCornerRadius)
            .padding(.top, Dimensions.Padding.MSPadding)
            .onTapGesture {
                showBottomSheetFromTap = true
            }
            .accessibilityAddTraits([.isButton])
            .bottomSheet(isPresented: $showBottomSheetFromTap, actions: bottomSheetActions)
        }
    }
}

#Preview {
    ContainerNameView(
        icon: "ic_m3_stylus_note_48pt_wght400",
        containerNameTitle: "Container name",
        name: .constant("Test.asice"),
        isEditContainerButtonShown: true,
        isEncryptButtonShown: false,
        showLeftActionButton: true,
        showRightActionButton: true,
        leftActionButtonName: "Sign",
        rightActionButtonName: "Encrypt",
        leftActionButtonAccessibilityLabel: "Sign",
        rightActionButtonAccessibilityLabel: "Encrypt",
        onLeftActionButtonClick: {},
        onRightActionButtonClick: {},
        onSaveContainerButtonClick: {},
        onRenameContainerButtonClick: {}
    )
    .environmentObject(LanguageSettings())
}
