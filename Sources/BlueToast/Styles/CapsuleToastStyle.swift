//
//  CapsuleToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI

import RectangleTools



public struct CapsuleToastStyle: ToastStyle {
    
    public func body(_ configuration: Configuration) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.clear)
            
            HStack(spacing: 4) {
                Group {
                    Text(configuration.text)
                        .padding(8)
                    
                    if let action = configuration.callToAction {
                        if #available(macOS 26, iOS 26, *) {
                            Button(action.label, action: action.userDidInteract)
                                .buttonStyle(.glassProminent)
                                .buttonBorderShape(.capsule)
                        }
                        else {
                            Button(action.label, action: action.userDidInteract)
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.capsule)
                                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        }
                    }
                }
                .font(.body)
                .background {
                    if #available(macOS 26, iOS 26, *) {
                        Capsule()
                            .glassEffect(.regular.tint(.black))
                            .shadow(radius: 6, y: 2)
                    }
                    else {
                        Capsule()
                            .fill(.ultraThinMaterial.blendMode(.multiply))
                            .shadow(radius: 6, y: 2)
                    }
                }
                .geometryGroup()
            }
            .padding(.bottom, 24)
            
            .colorScheme(.dark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .transition(.move(edge: .bottom).animation(.bouncy(duration: 0.3)))
    }
}



public extension ToastStyle where Self == CapsuleToastStyle {
    static var capsule: Self { Self.init() }
}



@available(iOS 18, macCatalyst 18, macOS 15, tvOS 18, visionOS 2, watchOS 11, *)
#Preview {
    ToastPreview(.capsule)
}
