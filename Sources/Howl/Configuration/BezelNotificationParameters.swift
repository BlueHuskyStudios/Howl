//
//  File.swift
//  Howl
//
//  Created by Ky on 2026-04-20.
//

import Foundation

import CrossKitTypes

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif



/// A set of parameters used to configure and present a bezel notification
public struct BezelNotificationParameters {
    
    public static let defaultLocation: Location = .normal
    public static let defaultSize: Size = .normal
    public static let defaultTimeToLive: TimeToLive = .short
    
    public static let defaultFadeInAnimationDuration: TimeInterval = 0
    public static let defaultFadeOutAnimationDuration: TimeInterval = 0.25
    
    public static let defaultCornerRadius: CGFloat = 18
    public static let defaultBackgroundTint = NativeColor.clear
    public static let defaultMessageLabelBaselineOffsetFromBottomOfBezel: CGFloat = 20
    public static let defaultMessageLabelFontSize: CGFloat = 18
    public static let defaultMessageLabelFont = NativeFont.systemFont(ofSize: defaultMessageLabelFontSize)
#if canImport(UIKit)
    public static let defaultMessageLabelColor = NativeColor.label
#elseif canImport(AppKit)
    public static let defaultMessageLabelColor = NativeColor.labelColor
#endif
    
    
    // MARK: Basics
    
    /// The text to show in the bezel notification's message area
    var messageText: String
    
    /// The icon to show in the bezel notification's icon area
    var icon: NativeImage?
    
    
    // MARK: Presentation
    
    /// The location on the screen at which to display the bezel notification
    var location: Location
    
    /// The size of the bezel notification
    var size: Size
    
    /// The number of seconds to display the bezel notification on the screen
    var timeToLive: TimeToLive
    
    
    // MARK: Animations
    
    /// The number of seconds that it takes to fade in the bezel notification
    var fadeInAnimationDuration: TimeInterval
    
    /// The number of seconds that it takes to fade out the bezel notification
    var fadeOutAnimationDuration: TimeInterval
    
    
    // MARK: Drawing
    
    /// The radius of the bezel notification's corners, in points
    var cornerRadius: CGFloat
    
    /// The tint of the bezel notification's background
    var rawBackgroundTint: NativeColor
    
    /// The distance from the bottom of the bezel notification at which the baseline of the message label sits
    var messageLabelBaselineOffsetFromBottomOfBezel: CGFloat
    
    /// The font used for the message label
    var messageLabelFont: NativeFont
    
    /// The text color of the message label
    var messageLabelColor: NativeColor
    
    
    public init(messageText: String,
                icon: NativeImage? = nil,
                
                location: Location = defaultLocation,
                size: Size = defaultSize,
                timeToLive: TimeToLive = defaultTimeToLive,
                
                fadeInAnimationDuration: TimeInterval = defaultFadeInAnimationDuration,
                fadeOutAnimationDuration: TimeInterval = defaultFadeOutAnimationDuration,
                
                cornerRadius: CGFloat = defaultCornerRadius,
                backgroundTint: NativeColor = defaultBackgroundTint,
                messageLabelBaselineOffsetFromBottomOfBezel: CGFloat = defaultMessageLabelBaselineOffsetFromBottomOfBezel,
                messageLabelFont: NativeFont = defaultMessageLabelFont,
                messageLabelColor: NativeColor = defaultMessageLabelColor
    ) {
        self.messageText = messageText
        self.icon = icon
        
        self.location = location
        self.size = size
        self.timeToLive = timeToLive
        
        self.fadeInAnimationDuration = fadeInAnimationDuration
        self.fadeOutAnimationDuration = fadeOutAnimationDuration
        
        self.cornerRadius = cornerRadius
        self.rawBackgroundTint = backgroundTint
        self.messageLabelBaselineOffsetFromBottomOfBezel = messageLabelBaselineOffsetFromBottomOfBezel
        self.messageLabelFont = messageLabelFont
        self.messageLabelColor = messageLabelColor
    }
}



// MARK: - TTL

public extension BezelNotificationParameters {
    
    /// How long a bezel notification should stay on screen
    enum TimeToLive {
        
        /// Bezel is shown for just a couple seconds
        case short
        
        /// Bezel if shown for several seconds
        case long
        
        /// Bezel is never hidden
        case forever
        
        /// Bezel is shown for an exact number of seconds
        case exactly(seconds: TimeInterval)
        
        
        var inSeconds : TimeInterval {
            switch self {
            case .short: return 2
            case .long: return 6
            case .forever: return .infinity
            case .exactly(let seconds): return seconds
            }
        }
    }
}



extension BezelNotificationParameters.TimeToLive: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .short:
            hasher.combine("\(Self.self).__PREDEFINED__.short")
            
        case .long:
            hasher.combine("\(Self.self).__PREDEFINED__.long")
            
        case .forever:
            hasher.combine("\(Self.self).__PREDEFINED__.forever")
            
        case .exactly(let seconds):
            hasher.combine("\(Self.self).exactly(seconds: \(seconds))")
        }
    }
}



// MARK: - Size

public extension BezelNotificationParameters {
    /// The semantic size of a bezel notification
    enum Size {
        case normal
    }
}



internal extension BezelNotificationParameters.Size {
    
    private var width: CGFloat {
        switch self {
        case .normal:
            return 200
        }
    }
    
    
    private var height: CGFloat {
        switch self {
        case .normal:
            return 200
        }
    }
    
    
    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
}



// MARK: - Location

public extension BezelNotificationParameters {
    /// The semantic location of a bezel notification
    enum Location {
        case normal
    }
}



internal extension BezelNotificationParameters.Location {
    func bezelWindowContentRect(in parent: CGRect, atSize size: BezelNotificationParameters.Size) -> CGRect {
        switch self {
        case .normal:
            return parent.lowerCenterRect(ofSize: size.cgSize)
        }
    }
}



internal extension CGRect {
    
    private static let lowerCenterRectBottomOffset: CGFloat = 140
    
    func lowerCenterRect(ofSize size: CGSize) -> CGRect {
        return CGRect(origin: CGPoint(x: self.midX - (size.width / 2),
                                      y: self.minY + Self.lowerCenterRectBottomOffset),
                      size: size)
    }
}



// MARK: - Background tint

public extension BezelNotificationParameters {
    var backgroundTint: NativeColor {
        get {
            var rawBackgroundTintAlpha: CGFloat = 0
            #if canImport(AppKit)
                rawBackgroundTintAlpha = rawBackgroundTint.alphaComponent
            #else
                rawBackgroundTint.getRed(nil, green: nil, blue: nil, alpha: &rawBackgroundTintAlpha)
            #endif
            
            return rawBackgroundTint.withAlphaComponent(rawBackgroundTintAlpha * 0.15)
        }
        
        @available(*, deprecated, renamed: "rawBackgroundTint", message: "`backgroundTint` is the processed color to use as the bezel notification's background tint. Use `rawBackgroundTint` to set the raw color value, and get its processed version from `backgroundTint`.")
        set {
            rawBackgroundTint = newValue
        }
    }
}
