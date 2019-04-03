//
//  User.swift
//  Caressa
//
//  Created by Hüseyin Metin on 1.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let profilePictureURL: String?
    let thumbnailURL: String?
    let onlineStatus: String?
    let messageThreadURL: String?
    let phoneNumber: String?
    let birthday: String?
    let moveInData: String?
    let serviceType: String?
    let morningStatus: String?
    let senior: Senior?
    let mockStatus: Bool?
    let roomNo: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePictureURL = "profile_picture_url"
        case thumbnailURL = "thumbnail_url"
        case onlineStatus = "online_status"
        case messageThreadURL = "message_thread_url"
        case phoneNumber = "phone_number"
        case birthday = "birthday:"
        case moveInData = "move_in data"
        case serviceType = "service_type"
        case morningStatus = "morning_status"
        case senior = "senior"
        case mockStatus = "mock_status"
        case roomNo = "room_no"
    }
}

struct Senior: Codable {
    let primaryContact: Caretaker?
    let caretaker: Caretaker?
    
    enum CodingKeys: String, CodingKey {
        case primaryContact = "primary_contact"
        case caretaker = "caretaker"
    }
}

struct Caretaker: Codable {
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let relationship: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case relationship = "relationship"
    }
}
