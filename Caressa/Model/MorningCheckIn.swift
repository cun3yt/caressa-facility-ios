//
//  MorningCheckIn.swift
//  Caressa
//
//  Created by Hüseyin Metin on 13.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct MorningCheckInRequest: Encodable {
    
}

struct MorningCheckInResponse: Codable {
    var staffChecked: Status
    var selfChecked: Status
    var pending: Status
    let notified: Status
    
    enum CodingKeys: String, CodingKey {
        case staffChecked = "staff-checked"
        case selfChecked = "self-checked"
        case pending = "pending"
        case notified = "notified"
    }
}

struct Status: Codable {
    let status: String
    let label: String
    var residents: [Resident]
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case label = "label"
        case residents = "residents"
    }
}

struct MorningCheckToday: Codable {
    let success: Bool
}
