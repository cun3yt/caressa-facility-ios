//
//  NotificationDataModel.swift
//  Caressa
//
//  Created by Hüseyin Metin on 11.05.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct NotificationDataModel: Codable {
    let alert: Alert
    let badge: Int
    let payload: Payload
    
    enum CodingKeys: String, CodingKey {
        case alert = "alert"
        case badge = "badge"
        case payload = "payload"
    }
}

struct Alert: Codable {
    let title: String
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case body = "body"
    }
}

struct Payload: Codable {
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
    }
}
