//
//  ProfilePageVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class ProfilePageVC: UIViewController {

    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblFamilyName: UILabel!
    @IBOutlet weak var lblCaretaker: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    @IBOutlet weak var lblMoveIn: UILabel!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var lblMorningStatus: UILabel!
    
    private lazy var imagePicker = UIImagePickerController()
    private var ivHeaderProfile: UIButton!
    private var user: User!
    
    public var resident: Resident!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ivHeaderProfile = WindowManager.setup(vc: self,
                                              title: "\(resident.firstName) \(resident.lastName)",
                                              deviceStatus: resident.deviceStatus?.status)
        setup()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebAPI.shared.disableActivity = false
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func changeProfileAction(_ sender: UIButton) {
        
        ImageManager.shared.takePhoto(view: self) { (image) in
            self.changeProfilePhoto(image: image)
        }
    }
    
    // MARK: User
    @IBAction func btnCallUser(_ sender: UIBarButtonItem) {
        if let url = URL(string: "tel://\(user.phoneNumber)"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func btnMessageUser(_ sender: UIBarButtonItem) {
        if resident.messageThreadURL.url != nil {
            WindowManager.pushToMessageThreadVC(navController: navigationController, resident: resident)
        }
    }
    
    // MARK: Family
    @IBAction func btnCallFamily(_ sender: UIBarButtonItem) {
        if let phoneNumber = user.primaryContact?.phoneNumber,
            let url = URL(string: "tel://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func btnMessageFamily(_ sender: UIBarButtonItem) {
        if let email = user.primaryContact?.email,
            let url = URL(string: "mailto://\(email)"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    // MARK: Caregiver
    @IBAction func btnCallCaregiver(_ sender: UIBarButtonItem) {
        if let phoneNumber = user.caregivers.first?.phoneNumber,
            let url = URL(string: "tel://\(phoneNumber)"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func btnMessageCaregiver(_ sender: UIBarButtonItem) {
        if let email = user.caregivers.first?.email,
            let url = URL(string: "mailto://\(email)"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    // MARK: Change Profile Photo
    func changeProfilePhoto(image: UIImage?) {
        guard let image = image else { return }
        
        WebAPI.shared.disableActivity = true
        let imageData = image.pngData()
        let key = "\(resident.firstName)\(UUID().uuidString.prefix(4))"
        let param = [PresignedRequest(key: key,
                                     contentType: "image/png",
                                     clientMethod: "put_object",
                                     requestType: "PUT")]
        
        WebAPI.shared.post(APIConst.generateSignedURL, parameter: param) { (response: [PresignedResponse]) in
            guard let url = response.first?.url else { return }
            WebAPI.shared.put(url, parameter: imageData!, completion: { (success) in
                
                WebAPI.shared.post(String(format: APIConst.profilePicSignedUrl, self.resident.id),
                                   parameter: UploadedNewPhoto(key: key),
                                   completion: { (responsePhoto: NewPhotoResponse) in
                                   
                                    SessionManager.shared.temporaryProfile = nil
                                    SessionManager.shared.refreshRequired = true
                                    WebAPI.shared.disableActivity = false
                })
            })
        }
        
        DispatchQueue.main.async {
            SessionManager.shared.temporaryProfile = TemporaryProfile(id: self.resident.id, image: image)
            self.ivProfile.image = image
            self.ivHeaderProfile.setImage(image, for: .normal)
        }
    }
    
    func setup() {
        
        WebAPI.shared.get(String(format: APIConst.resident, resident.id)) { (u: User) in
            self.user = u
            DispatchQueue.main.async {
                ImageManager.shared.downloadImage(suffix: u.profilePictureURL, view: self.ivProfile)
                ImageManager.shared.downloadImage(url: u.thumbnailURL, view: self.ivHeaderProfile)
                
                self.lblName.text  = "\(u.firstName) \(u.lastName)"
                self.title = "\(u.firstName) \(u.lastName)"
                self.lblFamilyName.text = "\(u.primaryContact?.firstName ?? "") \(u.primaryContact?.lastName ?? "")"
                self.lblCaretaker.text =  "\(u.caregivers.first?.firstName ?? "") \(u.caregivers.first?.lastName ?? "")"
                self.lblBirthday.text = u.birthDate
                self.lblMoveIn.text = u.moveInDate
                self.lblRoom.text = u.roomNo
                self.lblService.text = u.serviceType
                self.lblMorningStatus.text = u.checkInInfo.checkedBy != nil ? "Checked" : ""
            }
        }
    }

}
