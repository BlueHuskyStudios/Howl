//
//  NSFont Extensions.swift
//  Howl
//
//  Created by Ky Leggiero on 2017-11-10.
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
