//
//  BezelNotificationParameters + Toast.swift
//  Howl
//
//  Created by Ky on 2026-04-20.
//

import Foundation



public extension BezelNotificationParameters.TimeToLive {
    
    /// Convert a toast duration to a bezel TTL.
    ///
    /// - Attention: Bezel TTLs describe an amount of time.
    /// Toast durations describe the semantics of how long a toast should be visible.
    /// Because of that difference, this initializer will attempt to find the best analog, but it isn't designed to losslessly convert between the two types. Users may experience different timings for the different types, and the exact conversions and values may change between versions of this package.
    ///
    /// - Parameter toastDuration: A toast duration to convert to a bezel TTL
    init(_ toastDuration: ToastConfiguration.Duration) {
        switch toastDuration {
        case .actionFeedback:
            self = .short
        case .importantText:
            self = .long
        case .manualDismiss:
            self = .forever
        }
    }
}



public extension ToastConfiguration.Duration {
    
    /// Convert a bezel TTL to a toast duration.
    ///
    /// - Attention: Bezel TTLs describe an amount of time.
    /// Toast durations describe the semantics of how long a toast should be visible.
    /// Because of that difference, this initializer will attempt to find the best analog, but it isn't designed to losslessly convert between the two types. Users may experience different timings for the different types, and the exact conversions & values may change between versions of this package.
    ///
    /// - Note: If you pass a `.exactly(seconds:)` then this will use a search algorithm to find the best analog, but the results of that search aren't guaranteed.
    ///
    /// - Parameter timeToLive: A bezel TTL to convert to a toast duration
    init(_ timeToLive: BezelNotificationParameters.TimeToLive) { // TODO: Test
        switch timeToLive {
        case .short:
            self = .actionFeedback
        case .long:
            self = .importantText
        case .forever:
            self = .manualDismiss
            
        case .exactly(seconds: let ttlSeconds):
            let closestDuration = Self
                .allCases
                .map { (duration: $0, seconds: $0.inSeconds) }
                .min {
                    abs($0.seconds - ttlSeconds) < abs($1.seconds - ttlSeconds)
                }
            
            self = closestDuration?.duration ?? .importantText
        }
    }
}
