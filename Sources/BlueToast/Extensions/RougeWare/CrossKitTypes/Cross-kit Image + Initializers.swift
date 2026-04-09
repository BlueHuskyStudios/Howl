//
//  Cross-kit Image + Initializers.swift
//  BlueToast Demo App
//
//  Created by The Northstar✨ System on 2024-02-14.
//  Copyright © 2024 Ky Leggiero. All rights reserved.
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
        #elseif canImport(UIKit)
            view.view.frame.size = view.preferredContentSize
        #endif
        return view.bitmapImage()
    }
}



// MARK: - Private utilities

private class NoInsetHostingView<V: View>: NativeHostingView<V> {
    @inline(__always)
    override var safeAreaInsets: OldEdgeInsets { .init() }
}



private extension NativeView {
    
    func bitmapImage() -> NativeImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        cacheDisplay(in: bounds, to: rep)
        guard let cgImage = rep.cgImage else {
            return nil
        }
        return NSImage(cgImage: cgImage, size: bounds.size)
    }
}



#if canImport(AppKit)
typealias NativeView = NSView
typealias NativeHostingView<V: View> = NSHostingView<V>
typealias OldEdgeInsets = NSEdgeInsets
#elseif canImport(UIKit)
typealias NativeView = UIView
typealias NativeHostingView<V: View> = UIHostingController<V>
typealias OldEdgeInsets = UIEdgeInsets
#endif
