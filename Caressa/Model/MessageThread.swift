//
//  MessageThread.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct MessageThread: Codable {
    let resident: ResidentUnion
    let messages: Messages
}

struct Messages: Codable {
    let url: String
}

struct MessageThreadHeader: Codable {
    let detail: String?
    let count: Int?
    let next: String?
    let previous: String?
    let results: [MessageThreadResult]?
    
    enum CodingKeys: String, CodingKey {
        case detail = "detail"
        case count = "count"
        case next = "next"
        case previous = "previous"
        case results = "results"
    }
}

struct MessageThreadResult: Codable {
    let id: Int
    let time: Date
    let messageType: String
    let messageFrom: MessageFrom
    let content: Content
    let reply: String? //Reply?
    var read: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case time = "time"
        case messageType = "message_type"
        case messageFrom = "message_from"
        case content = "content"
        case reply = "reply"
        case read
    }
}

//struct MessageResult: Codable {
//    let id: Int
//    let resident: ResidentUnion?
//    let lastMessage: MessageItem?
//    let message: MessageItem?
//    let mockStatus: Bool?
//    let messageFrom: MessageFrom?
//    var read: Bool?
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case resident = "resident"
//        case message = "message"
//        case lastMessage = "last_message"
//        case mockStatus = "mock_status"
//        case messageFrom = "message_from"
//        case read
//    }
//}

//struct MessageItem: Codable {
//    let time: Date
//    let reply: Reply?
//    let content: Content
//    let messageType: String
//    let messageFrom: MessageFrom?
//
//    enum CodingKeys: String, CodingKey {
//        case time = "time"
//        case reply = "reply"
//        case content = "content"
//        case messageType = "message_type"
//        case messageFrom = "message_from"
//    }
//}

//enum ResidentUnion: Codable {
//    case residentClass(Resident)
//    case string(String)
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if let x = try? container.decode(String.self) {
//            self = .string(x)
//            return
//        }
//        if let x = try? container.decode(Resident.self) {
//            self = .residentClass(x)
//            return
//        }
//        throw DecodingError.typeMismatch(ResidentUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ResidentUnion"))
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        switch self {
//        case .residentClass(let x):
//            try container.encode(x)
//        case .string(let x):
//            try container.encode(x)
//        }
//    }
//}

