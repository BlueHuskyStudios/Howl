//
//  Toast.swift
//
//
//  Created by The Northstar✨ System on 2024-02-16.
//

import Combine
import SwiftUI

import CrossKitTypes



/// How long the presentation animation takes
private let presentationAnimationLength: TimeInterval = 0.5



// MARK: - API

public extension View {
    
    /// Presents a toast when the bound `isPresented` is `true`.
    /// 
    /// Toasts are brief messages that appear on-screen for a moment, to tell the user that something happened, and then go away.
    /// They're a very common paradigm in Android, and Apple system-level things sometimes use them as well, though folks have historically called these things like "bezel notifications", "popup UI", etc.. Things like the volume UI coming up when you change the volume, or Xcode's "Build Succeeded", or the Apple Pencil charging UI when you place it on the side of your iPad.
    ///
    /// Use ``toastStyle(_:)`` to change how the toast actually looks.
    ///
    /// - SeeAlso: ``toastStyle(_:)``
    ///
    /// - Parameters:
    ///   - isPresented:  When the bound value is `true`, the toast is displayed; when `false`, the toast goes away. The value will automatically be set to `false` when the toast goes away.
    ///   - configuration: The full configuration of a toast, aside from its style.
    func toast(isPresented: Binding<Bool>, configuration: ToastConfiguration) -> some View {
        modifier(Toast(isPresented: isPresented, configuration: configuration))
    }
    
    
    /// Presents a toast when the bound `isPresented` is `true`.
    ///
    /// Toasts are brief messages that appear on-screen for a moment, to tell the user that something happened, and then go away.
    /// They're a very common paradigm in Android, and Apple system-level things sometimes use them as well, though folks have historically called these things like "bezel notifications", "popup UI", etc.. Things like the volume UI coming up when you change the volume, or Xcode's "Build Succeeded", or the Apple Pencil charging UI when you place it on the side of your iPad.
    ///
    /// Use ``toastStyle(_:)`` to change how the toast actually looks.
    ///
    /// - SeeAlso: ``toastStyle(_:)``
    ///
    /// - Parameters:
    ///   - isPresented: When the bound value is `true`, the toast is displayed; when `false`, the toast goes away. The value will automatically be set to `false` when the toast goes away.
    ///   - text:     The text to display inside the toast
    ///   - duration: _optional_ - How long to display the toast on-screen.
    ///                         Note that the actual amount of seconds that the toast appears might vary.
    ///                         Defaults to a reasonable default.
    ///   - icon:     _optional_ -  What icon the toast should display, if it supports images. Defaults to the toast style's default icon (usually nothing)
    ///   - action:   _optional_ - A simple action the user can take when they see this toast (e.g. "Undo")
    func toast(
        isPresented: Binding<Bool>,
        text: AttributedString,
        duration: ToastConfiguration.Duration? = nil,
        icon: Image? = nil,
        action: ToastConfiguration.CallToAction? = nil)
    -> some View
    {
        toast(isPresented: isPresented, configuration: .init(text: text, duration: duration, icon: icon, callToAction: action))
    }
    
    
    /// Presents a toast when the bound `isPresented` is `true`.
    ///
    /// Toasts are brief messages that appear on-screen for a moment, to tell the user that something happened, and then go away.
    /// They're a very common paradigm in Android, and Apple system-level things sometimes use them as well, though folks have historically called these things like "bezel notifications", "popup UI", etc.. Things like the volume UI coming up when you change the volume, or Xcode's "Build Succeeded", or the Apple Pencil charging UI when you place it on the side of your iPad.
    ///
    /// Use ``toastStyle(_:)`` to change how the toast actually looks.
    ///
    /// - SeeAlso: ``toastStyle(_:)``
    ///
    /// - Parameters:
    ///   - isPresented: When the bound value is `true`, the toast is displayed; when `false`, the toast goes away. The value will automatically be set to `false` when the toast goes away.
    ///   - text:     The text to display inside the toast
    ///   - duration: _optional_ - How long to display the toast on-screen.
    ///                         Note that the actual amount of seconds that the toast appears might vary.
    ///                         Defaults to a reasonable default.
    ///   - icon:     _optional_ -  What icon the toast should display, if it supports images. Defaults to the toast style's default icon (usually nothing)
    ///   - action:   _optional_ - A simple action the user can take when they see this toast (e.g. "Undo")
    func toast<ToastText>(
        isPresented: Binding<Bool>,
        text: ToastText,
        duration: ToastConfiguration.Duration? = nil,
        icon: Image? = nil,
        action: ToastConfiguration.CallToAction? = nil)
    -> some View
    where ToastText: StringProtocol
    {
        toast(isPresented: isPresented,
              text: AttributedString(text),
              duration: duration,
              icon: icon,
              action: action)
    }
}



// MARK: - Implementation

private struct Toast: ViewModifier {
    
    
    @Environment(\.self)
    private var environment
    
    @Environment(\.toastStyle)
    private var toastStyle
    
    @State
    private var disableToast = true
    
    @State
    private var disappearDate: Date = .distantPast
    
    @State
    private var timerStorage: Task<Void, Never>?
    
    @Binding
    var isPresented: Bool
    
    let configuration: ToastConfiguration
    
    
    #if DEBUG
    @Environment(\.debugOverlay)
    private var debugOverlay
    
    @State
    private var _debug_appearCount = 0
    #endif
    
    
    func body(content parent: Content) -> some View {
        
        // Only need to allocate this once per `Toast` instance since `configuration` is a `let`
        let actualConfiguration = actualConfiguration
        
        parent
            .overlay {
                ZStack {
                    #if DEBUG
                    if debugOverlay.shouldShow {
                        _debug_infoView
                    }
                    #endif
                    
                    if isPresented {
                        AnyView(toastStyle.body(actualConfiguration, environment: environment))
                            .disabled(disableToast)
                            .task { // Give the user a moment to notice that the toast is shown before interactive elements become interactive
                                disableToast = true
                                try? await Task.sleep(for: .seconds(presentationAnimationLength + 0.2))
                                disableToast = false
                            }
                            .transition(.blurReplace(.upUp).animation(.bouncy(duration: presentationAnimationLength)))
                    }
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
                }
                .animation(.bouncy, value: isPresented)
            }
        
        
            .onChange(of: isPresented) { _, isPresented in
                if isPresented {
                    #if DEBUG
                    _debug_appearCount += 1
                    #endif
                    
                    disappearDate = configuration.disappearDateIfAppearingNow()
                    
                    timerStorage = Task {
                        try? await Task.sleep(until: disappearDate.instant)
                        wrapUpDisappear()
                    }
                }
                else {
                    wrapUpDisappear()
                }
            }
            .onDisappear {
                timerStorage?.cancel()
            }
    }
}



private extension Toast {
    
    func wrapUpDisappear() {
        withAnimation(.bouncy) {
            isPresented = false
            timerStorage?.cancel()
            timerStorage = nil
        }
    }
    
    
    /// Modifies the dev-specified configuration as-needed
    var actualConfiguration: ToastConfiguration {
        if let cta = configuration.callToAction,
           cta.dismissOnInteraction {
            // If we have a call-to-action, make the toast disappear when the CTA is called
            var tweakedCallToAction = ToastConfiguration.CallToAction(
                label: cta.label,
                dismissOnInteraction: cta.dismissOnInteraction,
                userDidInteract: {
                    isPresented = false
                    cta.userDidInteract()
                }
            )
            
            tweakedCallToAction.id = cta.id
            
            
            var tweakedConfig = ToastConfiguration(
                text: configuration.text,
                duration: configuration.duration,
                icon: configuration.icon,
                callToAction: tweakedCallToAction
            )
            
            tweakedConfig.id = configuration.id
            
            return tweakedConfig
        }
        else {
            return configuration
        }
    }
}



#if DEBUG
private extension Toast {
    @ViewBuilder
    var _debug_infoView: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                _debug_infoItem("isPresented", value: isPresented)
                _debug_infoItem("Appearance count", value: _debug_appearCount, format: .number)
                _debug_infoItem("Disappear date", value: disappearDate)
            }
            .font(.caption)
//            .background(Color(white: 0.6).blendMode(.darken))
            
            Rectangle().fill(.clear)
            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
        .foregroundStyle(.white)
    }
    
    
    private func _debug_infoItem<Value, Format>(_ title: String, value: Value, format: Format) -> some View
    where Value: Equatable,
          Format: FormatStyle,
          Format.FormatInput == Value,
          Format.FormatOutput == String
    {
        Text("\(title): \(Text("\(value, format: format)").bold().monospacedDigit())")
    }
    
    
    func _debug_infoItem<Value>(_ title: String, value: Value) -> some View {
        Text("\(title): \(Text(String(describing: value)).bold().monospacedDigit())")
    }
}
#endif
