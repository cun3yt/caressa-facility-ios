//
//  Facility.swift
//  Caressa
//
//  Created by Hüseyin Metin on 23.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct FacilityResponse: Codable {
    let id: Int
    let name: String
    let numberOfResidents: Int
    let timezone: String
    let photoGalleryURL: String
    let profilePicture: String
    let realTimeCommunicationChannels: RealTimeCommunicationChannels
    let featureFlags: FeatureFlags
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case numberOfResidents = "number_of_residents"
        case timezone = "timezone"
        case photoGalleryURL = "photo_gallery_url"
        case profilePicture = "profile_picture"
        case realTimeCommunicationChannels = "real_time_communication_channels"
        case featureFlags = "feature_flags"
    }
}

struct FeatureFlags: Codable {
    let morningCheckIn: Bool
    
    enum CodingKeys: String, CodingKey {
        case morningCheckIn = "morning_check_in"
    }
}

struct RealTimeCommunicationChannels: Codable {
    let checkIn: CheckIn
    let deviceStatus: CheckIn
    
    enum CodingKeys: String, CodingKey {
        case checkIn = "check-in"
        case deviceStatus = "device-status"
    }
}

struct CheckIn: Codable {
    let channel: String
    let event: String
    
    enum CodingKeys: String, CodingKey {
        case channel = "channel"
        case event = "event"
    }
}
