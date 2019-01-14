// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "CI",
    products: [
        .executable(name: "swift-ci", targets: ["swift-ci"]),
        .library(name: "CI", type: .dynamic, targets: ["CI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0"),
        .package(url: "https://github.com/binarybirds/spm", from: "1.0.0"),
        .package(url: "https://github.com/binarybirds/env", from: "1.0.0"),
        .package(url: "https://github.com/binarybirds/git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "install",
            dependencies: ["SPM", "Utility"],
            path: "./Sources/install"),
        .target(
            name: "swift-ci",
            dependencies: ["CI"],
            path: "./Sources/swift-ci"),
        .target(
            name: "CI",
            dependencies: ["SPM", "Env", "Git"],
            path: "./Sources/CI"),
        .testTarget(
            name: "CITests",
            dependencies: ["CI"]),
    ]
)
