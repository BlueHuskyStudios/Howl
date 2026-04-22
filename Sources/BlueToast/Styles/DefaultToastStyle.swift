//
//  DefaultToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



#if os(macOS)
public typealias DefaultToastStyle = SystemBezelToastStyle
#else
public typealias DefaultToastStyle = BezelToastStyle
#endif



public extension ToastStyle where Self == DefaultToastStyle {
    /// A reasonable default taost style. This might change across versions and platforms.
    static var `default`: Self { .init() }
}
