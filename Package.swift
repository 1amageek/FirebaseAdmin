// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseAdmin",
    platforms: [
        .iOS(.v15), .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "FirebaseApp",
            targets: ["FirebaseApp"]),
        .library(
            name: "Firestore",
            targets: ["Firestore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.17.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.51.1"),
        .package(url: "https://github.com/1amageek/FirebaseAPI.git", branch: "main"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "FirebaseApp",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "JWTKit", package: "jwt-kit"),
            ]),
        .target(
            name: "Firestore",
            dependencies: [
                "FirebaseApp",
                .product(name: "FirestoreAPI", package: "FirebaseAPI"),
                .product(name: "JWTKit", package: "jwt-kit"),
            ]),
        .testTarget(
            name: "FirestoreTests",
            dependencies: ["Firestore"],
            resources: [.copy("ServiceAccount.json")]
        ),
    ]
)
