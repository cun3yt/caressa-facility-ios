//
//  TimeState.swift
//  Caressa
//
//  Created by Hüseyin Metin on 27.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct TimeState: Codable {
    let timezone: String
    let currentTime: Date
    let status: String
    let statusChangeDatetime: Date
    
    enum CodingKeys: String, CodingKey {
        case timezone = "timezone"
        case currentTime = "current_time"
        case status = "status"
        case statusChangeDatetime = "status_change_datetime"
    }
}
