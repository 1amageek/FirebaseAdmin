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
            name: "AppCheck",
            targets: ["AppCheck"]),
        .library(
            name: "Firestore",
            targets: ["Firestore"]),
        .library(
            name: "Auth",
            targets: ["Auth"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.2"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.68.0"),
        .package(url: "https://github.com/1amageek/FirebaseAPI.git", branch: "main"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.13.4"),
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.7")
    ],
    targets: [
        .target(
            name: "FirebaseApp",
            dependencies: [
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "JWTKit", package: "jwt-kit"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=targeted", .when(platforms: [.macOS, .iOS])),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES")
            ]
        ),
        .target(
            name: "AppCheck",
            dependencies: [
                "FirebaseApp",
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "JWTKit", package: "jwt-kit")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=targeted", .when(platforms: [.macOS, .iOS])),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES")
            ]),
        .target(
            name: "Firestore",
            dependencies: [
                "FirebaseApp",
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "FirestoreAPI", package: "FirebaseAPI"),
                .product(name: "JWTKit", package: "jwt-kit"),
            ],swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=targeted", .when(platforms: [.macOS, .iOS])),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES")
            ]),
        .target(
            name: "Auth",
            dependencies: [
                "FirebaseApp",
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "AnyCodable", package: "AnyCodable"),
            ],swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=targeted", .when(platforms: [.macOS, .iOS])),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES")
            ]),
        .testTarget(
            name: "AppCheckTests",
            dependencies: [
                "AppCheck",
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ]
        ),
        .testTarget(
            name: "FirestoreTests",
            dependencies: ["Firestore"],
            resources: [.copy("ServiceAccount.json")]
        ),
    ]
)
