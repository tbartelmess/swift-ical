// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-ical",
    products: [
        .library(
            name: "SwiftIcal",
            targets: ["SwiftIcal"]),
    ],
    targets: [
        .target(
            name: "CLibical", cSettings: [
            .define("HAVE_CONFIG_H"),
            .define("_GNU_SOURCE", .when(platforms: [Platform.linux])),
            .define("HAVE_ENDIAN_H", .when(platforms: [Platform.linux])),
            .define("HAVE_BYTESWAP_H", .when(platforms: [Platform.linux])),
            .define("PACKAGE_DATA_DIR=\"/tmp/zoneinfo\""),
            .headerSearchPath("headers")
        ]),
        .target(
            name: "SwiftIcal",
            dependencies: ["CLibical"]
        ),
        .testTarget(
            name: "SwiftIcalTests",
            dependencies: ["SwiftIcal"]),
    ],
    cLanguageStandard: .c11

)
