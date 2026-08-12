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

import SwiftUI
import UIKit
import FactoryKit

@MainActor
final class CaptureCoverWindow {
    enum CoverReason {
        case sceneCaptured
        case sceneInactive
    }

    static let shared = CaptureCoverWindow()

    private var window: UIWindow?
    private var accessibilityStateBeforeCovering: [(window: UIWindow, wasHidden: Bool)] = []
    private var coverReasons: Set<CoverReason> = []

    private init() {}

    func setCovered(_ isCovered: Bool, for reason: CoverReason) {
        if isCovered {
            coverReasons.insert(reason)
            if reason == .sceneCaptured {
                dismissKeyboard()
            }
        } else {
            coverReasons.remove(reason)
        }

        if coverReasons.isEmpty {
            hide()
        } else {
            show()
        }
    }

    private func show() {
        guard window == nil, let windowScene = Self.foregroundWindowScene() else { return }

        let hostingController = UIHostingController(
            rootView: LaunchScreenView()
                .environment(Container.shared.themeSettings())
                .environment(Container.shared.languageSettings())
        )

        let coverWindow = UIWindow(windowScene: windowScene)
        coverWindow.windowLevel = .alert + 1
        coverWindow.rootViewController = hostingController
        coverWindow.isHidden = false

        accessibilityStateBeforeCovering = windowScene.windows
            .filter { $0 !== coverWindow }
            .map { ($0, $0.accessibilityElementsHidden) }
        accessibilityStateBeforeCovering.forEach { $0.window.accessibilityElementsHidden = true }

        window = coverWindow
    }

    private func hide() {
        accessibilityStateBeforeCovering.forEach { $0.window.accessibilityElementsHidden = $0.wasHidden }
        accessibilityStateBeforeCovering = []

        window?.isHidden = true
        window = nil
    }

    private func dismissKeyboard() {
        Self.foregroundWindowScene()?.windows.forEach { $0.endEditing(true) }
    }

    private static func foregroundWindowScene() -> UIWindowScene? {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return windowScenes.first { $0.activationState == .foregroundActive } ?? windowScenes.first
    }
}

struct HideSensitiveContentViewModifier: ViewModifier {
    @Environment(\.isSceneCaptured) private var isSceneCaptured
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: isSceneCaptured, initial: true) { _, isCaptured in
                CaptureCoverWindow.shared.setCovered(isCaptured, for: .sceneCaptured)
            }
            .onChange(of: scenePhase, initial: true) { _, phase in
                CaptureCoverWindow.shared.setCovered(phase != .active, for: .sceneInactive)
            }
    }
}

extension View {
    func hideSensitiveContent() -> some View {
        #if DEBUG || ENABLE_LOGGING
        return self
        #else
        return self.modifier(HideSensitiveContentViewModifier())
        #endif
    }
}

// Applies the modifier directly rather than hideSensitiveContent(), which compiles to a no-op in DEBUG
#Preview {
    Text(verbatim: "Sensitive content")
        .modifier(HideSensitiveContentViewModifier())
        .environment(\.isSceneCaptured, true)
}
