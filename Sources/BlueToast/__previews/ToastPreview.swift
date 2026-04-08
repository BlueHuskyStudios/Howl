//
//  ToastPreview.swift
//  
//
//  Created by Ky on 2024-02-24.
//

import SwiftUI



@available(iOS 16, *)
internal struct ToastPreview<ToastStyleKind: ToastStyle>: View {
    
    @State
    private var show = true
    
    let demoToast: () -> ToastStyleKind
    
    var body: some View {
        ZStack {
            VStack {
                ForEach(Bundle.allBundles, id: \.hashValue) { bundle in
                    Text("\(URL(filePath: ".", relativeTo: bundle.resourceURL).resolvingSymlinksInPath().absoluteString)")
                        .truncationMode(.head)
                }
            }
//            Toggle("Show", isOn: $show)
            
//            Image(decorative: "Background")
//            Image(nsImage: NSImage(cgImage: cgBackgroundImage, size: NSSize(scaling: CGSize(width: 1440, height: 1080), toFitWithin: CGSize(width: 640, height: 480), approach: .scaleProportionallyDown)))
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 640, height: 480)
//                .overlay {
//                    if show {
//                        demoToast()
//                            .body(.init(text: "Test toast",
//                                        duration: .criticalAlert,
//                                        icon: nil,
//                                        action: .init(label: "Action!", userDidInteract: null)))
////                            .animation(.bouncy, value: show)
//                    }
//                }
        }
    }
}



// MARK: - Background image data

#if DEBUG
@available(iOS 16, *)
private let cgBackgroundImage: CGImage = CGImage(jpegDataProviderSource: .init(url: URL(filePath: "../") as CFURL)!, decode: nil, shouldInterpolate: false, intent: .perceptual)!
#else
private let cgBackgroundImage: CGImage = CGImage(width: 0, height: 0, bitsPerComponent: 0, bitsPerPixel: 0, bytesPerRow: 0, space: .init(name: CGColorSpace.genericRGBLinear)!, bitmapInfo: [], provider: .init(data: Data() as CFData)!, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
#endif
