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



// MARK: - Disappear date calculations

/// The average number of letters in an English word
///
/// https://arxiv.org/abs/1208.6109
private let english_averageLettersPerWord: CGFloat = 5

/// The average number of English words that a human can speak in a minute
///
/// https://tfcs.baruch.cuny.edu/speaking-rate/
private let english_slowestAverageSpeechWpm: CGFloat = 100

private let english_slowestAverageSpeechLettersPerMinute = english_averageLettersPerWord * english_slowestAverageSpeechWpm
private let english_slowestAverageSpeechLettersPerSecond = english_slowestAverageSpeechLettersPerMinute / 60
private let english_slowestAverageSpeechSecondsPerLetter = 1 / english_slowestAverageSpeechLettersPerSecond
private let english_slowestAverageSpeechSecondsPerLetter_halved = english_slowestAverageSpeechSecondsPerLetter / 2

private let additionalSecondsToNoticeToast: CGFloat = 1
private let additionalSecondsToNoticeCallToAction: CGFloat = 2

private let maxAdditionalSecondsPerFactor: CGFloat = 30



internal extension ToastStyle.Configuration {
    
    /// The `duration` value to use, regardless of what the dev specified in `.toast(...`.
    var actualDuration: Duration {
        duration ?? .default
    }
    
    
    /// The date at which a toast with this configuration should disappear, assuming it's appearing the moment this function is called
    func disappearDateIfAppearingNow() -> Date {
        disappearDate(appearingAt: .now)
    }
    
    
    /// The date at which a toast with this configuration should disappear, assuming it's appearing at the given date
    func disappearDate(appearingAt appearDate: Date) -> Date {
        max(
            actualDuration.disappearDate(appearingAt: appearDate),
            
            appearDate
                + additionalTimeAccountingForBodyText()
                + additionalTimeAccountingForCallToAction()
        )
    }
    
    
    /// How much additional time the toast should be shown, based on how long its main body text is
    private func additionalTimeAccountingForBodyText() -> Swift.Duration {
        let bodyLength = max(0, self.text.characters.count)
        let bodyReadingTime: TimeInterval = .init(bodyLength) * english_slowestAverageSpeechSecondsPerLetter_halved
        return .seconds(min(
            maxAdditionalSecondsPerFactor,
            additionalSecondsToNoticeToast
                + bodyReadingTime
        ))
    }
    
    
    /// How much additional time the toast should be shown, based on its CTA value
    private func additionalTimeAccountingForCallToAction() -> Swift.Duration {
        if let callToAction {
            let labelLength = callToAction.label.count
            let labelReadingTime: TimeInterval = .init(labelLength) * english_slowestAverageSpeechSecondsPerLetter
            return .seconds(min(
                maxAdditionalSecondsPerFactor,
                additionalSecondsToNoticeToast
                    + additionalSecondsToNoticeCallToAction
                    + labelReadingTime
            ))
        }
        else {
            return .zero
        }
    }
}



internal extension ToastStyle.Configuration.Duration {
    
    /// The ideal date at which a toast of this duration should disappear, assuming it appeares at the given date
    ///
    /// - Parameter appearDate: The date the toast will have appeared
    func disappearDate(appearingAt appearDate: Date) -> Date {
        switch self {
        case .actionFeedback,
                .importantText:
            appearDate + inSeconds
            
        case .manualDismiss:
                .distantFuture
        }
    }
    
    
    /// The number of seconds that the toast should appear on-screen
    var inSeconds: TimeInterval {
        switch self {
        case .actionFeedback: 2.5
        case .importantText: 6
        case .manualDismiss: 60 * 60 * 24 * 365.242189 * 1000 // 1,000 years
        }
    }
    
    
    
    /// This duration is safe to use if no other duration is specified
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
