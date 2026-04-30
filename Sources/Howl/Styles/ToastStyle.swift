//
//  ToastStyle.swift
//  
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



/// The visual appearance of a toast.
///
/// - Note: If you're implementing it, you must be aware that this is _not_ run within the SwiftUI framework. It must build a SwiftUI view in its `body` (which _will_ be rendered within SwiftUI), and that body function will be passed the current environment values in case it needs them.
///         If you need to use things like `@State` or `@EnvironmentObject` fields, you can use a custom SwiftUI view somewhere inside the view built by the `body` function, and inside that custom view you may use `@State` and all other SwiftUI paradigms.
public protocol ToastStyle {
    
    /// Generates the toast's visual style
    /// 
    /// - Parameters:
    ///   - configuration: All the information that the toast can contain
    ///   - environment:   The values of the SwiftUI environment that this toast will be rendered in
    func body(_ configuration: Configuration, environment: EnvironmentValues) -> Body
    
    
    
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



public extension ToastStyle {
    
    /// Describes how a toast should appear on-screen.
    ///
    /// This is all about the semantics of any toast, regardless of its styling. For fine-grained control of toast styling, create a custom ``ToastStyle``
    typealias Configuration = ToastConfiguration
}



internal extension ToastStyle.Configuration {
    func disappearDateIfAppearingNow() -> Date {
        disappearDate(appearingAt: .now)
    }
    
    
    func disappearDate(appearingAt appearDate: Date) -> Date {
        max(
            actualDuration.disappearDate(appearingAt: appearDate),
            earliestDateForCallToAction(appearingAt: appearDate)
        )
    }
    
    
    var actualDuration: Duration {
        duration ?? .default
    }
    
    
    private func earliestDateForCallToAction(appearingAt appearDate: Date) -> Date {
        if let callToAction {
            let labelLength = callToAction.label.count
            let extraReadingTime: TimeInterval = .init(labelLength) * 0.1
            return .now + .seconds(min(30, 3 + extraReadingTime))
        }
        else {
            return appearDate
        }
    }
}



internal extension ToastStyle.Configuration.Duration {
    func disappearDate(appearingAt appearDate: Date) -> Date {
        switch self {
        case .actionFeedback,
                .importantText:
            appearDate + inSeconds
            
        case .manualDismiss:
                .distantFuture
        }
    }
    
    
    var inSeconds: TimeInterval {
        switch self {
        case .actionFeedback: 2.5
        case .importantText: 6
        case .manualDismiss: 60 * 60 * 24 * 365.242189 * 1000 // 1,000 years
        }
    }
    
    
    
    static let `default` = actionFeedback
}



// MARK: - Environment

internal extension EnvironmentValues {
    /// This is how this framework passes around the toast style as needed
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
