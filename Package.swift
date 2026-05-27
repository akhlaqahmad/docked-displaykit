// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DisplayKit",
    platforms: [.macOS(.v14)],
    products: [.library(name: "DisplayKit", targets: ["DisplayKit"])],
    dependencies: [
        .package(url: "https://github.com/akhlaqahmad/docked-appcore.git", branch: "main")
    ],
    targets: [
        .target(name: "DisplayKit", dependencies: ["AppCore"])
    ]
)
