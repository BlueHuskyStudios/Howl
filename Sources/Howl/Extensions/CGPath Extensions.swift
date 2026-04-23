//
//  CGPath Extensions.swift
//  BH Bezel Notification
//
//  Created by Ky Leggiero on 2017-11-10.
//  Copyright © 2017 Ky Leggiero. All rights reserved.
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
