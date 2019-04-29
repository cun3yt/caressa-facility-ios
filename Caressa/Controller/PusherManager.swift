//
//  PusherManager.swift
//  Caressa
//
//  Created by Hüseyin Metin on 6.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation
import PusherSwift

protocol PusherManagerDelegate {
    func subscribed(deviceStatus: DeviceStatusEvent)
    func subscribed(checkIn: CheckInEvent)
}

class PusherManager: NSObject {
    
    //static let shared = PusherManager()
    
    //private var pusher: Pusher = (UIApplication.shared.delegate as? AppDelegate)!.pusher
    private var channel: PusherChannel!
    
    public var delegate: PusherManagerDelegate? {
        didSet {
            bind()
        }
    }
    
    override init() {
        super.init()
        channel = (UIApplication.shared.delegate as? AppDelegate)!.pusherChannel
    }
    
    func bind() {
        let _ = channel.bind(eventName: "DeviceStatusEvent", callback: { (dic: Any?) -> Void in
            if let dic = dic as? [String : AnyObject],
                let data = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted),
                let deviceStatus = try? JSONManager().decoder.decode(DeviceStatusEvent.self, from: data) {
                
                self.delegate?.subscribed(deviceStatus: deviceStatus)
            }
        })
        
        
        let _ = channel.bind(eventName: "CheckInEvent", callback: { (dic: Any?) -> Void in
            if let dic = dic as? [String : AnyObject],
                let data = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted),
                let checkin = try? JSONManager().decoder.decode(CheckInEvent.self, from: data) {
                
                self.delegate?.subscribed(checkIn: checkin)
            }
        })
    }
}
