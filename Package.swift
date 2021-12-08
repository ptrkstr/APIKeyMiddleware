// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "APIKeyMiddleware",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "APIKeyMiddleware",
            targets: ["APIKeyMiddleware"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "APIKeyMiddleware",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ]),
        .testTarget(
            name: "APIKeyMiddlewareTests",
            dependencies: [
                "APIKeyMiddleware",
                .product(name: "XCTVapor", package: "vapor"),
            ]),
    ]
)
