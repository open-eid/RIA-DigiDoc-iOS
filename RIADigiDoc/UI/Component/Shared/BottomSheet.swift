import SwiftUI

struct BottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageSettings: LanguageSettings
    @AppTheme private var theme
    @AppTypography private var typography

    let actions: [BottomSheetButton]

    var body: some View {
        VStack(spacing: Dimensions.Padding.LPadding) {
            HStack {
                Spacer()
                Button(action: { dismiss() }, label: {
                    Image("ic_m3_close_48pt_wght400")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                        .foregroundStyle(theme.onSurface)
                        .accessibilityLabel(languageSettings.localized("Close"))
                })
            }
            .padding(Dimensions.Padding.SPadding)

            ForEach(actions) { item in
                if item.showButton {
                    Button(action: {
                        item.onClick()
                        dismiss()
                    }, label: {
                        HStack {
                            Image(item.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                .foregroundStyle(theme.onSurface)
                                .accessibilityLabel(item.accessibilityLabel)

                            Text(item.title)
                                .foregroundStyle(theme.onSurface)
                                .font(typography.bodyLarge)

                            Spacer()

                            if item.showExtraIcon {
                                Image(item.extraIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: Dimensions.Icon.IconSizeXXS, height: Dimensions.Icon.IconSizeXXS)
                                    .foregroundStyle(theme.onSurface)
                                    .accessibilityLabel(item.accessibilityLabel)
                            }
                        }
                        .foregroundStyle(theme.onSurface)
                        .padding(.horizontal, Dimensions.Padding.MPadding)
                    })
                }
            }
        }
        .padding(.vertical, Dimensions.Padding.MSPadding)
        .padding(.bottom, Dimensions.Padding.MPadding)
        .frame(maxWidth: .infinity)
    }
}

struct BottomSheetViewModifier: ViewModifier {
    @State private var contentHeight: CGFloat = 0
    @Binding var isPresented: Bool
    let actions: [BottomSheetButton]

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                let sheet = BottomSheet(actions: actions)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    contentHeight = geometry.size.height
                                }
                        }
                    )

                if #available(iOS 16.0, *) {
                    Group {
                        sheet
                    }
                    .presentationDetents([.height(contentHeight)])
                    .presentationDragIndicator(.visible)
                } else {
                    LegacyBottomSheetWrapper(isPresented: $isPresented, actions: actions)
                }
            }
    }
}

// MARK: Pre-iOS 16 bottom sheet

class LegacyBottomSheetViewController: UIViewController {
    private var isPresented: Bool
    private let actions: [BottomSheetButton]
    private let tableView = UITableView()

    init(isPresented: Bool, actions: [BottomSheetButton]) {
        self.isPresented = isPresented
        self.actions = actions
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomSheet()
    }

    private func setupBottomSheet() {
        let bottomSheetView = BottomSheet(actions: actions)
        let hostingController = UIHostingController(rootView: bottomSheetView)

        hostingController.modalPresentationStyle = .pageSheet

        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}

struct LegacyBottomSheetWrapper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let actions: [BottomSheetButton]

    func makeUIViewController(context _: Context) -> LegacyBottomSheetViewController {
        LegacyBottomSheetViewController(isPresented: isPresented, actions: actions)
    }

    func updateUIViewController(_: LegacyBottomSheetViewController, context _: Context) {}
}

extension View {
    func bottomSheet(isPresented: Binding<Bool>, actions: [BottomSheetButton]) -> some View {
        self.modifier(BottomSheetViewModifier(isPresented: isPresented, actions: actions))
    }
}

#Preview {
    let sheetActions = [
        BottomSheetButton(
            icon: "ic_m3_edit_48pt_wght400",
            title: "Change container name",
            accessibilityLabel: "Change container name",
            onClick: {}
        ),
        BottomSheetButton(
            icon: "ic_m3_download_48pt_wght400",
            title: "Save container",
            accessibilityLabel: "Save container",
            onClick: {}
        )
    ]
    Button("Show Sheet") {}
        .bottomSheet(isPresented: .constant(true), actions: sheetActions)
        .environmentObject(LanguageSettings())
}
