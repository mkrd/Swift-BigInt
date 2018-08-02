// swift-tools-version:4.0

import PackageDescription

#if os(Linux)
let deps: [Package.Dependency] = [.package(url: "https://github.com/mdaxter/CBSD.git", from: "1.0.0")]
#else
let deps: [Package.Dependency] = []
#endif

let package = Package(
    name: "BigInteger",
    products: [
        .library(
            name: "BigInteger",
            targets: ["BigInteger"]),
    ],
    dependencies: deps,
    targets: [
        .target(
            name: "BigInteger",
            dependencies: []),
        .target(
            name: "Tools",
            dependencies: ["BigInteger"],
            path: "Tools"),
        .testTarget(
            name: "BigIntegerTests",
            dependencies: ["BigInteger", "Tools"]),
    ]
)
