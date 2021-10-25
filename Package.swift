// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "JNGradientLabel",

    platforms: [
        .iOS("9.0"),
        .tvOS("9.0")
    ],

    products: [
        .library(name: "JNGradientLabel", targets: ["JNGradientLabel"])
    ],

    targets: [
        .target(name: "JNGradientLabel")
    ],

    swiftLanguageVersions: [.version("5")]
)
