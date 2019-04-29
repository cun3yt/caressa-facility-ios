//
//  Resident.swift
//  Caressa
//
//  Created by Hüseyin Metin on 23.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct Resident: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let roomNo: String
    var deviceStatus: DeviceStat?
    let messageThreadURL: MessageThreadURL //MessageUnion?
    let profilePicture: String?
    var checkIn: CheckInURL?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case roomNo = "room_no"
        case deviceStatus = "device_status"
        case messageThreadURL = "message_thread_url"
        case profilePicture = "profile_picture_url"
        case checkIn = "check_in_info"
    }
}

struct DeviceStat: Codable {
    let isThereDevice: Bool
    var status: DeviceStatus
    
    enum CodingKeys: String, CodingKey {
        case isThereDevice = "is_there_device"
        case status = "status"
    }
}

struct DeviceStatus: Codable {
    var isOnline: Bool?
    let statusChecked: String?
    let lastActivityTime: String?
    let isTodayCheckedIn: Bool?
    
    enum CodingKeys: String, CodingKey {
        case isOnline = "is_online"
        case statusChecked = "status_checked"
        case lastActivityTime = "last_activity_time"
        case isTodayCheckedIn = "is_today_checked_in"
    }
}

struct CheckInInfo: Codable {
    let checkedBy: String?
    let checkInTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case checkedBy = "checked_by"
        case checkInTime = "check_in_time"
    }
}

struct MessageThreadURL: Codable {
    let url: String?
}

struct CheckInURL: Codable {
    let url: String
    let checkedBy: String?
    let checkInTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case url
        case checkedBy = "checked_by"
        case checkInTime = "check_in_time"
    }
}

enum MessageUnion: Codable {
    case Class(MessageThreadURL)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(MessageThreadURL.self) {
            self = .Class(x)
            return
        }
        throw DecodingError.typeMismatch(ResidentUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MessageUnion"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .Class(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
