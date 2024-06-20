//
//  ContentView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GestureKit
import Speech



struct ContentView: View {
    @State private var handsTogether = false
    @State private var prompt = ""
    @State private var showImmersiveSpace = true
    @State private var immersiveSpaceIsShown = true
    @State private var nightMode = false
    @State private var isRecording = false
    
    @State private var question = ""
    @State private var meetingText = ""
    let speechSynthesizer = AVSpeechSynthesizer()
//    @ObservedObject var updatingTextHolder = UpdatingTextHolder()
    var updatingTextHolder: UpdatingTextHolder
    let frameDuration = 1.0 / 30.0 // 30 fps
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        NavigationStack {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.blue, Color.clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                    .frame(width: 2000, height: 2000)
                VStack {
                    mainMenuItems()
                        .onAppear {
                        Task {
                            
                            await openImmersiveSpace(id: "ImmersiveSpace")
                            print("opened space from content")
                            
                            
                        }
                    }
                    
                    Text("\(updatingTextHolder.mode)")
                    ScrollView {
                        Text(updatingTextHolder.recongnizedText)
                            .frame(width: 1000)
                            .multilineTextAlignment(.center)
                    }.frame(height: 60)
                    ScrollView {
                        Text(updatingTextHolder.responseText)
                            .frame(width: 1000)
                            .multilineTextAlignment(.center)
                    }.frame(height: 60)
                    Button("Video") {
                        openWindow(id: "sim", value: "https://www.w3schools.com/html/mov_bbb.mp4")
                    }
                    Button(action: {
                        updatingTextHolder.isRecording.toggle()
                        if updatingTextHolder.isRecording {
                            Recorder().startRecording(updatingTextHolder: updatingTextHolder)
                        } else {
                            Recorder().stopRecording()
                            Argo().handleRecording(updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
                        }
                    }) {
                        Image(systemName: updatingTextHolder.isRecording ? "stop.circle" : "record.circle")
                            .resizable()
                            .frame(width: 75, height: 75)
                            .foregroundColor(updatingTextHolder.isRecording ? .red : .primary)
                    }.frame(width: 75, height: 75)
                    .padding()
                    .navigationTitle("GENIUS")
                    .textFieldStyle(.roundedBorder)
                }
            }
        }
        .padding()
    };
}

#Preview(windowStyle: .automatic) {
    ContentView(updatingTextHolder: UpdatingTextHolder())
}

struct mainMenuItems: View {
    var body: some View {
        
        VStack {
            GeniusAnimView()
                .frame(width: 200, height: 200)
            
        }
    }
}



struct ImageSequenceView: View {
    let imageNames: [String]
    let frameDuration: Double
    
    @State private var currentFrame = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        Image(imageNames[currentFrame])
            .resizable()
            .scaledToFit()
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % imageNames.count
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}


class UpdatingTextHolder: ObservableObject {
    @Published var responseText: String = ""
    @Published var recongnizedText: String = ""
    @Published var isRecording: Bool = false
    @Published var mode: String = "none"
    @Published var meetingManagers: [MeetingManager] = []
}
