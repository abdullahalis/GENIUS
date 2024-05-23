//
//  RecorderModel.swift
//  GENIUS
//
//  Created by Rick Massa on 5/17/24.
//

import Foundation
import AVFAudio
import Speech


class Recorder: ObservableObject {
    var isCapturingText = false;
    var isCapturingMeeting = false;
    let audioEngine = AVAudioEngine()
    var recognitionTask: SFSpeechRecognitionTask?
    var question = ""
    @Published var recognizedText: String = ""
    @Published var nightMode: Bool = false
    @Published var responseText = ""
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    let speechSynthesizer = AVSpeechSynthesizer()
    
  
    func startRecording(updatingTextHolder: UpdatingTextHolder) {
    
        guard speechRecognizer.isAvailable else {
            print("Speech recognition is not available on this device")
            return
        }
    
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
    
        recognitionRequest.shouldReportPartialResults = true
    
        var finalTranscription = ""
    
        self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                finalTranscription = result.bestTranscription.formattedString
                print("transcribe:", finalTranscription.lowercased())
                updatingTextHolder.recongnizedText = finalTranscription.lowercased()

        }
      
        if error != nil || result?.isFinal == true {
            self.audioEngine.stop()
            inputNode.removeTap(onBus: 0)
        }
        }
    
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
            recognitionRequest.append(buffer)
        }
    
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
  
  func stopRecording() {
      let audioSession = AVAudioSession.sharedInstance()
      do {
          try audioSession.setActive(false)
          audioEngine.stop()
          recognitionTask?.cancel()
          audioEngine.inputNode.removeTap(onBus: 0)
           
      } catch let error {
          print("error deactivating audio session after finishing recording:", error.localizedDescription)
      }
      
  }
  
}
