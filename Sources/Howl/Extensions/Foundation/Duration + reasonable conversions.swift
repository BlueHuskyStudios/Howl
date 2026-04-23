//
//  Duration + reasonable conversions.swift
//  Howl
//
//  Created by Ky on 2026-04-21.
//

import Foundation



let attosecondsPerSecond: TimeInterval = 1_000_000_000_000_000_000



public extension Duration {
    /// Converts this duration into a ``TimeInterval`` (seconds)
    var timeInterval: TimeInterval {
        let (seconds, attoseconds) = self.components
        return TimeInterval(seconds)
            + (TimeInterval(attoseconds) / attosecondsPerSecond)
    }
}
