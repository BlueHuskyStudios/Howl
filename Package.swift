// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BlueToast",
    
    platforms: [
        .macOS("14"),
        .iOS("17"), // 15: AttributedString; 17: .geometryGroup(): 
    ],
    
    products: [
        .library(
            name: "BlueToast",
            targets: ["BlueToast"]),
        .library(
            name: "BezelNotification",
            targets: ["BlueToast"]),
    ],
    dependencies: [
        .package(name: "CrossKitTypes",  url: "https://github.com/RougeWare/Swift-Cross-Kit-Types.git", from: "1.0.0"),
        .package(name: "FunctionTools",  url: "https://github.com/RougeWare/Swift-Function-Tools.git",  from: "2.0.0"),
        .package(name: "RectangleTools", url: "https://github.com/RougeWare/Swift-Rectangle-Tools.git", from: "2.17.1"),
//        .package(name: "SimpleLogging",  url: "https://github.com/RougeWare/Swift-Simple-Logging.git",  from: "0.5.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BlueToast",
            dependencies: [
                "CrossKitTypes",
                "FunctionTools",
                "RectangleTools",
//                "SimpleLogging",
            ]),
        
        .testTarget(
            name: "BezelNotificationTests",
            dependencies: ["BlueToast"]),
    ]
)
