// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PowerModeStatusBar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PowerModeCore",
            targets: ["PowerModeCore"]
        ),
        .executable(
            name: "PowerModeStatusBar",
            targets: ["PowerModeStatusBar"]
        ),
        .executable(
            name: "PowerModeCoreSmokeTests",
            targets: ["PowerModeCoreSmokeTests"]
        )
    ],
    targets: [
        .target(
            name: "PowerModeCore"
        ),
        .executableTarget(
            name: "PowerModeStatusBar",
            dependencies: ["PowerModeCore"],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit"),
                .linkedFramework("ServiceManagement")
            ]
        ),
        .executableTarget(
            name: "PowerModeCoreSmokeTests",
            dependencies: ["PowerModeCore"]
        )
    ]
)
