//
//  CapsuleToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



public struct CapsuleToastStyle: ToastStyle {
    public func body(_ configuration: Configuration) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.clear)
            
            VStack {
                Group {
                    Text(configuration.text)
                    
                    if let action = configuration.callToAction {
                        Button(action.label, action: action.userDidInteract)
                            .buttonStyle(.link)
                    }
                }
                .font(.body)
                .padding()
                .background {
                    if #available(macOS 26.0, *) {
                        Capsule()
                            .glassEffect()
                            .shadow(radius: 6, y: 2)
                    }
                    else {
                        Capsule()
                            .fill(.ultraThinMaterial.blendMode(.multiply))
                            .shadow(radius: 6, y: 2)
                    }
                }
                .padding()
//                .geometryGroup()
            }
            
            .colorScheme(.dark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .transition(.move(edge: .bottom).animation(.bouncy(duration: 0.3)))
        .animation(.bouncy)
    }
}



public extension ToastStyle where Self == CapsuleToastStyle {
    static var capsule: Self { Self.init() }
}



#Preview {
    ToastPreview {
        CapsuleToastStyle()
    }
}
