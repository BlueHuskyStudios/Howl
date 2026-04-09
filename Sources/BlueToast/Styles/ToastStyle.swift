//
//  ToastStyle.swift
//  
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



/// The visual appearance of a toast
public protocol ToastStyle {
    
    /// Generates the toast's visual style
    ///
    /// - Parameter configuration: All the information that the toast can contain
    func body(_ configuration: Configuration) -> Body
    
    
    
    associatedtype Body: View
}




public extension View {
    
    /// Set the visual style of toasts presented from this view
    ///
    /// - Parameter toastStyle: The style to apply to toasts in this view
    func toastStyle<Style: ToastStyle>(_ toastStyle: Style) -> some View {
        environment(\.toastStyle, toastStyle)
    }
}




internal extension ToastStyle.Configuration {
    func disappearDateIfAppearingNow() -> Date {
        disappearDate(appearingAt: .now)
    }
    
    
    func disappearDate(appearingAt appearDate: Date) -> Date {
        actualDuration.disappearDate(appearingAt: appearDate)
    }
    
    
    var actualDuration: Duration {
        duration ?? .default
    }
}



internal extension ToastStyle.Configuration.Duration {
    func disappearDate(appearingAt appearDate: Date) -> Date {
        switch self {
        case .actionFeedback,
                .importantText:
            appearDate + inSeconds
            
        case .criticalAlert:
                .distantFuture
        }
    }
    
    
    var inSeconds: TimeInterval {
        switch self {
        case .actionFeedback: 2
        case .importantText: 6
        case .criticalAlert: 60 * 60 * 24 * 365.242189 // 1 year
        }
    }
    
    
    
    static let `default` = actionFeedback
}



// MARK: - Environment

internal extension EnvironmentValues {
    var toastStyle: any ToastStyle {
        get { self[ToastStyle.EnvironmentKey.self] }
        set { self[ToastStyle.EnvironmentKey.self] = newValue }
    }
}



private extension ToastStyle {
    typealias EnvironmentKey = ToastStyleEnvironmentKey
}



private struct ToastStyleEnvironmentKey: EnvironmentKey {
    static var defaultValue: any ToastStyle {
        DefaultToastStyle()
    }
}
