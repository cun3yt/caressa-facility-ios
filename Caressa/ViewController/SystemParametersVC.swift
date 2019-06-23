//
//  SystemParametersVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 23.05.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class SystemParametersVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtAPIBASE: UITextField!
    @IBOutlet weak var txtPusherInstanceId: UITextField!
    @IBOutlet weak var txtPusherKey: UITextField!
    @IBOutlet weak var txtPusherInterestName: UITextField!
    @IBOutlet weak var txtPusherCluster: UITextField!
    @IBOutlet weak var txtSentryDSN: UITextField!
    
    private weak var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(aNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(aNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        txtAPIBASE.text = UserSettings.shared.API_BASE
        txtPusherInstanceId.text = UserSettings.shared.PUSHER_INSTANCE_ID
        txtPusherKey.text = UserSettings.shared.PUSHER_KEY
        txtPusherInterestName.text = UserSettings.shared.PUSHER_INTEREST_NAME
        txtPusherCluster.text = UserSettings.shared.PUSHER_CLUSTER
        txtSentryDSN.text = UserSettings.shared.PUSHER_CLUSTER
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func saveAction(_ sender: Any?) {
        UserSettings.shared.API_BASE = txtAPIBASE.text
        UserSettings.shared.PUSHER_INSTANCE_ID = txtPusherInstanceId.text
        UserSettings.shared.PUSHER_KEY = txtPusherKey.text
        UserSettings.shared.PUSHER_INTEREST_NAME = txtPusherInterestName.text
        UserSettings.shared.PUSHER_CLUSTER = txtPusherCluster.text
        UserSettings.shared.SENTRY_DSN = txtSentryDSN.text
        WindowManager.showMessage(type: .success, message: "Saved. Please restart application.")
    }
}

extension SystemParametersVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtAPIBASE {
            txtPusherInstanceId.becomeFirstResponder()
        } else if textField == txtPusherInstanceId {
            txtPusherKey.becomeFirstResponder()
        } else if textField == txtPusherKey {
            txtPusherInterestName.becomeFirstResponder()
        } else if textField == txtPusherInterestName {
            txtPusherCluster.becomeFirstResponder()
        } else if textField == txtPusherCluster {
            txtSentryDSN.becomeFirstResponder()
        } else if textField == txtSentryDSN {
            txtSentryDSN.resignFirstResponder()
        }
        return true
    }
    
    @objc func keyboardWillBeHidden(aNotification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    @objc func keyboardWillShow(aNotification: NSNotification) {
        if activeField == nil { return }
        guard let userInfo = aNotification.userInfo else { return }
        guard let kbSize =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{ return }
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        var aRect: CGRect = self.view.frame
        aRect.size.height -= kbSize.height
        if let iv = activeField?.inputAccessoryView {
            aRect.size.height -= iv.frame.height
        }
        if let vcontent = self.scrollView!.subviews.first {
            let p : CGPoint = vcontent.convert(activeField!.frame.origin, from: activeField!)
            if !aRect.contains(p) {
                let fr = vcontent.convert(activeField!.bounds, from: activeField!)
                self.scrollView.scrollRectToVisible(fr, animated: true)
            }
        }
    }
}
