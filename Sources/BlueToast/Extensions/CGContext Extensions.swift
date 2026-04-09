//
//  CGContext Extensions.swift
//  BH Bezel Notification
//
//  Created by Ky Leggiero on 2017-11-10.
//  Copyright © 2017 Ky Leggiero. All rights reserved.
//

import CoreGraphics
import Foundation

import CrossKitTypes



extension CGContext {
    func draw(text string: String,
              at point: CGPoint,
              color: NativeColor,
              font: NativeFont = .systemFont(ofSize: NativeFont.systemFontSize))
    {
        (string as NSString).draw(at: point,
                                  withAttributes: [
                                    .foregroundColor : color,
                                    .font : font
            ])
    }
}
