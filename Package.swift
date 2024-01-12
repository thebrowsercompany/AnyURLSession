// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-anyurlsession",
    products: [
        .library(
            name: "AnyURLSession",
            targets: ["AnyURLSession"]),
    ],
    targets: [
        .target(
            name: "AnyURLSession"),
        .testTarget(
            name: "AnyURLSessionTests",
            dependencies: ["AnyURLSession"]),
    ]
)
