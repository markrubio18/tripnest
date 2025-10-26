// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TripNest",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "TripNest",
            targets: ["TripNest"]
        ),
    ],
    dependencies: [
        // Dependencies will be added here
    ],
    targets: [
        .executableTarget(
            name: "TripNest",
            dependencies: []
        ),
        .testTarget(
            name: "TripNestTests",
            dependencies: ["TripNest"]
        ),
    ]
)
