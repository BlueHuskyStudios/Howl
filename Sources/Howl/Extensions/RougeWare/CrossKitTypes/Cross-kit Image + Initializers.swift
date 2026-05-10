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

#if canImport(AppKit)
typealias LegacyEdgeInsets = NSEdgeInsets
#elseif canImport(UIKit)
typealias LegacyEdgeInsets = UIEdgeInsets
#endif
