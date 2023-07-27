//
//  SystemBezelTostStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import Combine
import SwiftUI



#if !canImport(AppKit)
@available(*, unavailable, renamed: "BezelToastStyle", message: """
    `SystemBezelToastStyle` is only available on macOS because of how it escapes the app window.
    
    If you want a similar effect within your app, try using `BezelToastStyle` instead.
    """)
public typealias SystemBezelToastStyle = BezelToastStyle
#else
public struct SystemBezelToastStyle: ToastStyle {
    
    private static var notificationLifecyclePublishers: Set<AnyCancellable> = []
    
    private let initialParameters: Parameters
    
    
    public init(parameters: Parameters = .init(messageText: "")) {
        self.initialParameters = parameters
    }
    
    
    
    public func body(_ configuration: Configuration) -> some View {
        Rectangle()
            .fill(.clear)
            .onAppear {
                SystemBezelNotification.show(with: parameters(with: configuration))
                    .sink { _ in }
                    .store(in: &SystemBezelToastStyle.notificationLifecyclePublishers)
            }
    }
    
    
    private func parameters(with configuration: Configuration) -> Parameters {
        var parameters = self.initialParameters
        
        parameters.messageText = String(configuration.text.characters)
        parameters.timeToLive = .init(configuration.actualDuration)
        
        if let icon = configuration.icon {
            parameters.icon = icon.nativeImage()
        }
        
        return parameters
    }
    
    
    
    public typealias Parameters = SystemBezelNotification.Parameters
}



private extension SystemBezelNotification.TimeToLive {
    init(_ duration: ToastStyle.Configuration.Duration) {
        self = switch duration {
        case .actionFeedback: .short
        case .importantText: .long
        case .criticalAlert: .forever
        }
    }
}



public extension ToastStyle where Self == SystemBezelToastStyle {
    
    static var systemBezel: Self { Self.init() }
    
    
    static func systemBezel(_ parameters: SystemBezelToastStyle.Parameters) -> Self { Self.init(parameters: parameters) }
    
    
    static func systemBezel(
        location: SystemBezelNotification.Location = SystemBezelNotification.Parameters.defaultLocation,
        size: SystemBezelNotification.Size = SystemBezelNotification.Parameters.defaultSize,
        
        fadeInAnimationDuration: TimeInterval = SystemBezelNotification.Parameters.defaultFadeInAnimationDuration,
        fadeOutAnimationDuration: TimeInterval = SystemBezelNotification.Parameters.defaultFadeOutAnimationDuration,
        
        cornerRadius: CGFloat = SystemBezelNotification.Parameters.defaultCornerRadius,
        tint: Color = Color(SystemBezelNotification.Parameters.defaultBackgroundTint),
        messageLabelFont: NSFont = SystemBezelNotification.Parameters.defaultMessageLabelFont,
        messageLabelColor: Color = Color(SystemBezelNotification.Parameters.defaultMessageLabelColor))
    -> Self
    {
        systemBezel(.init(
            messageText: "",
            location: location,
            size: size,
            fadeInAnimationDuration: fadeInAnimationDuration,
            fadeOutAnimationDuration: fadeOutAnimationDuration,
            cornerRadius: cornerRadius,
            backgroundTint: .init(tint),
            messageLabelFont: messageLabelFont,
            messageLabelColor: .init(messageLabelColor)))
    }
}



#Preview("System bezel") {
    ToastPreview {
        SystemBezelToastStyle()
    }
}
#endif
