//
//  SnackbarToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



public struct SnackbarToastStyle: ToastStyle {
    
    private let shape = RoundedRectangle(cornerRadius: 8)
    
    
    public func body(_ configuration: Configuration, environment _: EnvironmentValues) -> some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(.clear)
            
            HStack(spacing: 12) {
                Text(configuration.text)
                
                ctaButtonOrNaw(configuration: configuration)
                    .animation(.bouncy, value: configuration)
            }
            .font(.body)
            .padding()
            .background {
                background
                    .animation(.bouncy, value: configuration)
            }
            .padding()
//            .geometryGroup()
            
            .colorScheme(.dark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .compositingGroup()
        .transition(.move(edge: .bottom).animation(.bouncy))
//        .animation(.bouncy)
    }
    
    
    @ViewBuilder
    private var background: some View {
        if #available(macOS 26, iOS 26, *) {
            shape
                .fill(.clear)
                .glassEffect(.regular.tint(.black.opacity(0.5)), in: shape)
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
    
    
    @ViewBuilder
    private func ctaButtonOrNaw(configuration: Configuration) -> some View {
        if let action = configuration.callToAction {
            Button(action.label, action: action.userDidInteract)
            #if os(macOS)
                .buttonStyle(.link)
            #else
                .buttonStyle(.borderless)
            #endif
                .transition(.move(edge: .leading).combined(with: .blurReplace).animation(.bouncy))
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
