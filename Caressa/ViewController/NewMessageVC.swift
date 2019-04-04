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
    
    private let textViewPlaceholder = "Message..."
    private var to: Resident?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
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
        sender.isSelected = !sender.isSelected
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
        if sender.isSelected {
            vTo.isUserInteractionEnabled = false
            vTo.alpha = 0.5
        }
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
    }
    
    @IBAction func audioAction(_ sender: UIButton) {
        if audioRecorder?.isRecording ?? false {
            audioRecorder?.stopRecording(success: true)
            sender.setTitle(nil, for: .normal)
            lcAudioBtnWidth.constant = 40
        } else {
            lcAudioBtnWidth.constant = 250
            sender.setTitle("Recording...", for: .normal)
            
            audioRecorder = AudioRecorder(delegate: self)
            audioRecorder!.record(fileName: (to?.firstName ?? "NoName") + UUID().uuidString.prefix(4))
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
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
        }
        return true
    }
}

extension NewMessageVC: AudioRecorderDelegate {
    func stopped() {
        btnAudio.setTitle(nil, for: .normal)
        lcAudioBtnWidth.constant = 40
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}
