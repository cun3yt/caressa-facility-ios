//
//  LoginVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 22.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblErrorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblErrorMessage.isHidden = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(false)
    }
    
    
    @IBAction func loginAction(_ sender: UIButton) {
        guard let user = txtEmail.text,
            let pass = txtPassword.text,
            !user.isEmpty, !pass.isEmpty else {
                self.lblErrorMessage.text = "Please enter the login informations"
                self.lblErrorMessage.isHidden = false
                return
        }
        
        let param = LoginRequest(username: user, password: pass)
        WebAPI.shared.post(APIConst.token, parameter: param) { (response: LoginResponse) in
            
            DispatchQueue.main.async {
                if //let errTitle = response.error,
                    let errDesc = response.errorDescription {
                    self.lblErrorMessage.text = errDesc
                    self.lblErrorMessage.isHidden = false
                    return
                }
            }
            
            guard let token = response.accessToken, let type = response.tokenType else {
                return
            }
            
            DispatchQueue.main.async {
                self.lblErrorMessage.text = nil
                self.lblErrorMessage.isHidden = true
                
            }
            
            SessionManager.shared.token = "\(type) \(token)"
            if let refresh = response.refreshToken {
                SessionManager.shared.refreshToken = "\(type) \(refresh)"
            }
            
            WindowManager.pushToTabBarVC()
        }
    }
    
    @IBAction func forgotPassAction(_ sender: UIButton) {
        WindowManager.openSafari(with: APIConst.forgotPassword)
    }
    
    @IBAction func newMemberAction(_ sender: UIButton) {
    
    }
    
    
}

