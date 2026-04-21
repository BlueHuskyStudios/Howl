//
//  BezelToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI

import RectangleTools



private let cornerRadius: CGFloat = 12



public struct BezelToastStyle: ToastStyle {
    
    private let shape = RoundedRectangle(cornerRadius: cornerRadius)
    
    public func body(_ configuration: Configuration) -> some View {
        ZStack(alignment: .bottom) {
            Color.clear
            bezel(config: configuration, parameters: parameters(from: configuration))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}



private extension BezelToastStyle {
    
    func parameters(from configuration: Configuration) -> BezelNotificationParameters {
        BezelNotificationParameters(
            messageText: .init(configuration.text.characters),
            //icon: configuration.icon?.nativeImage(),
            timeToLive: configuration.duration.map(BezelNotificationParameters.TimeToLive.init) ?? .long,
        )
    }
    
    
    func bezel(config: Configuration, parameters: BezelNotificationParameters) -> some View {
        bezelBuilder(config: config, parameters: parameters) {
            let renderedMessage = Text(parameters.messageText)
                .font(.init(parameters.messageLabelFont))
                .multilineTextAlignment(.center)
                .contentTransition(.interpolate)
                .padding(.horizontal)
                .id("\(Self.self).message")
            
            
            if let icon = config.icon {
                VStack {
                    let bezelSize = parameters.size.cgSize
                    let imageSize = CGSize(square: 999)
                        .scaled(within: bezelSize * 0.6,
                                method: .fit,
                                direction: .upOrDown)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        icon
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: imageSize.width, maxHeight: imageSize.height)
                        Spacer()
                    }
                    .id("sdiufnds")
                    .tag("9ijtofkmd")
                    .transition(.blurReplace.animation(.bouncy))
                    
                    renderedMessage
                }
                .padding(.bottom)
            }
            else {
                renderedMessage
            }
        }
    }
    
    
    @ViewBuilder
    private func bezelBuilder<Content: View>(config: Configuration, parameters: BezelNotificationParameters, @ViewBuilder content: () -> Content) -> some View {
        let bezel = Rectangle()
            .fill(.thinMaterial)
            .frame(width: parameters.size.cgSize.width,
                   height: parameters.size.cgSize.height)
            .overlay {
                ZStack {
                    Color(parameters.backgroundTint)
                    content()
                        .animation(.bouncy, value: config)
                }
                .compositingGroup()
                .blendMode(.plusLighter)
            }
            .clipShape(RoundedRectangle(cornerRadius: BezelNotificationParameters.defaultCornerRadius))
        
        if #available(macOS 15, iOS 18, *) {
            bezel
                .materialActiveAppearance(.active)
        }
        else {
            bezel
        }
    }
}



public extension ToastStyle where Self == BezelToastStyle {
    static var bezel: Self { Self.init() }
}



// MARK: - Preview

@available(iOS 18, macCatalyst 18, macOS 15, tvOS 18, visionOS 2, watchOS 11, *)
#Preview("Bezel") {
    ToastPreview(.bezel)
}
