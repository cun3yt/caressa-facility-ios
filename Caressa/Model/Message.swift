//
//  Message.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct MessageHeader: Codable {
    let detail: String?
    let count: Int?
    let next: String?
    let previous: String?
    let results: [MessageResult]?
    
    enum CodingKeys: String, CodingKey {
        case detail = "detail"
        case count = "count"
        case next = "next"
        case previous = "previous"
        case results = "results"
    }
}

struct MessageResult: Codable {
    let id: Int
    let resident: ResidentUnion?
    let lastMessage: MessageItem?
    let message: MessageItem?
    let mockStatus: Bool?
    let messageFrom: MessageFrom?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case resident = "resident"
        case message = "message"
        case lastMessage = "last_message"
        case mockStatus = "mock_status"
        case messageFrom = "message_from"
    }
}

struct MessageItem: Codable {
    let time: Date
    let reply: Reply?
    let content: Content
    let messageType: String
    let messageFrom: MessageFrom?
    
    enum CodingKeys: String, CodingKey {
        case time = "time"
        case reply = "reply"
        case content = "content"
        case messageType = "message_type"
        case messageFrom = "message_from"
    }
}

struct Content: Codable {
    let type: String
    let details: String
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case details = "details"
    }
}

struct Reply: Codable {
    let time: Date
    let content: String
    let requested: Bool?
    
    enum CodingKeys: String, CodingKey {
        case time = "time"
        case content = "content"
        case requested = "requested"
    }
}

struct MessageFrom: Codable {
    let lastName: String?
    let firstName: String?
    
    enum CodingKeys: String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
    }
}

enum ResidentUnion: Codable {
    case residentClass(Resident)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(Resident.self) {
            self = .residentClass(x)
            return
        }
        throw DecodingError.typeMismatch(ResidentUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ResidentUnion"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .residentClass(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

//struct ResidentClass: Codable {
//    let firstName: String
//    let lastName: String
//    let roomNo: String
//    let deviceStatus: DeviceStatus?
//    let messageThreadURL: String
//    let profilePicture: String
//    let mockStatus: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case firstName = "first_name"
//        case lastName = "last_name"
//        case roomNo = "room_no"
//        case deviceStatus = "device_status"
//        case messageThreadURL = "message_thread_url"
//        case profilePicture = "profile_picture"
//        case mockStatus = "mock_status"
//    }
//}

