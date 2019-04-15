//
//  SendMessage.swift
//  Caressa
//
//  Created by Hüseyin Metin on 5.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct SendMessageRequest: Codable {
    let to: String
    let messageType: String
    let message: Message
    let requestReply: Bool
    
    enum CodingKeys: String, CodingKey {
        case to = "to"
        case messageType = "message_type"
        case message = "message"
        case requestReply = "request_reply"
    }
}

struct SendMessageResponse: Codable {
    let detail: String?
    let id: Int?
    let content: String?
    let contentAudioFile: String?
    let isResponseExpected: Bool?
    
    enum CodingKeys: String, CodingKey {
        case detail
        case id = "id"
        case content = "content"
        case contentAudioFile = "content_audio_file"
        case isResponseExpected = "is_response_expected"
    }
}

struct Message: Codable {
    let format: enmContent
    let content: String?
    //let contentAudioFile: String?
    
    enum CodingKeys: String, CodingKey {
        case format = "format"
        case content = "content"
        //case contentAudioFile = "content_audio_file"
    }
}

enum enmContent: String, Codable {
    case audio = "audio"
    case text = "text"
}
