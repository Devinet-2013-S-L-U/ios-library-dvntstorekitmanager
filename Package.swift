// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DVNTStoreKitManager",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "DVNTStoreKitManager",
            targets: ["DVNTStoreKitManager"]),
    ],
    dependencies: [
        .package(url: "https://bitbucket.org/Devinet_Team/ios-library-dvntalertmanager", from: "1.1.2"),
    ],
    targets: [
        .target(
            name: "DVNTStoreKitManager",
            dependencies: ["DVNTAlertManager"])
    ]
)
