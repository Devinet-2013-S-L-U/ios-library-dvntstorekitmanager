// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DVNTStoreKitManager",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v12),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "DVNTStoreKitManager",
            targets: ["DVNTStoreKitManager"]),
    ],
    dependencies: [
        .package(url: "https://bitbucket.org/Devinet_Team/ios-library-dvntalertmanager", from: "1.2.9"),
        .package(url: "https://github.com/crashoverride777/swifty-receipt-validator.git", from: "6.4.0")
    ],
    targets: [
        .target(
            name: "DVNTStoreKitManager",
            dependencies: [
                .productItem(name: "DVNTAlertManager", package: "ios-library-dvntalertmanager", condition: .none),
                .productItem(name: "SwiftyReceiptValidator", package: "swifty-receipt-validator", condition: .none)
            ]
        ),
    ]
)
