// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "RunestoneObservation",
    platforms: [.macOS(.v10_15), .iOS(.v12)],
    products: [
        .library(name: "RunestoneObservation", targets: [
            "RunestoneObservation"
        ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ],
    targets: [
        .target(name: "RunestoneObservation", dependencies: [
            "RunestoneObservationMacros"
        ]),
        .macro(name: "RunestoneObservationMacros", dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
        ]),
        .testTarget(name: "RunestoneObservationTests", dependencies: [
            "RunestoneObservation"
        ]),
        .testTarget(name: "RunestoneObservationMacrosTests", dependencies: [
            "RunestoneObservationMacros",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
        ])
    ]
)
