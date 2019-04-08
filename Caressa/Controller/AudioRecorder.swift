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
    
    public var isRecording: Bool {
        get {
            return recorder?.isRecording ?? false
        }
    }
    
    public var delegate: AudioRecorderDelegate?
    
    init(delegate: AudioRecorderDelegate?) {
        super.init()
        
        self.delegate = delegate
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
                    recorder.record(forDuration: 3)
                    
                    print(fileName)
                    
                    //timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
                    
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
        
        //timer?.invalidate()
        return url
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
