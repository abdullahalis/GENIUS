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
    @State private var responseText = ""
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    @State private var nightMode = false
    @State private var recognizedText = ""
    @State private var isRecording = false
    
    @State private var question = ""
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    let speechSynthesizer = AVSpeechSynthesizer()
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: nightMode ? [Color.red, Color.clear] : [Color.blue, Color.clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 400
                    )
                )
                .frame(width: 2000, height: 2000)
            VStack {
                
                mainMenuItems()
                
                Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                    .font(.title)
                    .frame(width: 360)
                    .padding(24)
                    .glassBackgroundEffect()
                
                TextField("Ask Genius something", text: $prompt)
                
                Button("Ask Genius") {
                    getResponse(prompt: prompt, responseText: $responseText, speechSynthesizer: speechSynthesizer)
                      }
                Text(responseText)
                
                Button {nightMode.toggle() }label: {
                    Text("NightMode")
                        .frame(width: 200, height: 50)
                        .cornerRadius(20)
                }
                Text("\(recognizedText)")
                
            }
        }
                
    
        
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                startRecording()
            }
        }
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
    
    
    private func startRecording() {
            var isCapturingText = false
            print("recording")
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .default)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("Audio session error: \(error.localizedDescription)")
            }

            let request = SFSpeechAudioBufferRecognitionRequest()
            let inputNode = audioEngine.inputNode

            request.shouldReportPartialResults = true

            let speechRecognitionTask = speechRecognizer.recognitionTask(with: request) { (result, error) in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                    
                    if recognizedText.contains("hey genius") {
                        isCapturingText = true
                        question = ""
                    }

                    // Check for the end phrase
                    if recognizedText.contains("thank you") && isCapturingText {
                        getResponse(prompt: question, responseText: $responseText, speechSynthesizer: speechSynthesizer)
                        isCapturingText = false
                        
                    }
                    
                    

                    // Capture text between start and end phrases
                    if isCapturingText {
                        self.question += recognizedText
                    }
                    
                    // React to recognized commands here
                    if recognizedText.contains("night mode") {
                        nightMode.toggle()
                    }
                    if recognizedText.contains("clear chat") {
                        recognizedText = ""
                    }
                }

                if error != nil || result?.isFinal ?? false {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                }
            }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                request.append(buffer)
            }

            audioEngine.prepare()

            do {
                try audioEngine.start()
            } catch {
                print("Audio engine error: \(error.localizedDescription)")
            }
        }

        private func stopRecording() {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        
        private let audioEngine = AVAudioEngine()
        private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
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


