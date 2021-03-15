// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DVNTStoreKitManager",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v11),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "DVNTStoreKitManager",
            targets: ["DVNTStoreKitManager"]),
    ],
    dependencies: [
        .package(url: "https://bitbucket.org/Devinet_Team/ios-library-dvntalertmanager", from: "1.1.14"),
        .package(url: "https://github.com/crashoverride777/swifty-receipt-validator.git", from: "6.1.9")
    ],
    targets: [
        .target(
            name: "DVNTStoreKitManager",
            dependencies: ["DVNTAlertManager", "SwiftyReceiptValidator"])
    ]
)
