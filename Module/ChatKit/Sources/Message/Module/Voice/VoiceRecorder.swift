//
//  VoiceRecorder.swift
//  ChatKit
//
//  Created by chenwei on 2017/10/4.
//

import UIKit
import AVFoundation

protocol VoiceRecorderDelegate: class {
    /**
     更新进度 , 0.0 - 9.0, 浮点数
     */
    func audioRecordUpdateMetra(_ metra: Float)
    
    /**
     录音太短
     */
    //    func audioRecordTooShort()

    /**
     录音失败
     */
    //    func audioRecordFailed()
    
    /**
     取消录音
     */
    //    func audioRecordCanceled()
    
    /**
     录音完成
     
     - parameter recordTime:        录音时长
     - parameter uploadAmrData:     上传的 amr Data
     */
    func audioRecordFinish(_ filename: String, recordTime: Float)
}

class VoiceRecorder: NSObject {
    
    weak var delegate: VoiceRecorderDelegate?
    /// 最大录音时间
    let maxRecordTime: CGFloat = 60
    
    var operationQueue: OperationQueue
    
    private var startTime: CFTimeInterval! //录音开始时间
    private var endTimer: CFTimeInterval! //录音结束时间
    private var audioTimeInterval: NSNumber!
    private var isFinishRecord: Bool = true
    private var isCancelRecord: Bool = false
    
    private let recordSettings = [AVSampleRateKey: NSNumber(value: 44100.0),//声音采样率
        AVFormatIDKey: NSNumber(value: Int32(kAudioFormatLinearPCM)),//编码格式
        AVNumberOfChannelsKey: NSNumber(value: 1),//采集音轨
        AVEncoderAudioQualityKey: NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]//音频质量

    private var audioRecorder:AVAudioRecorder!
    
    var voiceName: String = {
        let random = arc4random() % 1000
        let voiceName = String(format: "%04d.wav", random)
        return voiceName
    }()
    
    lazy private var directoryURL: URL = {
        let filePath = ""
        return URL(fileURLWithPath: filePath)
    }()

    override init() {
        self.operationQueue = OperationQueue()
        super.init()
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { (result) in
            if result {
                do {
                    try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                    try self.audioRecorder = AVAudioRecorder(url: self.directoryURL,
                                                             settings: self.recordSettings)//初始化实例
                    self.audioRecorder.delegate = self
                    self.audioRecorder.prepareToRecord()//准备录音
                } catch {
                    print(error)
                }
            }
        }
    }
    
    ///开始录音
    func startRecord() {
        
        self.isCancelRecord = false
        
        guard let audioRecorder = audioRecorder else {
            return
        }
        if audioRecorder.isRecording == false {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
                
                let operation = BlockOperation()
                operation.addExecutionBlock(updateMeters)
                self.operationQueue.addOperation(operation)
                
            } catch {
                
            }
        }
    }
    
    func cancelRecord() {
        
        self.isFinishRecord = false
        self.audioRecorder.stop()
        self.audioRecorder.deleteRecording()
        self.audioRecorder = nil
        
    }
    
    ///停止录音
    func stopRecord() {
        
        self.isFinishRecord = true
        self.isCancelRecord = false
        self.endTimer = CACurrentMediaTime()
        audioRecorder?.stop()
        
        self.audioTimeInterval = NSNumber(value: NSNumber(value: self.audioRecorder.currentTime as Double).int32Value as Int32)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {

        }
        self.operationQueue.cancelAllOperations()
    }
    
    /**
     更新进度
     */
    func updateMeters() {
        guard let recorder = self.audioRecorder else { return }
        repeat {
            recorder.updateMeters()
            self.audioTimeInterval = NSNumber(value: NSNumber(value: recorder.currentTime as Double).floatValue as Float)
            let averagePower = recorder.averagePower(forChannel: 0)
            let lowPassResults = pow(10, (0.05 * averagePower)) * 10
            
            DispatchQueue.main.async(execute: { 
                self.delegate?.audioRecordUpdateMetra(lowPassResults)
            })
            //如果大于 60 ,停止录音
            if self.audioTimeInterval.int32Value > 60 {
                self.stopRecord()
            }
            
            Thread.sleep(forTimeInterval: 0.05)
        } while(recorder.isRecording)
    }
    
}

extension VoiceRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag && self.isFinishRecord {
            if let delegate = self.delegate {
                delegate.audioRecordFinish(self.voiceName, recordTime: self.audioTimeInterval.floatValue)
            }
        }
    }
    
}

