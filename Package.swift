// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-parser-machine",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Parser Machine",
            targets: ["Parser Machine"]
        ),
        .library(
            name: "Parser Machine Program",
            targets: ["Parser Machine Program"]
        ),
        .library(
            name: "Parser Machine Runtime",
            targets: ["Parser Machine Runtime"]
        ),
        .library(
            name: "Parser Machine Memoization",
            targets: ["Parser Machine Memoization"]
        ),
        .library(
            name: "Parser Machine Compile",
            targets: ["Parser Machine Compile"]
        ),
        .library(
            name: "Parser Machine Combinator",
            targets: ["Parser Machine Combinator"]
        ),
        .library(
            name: "Parser Machine Parse",
            targets: ["Parser Machine Parse"]
        ),
        .library(
            name: "Parser Machine Test Support",
            targets: ["Parser Machine Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-stack.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-machine.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-checkpoint.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-cursor.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cursor-parser.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-iterator.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Parser Machine Program",
            dependencies: [
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Machine", package: "swift-machine"),
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Parser Machine Runtime",
            dependencies: [
                "Parser Machine Program",
                .product(name: "Parser", package: "swift-parser"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Machine", package: "swift-machine"),
                .product(name: "Stack", package: "swift-stack"),
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Parser Machine Memoization",
            dependencies: [
                "Parser Machine Program",
                "Parser Machine Runtime",
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Parser Machine Compile",
            dependencies: [
                "Parser Machine Program",
                "Parser Machine Runtime",
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Parser Machine Combinator",
            dependencies: [
                "Parser Machine Program",
                "Parser Machine Runtime",
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Parser Machine Parse",
            dependencies: [
                "Parser Machine Runtime",
                "Parser Machine Memoization",
                "Parser Machine Compile",
                .product(name: "Checkpoint", package: "swift-checkpoint"),
                .product(name: "Cursor", package: "swift-cursor"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),

        .target(
            name: "Parser Machine",
            dependencies: [
                "Parser Machine Program",
                "Parser Machine Runtime",
                "Parser Machine Memoization",
                "Parser Machine Compile",
                "Parser Machine Combinator",
                "Parser Machine Parse",
            ]
        ),

        .testTarget(
            name: "Parser Machine Program Tests",
            dependencies: [
                "Parser Machine Program"
            ]
        ),

        .testTarget(
            name: "Parser Machine Memoization Tests",
            dependencies: [
                "Parser Machine Memoization",
                .product(
                    name: "Tagged Test Support",
                    package: "swift-tagged"
                ),
            ]
        ),

        .testTarget(
            name: "Parser Machine Compile Tests",
            dependencies: [
                "Parser Machine Compile",
                "Parser Machine Combinator",
                .product(
                    name: "Cursor Parser Test Support",
                    package: "swift-cursor-parser"
                ),
            ]
        ),

        .testTarget(
            name: "Parser Machine Combinator Tests",
            dependencies: [
                "Parser Machine Combinator",
                "Parser Machine Parse",
                .product(
                    name: "Cursor Parser Test Support",
                    package: "swift-cursor-parser"
                ),
            ]
        ),

        .testTarget(
            name: "Parser Machine Parse Tests",
            dependencies: [
                "Parser Machine Parse",
                "Parser Machine Combinator",

                "Parser Machine Memoization",
                .product(
                    name: "Cursor Parser Test Support",
                    package: "swift-cursor-parser"
                ),
            ]
        ),

        .testTarget(
            name: "Parser Machine Equivalence Tests",
            dependencies: [
                "Parser Machine Compile",
                "Parser Machine Combinator",
                .product(
                    name: "Cursor Parser Test Support",
                    package: "swift-cursor-parser"
                ),
            ]
        ),

        .target(
            name: "Parser Machine Test Support",
            dependencies: [
                "Parser Machine",
                .product(
                    name: "Cursor Parser Test Support",
                    package: "swift-cursor-parser"
                ),
                .product(
                    name: "Tagged Test Support",
                    package: "swift-tagged"
                ),
            ],
            path: "Tests/Support"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
