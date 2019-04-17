//
//  SettingsVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var ivFacility: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture,
                                          view: WindowManager.setup(vc: self, title: "Settings"))
        ImageManager.shared.downloadImage(suffix: SessionManager.shared.facility?.profilePicture,
                                          view: ivFacility)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    @IBAction func logoutAction() {
        
        WindowManager.pushToLoginVC()
    }

    @IBAction func changeProfileAction(_ sender: UIButton) {
        
        ImageManager.shared.takePhoto(view: self) { (image) in
            self.changeProfilePhoto(image: image)
        }
    }
    
    func changeProfilePhoto(image: UIImage?) {
        //guard let image = image else { return }
        
        // to be continue...
    }
}
