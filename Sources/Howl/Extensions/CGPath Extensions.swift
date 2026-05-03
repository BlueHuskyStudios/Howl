//
//  CGPath Extensions.swift
//  Howl
//
//  Created by Ky Leggiero on 2017-11-10.
//

import CoreGraphics



internal extension CGPath {
    static func roundedRect(size: CGSize, cornerRadius: CGFloat) -> CGPath {
        return CGPath(roundedRect: CGRect(origin: .zero, size: size),
                      cornerWidth: cornerRadius,
                      cornerHeight: cornerRadius,
                      transform: nil)
    }
}
