// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TermPlot",
    platforms: [ // TODO remove
        .macOS(.v10_15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TermPlot",
            targets: ["TermPlot"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "SwiftLogger", url: "https://github.com/krugazor/SwiftLoggerServer", from: "1.1.1") // TODO: remove
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TermPlot",
            dependencies:
                // []
                [.product(name: "SwiftLoggerClient", package: "SwiftLogger")]
        ),
        .target(
            name: "TermPlotExe",
            dependencies: ["TermPlot"]),
        .testTarget(
            name: "TermPlotTests",
            dependencies: ["TermPlot"]),
    ]
)
