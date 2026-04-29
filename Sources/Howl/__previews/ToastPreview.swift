//
//  ToastPreview.swift
//  
//
//  Created by Ky on 2024-02-24.
//

import SwiftUI

import CrossKitTypes
import FunctionTools



@available(macOS 15, iOS 18, *)
internal struct ToastPreview<ToastStyleKind: ToastStyle>: View {
    
    @State
    private var text: String = "Demo toast"
    
    @State
    private var show = true
    
    @State
    private var useIcon = true
    
    @State
    private var useCta = true
    
    let demoToast: ToastStyleKind
    
    
    init(_ demoToast: ToastStyleKind) {
        self.demoToast = demoToast
    }
    
    
    var body: some View {
//        TabView {
//            Tab("Demo", systemImage: "sparkles") {
                ZStack {
//                    Image.previewBackground
                    MeshGradient.toastPreview
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        TextField("Text", text: $text)
                            .textFieldStyle(.roundedBorder)
                            .frame(idealWidth: 100, maxWidth: 200)
                            .fixedSize(horizontal: false, vertical: false)
                        Toggle("Show", isOn: $show)
                        Toggle("Use icon", isOn: $useIcon)
                        Toggle("Use CTA", isOn: $useCta)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                        #if canImport(AppKit)
                            .fill(Color(.controlBackgroundColor))
                        #else
                            .fill(Color(.systemBackground))
                        #endif
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
                
                .toast(
                    isPresented: $show,
                    text: text,
                    duration: .manualDismiss,
                    icon: useIcon ? Image(systemName: "hammer.fill").resizable() : nil,
                    action: useCta ? .init(label: "Undo", userDidInteract: null) : nil,
                )
                .toastStyle(demoToast)
//            }
//            
//            Tab("Foo", systemImage: "square", content: { EmptyView() })
//            Tab("Bar", systemImage: "circle", content: { EmptyView() })
//        }
    }
}



@available(macOS 15, iOS 18, *)
#Preview("Capsule") {
    ToastPreview(.capsule)
}
