//
//  AmazonModel.swift
//  Caressa
//
//  Created by Hüseyin Metin on 1.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct PresignedRequest: Codable {
    let key: String
    let contentType: String
    let clientMethod: String
    let requestType: String
    
    enum CodingKeys: String, CodingKey {
        case key
        case contentType = "content-type"
        case clientMethod = "client-method"
        case requestType = "request-type"
    }
}

struct PresignedResponse: Codable {
    let url: String
}
