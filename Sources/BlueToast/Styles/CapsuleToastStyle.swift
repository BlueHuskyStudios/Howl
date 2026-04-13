//
//  CapsuleToastStyle.swift
//
//
//  Created by Ky on 2024-02-21.
//

import SwiftUI



public struct CapsuleToastStyle: ToastStyle {
    public func body(_ configuration: Configuration) -> some View {
        ZStack(alignment: .bottom) {
            
            Text(configuration.text)
                .padding()
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
            
            Rectangle()
                .fill(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}



public extension ToastStyle where Self == CapsuleToastStyle {
    static var capsule: Self { Self.init() }
}



#Preview {
    ToastPreview {
        CapsuleToastStyle()
    }
}
