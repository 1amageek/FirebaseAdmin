// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseAdmin",
    platforms: [
        .iOS(.v16), .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "FirebaseApp",
            targets: ["FirebaseApp"]),
        .library(
            name: "Firestore",
            targets: ["Firestore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.21.0"),
        .package(url: "https://github.com/grpc/grpc-swift.git", branch: "main"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "FirebaseApp",
            dependencies: [
                .product(name: "JWTKit", package: "jwt-kit"),
            ]),
        .target(
            name: "Firestore",
            dependencies: [
                "FirebaseApp",
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "protoc-gen-swift", package: "swift-protobuf"),
                .product(name: "JWTKit", package: "jwt-kit"),
            ]),
        .testTarget(
            name: "FirestoreTests",
            dependencies: ["Firestore"],
            resources: [.copy("ServiceAccount.json")]
        ),
    ]
)
