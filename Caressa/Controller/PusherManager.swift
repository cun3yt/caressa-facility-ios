//
//  PusherManager.swift
//  Caressa
//
//  Created by Hüseyin Metin on 6.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation
import PusherSwift


class PusherManager: NSObject {
    
    static let shared = PusherManager()
    
    private var pusher: Pusher!
    
    override init() {
        super.init()
        
        let options = PusherClientOptions(
            host: .cluster("us2")
        )
        
        pusher = Pusher(key: "c984c4342b09e06c02a0", options: options)
        
        pusher.connect()
        
        let channel = pusher.subscribe("my-channel")
        
        let _ = channel.bind(eventName: "my-event", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    print(message)
                }
            }
        })
        
    }
    
    func listen() {
        
    }
}
