// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "RunestoneObservationMacro",
    platforms: [.macOS(.v10_15), .iOS(.v12)],
    products: [
        .library(name: "RunestoneObservationMacro", targets: [
            "RunestoneObservationMacro"
        ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ],
    targets: [
        .target(name: "RunestoneObservationMacro", dependencies: [
            "RunestoneObservationMacros"
        ]),
        .macro(name: "RunestoneObservationMacros", dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
        ]),
        .testTarget(name: "RunestoneObservationMacrosTests", dependencies: [
            "RunestoneObservationMacros",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
        ])
    ]
)
