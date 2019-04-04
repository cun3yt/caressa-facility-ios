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
    
    public var token: String?
    public var refreshToken: String?
    
    public var facility: FacilityResponse?
    
    static var appVersion: String {
        return "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).\(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)"
    }
    
}
