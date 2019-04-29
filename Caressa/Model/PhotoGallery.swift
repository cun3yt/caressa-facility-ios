//
//  PhotoGallery.swift
//  Caressa
//
//  Created by Hüseyin Metin on 25.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct PhotoGallery: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PhotoGalleryDay]
}

struct PhotoGalleryDay: Codable {
    let day: Day
}

struct Day: Codable {
    let date: String
    let url: String
}

struct PhotoDay: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Photo]
}

struct Photo: Codable {
    let url: String
}
