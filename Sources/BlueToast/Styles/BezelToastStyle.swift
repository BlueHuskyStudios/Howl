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
    
    
    public func body(_ configuration: Configuration, environment: EnvironmentValues) -> some View {
        ZStack(alignment: .bottom) {
            Color.clear
            positionedBezel(
                config: configuration,
                parameters: parameters(from: configuration),
                environment: environment)
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
    
    
    func positionedBezel(
        config: Configuration,
        parameters: BezelNotificationParameters,
        environment: EnvironmentValues)
    -> some View {
        bezel(config: config, parameters: parameters, environment: environment) {
            VStack {
                if let icon = config.icon {
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
                    .transition(.blurReplace)
                    
                }
                
                renderedMessage(config: config, parameters: parameters)
                    .padding(.bottom, nil == config.icon ? 0 : nil)
            }
        }
    }
    
    
    @ViewBuilder
    private func renderedMessage(config: Configuration, parameters: BezelNotificationParameters) -> some View {
        Text(config.text)
//            .font(.init(parameters.messageLabelFont)) <- was not friendly with accessibility sizes
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
            .lineLimit(nil == config.icon ? nil : 1)
            .frame(maxHeight: nil == config.icon ? .infinity : nil)
            .contentTransition(.interpolate)
            .padding(.horizontal)
            .id("Message")
    }
    
    
    @ViewBuilder
    private func bezel<Content: View>(
        config: Configuration,
        parameters: BezelNotificationParameters,
        environment: EnvironmentValues,
        @ViewBuilder content: () -> Content)
    -> some View {
        
        if #available(macOS 15, iOS 18, *) {
            _bezel(config: config, parameters: parameters, environment: environment, content: content)
                .materialActiveAppearance(.active)
        }
        else {
            _bezel(config: config, parameters: parameters, environment: environment, content: content)
        }
    }
    
    
    private func _bezel<Content: View>(
        config: Configuration,
        parameters: BezelNotificationParameters,
        environment: EnvironmentValues,
        content: () -> Content)
    -> some View {
        Rectangle()
            .fill(.thinMaterial)
            .frame(width: parameters.size.cgSize.width,
                   height: parameters.size.cgSize.height)
            .overlay {
                ZStack {
                    Color(parameters.backgroundTint)
                    content()
                        .foregroundStyle(.secondary)
                        .animation(.bouncy, value: config)
                }
                .compositingGroup()
                .blendMode(bestForegroundBlendMode(in: environment.colorScheme))
            }
            .clipShape(RoundedRectangle(cornerRadius: BezelNotificationParameters.defaultCornerRadius))
    }
    
    
    private func bestForegroundBlendMode(in colorScheme: ColorScheme) -> BlendMode {
        switch colorScheme {
        case .dark: .plusLighter
        case .light: .plusDarker
        @unknown default: .normal
        }
    }
}



public extension ToastStyle where Self == BezelToastStyle {
    static var bezel: Self { Self.init() }
}



// MARK: - Preview

@available(macOS 15, iOS 18, macCatalyst 18, tvOS 18, visionOS 2, watchOS 11, *)
#Preview("Bezel") {
    ToastPreview(.bezel)
}
