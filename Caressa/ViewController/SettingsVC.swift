//
//  SettingsVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.cornerRadius = imageView.frame.height / 2
        imageView.contentMode = .scaleAspectFit
        imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 40))
        navigationItem.leftBarButtonItem?.customView = imageView
    }
    
    @IBAction func logoutAction() {
        
        WindowManager.pushToLoginVC()
    }

}
