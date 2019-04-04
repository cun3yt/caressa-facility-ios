//
//  MessageCell.swift
//  Caressa
//
//  Created by Hüseyin Metin on 24.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit
import AVFoundation

class MessageCell: UITableViewCell {

    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var lblAudioDuration: UILabel!
    @IBOutlet weak var btnStopAudio: UIButton!
    @IBOutlet weak var deviceStatus: UIView!
    
    private var url: URL?
    private var player: AVPlayer?
    private var timer: Timer?
    
    func setup(message: MessageResult) {
        switch message.resident {
        case .residentClass(let x)? :
            lblTitle.text = "\(x.firstName) \(x.lastName)"
            ImageManager.shared.downloadImage(suffix: x.profilePicture, view: ivImage)
            
            contentView.alpha = 1.0
            if let devStat = x.deviceStatus {
                if devStat.isOnline {
                    deviceStatus.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                } else {
                    deviceStatus.backgroundColor = #colorLiteral(red: 1, green: 0.1564272642, blue: 0.18738392, alpha: 1)
                }
            } else {
                contentView.alpha = 0.4
            }
            
            
        case .string(let x)?:
            lblTitle.text = x
            ImageManager.shared.downloadImage(suffix: SessionManager.shared.facility?.photoGalleryURL, view: ivImage)
            
        case .none:
            break
        }
        if let lastMessage = message.lastMessage {
            lblBody.text = lastMessage.content.details
            lblTime.text = DateManager("HH:mm a").string(date: lastMessage.time)
            lblStatus.text = lastMessage.reply != nil ? "Replied \(DateManager("HH:mm a").string(date: lastMessage.reply!.time)) Yes" : "No Reply Yet"
            lblType.text = lastMessage.messageType
            
            audioView.isHidden = lastMessage.content.type != "Audio"
            lblBody.isHidden = !audioView.isHidden
            lblStatus.isHidden = !audioView.isHidden
            btnStopAudio.isHidden = true
            lblAudioDuration.text = ""
            
            if !audioView.isHidden {
                url = URL(string: lastMessage.content.details)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
    }

    @IBAction func btnAudioAction(_ sender: UIButton) {
        if player?.timeControlStatus == .playing {
            player?.pause()
            btnAudio.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else
            if player?.timeControlStatus == .paused {
                player?.play()
                btnAudio.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            } else {
                if let url = url {
                    
                    btnAudio.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                    lblAudioDuration.isHidden = false
                    lblAudioDuration.text = "Loading..."
                    
                    let item = AVPlayerItem(url: url)
                    player = AVPlayer(playerItem: item)
                    player?.automaticallyWaitsToMinimizeStalling = false
                    
                    player!.play()
                    player?.addObserver(self, forKeyPath: "status", options: .init(rawValue: 0), context: nil)
                }
        }
    }
    
    @IBAction func btnStop(_ sender: UIButton) {
        if player?.timeControlStatus == .playing {
            player?.pause()
            player = nil
            btnAudio.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            btnStopAudio.isHidden = true
            lblAudioDuration.text = ""
        }
    }
    
    @objc func updateTime() {
        if let player = player?.currentItem {
            btnStopAudio.isHidden = false
            let time = DateManager.getDateParts(seconds: player.currentTime().seconds)
            let duration = DateManager.getDateParts(seconds: player.duration.seconds)
            self.lblAudioDuration.text = String(format: "%02d:%02d",  time.1, time.2) + " / " + String(format: "%02d:%02d",  duration.1, duration.2)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            if player?.status == .readyToPlay {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            } else {
                
            }
        }
    }
}
