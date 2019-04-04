//
//  Login.swift
//  Caressa
//
//  Created by Hüseyin Metin on 23.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct LoginRequest: Encodable {
    let grant_type: String
    let username: String
    let password: String
    let client_id: String
    let client_secret: String
    
    init(username: String, password: String) {
        self.grant_type = "password"
        self.username = username
        self.password = password
        self.client_id = "A6KaFyXMWdEAI63ysTeea2ZtDY4k5vWeVcl6xqns"
        self.client_secret = "nrhnRiWqcaEsnMBYlaoMzxvRa4lXMqPdOOlyaRC8UJBWnlnVKeKcXmGZpcVp6ggLSjxl6mZNp7cemn9dGmj2szlJ4TtMPtJ6hBd0Q9Bxq4YhnDiQebucGdJRugjzNgOK"
    }
}

struct LoginResponse: Codable {
    let error: String?
    let errorDescription: String?
    
    let accessToken: String?
    let expiresIn: Int?
    let tokenType: String?
    let scope: String?
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case scope
        case refreshToken = "refresh_token"
    }
}
