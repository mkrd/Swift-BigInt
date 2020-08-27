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
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "BigNumberTests",
            dependencies: ["BigNumber"],
            path: "Tests"),
    ]
)
