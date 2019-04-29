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
        
        DispatchQueue.main.async {
            if self.indicator.isAnimating { return }
            
            var topView: UIView = UIView()
            
            if let view = UIApplication.shared.keyWindow?.rootViewController?.view {
                topView = view
            }
            
            self.bgView.frame = UIScreen.main.bounds
            self.bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            
            let aniX = Int(self.bgView.bounds.maxX / 2) - Int(self.size.width / 2)
            let aniY = Int(self.bgView.bounds.maxY / 2) - Int(self.size.height / 2)
            
            self.indicator.frame.size = self.size
            self.indicator.frame.origin = CGPoint(x: aniX, y: aniY)
            
            self.bgView.addSubview(self.indicator)
            topView.addSubview(self.bgView)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.indicator.startAnimating()
        }
    }
    
    func stopActivity() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.indicator.stopAnimating()
            self.bgView.removeFromSuperview()
            self.disableActivity = false
        }
    }
}
