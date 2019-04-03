//
//  ProfilePageVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class ProfilePageVC: UIViewController {

    //@IBOutlet weak var lblTitle: UILabel!
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
    
    public var resident: Resident!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ivHeaderProfile = WindowManager.setup(vc: self, title: "\(resident.firstName) \(resident.lastName)")
        setup()
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func changeProfileAction(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func changeProfilePhoto(image: UIImage?) {
        guard let image = image else { return }
        
        DispatchQueue.main.async {
            ActivityManager.shared.startActivity()
        }
        
        let imageData = image.pngData()
        let param = PresignedRequest(key: "\(resident.firstName)\(UUID().uuidString.prefix(4))",
            contentType: "image/png",
            clientMethod: "put_object",
            requestType: "PUT")
        
        WebAPI.shared.post(APIConst.generateSignedURL, parameter: param) { (response: PresignedResponse) in
            WebAPI.shared.put(response.url, parameter: imageData!, completion: { (success) in
                DispatchQueue.main.async {
                    ActivityManager.shared.stopActivity()
                    
                    if success {
                        WindowManager.showMessage(type: .success, message: "Upload successfully!")
                    } else {
                        WindowManager.showMessage(type: .success, message: "Upload unsuccessfull.")
                    }
                }
            })
            
        }
    }
    
    func setup() {
        
        WebAPI.shared.get(APIConst.users.replacingOccurrences(of: "#ID#", with: "\(resident.id ?? 1)")) { (u: User) in
            DispatchQueue.main.async {
                ImageManager.shared.downloadImage(suffix: u.profilePictureURL, view: self.ivProfile)
                ImageManager.shared.downloadImage(url: u.profilePictureURL, view: self.ivHeaderProfile)
                
                self.lblName.text  = "\(u.firstName ?? "") \(u.lastName ?? "")"
                self.title = "\(u.firstName ?? "") \(u.lastName ?? "")"
                self.lblFamilyName.text = "\(u.senior?.primaryContact?.firstName ?? "") \(u.senior?.primaryContact?.lastName ?? "")"
                self.lblCaretaker.text =  "\(u.senior?.caretaker?.firstName ?? "") \(u.senior?.caretaker?.lastName ?? "")"
                self.lblBirthday.text = u.birthday
                self.lblMoveIn.text = u.moveInData
                self.lblRoom.text = u.roomNo
                self.lblService.text = u.serviceType
                self.lblMorningStatus.text = u.morningStatus
            }
        }
    }

}

extension ProfilePageVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true)
        changeProfilePhoto(image: info[.originalImage] as? UIImage)
    }
}
