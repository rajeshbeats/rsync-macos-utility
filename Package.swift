// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rsync",
    platforms: [
        .macOS(.v10_15)
    ],

    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Rsync",
            targets: ["Rsync"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "Rsync",
            dependencies: [],
            resources: [.process("Scripts")]
        ),
    ]
)
