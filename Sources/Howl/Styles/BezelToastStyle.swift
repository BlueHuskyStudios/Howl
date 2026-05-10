//
//  BezelToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI

import RectangleTools



/// A toast style like the classic square notifications that Apple devices have shown over the years.
///
/// This was once the default style to display volume changes on OS X and iOS, and is still how Xcode displays build notifications.
/// This mimics that style, recreating it from scratch.
/// This displays the bezel inside a view. If you want it to display for the whole OS, on top of all windows, use ``SystemBezelToastStyle`` instead (only available on macOS).
public struct BezelToastStyle: ToastStyle {
    
    
    public let effect: Effect?
    
    
    /// Create a new bezel toast style
    /// - Parameter effect: _optional_ - What effect the bezel toast should be designed with. If omitted or set to `nil`, a good default will be selected for the current platform.
    public init(effect: Effect? = nil) {
        self.effect = effect
    }
    
    
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



// MARK: - Effect

public extension BezelToastStyle {
    enum Effect {
        
        /// The vibrant material ("frosted glass") design that was introduced in Mac OS X Yosemite and iOS 7
        case vibrantMaterial
        
        /// The liquid glass design that was introduced in 26
        @available(macOS 26, iOS 26, *)
        case liquidGlass
    }
}



public extension BezelToastStyle.Effect {
    var localizedDescription: LocalizedStringKey {
        switch self {
        case .vibrantMaterial:
            "Vibrant material"
            
        case .liquidGlass:
            "Liquid glass"
        }
    }
}



extension BezelToastStyle.Effect: CaseIterable {
    public static var allCases: [BezelToastStyle.Effect] {
        if #available(macOS 26, iOS 26, *) {
            [.vibrantMaterial, .liquidGlass]
        }
        else {
            [.vibrantMaterial]
        }
    }
}



extension BezelToastStyle.Effect: Hashable {}



extension BezelToastStyle.Effect: Identifiable {
    public var id: Self { self }
}



// MARK: - Bezel view building

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
                    let idealImageSize = CGSize(square: (bezelSize * 0.6).minMeasurement)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: idealImageSize.width, maxHeight: idealImageSize.height)
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
        #if os(macOS)
            .font(.system(.title, weight: .medium))
        #else
            .font(.system(.title3, weight: .medium))
        #endif
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
        bezelBasis(parameters: parameters)
            .frame(width: environment.dynamicTypeSize.isAccessibilitySize ? nil : parameters.size.cgSize.width,
                   height: parameters.size.cgSize.height)
//            .frame(maxWidth: environment.dynamicTypeSize.isAccessibilitySize ? 50 : parameters.size.cgSize.width)
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
            .clipShape(RoundedRectangle(cornerRadius: parameters.cornerRadius))
    }
    
    
    @ViewBuilder
    private func bezelBasis(parameters: BezelNotificationParameters) -> some View {
        switch effect {
        case .liquidGlass,
                .none:
            if #available(macOS 26, iOS 26, *) {
                Rectangle()
                    .glassEffect(in: RoundedRectangle(cornerRadius: parameters.cornerRadius))
            }
            else {
                Rectangle()
                    .fill(.thinMaterial)
            }
        case .vibrantMaterial:
            Rectangle()
                .fill(.thinMaterial)
        }
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
    
    /// A toast style like the classic square notifications that Apple devices have shown over the years.
    ///
    /// This was once the default style to display volume changes on OS X and iOS, and is still how Xcode displays build notifications.
    /// This mimics that style, recreating it from scratch.
    /// This displays the bezel inside a view. If you want it to display for the whole OS, on top of all windows, use ``.systemBezel`` instead (only available on macOS).
    static var bezel: Self { Self.init(effect: nil) }
    
    
    /// A toast style like the classic square notifications that Apple devices have shown over the years.
    /// 
    /// This was once the default style to display volume changes on OS X and iOS, and is still how Xcode displays build notifications.
    /// This mimics that style, recreating it from scratch.
    /// This displays the bezel inside a view. If you want it to display for the whole OS, on top of all windows, use ``.systemBezel`` instead (only available on macOS).
    ///
    /// - Parameter effect: You can use this field to specify which material effect is used for the bezel toast
    static func bezel(effect: Self.Effect?) -> Self { Self.init(effect: effect) }
}



// MARK: - Preview

@available(macOS 15, iOS 18, macCatalyst 18, tvOS 18, visionOS 2, watchOS 11, *)
#Preview("Bezel") {
    ToastPreview(.bezel)
}
