//
//  Date + InstantProtocol.swift
//  BlueToast
//
//  Created by Ky on 2026-04-22.
//

import Foundation



internal extension Date {
    
    /// Converts this date into an instant
    var instant: ContinuousClock.Instant {
        let nowInstant = ContinuousClock.now
        let interval = self.timeIntervalSinceNow
        return nowInstant.advanced(by: .seconds(interval))
    }
}
