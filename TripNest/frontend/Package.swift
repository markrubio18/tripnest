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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "8.10.0")),
    ],
    targets: [
        .executableTarget(
            name: "TripNest",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "TripNestTests",
            dependencies: ["TripNest"]
        ),
    ]
)
