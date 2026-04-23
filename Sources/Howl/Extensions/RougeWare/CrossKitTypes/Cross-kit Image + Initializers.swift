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
    
    @MainActor
    func nativeImage() -> NativeImage? {
        let renderer = ImageRenderer(content: self)
        #if canImport(AppKit)
            renderer.scale = NSScreen.main?.backingScaleFactor ?? 1.0
            return renderer.nsImage
        #elseif canImport(UIKit)
            renderer.scale = UIScreen.main.scale
            return renderer.uiImage
        #endif
    }
}



// MARK: - Private utilities

//private class NoInsetHostingView<V: View>: NativeSwiftUiHost<V> {
//    #if canImport(AppKit)
//    @inline(__always)
//    override var safeAreaInsets: LegacyEdgeInsets { .init() }
//    #elseif canImport(UIKit)
//    #endif
//}
//
//
//
//private extension NativeView {
//    
//    func bitmapImage() -> NativeImage? {
//        #if canImport(AppKit)
//        guard let layer else { return nil }
//
//        let scale = window?.backingScaleFactor ?? 1.0
//        let pixelWidth  = Int((bounds.width  * scale).rounded())
//        let pixelHeight = Int((bounds.height * scale).rounded())
//
//        guard pixelWidth > 0, pixelHeight > 0 else { return nil }
//
//        guard let context = CGContext(
//            data: nil,
//            width: pixelWidth,
//            height: pixelHeight,
//            bitsPerComponent: 8,
//            bytesPerRow: 0,
//            space: CGColorSpaceCreateDeviceRGB(),
//            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
//                      | CGBitmapInfo.byteOrder32Little.rawValue
//        ) else { return nil }
//
//        // Scale up for HiDPI, then render.
//        context.scaleBy(x: scale, y: scale)
//        layer.render(in: context)
//
//        guard let cgImage = context.makeImage() else { return nil }
//        return NSImage(cgImage: cgImage, size: bounds.size)
//        #elseif canImport(UIKit)
//        let renderer = UIGraphicsImageRenderer(bounds: bounds)
//        return renderer.image { context in
//            layer.render(in: context.cgContext)
//        }
//        #endif
//    }
//}
//
//
//
#if canImport(AppKit)
//typealias NativeView = NSView
//typealias NativeSwiftUiHost<V: View> = NSHostingView<V>
typealias LegacyEdgeInsets = NSEdgeInsets
#elseif canImport(UIKit)
//typealias NativeView = UIView
//typealias NativeSwiftUiHost<V: View> = UIHostingController<V>
typealias LegacyEdgeInsets = UIEdgeInsets
#endif
