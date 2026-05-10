//
//  CGContext Extensions.swift
//  Howl
//
//  Created by Ky Leggiero on 2017-11-10.
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
