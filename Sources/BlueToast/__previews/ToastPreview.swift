//
//  ToastPreview.swift
//  
//
//  Created by Ky on 2024-02-24.
//

import SwiftUI



@available(iOS 18, *)
internal struct ToastPreview<ToastStyleKind: ToastStyle>: View {
    
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
        TabView {
            Tab("Demo", systemImage: "sparkles") {
                ZStack {
//            VStack {
//                ForEach(Bundle.allBundles, id: \.hashValue) { bundle in
//                    Text("\(URL(filePath: ".", relativeTo: bundle.resourceURL).resolvingSymlinksInPath().absoluteString)")
//                        .truncationMode(.head)
//                }
//            }
            
//            Image(decorative: "Background")
                    MeshGradient.toastPreview
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        Toggle("Show", isOn: $show)
                        Toggle("Use icon", isOn: $useIcon)
                        Toggle("Use CTA", isOn: $useCta)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                    }
                    .padding()
                }
                .toast(
                    isPresented: $show,
                    text: "Demo toast",
                    duration: .criticalAlert,
                    icon: useIcon ? Image(systemName: "hammer.fill").resizable() : nil,
                )
                .toastStyle(demoToast)
            }
            
            Tab("Foo", systemImage: "square", content: { EmptyView() })
            Tab("Bar", systemImage: "circle", content: { EmptyView() })
        }
    }
}



@available(iOS 18, *)
#Preview("Capsule") {
    ToastPreview(.capsule)
}
