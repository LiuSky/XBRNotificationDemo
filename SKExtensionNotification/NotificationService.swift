//
//  NotificationService.swift
//  SKExtensionNotification
//
//  Created by xiaobin liu on 2017/11/22.
//  Copyright © 2017年 Sky. All rights reserved.
//

import UserNotifications
import AVFoundation

class NotificationService: UNNotificationServiceExtension, AVSpeechSynthesizerDelegate {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    
    private lazy var aVSpeechSynthesizer: AVSpeechSynthesizer = {
        let synth = AVSpeechSynthesizer()
        synth.delegate = self
        return synth
    }()
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        self.read(content: self.bestAttemptContent!.body)
        contentHandler(bestAttemptContent!)
    }
    
    private func read(content: String) {
        
        /// 必须要加，才能在后台播放
        let audionSession = AVAudioSession.sharedInstance()
        try? audionSession.setCategory(AVAudioSessionCategoryPlayback)
        try? audionSession.setActive(true)
        
        let utterance = AVSpeechUtterance(string: content)
        utterance.volume = 1
        utterance.pitchMultiplier = 1
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        
        let voiceType = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.voice = voiceType
        
        self.aVSpeechSynthesizer.speak(utterance)
    }
    
    /// MARK - 读完
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        debugPrint("音频阅读完")
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
    }
    
    
    override func serviceExtensionTimeWillExpire() {
        /// 停止播放
        self.aVSpeechSynthesizer.stopSpeaking(at: .immediate)
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
