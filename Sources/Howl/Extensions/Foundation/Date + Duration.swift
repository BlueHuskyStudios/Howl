//
//  Date + Duration.swift
//  Howl
//
//  Created by Ky on 2026-04-21.
//

import Foundation



public extension Date {
    static func + (lhs: Date, rhs: Duration) -> Date {
        .init(timeInterval: rhs.timeInterval, since: lhs)
    }
}
