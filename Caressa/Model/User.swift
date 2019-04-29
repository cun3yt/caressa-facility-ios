//
//  User.swift
//  Caressa
//
//  Created by Hüseyin Metin on 1.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let userType: String
    let seniorLivingFacility: Int
    let phoneNumber: String
    let birthDate: String?
    let moveInDate: String?
    let serviceType: String
    let roomNo: String
    let primaryContact: Caretaker?
    let caregivers: [Caretaker]
    let thumbnailURL: String
    let deviceStatus: DeviceStatus
    let messageThreadURL: MessageThreadURL?
    let profilePictureURL: String
    let checkInInfo: CheckInInfo
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case userType = "user_type"
        case seniorLivingFacility = "senior_living_facility"
        case phoneNumber = "phone_number"
        case birthDate = "birth_date"
        case moveInDate = "move_in_date"
        case serviceType = "service_type"
        case roomNo = "room_no"
        case primaryContact = "primary_contact"
        case caregivers = "caregivers"
        case thumbnailURL = "thumbnail_url"
        case deviceStatus = "device_status"
        case messageThreadURL = "message_thread_url"
        case profilePictureURL = "profile_picture_url"
        case checkInInfo = "check_in_info"
    }
}

struct UserMe: Codable {
    let pk: Int
    let firstName: String
    let lastName: String
    let email: String
    let userType: String
    let seniorLivingFacility: Int
    let senior: Senior
    let profilePictureURL: String
    let thumbnailURL: String
    
    enum CodingKeys: String, CodingKey {
        case pk = "pk"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case userType = "user_type"
        case seniorLivingFacility = "senior_living_facility"
        case senior = "senior"
        case profilePictureURL = "profile_picture_url"
        case thumbnailURL = "thumbnail_url"
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
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case relationship = "relationship"
        case email
    }
}

struct MorningStatus: Codable {
    let status: String
    let label: String
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case label = "label"
    }
}
