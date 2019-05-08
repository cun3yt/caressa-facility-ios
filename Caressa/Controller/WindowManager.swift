//
//  WindowManager.swift
//  Caressa
//
//  Created by Hüseyin METİN on 22.03.2019.
//  Copyright © 2018 Hüseyin METİN. All rights reserved.
//

import UIKit

class WindowManager: NSObject {
    
    //Screens
    class public func pushToTabBarVC() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarVC") as! UITabBarController
            let AppDel = UIApplication.shared.delegate as! AppDelegate
            AppDel.window?.rootViewController = vc
        }
    }
    
    class public func pushToLoginVC() {
        UserSettings.shared.accessToken = nil
        UserSettings.shared.refreshToken = nil
        UserSettings.shared.password = nil
        
        DispatchQueue.main.async {
            let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNC") as! UINavigationController
            let AppDel = UIApplication.shared.delegate as! AppDelegate
            AppDel.window?.rootViewController = nc
        }
    }
    
    class public func pushToResidentVC(navController: UINavigationController) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResidentVC") as! ResidentVC
        
        navController.present(vc, animated: true)
    }
    
    class public func pushToMessageThreadVC<T>(navController: UINavigationController?, resident: T) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageThreadVC") as! MessageThreadVC

        if let res = resident as? Resident {
            vc.resident = res
            vc.messageThreadUrl = res.messageThreadURL.url
        }
        else if let res = resident as? AllResidents {
            vc.messageThreadUrl = res.messageThreadURL
        }
        
//        if resident.allResidents == true {
//            vc.messageThreadUrl = resident.allResidentMTUrl
//        } else {
//            vc.messageThreadUrl = resident.messageThreadURL?.url
//        }
        
//        if let r = resident as? Resident {
//            vc.resident = r
//        }
//        if let s = resident as? AllResidents {
//            vc.allResidentId = s
//        }
        if let navController = navController {
            navController.pushViewController(vc, animated: true)
        } else {
            if let top = getTopView() {
                top.present(vc, animated: true)
            }
        }
    }
    
    class public func pushToProfileVC(navController: UINavigationController?, resident: Resident) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfilePageVC") as! ProfilePageVC
        vc.resident = resident
        if let navController = navController {
            navController.pushViewController(vc, animated: true)
        } else {
            if let top = getTopView() {
                top.present(vc, animated: true)
            }
        }
    }
    
    
    //Popups
    enum MessageTypes {
        case error
        case success
        case information
        case warning
    }
    
    class open func showMessage(type: MessageTypes, message: String, handler: (()->Void)? = nil) {
        
        DispatchQueue.main.async {
            if var topView = UIApplication.shared.keyWindow?.rootViewController {
                
                while let presentedViewController = topView.presentedViewController {
                    topView = presentedViewController
                }
                
                var errorTitle = ""
                switch type {
                case .error:
                    errorTitle = "Error"
                case .success:
                    errorTitle = "Success"
                case .information:
                    errorTitle = "Information"
                case .warning:
                    errorTitle = "Warning"
                }
                
                let alertView = UIAlertController(title: errorTitle, message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    handler?()
                })
                alertView.addAction(ok)
                topView.present(alertView, animated: true)
            }
        }
    }
    
    class open func showConfirmation(message: String, yesHandler: (() -> Void)? ) {
        DispatchQueue.main.async {
            if var topView = UIApplication.shared.keyWindow?.rootViewController {
                
                while let presentedViewController = topView.presentedViewController {
                    topView = presentedViewController
                }
                
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let yes = UIAlertAction(title: "OK", style: .default) { (_) in
                    yesHandler?()
                }
                let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(yes)
                alert.addAction(no)
                topView.present(alert, animated: true)
            }
        }
    }
    
    class open func openSafari(with url: String) {
        if let url = URL(string: url),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    public class func getTopView() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        return nil
    }
    
    public class func setup(vc: UIViewController, title: String, deviceStatus: DeviceStatus? = nil) -> UIButton {
        let headerHeight: CGFloat = 30.0 //vc.navigationController!.navigationBar.frame.height - 14
        let headerWidth = vc.navigationController!.navigationBar.frame.width - 100
        let profile = UIButton(frame: CGRect(x: 0, y: 0, width: headerHeight, height: headerHeight))
        profile.setImage(nil, for: .normal)
        profile.contentMode = .scaleAspectFit
        profile.layer.cornerRadius = headerHeight / 2
        profile.clipsToBounds = true
 
        let titleLabel = UILabel(frame: CGRect(x: 6, y: 0, width: headerWidth, height: headerHeight))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.frame.origin = CGPoint(x: profile.frame.maxX + 6, y: (headerHeight / 2) - (titleLabel.frame.height / 2))
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: vc.view.frame.width - profile.frame.width - 20, height: headerHeight))
        titleView.addSubview(profile)
        titleView.addSubview(titleLabel)
        
        //status.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        if let stat = deviceStatus {
            let status = UIView(frame: CGRect(x: profile.frame.maxX - 8, y: 0, width: 14, height: 14))
            status.cornerRadius = 7
            if let isOnline = stat.isOnline {
                status.backgroundColor = isOnline ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            } else {
                status.backgroundColor = .gray
            }
            status.tag = 999
            titleView.addSubview(status)
        }
        vc.navigationItem.titleView = titleView
        
        return profile
    }
    
    public static func repaintBarTitle(vc: UIViewController, deviceStatus: DeviceStatus? = nil) {
        DispatchQueue.main.async {
            vc.navigationItem.titleView?.frame.size.width = vc.view.frame.width - 30
            if let stat = deviceStatus {
                if let isOnline = stat.isOnline {
                    vc.navigationItem.titleView?.viewWithTag(999)?.backgroundColor = isOnline ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                } else {
                    vc.navigationItem.titleView?.viewWithTag(999)?.backgroundColor = .gray
                }
            }
        }
    }
}
