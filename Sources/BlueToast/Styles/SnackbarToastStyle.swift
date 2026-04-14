//
//  SnackbarToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



public struct SnackbarToastStyle: ToastStyle {
    
    private let shape = RoundedRectangle(cornerRadius: 8)
    
    public func body(_ configuration: Configuration) -> some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(.clear)
            
            HStack {
                Text(configuration.text)
                
                if let action = configuration.callToAction {
                    Button(action.label, action: action.userDidInteract)
                        .buttonStyle(.link)
                }
            }
            .font(.body)
            .padding()
            .background {
                if #available(macOS 26, iOS 26, *) {
                    shape
                        .glassEffect(.regular.tint(.black), in: shape)
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
            .padding()
            .geometryGroup()
            
            .colorScheme(.dark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .transition(.move(edge: .bottom).animation(.bouncy(duration: 0.3)))
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
