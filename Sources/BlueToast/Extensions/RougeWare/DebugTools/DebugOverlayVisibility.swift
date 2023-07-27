//
//  DebugOverlayVisibility.swift
//
//
//  Created by Ky on 2024-02-19.
//

import SwiftUI



/// The visibility of debug overlays.
///
/// Not all debug overlays support all visibility levels, but `hidden` will always hide them.
///
/// This can also be represnted by a `Bool` literal, where `true == .showAll` and `.false == .hidden`
public enum DebugOverlayVisibility {
    
    /// Hide the debug overlay(s) entirely.
    ///
    /// The user won't be able to perceive nor interact with them.
    ///
    /// - Note: When using `Bool` literals to represent this enum, this case is represented as `false`
    case hidden
    
    /// Show minimal information, for quick debugging.
    ///
    /// It's up to the debug overlay to decide what this means, but it should display _something_.
    ///
    /// - Note: This is an optional visibility level, so not all debug overlays will support this.
    ///         If a debug overlay does not support this, but is still told to present this visibility, it's encouraged to present as `showAll` instead.
    case simplified
    
    /// Show all debug info in the overlay(s).
    ///
    /// It's up to the debug overlay what is presented and whether it is interactable, but it should present everything it can.
    ///
    /// - Note: When using `Bool` literals to represent this enum, this case is represented as `true`
    case showAll
}



extension DebugOverlayVisibility: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = value
            ? .showAll
            : .hidden
    }
}



public extension DebugOverlayVisibility {
    /// Simplifies this enum into a `Bool` indicating just whether to show the overlay.
    ///
    /// This follows the same rules as Bool literal representations
    var shouldShow: Bool {
        switch self {
        case .hidden:
            false
            
        case .simplified,
                .showAll:
            true
        }
    }
}



public extension EnvironmentValues {
    /// The visibility of debug overlays in this environment.
    ///
    /// Accepts an explicit `DebugOverlayVisibility` case, or a `Bool` where `true` is `.showAll` and `false` is `.hidden`.
    var debugOverlay: DebugOverlayVisibility {
        get { self[DebugOverlayVisibility.EnvironmentKey.self] }
        set { self[DebugOverlayVisibility.EnvironmentKey.self] = newValue }
    }
}



public extension DebugOverlayVisibility {
    struct EnvironmentKey: SwiftUI.EnvironmentKey {
        @inline(__always)
        public static var defaultValue: DebugOverlayVisibility { .hidden }
    }
}
