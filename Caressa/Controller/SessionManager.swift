//
//  SessionManager.swift
//  Caressa
//
//  Created by Hüseyin METİN on 22.03.2019.
//  Copyright © 2018 Hüseyin METİN. All rights reserved.
//

import Foundation

class SessionManager: NSObject {
    
    static let shared: SessionManager = SessionManager()
    
    public var token: String? {
        get { return UserSettings.shared.accessToken }
        set { UserSettings.shared.accessToken = newValue }
    }
    public var refreshToken: String? {
        get { return UserSettings.shared.refreshToken }
        set { UserSettings.shared.refreshToken = newValue }
    }
    
    public var facility: FacilityResponse?
    public var activeUser: UserMe?
    
    static var appVersion: String {
        return "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).\(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)"
    }
    
    public var subscribedChannel: Bool = false
    public var calendarSyncTime: Date?
    public var refreshRequired: Bool = false {
        didSet {
            ImageManager.shared.imageCache.removeAllObjects()
        }
    }
    public var temporaryProfile: TemporaryProfile?
}
