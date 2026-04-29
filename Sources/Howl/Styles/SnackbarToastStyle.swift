//
//  SnackbarToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



public struct SnackbarToastStyle: ToastStyle {
    
    private let shape = RoundedRectangle(cornerRadius: 8)
    
    
    public func body(_ configuration: Configuration, environment: EnvironmentValues) -> some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(.clear)
            
            HStack(spacing: 12) {
                Text(configuration.text)
                    .contentTransition(.interpolate)
                
                ctaButtonOrNaw(configuration: configuration)
                    .animation(.bouncy, value: configuration)
            }
            .font(.body)
            .padding()
            .background {
                background(in: environment)
                    .animation(.bouncy, value: configuration)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.move(edge: .bottom).animation(.bouncy))
    }
}



private extension SnackbarToastStyle {
    
    /// The background of the snackbar, making the "bar" shape of it
    ///
    /// - Parameter environment: The current environment values, so the snackbar can be built correctly
    @ViewBuilder
    func background(in environment: EnvironmentValues) -> some View {
        if #available(macOS 26, iOS 26, *) {
            shape
                .fill(.clear)
                .glassEffect(.regular.tint(glassEffectTint(in: environment)), in: shape)
                .shadow(radius: 6, y: 2)
        }
        else {
            ZStack {
                shape
                    .fill(.ultraThinMaterial.blendMode(.multiply))
                    .shadow(radius: 6, y: 2)
                shape
                    .inset(by: -1)
                    .stroke(Color(white: 0.3).blendMode(.lighten),
                            style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
    }
    
    
    /// The call-to-action button, if the configuration calls for it.
    ///
    /// - Parameter configuration: The toast configuration, which might describe the CTA
    @ViewBuilder
    func ctaButtonOrNaw(configuration: Configuration) -> some View {
        if let action = configuration.callToAction {
            Button(action.label, action: action.userDidInteract)
                .fontWeight(.medium)
                .foregroundStyle(ctaButtonForegroundColor)
                .shadow(color: .accentColor.opacity(0.5), radius: 8)
                .buttonStyle(.plain)
                .contentTransition(.interpolate)
                .transition(.move(edge: .leading).combined(with: .blurReplace).animation(.bouncy))
        }
    }
    
    
    /// The foreground color of the call-to-action button
    var ctaButtonForegroundColor: Color {
        if #available(iOS 18, macOS 15, *) {
            Color.accentColor.mix(with: .primary, by: 0.1)
        }
        else {
            Color.accentColor
        }
    }
    
    
    /// The most-appropriate tint of the glass effect in the current environment
    ///
    /// - Parameter environment: The current environment values, so the snackbar can be built correctly
    func glassEffectTint(in environment: EnvironmentValues) -> Color {
        switch environment.colorScheme {
        case .dark:  .black.opacity(0.6)
        case .light: .clear
            
        @unknown default: .clear
        }
    }
}



public extension ToastStyle where Self == SnackbarToastStyle {
    static var snackbar: Self { Self.init() }
}



// MARK: - Preview

@available(macOS 15, iOS 18, macCatalyst 18, tvOS 18, visionOS 2, watchOS 11, *)
#Preview("Snackbar") {
    ToastPreview(.snackbar)
}
