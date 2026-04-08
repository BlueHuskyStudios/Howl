//
//  SystemBezelNotification.swift
//  Bezel Notification
//
//  Created by Ky Leggiero on 2017-11-09.
//  Version 2 created by Ky Leggiero on 2022-02-12.
//  Copyright © 2022 Ky Leggiero BH-1-PS
//

#if !canImport(AppKit)
@available(*, unavailable, message: """
    `SystemBezelNotification` is only available on macOS because of how it escapes the app window.
    
    If you want a similar effect within your SwiftUI app, try using a toast with `.toastStyle(.bezel)` instead.
    """)
public typealias SystemBezelToastStyle = BezelToastStyle

#else

import AppKit
import Combine
import Foundation

import CrossKitTypes
import FunctionTools
import RectangleTools



/// The style mask used on all bezel windows
private let bezelStyleMask: NSWindow.StyleMask = [.borderless]

/// All currently-showing bezel windows
private var bezelWindows = Set<SystemBezelNotification.Window>()



@available(*, deprecated, renamed: "SystemBezelNotification", message: """
    This was renamed to `SystemBezelNotification` in version 3 of this package.
    
    You may continue using it as you had been in previous versions, but consider using the new name instead.
    
    Direct usage of this API is no longer encouraged, but still actively supported.
    You're encouraged to use the new SwiftUI interface, detailed in the current readme.
    Documentation of previous behavior can be found in-code as documentation for `SystemBezelNotification`, and also in the old Git repo:
    https://github.com/BlueHuskyStudios/BezelNotification/blob/50c75204c5ca60c25bc5b6ac747cd9cf06e88046/README.md
    
    Use the new name to silence this warning.
    """)
public typealias BHBezelNotification = SystemBezelNotification



@available(*, deprecated, renamed: "SystemBezelNotification", message: """
    This was renamed to `SystemBezelNotification` in version 3 of this package.
    
    You may continue using it as you had been in previous versions, but consider using the new name instead.
    
    Direct usage of this API is no longer encouraged, but still actively supported.
    You're encouraged to use the new SwiftUI interface, detailed in the current readme.
    Documentation of previous behavior can be found in-code as documentation for `SystemBezelNotification`, and also in the old Git repo:
    https://github.com/BlueHuskyStudios/BezelNotification/blob/50c75204c5ca60c25bc5b6ac747cd9cf06e88046/README.md
    
    Use the new name to silence this warning.
    """)
public typealias BezelNotification = SystemBezelNotification



/// The public interface for showing a notification bezel
public enum SystemBezelNotification {
    // Empty on-purpose; all members are static
}



public extension SystemBezelNotification {
    
    /// Shows a BHBezel notification using the given parameters.
    /// See ``SystemBezelNotification.Parameters`` for documentation of each parameter.
    ///
    /// If you want to manually dismiss the notification, rather than trusting the time to live, you can give `.forever` for `timeToLive` and cancel or deallocate the resulting publisher when you're ready to dismiss it.
    ///
    /// - Returns: A publisher that allows you to react to the bezel appearing & disappearing.
    ///            **You must retain this in order for the notification to show!**
    ///            To hide the notification manually, simply cancel or deallocate it.
    ///
    /// - SeeAlso: ``SystemBezelNotification.Parameters``
    @discardableResult
    static func show(messageText: String,
                     icon: NativeImage? = nil,
                     
                     location: Location = Parameters.defaultLocation,
                     size: Size = Parameters.defaultSize,
                     
                     timeToLive: TimeToLive = Parameters.defaultTimeToLive,
                     fadeInAnimationDuration: TimeInterval = Parameters.defaultFadeInAnimationDuration,
                     fadeOutAnimationDuration: TimeInterval = Parameters.defaultFadeOutAnimationDuration,
                     
                     cornerRadius: CGFloat = Parameters.defaultCornerRadius,
                     tint: NSColor = Parameters.defaultBackgroundTint,
                     messageLabelFont: NSFont = Parameters.defaultMessageLabelFont,
                     messageLabelColor: NSColor = Parameters.defaultMessageLabelColor
    ) -> LifecyclePublisher
    {
        show(with: Parameters(
            messageText: messageText,
            icon: icon,
            
            location: location,
            size: size,
            
            timeToLive: timeToLive,
            fadeInAnimationDuration: fadeInAnimationDuration,
            fadeOutAnimationDuration: fadeOutAnimationDuration,
            
            //messageLabelBaselineOffsetFromBottomOfBezel: default,
            cornerRadius: cornerRadius,
            backgroundTint: tint,
            messageLabelFont: messageLabelFont,
            messageLabelColor: messageLabelColor
        ))
    }
    
    
    /// Shows a Bezel Notification using the given parameters.
    /// See ``SystemBezelNotification.Parameters`` for documentation of each parameter.
    ///
    /// If you want to manually dismiss the notification, rather than trusting the time to live, you can give `.forever` for `timeToLive` and cancel or deallocate the resulting publisher when you're ready to dismiss it.
    ///
    /// - Returns: A publisher that allows you to react to the bezel appearing & disappearing.
    ///            **You must retain this in order for the notification to show!**
    ///            To hide the notification manually, simply cancel or deallocate it.
    ///
    /// - SeeAlso: ``SystemBezelNotification.Parameters``
    static func show(with parameters: Parameters)
    -> LifecyclePublisher
    {
        let publisher = CurrentValueSubject<LifecycleStage, Never>(.willAppear)
        var _disappearNow: BlindCallback = null
        
        func disappearNow() { _disappearNow() } // this allows us to hot-swap the implementation even after sending it elsewhere
        
        
        DispatchQueue.main.async {
            
            let bezelWindow = Window(parameters: parameters)
            bezelWindows.insert(bezelWindow)
            
            _disappearNow = {
                _disappearNow = null
                publisher.send(.disappearing)
                bezelWindow.fadeOut(duration: bezelWindow.parameters.fadeOutAnimationDuration,
                                    closeSelector: .close)
                {
                    bezelWindows.remove(bezelWindow)
                    publisher.send(.didDisappear)
                    publisher.send(completion: .finished)
                }
            }
            
            
            publisher.send(.appearing)
            bezelWindow.fadeIn(duration: parameters.fadeInAnimationDuration,
                               presentationFunction: .orderFrontRegardless)
            {
                publisher.send(.presented(disappearEarly: disappearNow))
            }
            
            Timer.scheduledTimer(withTimeInterval: parameters.timeToLive.inSeconds, repeats: false) { _ in
                disappearNow()
            }
        }
        
        return publisher
            .handleEvents(receiveCancel: disappearNow)
            .eraseToAnyPublisher()
    }
}



public extension SystemBezelNotification {
    typealias LifecyclePublisher = AnyPublisher<LifecycleStage, Never>
}



public extension SystemBezelNotification {
    
    /// A stage in the lifecycle of a bezel notification
    enum LifecycleStage {
        
        /// The bezel notification is not showing and will appear soon
        case willAppear
        
        /// The bezel notification's appearance animation is in-progress
        case appearing
        
        /// The bezel notification has finished its appearance animation and is statically on-screen
        /// - Parameter disappearEarly: _optional_ - Call this to cause the bezel notification to disappear now rather than awaiting timeout
        case presented(disappearEarly: BlindCallback = null)
        
        /// The bezel notification's disappearance animation is in-progress
        case disappearing
        
        /// The bezel notification has finished its disappearance animation and is no longer on-screen.
        /// This typically indicates that this instance of a bezel notification will not appear again.
        case didDisappear
    }
}



/// A set of parameters used to configure and present a bezel notification
public extension SystemBezelNotification {
    struct Parameters {
        
        public static let defaultLocation: Location = .normal
        public static let defaultSize: Size = .normal
        public static let defaultTimeToLive: TimeToLive = .short
        
        public static let defaultFadeInAnimationDuration: TimeInterval = 0
        public static let defaultFadeOutAnimationDuration: TimeInterval = 0.25
        
        public static let defaultCornerRadius: CGFloat = 18
        public static let defaultBackgroundTint = NSColor.clear
        public static let defaultMessageLabelBaselineOffsetFromBottomOfBezel: CGFloat = 20
        public static let defaultMessageLabelFontSize: CGFloat = 18
        public static let defaultMessageLabelFont = NSFont.systemFont(ofSize: defaultMessageLabelFontSize)
        public static let defaultMessageLabelColor = NSColor.labelColor
        
        
        // MARK: Basics
        
        /// The text to show in the bezel notification's message area
        var messageText: String
        
        /// The icon to show in the bezel notification's icon area
        var icon: NSImage?
        
        
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
        var backgroundTint: NSColor
        
        /// The distance from the bottom of the bezel notification's bottom at which the baseline of the message label sits
        var messageLabelBaselineOffsetFromBottomOfBezel: CGFloat
        
        /// The font used for the message label
        var messageLabelFont: NSFont
        
        /// The text color of the message label
        var messageLabelColor: NSColor
        
        
        public init(messageText: String,
                    icon: NSImage? = nil,
                    
                    location: Location = defaultLocation,
                    size: Size = defaultSize,
                    timeToLive: TimeToLive = defaultTimeToLive,
                    
                    fadeInAnimationDuration: TimeInterval = defaultFadeInAnimationDuration,
                    fadeOutAnimationDuration: TimeInterval = defaultFadeOutAnimationDuration,
                    
                    cornerRadius: CGFloat = defaultCornerRadius,
                    backgroundTint: NSColor = defaultBackgroundTint,
                    messageLabelBaselineOffsetFromBottomOfBezel: CGFloat = defaultMessageLabelBaselineOffsetFromBottomOfBezel,
                    messageLabelFont: NSFont = defaultMessageLabelFont,
                    messageLabelColor: NSColor = defaultMessageLabelColor
        ) {
            self.messageText = messageText
            self.icon = icon
            
            self.location = location
            self.size = size
            self.timeToLive = timeToLive
            
            self.fadeInAnimationDuration = fadeInAnimationDuration
            self.fadeOutAnimationDuration = fadeOutAnimationDuration
            
            self.cornerRadius = cornerRadius
            self.backgroundTint = backgroundTint.withAlphaComponent(backgroundTint.alphaComponent * 0.15)
            self.messageLabelBaselineOffsetFromBottomOfBezel = messageLabelBaselineOffsetFromBottomOfBezel
            self.messageLabelFont = messageLabelFont
            self.messageLabelColor = messageLabelColor
        }
    }
    
    
    
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
    
    
    
    /// The window used to present a bezel notification.
    /// If you _really_ need minute control, you may use this.
    class Window : NSWindow {
        
        private lazy var bezelContentView: ContentView = {
            let bezelContentView = ContentView(parameters: self.parameters)
            bezelContentView.wantsLayer = true
            bezelContentView.layer?.backgroundColor = parameters.backgroundTint.cgColor
            return bezelContentView
        }()
        
        var messageText: String { return parameters.messageText }
        
        fileprivate let parameters: Parameters
        
        
        /// Creates a new bezel window with the given parameters
        ///
        /// - Parameter parameters: Those parameters that dictate how this window appears
        public init(parameters: Parameters) {
            
            self.parameters = parameters
            
            let contentRect = parameters.location.bezelWindowContentRect(atSize: parameters.size)
            
            super.init(contentRect: contentRect,
                       styleMask: bezelStyleMask,
                       backing: .buffered,
                       defer: false)
            
            contentView = makeVisualEffectsBackingView()
            
            self.minSize = contentRect.size
            self.maxSize = contentRect.size
            
            self.isReleasedWhenClosed = false
            self.level = .screenSaver
            self.ignoresMouseEvents = true
            self.appearance = NSAppearance(named: .vibrantCurrent)
            self.isOpaque = false
            self.backgroundColor = .clear
            self.tabbingMode = .disallowed
            self.collectionBehavior = [.canJoinAllSpaces, .fullScreenNone, .ignoresCycle, .stationary]
            
            addComponents()
        }
        
        
        private func addComponents() {
            guard let contentView = self.contentView else {
                assertionFailure("No content view when adding components to bezel!!")
                return
            }
            
            contentView.wantsLayer = true
            
            contentView.addSubview(bezelContentView)
            NSLayoutConstraint.activate([
                bezelContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
                bezelContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                bezelContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                bezelContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ])
        }
        
        
        private func makeVisualEffectsBackingView() -> NSVisualEffectView {
            let visualEffectView = NSVisualEffectView()
            visualEffectView.wantsLayer = true
            visualEffectView.blendingMode = .behindWindow
            visualEffectView.material = .hudWindow
            visualEffectView.state = .active
            visualEffectView.maskImage = .roundedRectMask(size: self.parameters.size.cgSize,
                                                          cornerRadius: self.parameters.cornerRadius)
            return visualEffectView
        }
    }
    
    
    
    /// The view powering the `BezelWindow`'s appearance.
    /// If you _really, really_ need _extreme_ control, you may use this. Don't, though, if you can avoid it.
    class ContentView: NSView {
        
        let parameters: Parameters
        
        override public var allowsVibrancy: Bool { return true }
        
        public init(parameters: Parameters) {
            self.parameters = parameters
            super.init(frame: NSRect(origin: .zero, size: parameters.size.cgSize))
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) not implemented")
        }
        
        override public func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            
            guard let context = NSGraphicsContext.current?.cgContext else {
                return
            }
            
            let textBounds = parameters.messageText.findBezelLabelBoundingBox(within: bounds,
                                                                              offsetFromBottom: parameters.messageLabelBaselineOffsetFromBottomOfBezel,
                                                                              font: parameters.messageLabelFont)
            
            if let icon = parameters.icon {
                let bezelSize = parameters.size.cgSize
                let bezelBounds = NSRect(origin: .zero, size: bezelSize)
                let bezelCenterX = bezelBounds.midX
                let messageLabelTop = textBounds.maxY;
                let halfwayBetweenLabelTopAndBezelTop = (bezelBounds.maxY + messageLabelTop) / 2
                
                let iconSize = icon.size.scaled(within: bezelSize * 0.6, method: .fit, direction: .down)
                
                
                let iconBottomLeftCorner = NSPoint(x: bezelCenterX - (iconSize.width / 2),
                                                   y: halfwayBetweenLabelTopAndBezelTop - (iconSize.height / 2))
                
                icon.draw(
                    in: NSRect(origin: iconBottomLeftCorner, size: iconSize),
                    from: .zero, // This is a "magic value" meaning "draw the whole image"
                    operation: .sourceOver,
                    fraction: 1, // "fraction" = "opacity"
                    respectFlipped: true,
                    hints: [.interpolation : NSNumber(value: NSImageInterpolation.high.rawValue)]
                )
            }
            
            context.setTextDrawingMode(.fill)
            context.draw(text: parameters.messageText,
                         at: textBounds.origin,
                         color: parameters.messageLabelColor.withAlphaComponent(parameters.messageLabelColor.alphaComponent * 0.8),
                         font: parameters.messageLabelFont)
        }
    }
}


private extension String {
    func findBezelLabelBoundingBox(within parentBounds: NSRect,
                                   offsetFromBottom: CGFloat,
                                   font: NSFont) -> NSRect {
        let attributedString = NSAttributedString(string: self, attributes: [.font : font])
        let textBounds = attributedString.boundingRect(with: parentBounds.size, options: [])
        let textBaselineY = offsetFromBottom
        let textLeftX = parentBounds.midX - textBounds.midX
        return NSRect(origin: NSPoint(x: textLeftX, y: textBaselineY), size: textBounds.size)
    }
    
    
    func findBezelLabelTextStartPoint(within parentBounds: NSRect,
                                      offsetFromBottom: CGFloat,
                                      font: NSFont) -> NSPoint {
        return findBezelLabelBoundingBox(within: parentBounds, offsetFromBottom: offsetFromBottom, font: font).origin
    }
}



public extension SystemBezelNotification {
    /// The semantic size of a bezel notification
    enum Size {
        case normal
    }
}



internal extension SystemBezelNotification.Size {
    
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



public extension SystemBezelNotification {
    /// The semantic location of a bezel notification
    enum Location {
        case normal
    }
}



internal extension SystemBezelNotification.Location {
    func bezelWindowContentRect(atSize size: SystemBezelNotification.Size) -> NSRect {
        switch self {
        case .normal:
            return screen?.lowerCenterRect(ofSize: size.cgSize) ?? NSRect(origin: NSPoint(x: 48, y: 48), size: size.cgSize)
        }
    }
    
    
    var screen: NSScreen? {
        switch self {
        case .normal:
            return .main ?? NSScreen.screens.first
        }
    }
}



private extension NSScreen {
    
    private static let lowerCenterRectBottomOffset: CGFloat = 140
    
    func lowerCenterRect(ofSize size: NSSize) -> NSRect {
        return NSRect(origin: NSPoint(x: self.frame.midX - (size.width / 2),
                                      y: self.frame.minY + NSScreen.lowerCenterRectBottomOffset),
                      size: size)
    }
}

#endif
