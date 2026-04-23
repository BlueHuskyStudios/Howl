//
//  Cross-kit Image + Initializers.swift
//  Howl
//
//  Created by Ky on 2024-02-14.
//

import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import CrossKitTypes
import RectangleTools



public extension Image {
    init(nativeImage: NativeImage) {
        #if canImport(AppKit)
        self.init(nsImage: nativeImage)
        #elseif canImport(UIKit)
        self.init(uiImage: nativeImage)
        #endif
    }
}



public extension Image {
    
    func nativeImage() -> NativeImage? {
        let view = NoInsetHostingView(rootView: self)
        #if canImport(AppKit)
            view.setFrameSize(view.fittingSize)
            return view.bitmapImage()
        #elseif canImport(UIKit)
            view.view.frame.size = view.preferredContentSize
            return view.view.bitmapImage()
        #endif
    }
}



// MARK: - Private utilities

private class NoInsetHostingView<V: View>: NativeSwiftUiHost<V> {
    #if canImport(AppKit)
    @inline(__always)
    override var safeAreaInsets: LegacyEdgeInsets { .init() }
    #elseif canImport(UIKit)
    #endif
}



private extension NativeView {
    
    func bitmapImage() -> NativeImage? {
        #if canImport(AppKit)
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        cacheDisplay(in: bounds, to: rep)
        guard let cgImage = rep.cgImage else {
            return nil
        }
        return NSImage(cgImage: cgImage, size: bounds.size)
        #elseif canImport(UIKit)
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
        #endif
    }
}



#if canImport(AppKit)
typealias NativeView = NSView
typealias NativeSwiftUiHost<V: View> = NSHostingView<V>
typealias LegacyEdgeInsets = NSEdgeInsets
#elseif canImport(UIKit)
typealias NativeView = UIView
typealias NativeSwiftUiHost<V: View> = UIHostingController<V>
typealias LegacyEdgeInsets = UIEdgeInsets
#endif
