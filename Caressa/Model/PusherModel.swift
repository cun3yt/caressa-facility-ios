//
//  PusherModel.swift
//  Caressa
//
//  Created by Hüseyin Metin on 20.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct DeviceStatusEvent: Codable {
    let user_id: Int
    let value: DeviceStatusEventValue
}

struct DeviceStatusEventValue: Codable {
    let new: Bool?
}


struct CheckInEvent: Codable {
    let user_id: Int
    let value: CheckInEventValue
}

struct CheckInEventValue: Codable {
    let status: String
    let checkedBy: String?
    let time: Date?
}
