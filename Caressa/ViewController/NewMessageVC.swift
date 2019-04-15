//
//  NewMessageVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

protocol NewMessageVCDelegate {
    func selectResident(resident: Resident)
}

class NewMessageVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ivProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRoomNo: UILabel!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnBroadcast: UIButton!
    @IBOutlet weak var btnAnnounce: UIButton!
    @IBOutlet weak var btnAllResidents: UIButton!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var btnRequest: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var vTo: UIView!
    @IBOutlet weak var lcAudioBtnWidth: NSLayoutConstraint!
    
    private var audioRecorder: AudioRecorder?
    private var sendAudio: Bool = false
    private var audioURL: URL?
    private let textViewPlaceholder = "Message..."
    private var to: Resident?

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        self.view.addGestureRecognizer(tap)
        
        setup()
        registerForKeyboardNotifications()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let searchVC = segue.destination as? SearchVC {
            searchVC.delegate = self
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
 
    @IBAction func typeAction(_ sender: UIButton) {
        sender.isSelected = true
        switch sender {
        case btnMessage:
            if sender.isSelected {
                btnBroadcast.isSelected = false
                btnAnnounce.isSelected = false
            }
            
        case btnBroadcast:
            if sender.isSelected {
                btnMessage.isSelected = false
                btnAnnounce.isSelected = false
            }
            
        case btnAnnounce:
            if sender.isSelected {
                btnBroadcast.isSelected = false
                btnMessage.isSelected = false
            }
        default: break
        }
    }
    
    @IBAction func btnAllAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        vTo.isUserInteractionEnabled = !sender.isSelected
        vTo.alpha = sender.isSelected ? 0.5 : 1.0
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        send()
    }
    
    @IBAction func requestAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func audioAction(_ sender: UIButton) {
        if sendAudio {
            sendAudio = false
            sender.setTitle(nil, for: .normal)
            lcAudioBtnWidth.constant = 40
            if let audio = self.audioURL {
                uploadAudio(filename: audio)
            }
        } else if audioRecorder?.isRecording ?? false {
            audioURL = audioRecorder?.stopRecording(success: true)
            sendAudio = true
            sender.setTitle("Send Audio", for: .normal)
        } else {
            lcAudioBtnWidth.constant = 250
            sender.setTitle("Stop 00:00 / 02:00", for: .normal)
            
            audioRecorder = AudioRecorder(delegate: self, button: sender)
            audioRecorder!.record(fileName: (to?.firstName ?? "NoName") + UUID().uuidString.prefix(4))
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func send(uploaded url: String? = nil) {
        var receiver: String = ""
        if btnAllResidents.isSelected {
            receiver = "all-residents"
        } else {
            if let to = to {
                receiver = "\(to.id)"
            }
        }
        
        guard let text = txtMessage.text, !receiver.isEmpty else { return }
        
        var messageType = "Message"
        if btnBroadcast.isSelected { messageType = "Broadcast" }
        if btnAnnounce.isSelected { messageType = "Announcement" }
        
        var message = Message(format: .text, content: text)
        if let key = url?.split(separator: "/").last {
           message = Message(format: .audio, content: String(key))
        }
        
        let param = SendMessageRequest(to: receiver, messageType: messageType, message: message, requestReply: btnRequest.isSelected)
        
        WebAPI.shared.post(APIConst.message, parameter: param) { (response: SendMessageResponse) in
            
            if let detail = response.detail {
                WindowManager.showMessage(type: .error, message: detail)
            } else {
                WindowManager.showMessage(type: .success, message: "Message Sent!")
            }
            
        }
    }
    
    func uploadAudio(filename: URL) {
        guard let data = try? Data(contentsOf: filename) else { return }
        
        let key = "\(filename.lastPathComponent)\(UUID().uuidString.prefix(4))"
        let param = PresignedRequest(key: key,
                                     contentType: "audio/mpeg",
                                     clientMethod: "put_object",
                                     requestType: "PUT")
        
        WebAPI.shared.post(APIConst.generateSignedURL, parameter: param) { (response: PresignedResponse) in
            
            WebAPI.shared.put(response.url, parameter: data, completion: { (success) in
                
                DispatchQueue.main.async {
                    self.send(uploaded: response.url)
                }
            })
        }
    }
    
    func setup() {
        btnMessage.isSelected = true
        btnMessage.setImage(#imageLiteral(resourceName: "radio_checked"), for: .selected)
        btnMessage.setImage(#imageLiteral(resourceName: "radio_unchecked"), for: .normal)
        btnBroadcast.setImage(#imageLiteral(resourceName: "radio_checked"), for: .selected)
        btnBroadcast.setImage(#imageLiteral(resourceName: "radio_unchecked"), for: .normal)
        btnAnnounce.setImage(#imageLiteral(resourceName: "radio_checked"), for: .selected)
        btnAnnounce.setImage(#imageLiteral(resourceName: "radio_unchecked"), for: .normal)
        btnAllResidents.setImage(#imageLiteral(resourceName: "check_square"), for: .selected)
        btnAllResidents.setImage(#imageLiteral(resourceName: "uncheck_square"), for: .normal)
        btnRequest.setImage(#imageLiteral(resourceName: "check_square"), for: .selected)
        btnRequest.setImage(#imageLiteral(resourceName: "uncheck_square"), for: .normal)
    }
    
    func refresh() {
        guard let to = to else { return }
        ImageManager.shared.downloadImage(suffix: to.profilePicture, view: ivProfile)
        lblName.text = "\(to.firstName) \(to.lastName)"
        lblRoomNo.text = "Room No # \(to.roomNo)"
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func endEditing() {
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let rect: CGRect = info[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        let kbSize = rect.size
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbSize.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
    }
    
    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension NewMessageVC: NewMessageVCDelegate {
    func selectResident(resident: Resident) {
        to = resident
        refresh()
    }
}

extension NewMessageVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == textViewPlaceholder {
            textView.text = nil
            textView.textColor = .black
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholder
            textView.textColor = .lightGray
        }
    }
}

extension NewMessageVC: AudioRecorderDelegate {
    func stopped() {
        sendAudio = true
        btnAudio.setTitle("Send Audio", for: .normal)
        //lcAudioBtnWidth.constant = 40
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}
