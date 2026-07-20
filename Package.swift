// swift-tools-version: 5.9
//
//  Package.swift
//  SnaplyAgent iOS SDK — binary distribution.
//
//  Ships the compiled SnaplyAgent.xcframework directly (path-based) so a private repo resolves over
//  plain git auth — no separate release-asset download (which 404s for private repos). Each SDK
//  version is a git tag on this repo whose committed xcframework is that version's build — see the
//  Releases page for the current version. The source lives in a separate private repository.
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
