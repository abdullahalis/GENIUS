//
//  ContentView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Speech

struct ContentView: View {
    
    @State private var prompt = ""
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    @State private var nightMode = false
    @State private var isRecording = false
    @State private var numberOfRects = 0
    
    @State private var question = ""
    @State private var meetingText = ""
    let speechSynthesizer = AVSpeechSynthesizer()
    @ObservedObject var updatingTextHolder = UpdatingTextHolder()
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @Environment(\.openWindow) var openWindow
    
    

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: updatingTextHolder.nightMode ? [Color.red, Color.clear] : [Color.blue, Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 400
                    )
                )
                .frame(width: 2000, height: 2000)
            VStack {
//                Button("but") {
//                    openWindow(id: "volume")
//                }
                Button("Earth") {
                        openWindow(id: "volume", value: "Earth")
                }
                Button("Mars") {
                        openWindow(id: "volume", value: "Mars")
                }
                mainMenuItems()
                
                Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                    .font(.title)
                    .frame(width: 360)
                    .padding(24)
                    .glassBackgroundEffect()
                
                TextField("Ask Genius something", text: $prompt)
                
                Button("Record") {
                    Recorder().startRecording(updatingTextHolder: updatingTextHolder)
                    //getResponse(prompt: prompt, updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
                      }
                Button("Ask Genius") {
                    Recorder().stopRecording(updatingTextHolder: updatingTextHolder)
                    //getResponse(prompt: prompt, updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
                      }
                Text(updatingTextHolder.responseText)
                
                Toggle("Show Immersive", isOn: $showImmersiveSpace)
                            .onChange(of: showImmersiveSpace) { _, newValue in
                            Task {
                                if newValue {
                                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                                    case .opened:
                                        immersiveSpaceIsShown = true
                                    case .error, .userCancelled:
                                        fallthrough
                                    @unknown default:
                                        immersiveSpaceIsShown = false
                                        showImmersiveSpace = false
                                    }
                                } else if immersiveSpaceIsShown {
                                    await dismissImmersiveSpace()
                                    immersiveSpaceIsShown = false
                                }
                            }
                        }
                Button {nightMode.toggle() }label: {
                    Text("NightMode")
                        .frame(width: 200, height: 50)
                        .cornerRadius(20)
                }
                Text("\(updatingTextHolder.recongnizedText)")
            }
        }
                
    
        
        .padding()
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                Recorder().startRecording(updatingTextHolder: updatingTextHolder)
//            }
//        }
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    };
}


#Preview(windowStyle: .automatic) {
    ContentView()
}

struct mainMenuItems: View {
    var body: some View {
        
        VStack {
            Text("Welcome to GENIUS")
                .font(.system(size: 50, weight: .medium))
            Image(systemName: "brain.head.profile.fill")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
        }
        .padding(.bottom, 40)

    }
}

class Recorder: ObservableObject {
    var isCapturingText = false;
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
                updatingTextHolder.recongnizedText = finalTranscription
                print(updatingTextHolder.recongnizedText)
                if updatingTextHolder.recongnizedText.contains("hey genius") {
                    self.isCapturingText = true
                    self.question = ""
                }

                             // Check for the end phrase
                if updatingTextHolder.recongnizedText.contains("thank you") {
                    
                    do {
                      try audioSession.setActive(false)
                    } catch let error {
                      print("error deactivating audio session after finishing recording:", error.localizedDescription)
                    }
                    getResponse(prompt: self.question, updatingTextHolder: updatingTextHolder, speechSynthesizer: self.speechSynthesizer)
                    print(updatingTextHolder.responseText)
                    self.isCapturingText = false
                                 
                    }

                // Capture text between start and end phrases
                if self.isCapturingText {
                    self.question += updatingTextHolder.recongnizedText
                }
                             
                // React to recognized commands here
                if updatingTextHolder.recongnizedText.contains("night mode") {
                    updatingTextHolder.nightMode.toggle()
                }
                if updatingTextHolder.recongnizedText.contains("clear chat") {
                    updatingTextHolder.recongnizedText = ""
                    self.stopRecording(updatingTextHolder: updatingTextHolder)
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
  
  func stopRecording(updatingTextHolder: UpdatingTextHolder) {
    audioEngine.stop()
    recognitionTask?.cancel()
    audioEngine.inputNode.removeTap(onBus: 0)
      
    //self.startRecording(updatingTextHolder: updatingTextHolder)
  }
  
}

class UpdatingTextHolder: ObservableObject {
    @Published var responseText: String = ""
    @Published var recongnizedText: String = ""
    @Published var nightMode: Bool = false
}

