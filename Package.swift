// swift-tools-version: 5.9
//
//  Package.swift
//  SnaplyAgent iOS SDK — binary distribution.
//
//  Ships the compiled SnaplyAgent.xcframework directly (path-based) so a private repo resolves over
//  plain git auth — no separate release-asset download (which 404s for private repos). The source
//  lives privately in Mobile-LLC/SnaplyAgent-SDK-iOS-Dev; each version is a git tag here whose
//  committed xcframework is that version's build (updated by the Dev repo's release.sh).
//

import PackageDescription

let package = Package(
    name: "SnaplyAgent",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SnaplyAgent", targets: ["SnaplyAgent"])
    ],
    targets: [
        .binaryTarget(name: "SnaplyAgent", path: "SnaplyAgent.xcframework")
    ]
)
