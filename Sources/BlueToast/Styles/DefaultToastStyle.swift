//
//  DefaultToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



#if canImport(AppKit)
public typealias DefaultToastStyle = SystemBezelToastStyle
#else
public typealias DefaultToastStyle = BezelToastStyle
#endif



public extension ToastStyle where Self == DefaultToastStyle {
    static var `default`: Self { .init() }
}
