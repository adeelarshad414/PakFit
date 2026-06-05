// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PakFitIOS",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(name: "PakFitCore", targets: ["PakFitCore"]),
        .executable(name: "PakFitApp", targets: ["PakFitApp"]),
        .executable(name: "PakFitCoreSmokeTests", targets: ["PakFitCoreSmokeTests"])
    ],
    targets: [
        .target(name: "PakFitCore"),
        .executableTarget(
            name: "PakFitApp",
            dependencies: ["PakFitCore"],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .executableTarget(
            name: "PakFitCoreSmokeTests",
            dependencies: ["PakFitCore"]
        ),
        .testTarget(
            name: "PakFitCoreTests",
            dependencies: ["PakFitCore"]
        )
    ]
)
