//
//  Facility.swift
//  Caressa
//
//  Created by Hüseyin Metin on 23.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct FacilityResponse: Codable {
    let name: String
    let numberOfResidents: Int
    let numberOfUnreadNotifications: Int
    let timezone: String
    let photoGalleryURL: String
    let mockStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case numberOfResidents = "number_of_residents"
        case numberOfUnreadNotifications = "number_of_unread_notifications"
        case timezone = "timezone"
        case photoGalleryURL = "photo_gallery_url"
        case mockStatus = "mock_status"
    }
}
