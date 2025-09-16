// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SBSObservation",
    platforms: [.macOS(.v10_15), .iOS(.v12)],
    products: [
        .library(name: "SBSObservation", targets: [
            "SBSObservation"
        ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "602.0.0")
    ],
    targets: [
        .target(name: "SBSObservation", dependencies: [
            "SBSObservationMacros"
        ]),
        .macro(name: "SBSObservationMacros", dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
        ]),
        .testTarget(name: "SBSObservationTests", dependencies: [
            "SBSObservation"
        ]),
        .testTarget(name: "SBSObservationMacrosTests", dependencies: [
            "SBSObservationMacros",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
        ])
    ]
)
