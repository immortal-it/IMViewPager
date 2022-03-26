//
//  Package.swift
//  IMViewPager
//
//  Created by immortal on 2022/3/26
//  Copyright (c) 2021 immortal. All rights reserved.
//
        
import Foundation

let package = Package(
    name: "IMViewPager",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "IMViewPager", targets: ["IMViewPager"])
    ],
    targets: [
        .target(name: "IMViewPager", path: "IMViewPager")
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
