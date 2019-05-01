//
//  AmazonModel.swift
//  Caressa
//
//  Created by Hüseyin Metin on 1.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

typealias PresignedMultipleRequest = [PresignedRequest]
typealias PresignedMultipleResponse = [PresignedResponse]

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
    let key: String
    let url: String
}

struct UploadedNewPhoto: Codable {
    let key: String
}

struct NewPhotoResponse: Codable {
    let detail: String?
    let message: String?
    let profilePictureURL: String?
    let thumbnailURL: String?
    
    enum CodingKeys: String, CodingKey {
        case detail
        case message
        case profilePictureURL = "profile_picture_url"
        case thumbnailURL = "thumbnail_url"
    }
}

