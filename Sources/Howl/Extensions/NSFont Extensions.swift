//
//  NSFont Extensions.swift
//  BH Bezel Notification
//
//  Created by Ky Leggiero on 2017-11-10.
//  Copyright © 2017 Ky Leggiero. All rights reserved.
//

#if canImport(AppKit)
import AppKit



internal extension NSFont {
     static var systemFont: NSFont {
        return systemFont(ofSize: systemFontSize)
    }
    
    
     static func systemFont(forControlSize controlSize: NSControl.ControlSize) -> NSFont {
        return systemFont(ofSize: systemFontSize(for: controlSize))
    }
}
#endif
