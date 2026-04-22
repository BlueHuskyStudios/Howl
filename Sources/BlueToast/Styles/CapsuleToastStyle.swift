//
//  CapsuleToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI

import RectangleTools



public struct CapsuleToastStyle: ToastStyle {
    
    public func body(_ configuration: Configuration, environment _: EnvironmentValues) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.clear)
            
            HStack(spacing: 4) {
                Group {
                    Text(configuration.text)
                        .padding(EdgeInsets(eachVertical: 8, eachHorizontal: 12))
                        .background {
                            if #available(macOS 26, iOS 26, *) {
                                Capsule()
                                    .glassEffect(.regular.tint(.black))
                            }
                            else {
                                Capsule()
                                    .fill(.ultraThinMaterial.blendMode(.multiply))
                            }
                        }
                        .id("text").tag("text")
                        .zIndex(1)
                    
                    if let action = configuration.callToAction {
                        ctaButton(action: action)
                            .id("CTA").tag("CTA")
                            .transition(.move(edge: .leading).combined(with: .opacity).animation(.bouncy))
                            .zIndex(0)
                    }
                }
                .shadow(radius: 6, y: 2)
                .font(.body)
                .geometryGroup()
                .animation(.bouncy, value: configuration)
            }
            .padding(.bottom, 24)
            .colorScheme(.dark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .geometryGroup()
//        .transition(.move(edge: .bottom).animation(.bouncy(duration: 0.3)))
    }
    
    
    @ViewBuilder
    private func ctaButton(action: ToastConfiguration.CallToAction) -> some View {
        if #available(macOS 26, iOS 26, *) {
            Button(action.label, action: action.userDidInteract)
                .buttonBorderShape(.capsule)
                .buttonStyle(.glassProminent)
        }
        else {
            Button(action.label, action: action.userDidInteract)
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
        }
    }
}



public extension ToastStyle where Self == CapsuleToastStyle {
    static var capsule: Self { Self.init() }
}



@available(macOS 15, iOS 18, macCatalyst 18, tvOS 18, visionOS 2, watchOS 11, *)
#Preview {
    ToastPreview(.capsule)
}
