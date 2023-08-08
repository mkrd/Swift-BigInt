// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "BigNumber",
    products: [
        .library(
            name: "BigNumber",
            targets: ["BigNumber"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BigNumber",
            dependencies: []),
        .target(
            name: "MGTools",
            dependencies: ["BigNumber"]),
        .testTarget(
            name: "MGToolsTests",
            dependencies: ["MGTools"]),
        .testTarget(
            name: "BigNumberTests",
            dependencies: ["BigNumber", "MGTools"]),
        .target(
            name: "Benchmarks",
            dependencies: ["BigNumber", "MGTools"])
    ]
)
