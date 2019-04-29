//
//  UserSettings.swift
//  Caressa
//
//  Created by Hüseyin Metin on 20.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

class UserSettings: NSObject {
    
    static let shared = UserSettings()
    private var userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults()
    }
    
    var accessToken: String? {
        get { return userDefaults.object(forKey: "accessToken") as? String }
        set { userDefaults.set(newValue, forKey: "accessToken") }
    }
    
    var refreshToken: String? {
        get { return userDefaults.object(forKey: "refreshToken") as? String }
        set { userDefaults.set(newValue, forKey: "refreshToken") }
    }
    
    var username: String? {
        get { return userDefaults.object(forKey: "username") as? String }
        set { userDefaults.set(newValue, forKey: "username") }
    }
    
    var password: String? {
        get { return userDefaults.object(forKey: "password") as? String }
        set { userDefaults.set(newValue, forKey: "password") }
    }
   
}
