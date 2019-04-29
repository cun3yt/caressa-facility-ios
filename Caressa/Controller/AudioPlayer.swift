//
//  AudioPlayer.swift
//  Caressa
//
//  Created by Hüseyin Metin on 4.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation
import AVKit

class AudioPlayer: NSObject {
  
    public var player: AVPlayer = AVPlayer(playerItem: nil)
    public var delegate: AudioPlayerDelegate?
    public var isPlaying: Bool {
        get {
            return player.timeControlStatus == .playing
        }
    }
    
    private var playButton: UIButton
    private var stopButton: UIButton
    private var timeLabel: UILabel
    private var timer: Timer?
    private var url: URL
    private var playerItemContext = Int(UUID().uuidString.prefix(3))
    
    init(url: URL, play: UIButton, stop: UIButton, timeLabel: UILabel) {
        
        self.playButton = play
        self.stopButton = stop
        self.timeLabel = timeLabel
        self.url = url
        
        super.init()
    }
    
    func prepareItem() {
        if player.currentItem == nil {
            timeLabel.text = "Loading..."
            let item = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: item)
            player.automaticallyWaitsToMinimizeStalling = false
            
            item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        } else {
            startTimer()
        }
    }
    
    func play() {
        if AppDelegate.audioPlayer != nil {
            AppDelegate.audioPlayer?.pause()
        }
        
        prepareItem()
        
        AppDelegate.audioPlayer = player
        
        player.play()
        delegate?.playing()
        playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    func pause() {
        if player.timeControlStatus == .playing {
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            player.pause()
            stopTimer()
            delegate?.paused()
        }
    }
    
    func stop() {
        player.pause()
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        stopButton.isHidden = true
        timeLabel.text = ""
        stopTimer()
        delegate?.stopped()
    }
    
    @objc func updateTime() {
        if timer == nil { return }
        if let player = player.currentItem {
            
            if self.player.timeControlStatus != .playing {
                playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                stopTimer()
                delegate?.paused()
            }
            
            stopButton.isHidden = false
            let time = DateManager().getDateParts(seconds: player.currentTime().seconds)
            let duration = DateManager().getDateParts(seconds: player.duration.seconds)
            timeLabel.text = String(format: "%02d:%02d",  time.1, time.2)
                + " / " +
                String(format: "%02d:%02d",  duration.1, duration.2)
        }
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }

        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status

            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            switch status {
            case .readyToPlay: startTimer()
            case .unknown: break
            case .failed: break
            }
        }
    }
    
}
