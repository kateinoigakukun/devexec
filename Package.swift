// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "devexec",
    platforms: [.macOS(.v10_12)],
    products: [.executable(name: "devexec", targets: ["devexec"])],
    targets: [
        .target(name: "devexec", dependencies: []),
    ]
)
