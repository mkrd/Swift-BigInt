// swift-tools-version:4.2
import PackageDescription

#if os(Linux)
let deps: [Package.Dependency] = [.package(url: "https://github.com/mdaxter/CBSD.git", from: "1.0.0")]
#else
let deps: [Package.Dependency] = []
#endif

let package = Package(
    name: "BigNumber",
    products: [
        .library(
            name: "BigNumber",
            targets: ["BigNumber"]),
    ],
    dependencies: deps,
    targets: [
        .target(
            name: "BigNumber",
            dependencies: [],
            path: "Sources"),
    ]
)
