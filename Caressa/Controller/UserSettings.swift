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
   
    var API_BASE: String? {
        get { return userDefaults.object(forKey: "API_BASE") as? String }
        set { userDefaults.set(newValue, forKey: "API_BASE") }
    }
    
    var PUSHER_INSTANCE_ID: String? {
        get { return userDefaults.object(forKey: "PUSHER_INSTANCE_ID") as? String }
        set { userDefaults.set(newValue, forKey: "PUSHER_INSTANCE_ID") }
    }
    
    var PUSHER_KEY: String? {
        get { return userDefaults.object(forKey: "PUSHER_KEY") as? String }
        set { userDefaults.set(newValue, forKey: "PUSHER_KEY") }
    }
    
    var PUSHER_INTEREST_NAME: String? {
        get { return userDefaults.object(forKey: "PUSHER_INTEREST_NAME") as? String }
        set { userDefaults.set(newValue, forKey: "PUSHER_INTEREST_NAME") }
    }
    
    var PUSHER_CLUSTER: String? {
        get { return userDefaults.object(forKey: "PUSHER_CLUSTER") as? String }
        set { userDefaults.set(newValue, forKey: "PUSHER_CLUSTER") }
    }
    
    var SENTRY_DSN: String? {
        get { return userDefaults.object(forKey: "SENTRY_DSN") as? String }
        set { userDefaults.set(newValue, forKey: "SENTRY_DSN") }
    }
}
