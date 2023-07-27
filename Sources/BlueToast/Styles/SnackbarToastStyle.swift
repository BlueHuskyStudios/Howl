//
//  SnackbarToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



public struct SnackbarToastStyle: ToastStyle {
    
    public func body(_ configuration: Configuration) -> some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(.clear)
            
            HStack {
                Text(configuration.text)
                
                if let action = configuration.action {
                    Button(action.label, action: action.userDidInteract)
                        .buttonStyle(.link)
                }
            }
            .font(.body)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.ultraThinMaterial.blendMode(.multiply))
                    .shadow(radius: 6, y: 2)
            }
            .padding()
            
            .preferredColorScheme(.dark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .transition(.move(edge: .bottom).animation(.bouncy))
    }
}



public extension ToastStyle where Self == SnackbarToastStyle {
    static var snackbar: Self { Self.init() }
}



// MARK: - Preview

#Preview("Snackbar") {
    ToastPreview {
        SnackbarToastStyle()
    }
}
