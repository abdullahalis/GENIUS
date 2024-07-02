//
//  Speaker.swift
//  GENIUS
//
//  Created by Abdullah Ali on 6/3/24.
//

import Foundation
import AVFoundation

//class Speaker: NSObject {
//    let synth = SpeechSynthesizer.shared.synthesizer
//
//    override init() {
//        super.init()
//        synth.delegate = self
//    }
//
//    func speak(text: String) {
//        let utterance = AVSpeechUtterance(string: text)
//        synth.speak(utterance)
//    }
//}
//
//// Used to find out when Argo is talking so we can set the animation but the AVSpeechSynthesizer doesn't work properly
//extension Speaker: AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        print("start talking")
//    }
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        print("all done")
//    }
//}


class Speaker: NSObject, ObservableObject {
    internal var errorDescription: String? = nil
    private let synthesizer: AVSpeechSynthesizer = SpeechSynthesizer.shared.synthesizer
    @Published var isSpeaking: Bool = false
    @Published var isShowingSpeakingErrorAlert: Bool = false
    
    let geniusAnimation = AnimationManager.geniusShared
    
    override init() {
        super.init()
        
        self.synthesizer.delegate = self
    }
    
    func speak(text: String) {
        do {
            geniusAnimation.startAnimation()
            print("speaking")
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            self.synthesizer.speak(utterance)
        } catch let error {
            print(error)
            self.errorDescription = error.localizedDescription
            isShowingSpeakingErrorAlert.toggle()
        }
    }
    
    internal func stop() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
}

extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("all done")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("start talking")
    }
}
