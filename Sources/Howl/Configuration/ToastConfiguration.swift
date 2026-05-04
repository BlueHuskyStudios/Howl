//
//  ToastConfiguration.swift
//  Howl
//
//  Created by Ky on 2026-04-21.
//

import SwiftUI

import CrossKitTypes
import FunctionTools



/// Describes how a toast should appear on-screen.
///
/// This is all about the semantics of any toast, regardless of its styling. For fine-grained control of toast styling, create a custom ``ToastStyle``
public struct ToastConfiguration {
    
    /// This allows us to track changes across otherwise-identical toast configurations.
    ///
    /// This does run the risk that, if SwiftUI decides to initialize the same toast configuration many times, we get many UUIDs. This field hedges its bets that this will be okay.
    internal var id = UUID() // internal so we can keep it consistent if we have to tweak the config before building a toast
    
    /// The text to display inside the toast
    public let text: AttributedString
    
    /// How long to display the toast on-screen.
    /// - Note: The actual amount of seconds that the toast appears might vary.
    public let duration: Duration?
    
    /// What icon the toast should display.
    /// - Note: Not all toast styles support icons
    public let icon: Image?
    
    /// If you want the user to be able to take simple action by interacting with the toast (e.g. "Undo"), describe that simple action here.
    /// - Note: Not all toast styles support a call-to-action
    public let callToAction: CallToAction?
    
    
    public init(text: AttributedString,
                duration: Duration? = nil,
                icon: Image? = nil,
                callToAction: CallToAction? = nil)
    {
        self.text = text
        self.duration = duration
        self.icon = icon
        self.callToAction = callToAction
    }
    
    
    public init<ToastText>(text: ToastText,
                           duration: Duration? = nil,
                           icon: Image? = nil,
                           callToAction: CallToAction? = nil)
    where ToastText: StringProtocol
    {
        self.init(text: AttributedString(text),
                  duration: duration,
                  icon: icon,
                  callToAction: callToAction)
    }
}



// MARK: - Duration

public extension ToastConfiguration {
    
    /// How long to display a toast on-screen.
    ///
    /// This is a semantic value, not a temporal one; use this to describe the general content of the toast, and the duration will be calculated when it needs to be shown.
    ///
    /// - Attention: Aside from `manualDismiss`, these durations aren't tied to actual time intervals. Avoid assuming that any one of these means any specific amount of time. The actual time interval that a toast is shown on-screen varies depending on factors like whether or not it's presenting a call-to-action, and might also change across versions.
    enum Duration {
        
        /// The toast is being shown for a brief moment to confirm that an action occurred, only remaining long enough to allow the user to read a couple words.
        ///
        /// Good examples include:
        /// - "Email sent" + "Undo"
        /// - "Saved"
        /// - "Download complete" + "Open"
        case actionFeedback
        
        /// The toast is explaining something to the user, who will be reading a modest amount of text on the toast
        ///
        /// Good examples include:
        /// - "You've gone offline. Your changes will be synced with the cloud when you're back online."
        /// - "15 minutes remaining on this test."
        /// - "Message saved to drafts." + "Resume editing"
        case importantText
        
        /// The toast alerts the user of something so critical that they must be able to see the toast even if they weren't using the device at the time it was presented. The toast won't be automatically hidden; you or the user must hide it.
        ///
        /// Good examples include:
        /// - "You've been logged out due to inactivity"
        /// - "Update ready" + "Quit & update"
        /// - "A fatal error occurred and the app had to restart" + "File a bug"
        case manualDismiss
    }
}



extension ToastConfiguration.Duration: Hashable {}
extension ToastConfiguration.Duration: CaseIterable {}



// MARK: - CallToAction

public extension ToastConfiguration {
    
    /// The call-to-action widget for a toast. This is something presented to the user, providing them with an action they can take based on the toast.
    ///
    /// It's not guaranteed that a user will interact with a CTA. Toasts don't have to have them, but even when they do, a toast might disappear automatically or be dismissed in some other way manually. It's best make this an _optional_ action; **avoid assuming** the user can/must perform the presented action.
    struct CallToAction {
        
        /// This is presented as the user, briefly describing what action will be taken.
        ///
        /// It's best to keep this to one word if possible, like "Okay", "Undo", or "Dismiss".
        /// However, styles should still make effort to display longer labels. For example, if the toast says that a pull request was successfully created on GitLab, it would be appropriate for the CTA label to say "Show in GitLab".
        public let label: String
        
        /// Whether to dismiss the toast when the user interacts with the CTA
        public let dismissOnInteraction: Bool
        
        /// This is called when the user interacts with the CTA.
        public let userDidInteract: BlindCallback
        
        
        public init(label: String, dismissOnInteraction: Bool = true, userDidInteract: @escaping BlindCallback) {
            self.label = label
            self.dismissOnInteraction = dismissOnInteraction
            self.userDidInteract = userDidInteract
        }
    }
}



extension ToastConfiguration.CallToAction: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}



extension ToastConfiguration.CallToAction: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(label)
        hasher.combine(withUnsafePointer(to: userDidInteract, echo))
    }
}



// MARK: - Conformance

extension ToastConfiguration: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        if nil != icon {
            hasher.combine(id) // Can't hash an icon, so this ID will be the standin until a better solution is found
        }
        hasher.combine(duration)
        hasher.combine(callToAction)
    }
}



extension ToastConfiguration: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
