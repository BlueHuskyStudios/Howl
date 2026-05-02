//
//  NativeImage Extensions.swift
//  Howl
//
//  Created by Ky Leggiero on 2017-11-10.
//

import Foundation

import CrossKitTypes

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif



public extension NativeImage {
    static func roundedRectMask(size: CGSize, cornerRadius: CGFloat) -> NativeImage {
        var maskImage: NativeImage
        
        #if canImport(AppKit)
        maskImage = NativeImage(size: size, flipped: false) { rect in
            let bezierPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
            NSColor.black.set()
            bezierPath.fill()
            return true
        }
        
        maskImage.capInsets = LegacyEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        maskImage.resizingMode = .stretch
        #elseif canImport(UIKit)
        let renderer = UIGraphicsImageRenderer(size: size)
        maskImage = renderer.image { _ in
            let bezierPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius)
            UIColor.black.setFill()
            bezierPath.fill()
        }

        let capInsets = UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        maskImage = maskImage.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
        #endif
        
        return maskImage
    }
}
