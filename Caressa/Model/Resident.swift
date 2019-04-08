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
    let deviceStatus: DeviceStatus?
    let messageThreadURL: String
    let profilePicture: String?
    let mockStatus: Bool
    let checkInInfo: CheckInInfo?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case roomNo = "room_no"
        case deviceStatus = "device_status"
        case messageThreadURL = "message_thread_url"
        case profilePicture = "profile_picture"
        case mockStatus = "mock_status"
        case checkInInfo = "check_in_info"
    }
}

struct DeviceStatus: Codable {
    let isOnline: Bool
    let statusChecked: String
    let lastActivityTime: String
    let isTodayCheckedIn: Bool
    
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
