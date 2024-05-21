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
                updatingTextHolder.recongnizedText = finalTranscription.lowercased()
                print(updatingTextHolder.recongnizedText)
                if updatingTextHolder.recongnizedText.contains("hey genius") {
                    self.isCapturingText = true
                    self.question = ""
                }
                if updatingTextHolder.recongnizedText.contains("record meeting") {
                    self.isCapturingMeeting = true
                }

                // Check for the end phrase
                if updatingTextHolder.recongnizedText.contains("thank you") {
                    
                    do {
                      try audioSession.setActive(false)
                    } catch let error {
                      print("error deactivating audio session after finishing recording:", error.localizedDescription)
                    }
                    if let range = updatingTextHolder.recongnizedText.range(of: "hey genius ") {
                        self.question = String(updatingTextHolder.recongnizedText[(range.upperBound...)])
                        Argo().getResponse(prompt: self.question, updatingTextHolder: updatingTextHolder, speechSynthesizer: self.speechSynthesizer)
                    }
                    print("Question: "+self.question)
                    self.isCapturingText = false
                }
                
                if updatingTextHolder.recongnizedText.contains("end meeting") {
                    
                    do {
                      try audioSession.setActive(false)
                    } catch let error {
                      print("error deactivating audio session after finishing recording:", error.localizedDescription)
                    }
                    if let range = updatingTextHolder.recongnizedText.range(of: "record meeting ") {
                        self.question = String(updatingTextHolder.recongnizedText[(range.upperBound...)])
                        Argo().getResponse(prompt: "Summarize this: " + self.question, updatingTextHolder: updatingTextHolder, speechSynthesizer: self.speechSynthesizer)
                    }
                    print("Meeting: "+self.question)
                    self.isCapturingText = true
                }

                             
                // React to recognized commands here
                if updatingTextHolder.recongnizedText.contains("night mode") {
                    updatingTextHolder.nightMode.toggle()
                    self.stopRecording()
                }
                if updatingTextHolder.recongnizedText.contains("clear chat") {
                    updatingTextHolder.recongnizedText = ""
                    self.stopRecording()
                }
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
    audioEngine.stop()
    recognitionTask?.cancel()
    audioEngine.inputNode.removeTap(onBus: 0)
  }
  
}
