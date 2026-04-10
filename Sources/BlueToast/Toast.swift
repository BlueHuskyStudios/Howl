//
//  Toast.swift
//
//
//  Created by The Northstar✨ System on 2024-02-16.
//

import Combine
import SwiftUI

import CrossKitTypes
import FunctionTools



// MARK: - ToastConfiguration

public struct ToastConfiguration {
    public let text: AttributedString
    public let duration: Duration?
    public let icon: Image?
    public let action: Action?
    
    
    init(text: AttributedString, duration: Duration?, icon: Image?, action: Action?) {
        self.text = text
        self.duration = duration
        self.icon = icon
        self.action = action
    }
    
    
    init<ToastText>(text: ToastText, duration: Duration?, icon: Image?, action: Action?)
    where ToastText: StringProtocol
    {
        self.init(text: AttributedString(text),
                  duration: duration,
                  icon: icon,
                  action: action)
    }
    
    
    
    public enum Duration {
        
        /// The toast is being shown for a brief moment to confirm that an action occurred, without remaining long enough allowing the user to read more than a couple words
        case actionFeedback
        
        /// The toast is explaining something to the user, who will be reading a notable amount of text on the toast
        case importantText
        
        /// The toast alerts the user of something so critical that they must be able to see the toast even if they weren't using the device at the time it was presented
        case criticalAlert
    }
    
    
    
    public struct Action {
        public let label: String
        public let userDidInteract: BlindCallback
        
        
        public init(label: String, userDidInteract: @escaping BlindCallback) {
            self.label = label
            self.userDidInteract = userDidInteract
        }
    }
}



extension ToastConfiguration.Duration: Hashable {}
extension ToastConfiguration.Duration: CaseIterable {}



public extension ToastStyle {
    typealias Configuration = ToastConfiguration
}



// MARK: - API

public extension View {
    func toast(
        isPresented: Binding<Bool>,
        text: AttributedString,
        duration: ToastConfiguration.Duration? = nil,
        icon: Image? = nil,
        action: ToastConfiguration.Action? = nil)
    -> some View
    {
        modifier(Toast(isPresented: isPresented, configuration: .init(text: text, duration: duration, icon: icon, action: action)))
    }
    
    
    func toast<ToastText>(
        isPresented: Binding<Bool>,
        text: ToastText,
        duration: ToastConfiguration.Duration? = nil,
        icon: Image? = nil,
        action: ToastConfiguration.Action? = nil)
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
    
    @Environment(\.toastStyle)
    private var toastStyle
    
    @State
    private var disappearDate: Date = .distantPast
    
    @State
    private var timerStorage: Set<AnyCancellable> = []
    
    @Binding
    var isPresented: Bool
    
    let configuration: ToastStyle.Configuration
    
    
    #if DEBUG
    @Environment(\.debugOverlay)
    private var debugOverlay
    
    @State
    private var _debug_appearCount = 0
    #endif
    
    
    func body(content parent: Content) -> some View {
        parent
            .overlay {
                ZStack {
                    #if DEBUG
                    if debugOverlay.shouldShow {
                        _debug_infoView
                    }
                    #endif
                    
                    if isPresented {
                        AnyView(toastStyle.body(configuration))
                        
                            .transition(.move(edge: .bottom).animation(.bouncy))
                            .onAppear {
                                #if DEBUG
                                _debug_appearCount += 1
                                #endif
                                
                                disappearDate = configuration.disappearDateIfAppearingNow()
                            }
                            .task {
                                Timer.publish(every: configuration.actualDuration.inSeconds / 12, on: .main, in: .modalPanel)
                                    .sink { now in
                                        if now >= disappearDate {
                                            wrapUpDippear()
                                        }
                                    }
                                    .store(in: &timerStorage)
                            }
                            .onDisappear {
                                wrapUpDippear()
                            }
                    }
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(true)
                }
            }
    }
    
    
    
    private func wrapUpDippear() {
        isPresented = false
        timerStorage = []
        disappearDate = .distantPast
    }
    
    
    #if DEBUG
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
    #endif
}



// MARK: - ToastPreview
