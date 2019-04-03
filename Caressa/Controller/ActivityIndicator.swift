//
//  ActivityIndicator.swift
//  Caressa
//
//  Created by Hüseyin METİN on 22.03.2019.
//  Copyright © 2017 Hüseyin METİN. All rights reserved.
//

import UIKit

final class ActivityManager: NSObject {
    
    static let shared = ActivityManager()
    
    public var disableActivity: Bool = false
    
    fileprivate var size = CGSize(width: 80, height: 80)
    fileprivate let bgView = UIView()
    fileprivate var indicator = UIActivityIndicatorView(style: .whiteLarge)
    
    func startActivity() {
     
        if disableActivity { return }
        if indicator.isAnimating { return }
        
        var topView: UIView = UIView()
        
        if let view = UIApplication.shared.keyWindow?.rootViewController?.view {
            topView = view
        }
        
        bgView.frame = UIScreen.main.bounds
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let aniX = Int(bgView.bounds.maxX / 2) - Int(size.width / 2)
        let aniY = Int(bgView.bounds.maxY / 2) - Int(size.height / 2)
        
        indicator.frame.size = size
        indicator.frame.origin = CGPoint(x: aniX, y: aniY)
        
        bgView.addSubview(indicator)
        topView.addSubview(bgView)
        
        indicator.startAnimating()
    }
    
    func stopActivity() {
        indicator.stopAnimating()
        bgView.removeFromSuperview()
        disableActivity = false
    }
}
