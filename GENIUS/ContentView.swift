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
                      }
                Button("Stop Recording") {
                    Recorder().stopRecording()
                      }
                Button("Ask GENIUS") {
                    Argo().getResponse(prompt: prompt, updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
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
                Button {updatingTextHolder.nightMode.toggle() }label: {
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
                .font(.system(size: 30, weight: .medium))
            Image(systemName: "brain.head.profile.fill")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
        }
        .padding(.bottom, 40)

    }
}

class UpdatingTextHolder: ObservableObject {
    @Published var responseText: String = ""
    @Published var recongnizedText: String = ""
    @Published var nightMode: Bool = false
}
