// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CatholicFastingCore",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "CatholicFastingCore", targets: ["CatholicFastingCore"]),
    ],
    targets: [
        .target(
            name: "CatholicFastingCore",
            path: "CatholicFastingApp/Models"),
        .testTarget(
            name: "CatholicFastingCoreTests",
            dependencies: ["CatholicFastingCore"],
            path: "Tests/CatholicFastingCoreTests"),
    ])
