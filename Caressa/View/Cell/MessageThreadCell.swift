//
//  MessageThreadCell.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit
import AVKit

class MessageThreadCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var vAudio: UIView!
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var audioDuration: UILabel!
    
    private var url: URL?
    private var player: AVPlayer?
    private var timer: Timer?
    
    func setup(message: MessageResult) {
        lblName.text = "\(message.messageFrom?.firstName ?? "") \(message.messageFrom?.lastName ?? "")"
        if let lastMessage = message.message {
            lblContent.text = lastMessage.content.details
            lblTime.text = DateManager("d/M/yy HH:mm a").string(date: lastMessage.time)
            lblReply.text = lastMessage.reply != nil ? "Replied \(DateManager("d/M/yy HH:mm a").string(date: lastMessage.reply!.time)) Yes" : "No Reply Yet"
            lblType.text = lastMessage.messageType
            
            vAudio.isHidden = lastMessage.content.type != "Audio"
            lblContent.isHidden = !vAudio.isHidden
            lblReply.isHidden = !vAudio.isHidden
            btnStop.isHidden = true
            audioDuration.text = ""
            
            if !vAudio.isHidden {
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
            timer = nil
            btnAudio.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            if let url = url {
                
                btnAudio.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                audioDuration.text = "Loading..."
                
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
            btnStop.isHidden = true
            audioDuration.text = ""
        }
    }
    
    @objc func updateTime() {
        if let player = player?.currentItem {
            btnStop.isHidden = false
            let time = DateManager.getDateParts(seconds: player.currentTime().seconds)
            let duration = DateManager.getDateParts(seconds: player.duration.seconds)
            self.audioDuration.text = String(format: "%02d:%02d",  time.1, time.2) + " / " + String(format: "%02d:%02d",  duration.1, duration.2)
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
