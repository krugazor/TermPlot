// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TermPlot",
    platforms: [
        .macOS(.v10_12),
        // ok, but why would you?
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .executable(name: "term-plot", targets: ["TermPlotExe"]),
        .library(
            name: "TermPlot",
            targets: ["TermPlot"]),
    ],
    dependencies: [
         .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "TermPlot",
            dependencies: []
        ),
        .target(
            name: "TermPlotExe",
            dependencies: ["TermPlot", .product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "TermPlotTests",
            dependencies: ["TermPlot"]),
    ]
)
