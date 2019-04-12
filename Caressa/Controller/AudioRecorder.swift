//
//  AudioRecorder.swift
//  Caressa
//
//  Created by Hüseyin Metin on 4.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation
import AVKit

class AudioRecorder: NSObject {
    
    private var recorder: AVAudioRecorder!
    private var audioButton: UIButton!
    private var timer: Timer?
    private let duration: Double  = 120//sec
    
    public var isRecording: Bool {
        get {
            return recorder?.isRecording ?? false
        }
    }
    
    public var delegate: AudioRecorderDelegate?
    
    init(delegate: AudioRecorderDelegate?, button: UIButton) {
        super.init()
        self.audioButton = button
        self.delegate = delegate
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error)
        }
    }
    
    func record(fileName: String) {
        if recorder == nil {
            if let fileName = directory()?.appendingPathComponent(fileName + ".m4a") {
                
                let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                AVSampleRateKey: 12000,
                                AVNumberOfChannelsKey: 1,
                                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
                
                do {
                    recorder = try AVAudioRecorder(url: fileName, settings: settings)
                    recorder.delegate = self
                    if recorder.prepareToRecord() {
                        recorder.record(forDuration: duration)
                    }
                    
                    print(fileName)
                    
                    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                    
                } catch {
                    stopRecording(success: false)
                }
            }
        }
    }
    
    @discardableResult func stopRecording(success: Bool) ->  URL? {
        recorder?.stop()
        var url: URL?
        if let u = recorder?.url {
            url = u
        }
        recorder = nil
        
        delegate?.stopped()
        
        timer?.invalidate()
        return url
    }
    
    @objc func updateTime() {
        if timer == nil { return }
        if let rec = recorder {
            
            let time = DateManager.getDateParts(seconds: rec.currentTime)
            let dur = DateManager.getDateParts(seconds: duration)
            audioButton.setTitle("STOP " + String(format: "%02d:%02d",  time.1, time.2)
                + " / " +
                String(format: "%02d:%02d", dur.1, dur.2), for: .normal)
        }
    }
    
    func directory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stopRecording(success: false)
    }
}
