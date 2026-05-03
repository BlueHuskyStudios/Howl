//
//  NSAppearance Extensions.swift
//  Howl
//
//  Created by Ky Leggiero on 2017-11-10.
//

#if canImport(AppKit)
import AppKit



internal extension NSAppearance.Name {
    
    /// Chooses an appropriate vibrant appearance (e.g. ``vibrantDark`` or ``vibrantLight``) based on the current appearance settings (e.g. dark mode)
    static var vibrantCurrent: NSAppearance.Name {
        switch NSAppearance.currentDrawing().name {
        case .aqua,
                .vibrantLight:
            return .vibrantLight
            
        case .darkAqua,
                .vibrantDark:
            return .vibrantDark
            
        default:
            return .vibrantDark
        }
    }
}
#endif
