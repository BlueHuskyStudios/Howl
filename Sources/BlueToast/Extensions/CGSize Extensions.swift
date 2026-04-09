//
//  NSSize Extensions.swift
//  BH Bezel Notification
//
//  Created by Ky Leggiero on 2017-11-10.
//  Copyright © 2017 Ky Leggiero. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGSize



//internal extension CGSize {
//    
//    init(scaling original: CGSize, toFitWithin parent: CGSize, approach: NSImageScaling) {
//        
//        switch approach {
//        case .scaleAxesIndependently:
//            self = parent
//            
//        case .scaleNone:
//            self = original
//            
//        case .scaleProportionallyDown:
//            // If it already fits, no need to scale. Just use the original.
//            if original.height < parent.height
//                && original.width < parent.width {
//                self = original
//            }
//            else {
//                fallthrough
//            }
//            
//        case .scaleProportionallyUpOrDown:
//            let tooManyPixelsTall = max(0, original.height - parent.height)
//            let tooManyPixelsWide = max(0, original.width - parent.width)
//            
//            let shouldScaleToFitHeight = tooManyPixelsTall > tooManyPixelsWide
//            
//            if shouldScaleToFitHeight {
//                self.init(scaling: original, proportionallyToFitHeight: parent.height)
//            }
//            else {
//                self.init(scaling: original, proportionallyToFitWidth: parent.width)
//            }
//            
//        @unknown default:
//            self = original
//        }
//    }
//    
//    
//    init(scaling original: CGSize, proportionallyToFitHeight newHeight: CGFloat) {
//        let percentChange = newHeight / original.height
//        self.init(width: original.width * percentChange,
//                  height: newHeight)
//    }
//    
//    
//    init(scaling original: CGSize, proportionallyToFitWidth newWidth: CGFloat) {
//        let percentChange = newWidth / original.width
//        self.init(width: newWidth,
//                  height: original.height * percentChange)
//    }
//    
//    
//    var aspectRatio: CGFloat {
//        return width / height
//    }
//}
//
//
//
//internal extension CGSize {
//    static func *(lhs: Double, rhs: CGSize) -> CGSize {
//        return CGFloat(lhs) * rhs
//    }
//    
//    
//    static func *(lhs: CGSize, rhs: Double) -> CGSize {
//        return lhs * CGFloat(rhs)
//    }
//    
//    
//    static func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
//        return CGSize(width: lhs * rhs.width,
//                      height: lhs * rhs.height)
//    }
//    
//    
//    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
//        return CGSize(width: lhs.width * rhs,
//                      height: lhs.height * rhs)
//    }
//    
//    
//    static func *(lhs: CGSize, rhs: CGSize) -> CGSize {
//        return CGSize(width: lhs.width * rhs.width,
//                      height: lhs.height * rhs.height)
//    }
//}
