//
//  MessageThread.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct MessageThread: Codable {
    let resident: Resident
    let messages: Messages
    let mockStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case resident = "resident"
        case messages = "messages"
        case mockStatus = "mock_status"
    }
}

struct Messages: Codable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url"
    }
}
