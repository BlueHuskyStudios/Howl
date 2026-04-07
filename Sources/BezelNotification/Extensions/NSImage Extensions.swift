//
//  NSImage Extensions.swift
//  BH Bezel Notification
//
//  Created by Ben Leggiero on 2017-11-10.
//  Copyright © 2017 Ben Leggiero. All rights reserved.
//

import Foundation
import AppKit

import CrossKitTypes



public extension NativeImage {
    static func roundedRectMask(size: NSSize, cornerRadius: CGFloat) -> NativeImage {

        let maskImage = NativeImage(size: size, flipped: false) { rect in
            let bezierPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
            NSColor.black.set()
            bezierPath.fill()
            return true
        }
        
        maskImage.capInsets = NSEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
        maskImage.resizingMode = .stretch
        
        return maskImage

//        guard let context = NSGraphicsContext.current?.cgContext else {
//            return NSImage(size: size)
//        }
//
//        context.setFillColor(.black)
//        context.fill(CGRect(origin: .zero, size: size))
//        context.setShouldAntialias(true)
//        context.setAllowsAntialiasing(true)
//
//        context.addPath(.roundedRect(size: size, cornerRadius: cornerRadius))
//        context.setFillColor(.white)
//        context.fillPath(using: .winding)
//        context.flush()
//
//        guard let cgImage = context.makeImage() else {
//            return NSImage(size: size)
//        }
//
//        return NSImage(cgImage: cgImage, size: size)
    }
}
