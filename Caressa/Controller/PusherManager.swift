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
    
    private var deviceStatusChannel: PusherChannel!
    private var checkinChannel: PusherChannel!
    
    public var delegate: PusherManagerDelegate? {
        didSet {
            bind()
        }
    }
    
    override init() {
        super.init()
        checkinChannel = (UIApplication.shared.delegate as? AppDelegate)!.checkinChannel
        deviceStatusChannel = (UIApplication.shared.delegate as? AppDelegate)!.deviceStatusChannel
    }
    
    func bind() {
        if let event = SessionManager.shared.facility?.realTimeCommunicationChannels.deviceStatus.event {
            let _ = deviceStatusChannel.bind(eventName: event, callback: { (dic: Any?) -> Void in
                if let dic = dic as? [String : AnyObject],
                    let data = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted),
                    let deviceStatus = try? JSONManager().decoder.decode(DeviceStatusEvent.self, from: data) {
                    
                    self.delegate?.subscribed(deviceStatus: deviceStatus)
                }
            })
        }
        
        if let event = SessionManager.shared.facility?.realTimeCommunicationChannels.checkIn.event {
            let _ = checkinChannel.bind(eventName: event, callback: { (dic: Any?) -> Void in
                if let dic = dic as? [String : AnyObject],
                    let data = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted),
                    let checkin = try? JSONManager().decoder.decode(CheckInEvent.self, from: data) {
                    
                    self.delegate?.subscribed(checkIn: checkin)
                }
            })
        }
    }
}
