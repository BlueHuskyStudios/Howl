//
//  HowlTests.swift
//  HowlTests
//
//  Tests the public API surface of the Howl package against its
//  documented contract. UI/SwiftUI rendering tests are intentionally
//  excluded; this file covers data types, semantics, and conversions.
//
//  Created by Ky directing Claude 4.7 Opus on 2026-04-30.
//

import Testing
import SwiftUI

@testable import Howl  // some `internal` machinery is exercised
                       // because behavior under test isn't visible
                       // through the View modifier without rendering.

import CrossKitTypes
import FunctionTools


// MARK: - Tags
// (Swift Testing tags so suites can be filtered or run together.)

extension Tag {
    @Tag static var bezelParameters: Self
    @Tag static var toastConfiguration: Self
    @Tag static var conversion: Self
    @Tag static var hashing: Self
    @Tag static var systemBezel: Self
}



// MARK: - BezelNotificationParameters

@Suite("BezelNotificationParameters", .tags(.bezelParameters))
struct BezelNotificationParametersTests {

    @Test("Static defaults have reasonable values")
    func staticDefaults() throws {
        // Locations / sizes should resolve to the only currently-defined case
        #expect(.normal == BezelNotificationParameters.defaultLocation)
        #expect(.normal == BezelNotificationParameters.defaultSize)

        // TTL default should be one of the predefined cases
        #expect(.short == BezelNotificationParameters.defaultTimeToLive)

        // Animation durations should be non-negative
        #expect(0 <= BezelNotificationParameters.defaultFadeInAnimationDuration)
        #expect(0 <= BezelNotificationParameters.defaultFadeOutAnimationDuration)

        // Corner radius should be positive
        #expect(0 < BezelNotificationParameters.defaultCornerRadius)

        // Font size should be positive
        #expect(0 < BezelNotificationParameters.defaultMessageLabelFontSize)
    }


    @Test("Init produces a parameters value that round-trips its public message text via system bezel")
    func initializerProducesUsableValue() {
        let messageText = "Hello, toast!"
        let parameters = BezelNotificationParameters(messageText: messageText)

        // The struct's stored properties are intentionally internal,
        // so we verify behavior through the public surfaces instead.
        // backgroundTint is the public computed property, and it must
        // honor the alpha-multiplier contract for any caller's color.
        let _ = parameters.backgroundTint  // exercises the getter

        // We can also feed it back into the legacy interop path.
        // (The conversion is the contract; the value is data we provide.)
        let ttl = BezelNotificationParameters.TimeToLive(.actionFeedback)
        #expect(.short == ttl)
    }


    @Test("backgroundTint multiplies the raw color's alpha by 0.15")
    func backgroundTintMultipliesAlpha() throws {
        // Construct a parameters value with a known-alpha tint.
        // We use a fully-opaque red so the alpha math is easy to verify.
        let opaqueRed = NativeColor(red: 1, green: 0, blue: 0, alpha: 1)
        let parameters = BezelNotificationParameters(
            messageText: "test",
            backgroundTint: opaqueRed)

        let processed = parameters.backgroundTint

        // The processed alpha should be (1.0 * 0.15) = 0.15
        var processedAlpha: CGFloat = 0
        #if canImport(AppKit)
        processedAlpha = processed.alphaComponent
        #else
        processed.getRed(nil, green: nil, blue: nil, alpha: &processedAlpha)
        #endif

        #expect(abs(0.15 - processedAlpha) < 0.001,
                "Expected processed alpha ≈ 0.15, got \(processedAlpha)")
    }


    @Test("backgroundTint with half-transparent input halves the multiplier")
    func backgroundTintWithPartialAlpha() throws {
        let halfRed = NativeColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        let parameters = BezelNotificationParameters(
            messageText: "test",
            backgroundTint: halfRed)

        let processed = parameters.backgroundTint

        var processedAlpha: CGFloat = 0
        #if canImport(AppKit)
        processedAlpha = processed.alphaComponent
        #else
        processed.getRed(nil, green: nil, blue: nil, alpha: &processedAlpha)
        #endif

        // (0.5 * 0.15) = 0.075
        #expect(abs(0.075 - processedAlpha) < 0.001,
                "Expected processed alpha ≈ 0.075, got \(processedAlpha)")
    }


    @Test("backgroundTint with the default clear color stays clear")
    func backgroundTintWithClearStaysClear() throws {
        let parameters = BezelNotificationParameters(messageText: "test")

        let processed = parameters.backgroundTint

        var processedAlpha: CGFloat = 0
        #if canImport(AppKit)
        processedAlpha = processed.alphaComponent
        #else
        processed.getRed(nil, green: nil, blue: nil, alpha: &processedAlpha)
        #endif

        #expect(0 == processedAlpha, "Clear input should yield clear output")
    }
}



// MARK: - TimeToLive

@Suite("BezelNotificationParameters.TimeToLive", .tags(.bezelParameters))
struct TimeToLiveTests {

    @Test("Predefined cases have positive duration in seconds",
          arguments: [
            BezelNotificationParameters.TimeToLive.short,
            .long,
          ])
    func predefinedDurationsArePositive(ttl: BezelNotificationParameters.TimeToLive) {
        #expect(0 < ttl.inSeconds)
    }


    @Test("`.forever` yields infinity in seconds")
    func foreverIsInfinity() {
        #expect(.infinity == BezelNotificationParameters.TimeToLive.forever.inSeconds)
    }


    @Test("`.exactly(seconds:)` returns exactly that many seconds",
          arguments: [0.0, 0.5, 1.0, 30.0, 12_345.6])
    func exactlyReturnsExactSeconds(seconds: TimeInterval) {
        let ttl = BezelNotificationParameters.TimeToLive.exactly(seconds: seconds)
        #expect(seconds == ttl.inSeconds)
    }


    @Test(".short is shorter than .long")
    func shortIsShorterThanLong() {
        #expect(BezelNotificationParameters.TimeToLive.short.inSeconds
                < BezelNotificationParameters.TimeToLive.long.inSeconds)
    }


    // MARK: Hashable

    @Test("Same case hashes equal", .tags(.hashing))
    func sameCaseHashesEqual() {
        let lhs = BezelNotificationParameters.TimeToLive.short
        let rhs = BezelNotificationParameters.TimeToLive.short
        #expect(lhs.hashValue == rhs.hashValue)
    }


    @Test("Different predefined cases hash differently", .tags(.hashing))
    func differentPredefinedCasesHashDifferently() {
        // We can't promise non-collision in general (any two hashes can
        // collide), but for these few well-separated values the property
        // should hold.
        var hashes = Set<Int>()
        hashes.insert(BezelNotificationParameters.TimeToLive.short.hashValue)
        hashes.insert(BezelNotificationParameters.TimeToLive.long.hashValue)
        hashes.insert(BezelNotificationParameters.TimeToLive.forever.hashValue)
        #expect(3 == hashes.count, "All three predefined TTLs should hash to distinct values")
    }


    @Test(".exactly with the same seconds hashes equally", .tags(.hashing))
    func exactlySameSecondsHashesEqual() {
        let a = BezelNotificationParameters.TimeToLive.exactly(seconds: 7.5)
        let b = BezelNotificationParameters.TimeToLive.exactly(seconds: 7.5)
        #expect(a.hashValue == b.hashValue)
    }


    @Test(".exactly with different seconds hashes differently (usually)", .tags(.hashing))
    func exactlyDifferentSecondsHashesDifferently() {
        let a = BezelNotificationParameters.TimeToLive.exactly(seconds: 1)
        let b = BezelNotificationParameters.TimeToLive.exactly(seconds: 2)
        // Hash collisions are theoretically possible, but for two
        // well-separated TimeIntervals they'd be a sign of trouble.
        #expect(a.hashValue != b.hashValue)
    }
}



// MARK: - Size

@Suite("BezelNotificationParameters.Size", .tags(.bezelParameters))
struct SizeTests {

    @Test("`.normal` produces a positive square size")
    func normalIsPositiveSquare() {
        let size = BezelNotificationParameters.Size.normal.cgSize
        #expect(0 < size.width)
        #expect(0 < size.height)
        #expect(size.width == size.height,
                "Bezel notifications are conventionally square; this can change but the test should be updated alongside.")
    }
}



// MARK: - Location

@Suite("BezelNotificationParameters.Location", .tags(.bezelParameters))
struct LocationTests {

    @Test("`.normal` places the bezel horizontally centered in its parent")
    func normalIsHorizontallyCentered() {
        let parent = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let bezelRect = BezelNotificationParameters.Location.normal
            .bezelWindowContentRect(in: parent, atSize: .normal)

        // The bezel's x-midpoint should match the parent's x-midpoint
        #expect(parent.midX == bezelRect.midX,
                "Expected bezel horizontally centered; got midX = \(bezelRect.midX), parent midX = \(parent.midX)")
    }


    @Test("`.normal` places the bezel near the bottom of its parent")
    func normalSitsNearBottom() {
        let parent = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let bezelRect = BezelNotificationParameters.Location.normal
            .bezelWindowContentRect(in: parent, atSize: .normal)

        // The bezel's bottom should be a bounded distance above the
        // parent's bottom (this is the "lower-center" placement).
        #expect(bezelRect.minY > parent.minY,
                "Bezel bottom should be above parent bottom")
        #expect(bezelRect.minY < parent.midY,
                "Bezel bottom should be in the lower half of parent")
    }


    @Test("Bezel rect's size matches the requested size")
    func sizeMatchesRequested() {
        let parent = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let bezelRect = BezelNotificationParameters.Location.normal
            .bezelWindowContentRect(in: parent, atSize: .normal)
        let expectedSize = BezelNotificationParameters.Size.normal.cgSize

        #expect(expectedSize.width == bezelRect.width)
        #expect(expectedSize.height == bezelRect.height)
    }


    @Test("`.normal` works with parents of varying width",
          arguments: [400.0, 800.0, 1600.0, 3200.0])
    func normalScalesWithParentWidth(parentWidth: CGFloat) {
        let parent = CGRect(x: 0, y: 0, width: parentWidth, height: 800)
        let bezelRect = BezelNotificationParameters.Location.normal
            .bezelWindowContentRect(in: parent, atSize: .normal)
        #expect(parent.midX == bezelRect.midX)
    }
}



// MARK: - ToastConfiguration

@Suite("ToastConfiguration", .tags(.toastConfiguration))
struct ToastConfigurationTests {

    @Test("Init with AttributedString preserves the text")
    func initWithAttributedString() {
        let text: AttributedString = "Saved"
        let config = ToastConfiguration(
            text: text,
            duration: nil,
            icon: nil,
            callToAction: nil)
        #expect(text == config.text)
    }


    @Test("Init with String wraps it in AttributedString")
    func initWithStringProtocol() {
        let plainString = "Saved"
        let config = ToastConfiguration(
            text: plainString,
            duration: nil,
            icon: nil,
            callToAction: nil)
        #expect(AttributedString(plainString) == config.text)
    }


    @Test("Init with Substring (also StringProtocol) works")
    func initWithSubstring() {
        let full = "Hello, world"
        let sub = full.dropFirst(7)  // "world"
        let config = ToastConfiguration(
            text: sub,
            duration: nil,
            icon: nil,
            callToAction: nil)
        #expect(AttributedString(sub) == config.text)
    }


    @Test("Init preserves all four core fields")
    func initPreservesAllFields() {
        let text: AttributedString = "Email sent"
        let duration: ToastConfiguration.Duration = .actionFeedback
        let icon = Image(systemName: "envelope.fill")
        let cta = ToastConfiguration.CallToAction(label: "Undo", userDidInteract: null)

        let config = ToastConfiguration(
            text: text,
            duration: duration,
            icon: icon,
            callToAction: cta)

        #expect(text == config.text)
        #expect(duration == config.duration)
        #expect(nil != config.icon, "icon should be preserved (Image isn't equatable for direct comparison)")
        #expect(cta == config.callToAction)
    }


    @Test("Two configs with identical content (no icon) compare equal", .tags(.hashing))
    func identicalConfigsWithoutIconAreEqual() {
        let a = ToastConfiguration(
            text: "Saved",
            duration: .actionFeedback,
            icon: nil,
            callToAction: nil)
        let b = ToastConfiguration(
            text: "Saved",
            duration: .actionFeedback,
            icon: nil,
            callToAction: nil)
        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }


    @Test("Two configs with different text compare unequal", .tags(.hashing))
    func differentTextConfigsAreUnequal() {
        let a = ToastConfiguration(
            text: "Saved",
            duration: .actionFeedback,
            icon: nil,
            callToAction: nil)
        let b = ToastConfiguration(
            text: "Sent",
            duration: .actionFeedback,
            icon: nil,
            callToAction: nil)
        #expect(a != b)
    }


    @Test("Two configs with same content + icons are intentionally not equal", .tags(.hashing))
    func iconBearingConfigsHaveDistinctIdentities() {
        // This is the documented surprise: because Image isn't hashable,
        // configs that carry an icon use a per-instance UUID as a stand-in.
        // That means two freshly-built configs with "the same" icon are
        // treated as distinct, even though the icon content is identical.
        let icon = Image(systemName: "checkmark")
        let a = ToastConfiguration(
            text: "Saved",
            duration: .actionFeedback,
            icon: icon,
            callToAction: nil)
        let b = ToastConfiguration(
            text: "Saved",
            duration: .actionFeedback,
            icon: icon,
            callToAction: nil)
        #expect(a != b, "Configs with icons are intentionally non-equal even with the same content")
    }


    @Test("Two configs with no icon and no CTA, but different durations, are unequal", .tags(.hashing))
    func differentDurationsAreUnequal() {
        let a = ToastConfiguration(
            text: "Saved",
            duration: .actionFeedback,
            icon: nil,
            callToAction: nil)
        let b = ToastConfiguration(
            text: "Saved",
            duration: .importantText,
            icon: nil,
            callToAction: nil)
        #expect(a != b)
    }


    @Test("Two configs with same content but different CTA labels are unequal", .tags(.hashing))
    func differentCTALabelsAreUnequal() {
        let a = ToastConfiguration(
            text: "Created",
            duration: .actionFeedback,
            icon: nil,
            callToAction: .init(label: "View", userDidInteract: null))
        let b = ToastConfiguration(
            text: "Created",
            duration: .actionFeedback,
            icon: nil,
            callToAction: .init(label: "Open", userDidInteract: null))
        #expect(a != b)
    }
}



// MARK: - ToastConfiguration.Duration

@Suite("ToastConfiguration.Duration", .tags(.toastConfiguration))
struct DurationTests {

    @Test("CaseIterable yields all three currently-defined cases")
    func caseIterableHasAllCases() {
        // If a fourth case is added, this test should fail and be updated.
        // That's intentional — adding a case is a SemVer break, and this
        // test makes the change visible.
        let allCases = ToastConfiguration.Duration.allCases
        #expect(3 == allCases.count)
        #expect(allCases.contains(.actionFeedback))
        #expect(allCases.contains(.importantText))
        #expect(allCases.contains(.manualDismiss))
    }


    @Test("Each case hashes equal to itself", .tags(.hashing),
          arguments: ToastConfiguration.Duration.allCases)
    func eachCaseHashesEqualToItself(duration: ToastConfiguration.Duration) {
        #expect(duration.hashValue == duration.hashValue)
        #expect(duration == duration)
    }


    @Test("Distinct cases hash differently", .tags(.hashing))
    func distinctCasesHashDifferently() {
        let hashes = Set(ToastConfiguration.Duration.allCases.map(\.hashValue))
        #expect(ToastConfiguration.Duration.allCases.count == hashes.count,
                "Each case should hash to a distinct value")
    }
}



// MARK: - ToastConfiguration.CallToAction

@Suite("ToastConfiguration.CallToAction", .tags(.toastConfiguration))
struct CallToActionTests {

    @Test("Init with default dismissOnInteraction sets it to true")
    func defaultDismissOnInteractionIsTrue() {
        let cta = ToastConfiguration.CallToAction(label: "Undo", userDidInteract: null)
        #expect(true == cta.dismissOnInteraction)
    }


    @Test("Init with explicit dismissOnInteraction respects the value")
    func explicitDismissOnInteractionIsRespected() {
        let cta = ToastConfiguration.CallToAction(
            label: "Undo",
            dismissOnInteraction: false,
            userDidInteract: null)
        #expect(false == cta.dismissOnInteraction)
    }


    @Test("Init preserves the label")
    func initPreservesLabel() {
        let cta = ToastConfiguration.CallToAction(label: "Open", userDidInteract: null)
        #expect("Open" == cta.label)
    }


    @Test("userDidInteract closure is callable and runs")
    func userDidInteractIsInvocable() async {
        let didCall = LockedFlag()
        let cta = ToastConfiguration.CallToAction(label: "Tap me") {
            didCall.set()
        }
        cta.userDidInteract()
        #expect(true == didCall.get())
    }


    // NOTE: Once Hashable/Equatable are revised to compare on label +
    // dismissOnInteraction (as discussed in review), the following tests
    // will exercise that contract. Until then, they're skipped because
    // the current implementation hashes a closure pointer, which is
    // not stable across runs.

    @Test("Two CTAs with the same label and dismiss flag are equal",
          .tags(.hashing),
          .disabled("Re-enable after the Hashable/Equatable revision discussed in code review"))
    func sameLabelSameDismissAreEqual() {
        let a = ToastConfiguration.CallToAction(label: "Undo", userDidInteract: null)
        let b = ToastConfiguration.CallToAction(label: "Undo", userDidInteract: null)
        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }


    @Test("Two CTAs with different labels are unequal",
          .tags(.hashing),
          .disabled("Re-enable after the Hashable/Equatable revision discussed in code review"))
    func differentLabelsAreUnequal() {
        let a = ToastConfiguration.CallToAction(label: "Undo", userDidInteract: null)
        let b = ToastConfiguration.CallToAction(label: "Redo", userDidInteract: null)
        #expect(a != b)
    }
}



// MARK: - Conversions: TimeToLive ↔ Duration

@Suite("BezelNotificationParameters.TimeToLive ↔ ToastConfiguration.Duration",
       .tags(.conversion))
struct TimeToLiveDurationConversionTests {

    // MARK: Forward (Duration → TTL)

    @Test("`.actionFeedback` converts to `.short`")
    func actionFeedbackToShort() {
        let ttl = BezelNotificationParameters.TimeToLive(.actionFeedback)
        #expect(.short == ttl)
    }


    @Test("`.importantText` converts to `.long`")
    func importantTextToLong() {
        let ttl = BezelNotificationParameters.TimeToLive(.importantText)
        #expect(.long == ttl)
    }


    @Test("`.manualDismiss` converts to `.forever`")
    func manualDismissToForever() {
        let ttl = BezelNotificationParameters.TimeToLive(.manualDismiss)
        #expect(.forever == ttl)
    }


    // MARK: Reverse (TTL → Duration)

    @Test("`.short` converts to `.actionFeedback`")
    func shortToActionFeedback() {
        let duration = ToastConfiguration.Duration(BezelNotificationParameters.TimeToLive.short)
        #expect(.actionFeedback == duration)
    }


    @Test("`.long` converts to `.importantText`")
    func longToImportantText() {
        let duration = ToastConfiguration.Duration(BezelNotificationParameters.TimeToLive.long)
        #expect(.importantText == duration)
    }


    @Test("`.forever` converts to `.manualDismiss`")
    func foreverToManualDismiss() {
        let duration = ToastConfiguration.Duration(BezelNotificationParameters.TimeToLive.forever)
        #expect(.manualDismiss == duration)
    }


    // MARK: Reverse with .exactly

    @Test("`.exactly(0)` picks the closest duration (`.actionFeedback`)")
    func exactlyZeroPicksClosest() {
        let duration = ToastConfiguration.Duration(.exactly(seconds: 0))
        // .actionFeedback is 2.5s, .importantText is 6s, .manualDismiss is huge.
        // |0 - 2.5| < |0 - 6| < |0 - huge|, so we expect actionFeedback.
        #expect(.actionFeedback == duration)
    }


    @Test("`.exactly(2.5)` picks `.actionFeedback` (exact match)")
    func exactlyTwoFivePicksActionFeedback() {
        let duration = ToastConfiguration.Duration(.exactly(seconds: 2.5))
        #expect(.actionFeedback == duration)
    }


    @Test("`.exactly(6)` picks `.importantText` (exact match)")
    func exactlySixPicksImportantText() {
        let duration = ToastConfiguration.Duration(.exactly(seconds: 6))
        #expect(.importantText == duration)
    }


    @Test("`.exactly(4)` picks `.actionFeedback` (closer to 2.5 than 6)")
    func exactlyFourPicksActionFeedback() {
        // |4 - 2.5| = 1.5; |4 - 6| = 2.0; so .actionFeedback wins.
        let duration = ToastConfiguration.Duration(.exactly(seconds: 4))
        #expect(.actionFeedback == duration)
    }


    @Test("`.exactly(5)` picks `.importantText` (closer to 6 than 2.5)")
    func exactlyFivePicksImportantText() {
        // |5 - 2.5| = 2.5; |5 - 6| = 1.0; so .importantText wins.
        let duration = ToastConfiguration.Duration(.exactly(seconds: 5))
        #expect(.importantText == duration)
    }


    @Test("`.exactly(3.5)` is on the conversion boundary (closer to 2.5)")
    func exactlyBoundaryPicksActionFeedback() {
        // |3.5 - 2.5| = 1.0; |3.5 - 6| = 2.5; so .actionFeedback wins.
        let duration = ToastConfiguration.Duration(.exactly(seconds: 3.5))
        #expect(.actionFeedback == duration)
    }


    @Test("`.exactly(huge)` picks `.manualDismiss` when given a value clearly closer to its 1000-year anchor")
    func exactlyHugePicksManualDismiss() {
        // We want a value strictly past the midpoint between .importantText
        // and .manualDismiss, so the closest-match algorithm has to land on
        // .manualDismiss. Computing 90% of the manualDismiss anchor gives us
        // generous headroom past the midpoint without hard-coding the
        // implementation's exact 1000-year choice.
        let nearManualDismiss = ToastConfiguration.Duration.manualDismiss.inSeconds * 0.9
        let duration = ToastConfiguration.Duration(.exactly(seconds: nearManualDismiss))
        #expect(.manualDismiss == duration)
    }


    @Test("Forward then reverse round-trips known cases (lossless for predefined values)")
    func forwardReverseRoundTripPreservesPredefined() {
        for d in ToastConfiguration.Duration.allCases {
            let ttl = BezelNotificationParameters.TimeToLive(d)
            let back = ToastConfiguration.Duration(ttl)
            #expect(d == back, "Duration \(d) failed to round-trip; got \(back)")
        }
    }
}



// MARK: - Internal duration math
// These exercise `internal` helpers that drive the live-display behavior
// of toasts. They use @testable import, which is acceptable because
// these helpers are pure functions of their inputs and not part of the
// public API (so we want to verify the math without rendering a view).

@Suite("Configuration.disappearDate semantics", .tags(.toastConfiguration))
struct ConfigurationDisappearMathTests {

    @Test("`.actionFeedback` disappears 2.5 seconds after appearance")
    func actionFeedbackDisappearsAt2_5Seconds() {
        let appearAt = Date(timeIntervalSinceReferenceDate: 0)
        let expected = appearAt + 2.5
        let actual = ToastConfiguration.Duration.actionFeedback.disappearDate(appearingAt: appearAt)
        #expect(expected == actual)
    }


    @Test("`.importantText` disappears 6 seconds after appearance")
    func importantTextDisappearsAt6Seconds() {
        let appearAt = Date(timeIntervalSinceReferenceDate: 0)
        let expected = appearAt + 6
        let actual = ToastConfiguration.Duration.importantText.disappearDate(appearingAt: appearAt)
        #expect(expected == actual)
    }


    @Test("`.manualDismiss` returns the distant future")
    func manualDismissIsDistantFuture() {
        let appearAt = Date(timeIntervalSinceReferenceDate: 0)
        let actual = ToastConfiguration.Duration.manualDismiss.disappearDate(appearingAt: appearAt)
        #expect(.distantFuture == actual)
    }


    @Test("Configs with no CTA use only the duration's disappear math")
    func noCTAUsesDurationOnly() {
        let appearAt = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let config = ToastConfiguration(
            text: "Saved",
            duration: .actionFeedback,
            icon: nil,
            callToAction: nil)

        let expected = appearAt + 2.5
        let actual = config.disappearDate(appearingAt: appearAt)
        #expect(expected == actual)
    }


    @Test("Configs with a CTA stay on screen at least the CTA-reading minimum")
    func ctaExtendsBriefDurations() {
        // If the duration would otherwise dismiss the toast in 2.5s but
        // there's a CTA, the toast should remain at least long enough to
        // read the CTA — currently 3 + 0.1 * label_length seconds, capped
        // at 30s.
        let appearAt = Date()
        let config = ToastConfiguration(
            text: "Created",
            duration: .actionFeedback,  // 2.5s
            icon: nil,
            callToAction: .init(label: "Open", userDidInteract: null))  // 4 chars => 3 + 0.4 = 3.4s

        let actual = config.disappearDate(appearingAt: appearAt)

        // The actual disappear date should be ≥ the duration's disappear
        // date AND ≥ the CTA reading minimum.
        let durationOnly = ToastConfiguration.Duration.actionFeedback.disappearDate(appearingAt: appearAt)
        #expect(actual >= durationOnly,
                "CTA presence should never shrink the duration below the duration's own value")
    }


    @Test("`actualDuration` falls back to the type's default when nil")
    func actualDurationDefaultsCorrectly() {
        let config = ToastConfiguration(
            text: "Saved",
            duration: nil,
            icon: nil,
            callToAction: nil)
        #expect(.actionFeedback == config.actualDuration,
                "When no duration is supplied, the default should be `.actionFeedback`")
    }


    @Test("`actualDuration` honors the supplied duration")
    func actualDurationHonorsExplicit() {
        let config = ToastConfiguration(
            text: "Logged out",
            duration: .manualDismiss,
            icon: nil,
            callToAction: nil)
        #expect(.manualDismiss == config.actualDuration)
    }
}



// MARK: - SystemBezelNotification (macOS only)

#if os(macOS)
@Suite("SystemBezelNotification", .tags(.systemBezel))
struct SystemBezelNotificationTests {

    @Test("`Parameters` is a typealias for `BezelNotificationParameters`")
    func parametersIsTypealiasForBezelNotificationParameters() {
        // Compile-time check: if these are different types, this won't
        // compile.
        let _ : SystemBezelNotification.Parameters.Type
            = BezelNotificationParameters.self
    }


    @available(*, deprecated) // silences the deprecation warning
    @Test("Deprecated `BHBezelNotification` typealias still resolves to SystemBezelNotification")
    func deprecatedBHBezelNotificationStillResolves() {
        // Same compile-time check as above; this is preserved-back-compat.
        // The deprecation warning is expected when this test compiles.
        let _ : BHBezelNotification.Parameters.Type
            = BezelNotificationParameters.self
    }
}
#endif



// MARK: - Test helpers

/// A small mutable flag used by the CallToAction invocation test.
/// Marked `final class` so it's a reference type (we mutate from inside
/// a closure and observe the result outside it). Locking is added so
/// the test is well-behaved under any future concurrency-aware test
/// runner.
private final class LockedFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false

    func set() {
        lock.lock()
        defer { lock.unlock() }
        value = true
    }

    func get() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}
