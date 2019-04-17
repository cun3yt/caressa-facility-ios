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
    @IBOutlet weak var lblRepliedTo: UILabel!
    
    private var url: URL?
    
    public var player: AudioPlayer?
    public var audioPlayerDelegate: AudioPlayerDelegate?
    
    func setup(message: MessageResult) {
        switch message.resident {
        case .residentClass(let x)? :
            lblTitle.text = "\(x.firstName) \(x.lastName)"
            ImageManager.shared.downloadImage(suffix: x.profilePicture, view: ivImage)
            
            //contentView.alpha = 1.0
            if let devStat = x.deviceStatus {
                if devStat.isOnline {
                    deviceStatus.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                } else {
                    deviceStatus.backgroundColor = #colorLiteral(red: 1, green: 0.1564272642, blue: 0.18738392, alpha: 1)
                }
            } else {
                //contentView.alpha = 0.4
            }
            
            
        case .string(let x)?:
            lblTitle.text = x
            ImageManager.shared.downloadImage(suffix: SessionManager.shared.facility?.profilePicture, view: ivImage)
            
        case .none:
            break
        }
        
        if let lastMessage = message.lastMessage {
            lblBody.text = lastMessage.content.details
            lblTime.text = DateManager("HH:mm a").string(date: lastMessage.time)
            lblStatus.text = lastMessage.reply != nil ? "Replied \(DateManager("HH:mm a").string(date: lastMessage.reply!.time))" : "No Reply Yet"
            lblRepliedTo.text = lastMessage.reply != nil ? "Yes" : ""
            lblType.text = lastMessage.messageType
            
            audioView.isHidden = lastMessage.content.type != "Audio"
            lblBody.isHidden = !audioView.isHidden
            lblStatus.isHidden = !audioView.isHidden
            lblRepliedTo.isHidden = !audioView.isHidden
            btnStopAudio.isHidden = true
            lblAudioDuration.text = ""
            
            if !audioView.isHidden {
                url = URL(string: lastMessage.content.details)
                player = AudioPlayer(url: url!, play: btnAudio, stop: btnStopAudio, timeLabel: lblAudioDuration)
            }
        }
        
        if message.read == true {
            contentView.alpha = 0.6
        }
    }

    @IBAction func btnPlayAction(_ sender: UIButton) {
        guard let player = player else { return }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    @IBAction func btnStopAction(_ sender: UIButton) {
        player?.stop()
    }

}
