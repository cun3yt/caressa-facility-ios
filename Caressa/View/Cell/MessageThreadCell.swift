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
    @IBOutlet weak var lblReplyTo: UILabel!
    
    private var url: URL?
    
    public var player: AudioPlayer?
    public var audioPlayerDelegate: AudioPlayerDelegate?

    func setup(message: MessageResult) {
        lblName.text = "\(message.messageFrom?.firstName ?? "") \(message.messageFrom?.lastName ?? "")"
        if let lastMessage = message.message {
            lblContent.text = lastMessage.content.details
            lblTime.text = DateManager("d/M/yy HH:mm a").string(date: lastMessage.time)
            lblReply.text = lastMessage.reply != nil ? "Replied \(DateManager("d/M/yy HH:mm a").string(date: lastMessage.reply!.time))" : "No Reply Yet"
            lblReplyTo.text = lastMessage.reply != nil ? "Yes" : ""
            lblType.text = lastMessage.messageType
            
            vAudio.isHidden = lastMessage.content.type != "Audio"
            lblContent.isHidden = !vAudio.isHidden
            lblReply.isHidden = !vAudio.isHidden
            lblReplyTo.isHidden = !vAudio.isHidden
            btnStop.isHidden = true
            audioDuration.text = ""
            
            if !vAudio.isHidden {
                url = URL(string: lastMessage.content.details)
                player = AudioPlayer(url: url!, play: btnAudio, stop: btnStop, timeLabel: audioDuration)
            }
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
    
    @IBAction func btnStop(_ sender: UIButton?) {
        player?.stop()
    }

}
