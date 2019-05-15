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
    
    private var ivHeaderProfile: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ivHeaderProfile = WindowManager.setup(vc: self, title: "Settings")

        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture,
                                          view: ivHeaderProfile)
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
        guard let image = image else { return }
        
        WebAPI.shared.disableActivity = true
        let imageData = image.pngData()
        let key = "facility_\(UUID().uuidString.prefix(4))"
        let param = [PresignedRequest(key: key,
                                      contentType: "image/png",
                                      clientMethod: "put_object",
                                      requestType: "PUT")]
        
        WebAPI.shared.post(APIConst.generateSignedURL, parameter: param) { (response: [PresignedResponse]) in
            guard let url = response.first?.url else { return }
            WebAPI.shared.put(url, parameter: imageData!, completion: { (success) in
                
                WebAPI.shared.post(APIConst.facilityProfilePicture,
                                   parameter: UploadedNewPhoto(key: key),
                                   completion: { (responsePhoto: NewProfileResponse) in
                                    
                                    WebAPI.shared.disableActivity = false
                })
            })
        }
        
        DispatchQueue.main.async {
            SessionManager.shared.changedFacilityProfile = image
            self.ivFacility.image = image
            self.ivHeaderProfile.setImage(image, for: .normal)
        }
    }
}
