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

    func setup(message: MessageThreadResult) {
        lblName.text = "\(message.messageFrom.firstName) \(message.messageFrom.lastName)"
        lblContent.text = message.content.details
        lblTime.text = DateManager("d/M/yy HH:mm a").string(date: message.time)
        lblReply.text = message.reply //message.reply != nil ? "Replied \(DateManager("d/M/yy HH:mm a").string(date: message.reply!.time))" : "No Reply Yet"
        lblReplyTo.text = nil //message.reply != nil ? "Yes" : ""
        lblType.text = message.messageType
        
        vAudio.isHidden = message.content.type != "Audio"
        lblContent.isHidden = !vAudio.isHidden
        lblReply.isHidden = !vAudio.isHidden
        lblReplyTo.isHidden = !vAudio.isHidden
        btnStop.isHidden = true
        audioDuration.text = ""
        
        if !vAudio.isHidden {
            url = URL(string: message.content.details)
            player = AudioPlayer(url: url!, play: btnAudio, stop: btnStop, timeLabel: audioDuration)
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
    
    @IBAction func btnStop(_ sender: UIButton?) {
        player?.stop()
    }

}
