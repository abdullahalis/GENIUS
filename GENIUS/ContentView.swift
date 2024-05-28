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
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @Environment(\.openWindow) var openWindow
    
    

    var body: some View {
        NavigationStack {
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
                    mainMenuItems()
                    HStack {
                        
                        Button("Earth") {
                            openWindow(id: "volume", value: "Earth")
                        }
                        Button("Mars") {
                            openWindow(id: "volume", value: "Mars")
                        }
                    }
                    
                    TextField("Ask Genius something", text: $prompt)
                    //                    Button("Ask GENIUS") {
                    //                        Argo().getResponse(prompt: prompt, updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
                    //                    }
                    HStack {
                        Button("Record") {
                            Recorder().startRecording(updatingTextHolder: updatingTextHolder)
                        }
                        Button("Stop Recording") {
                            Recorder().stopRecording()
                            Task {
                                await Argo().handleRecording(updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
                            }
                        }
                    }
                    Text("Mode: \(updatingTextHolder.mode)")
                    Text(updatingTextHolder.responseText)
                    Text("\(updatingTextHolder.recongnizedText)")
                    HStack {
                        VStack {
                            NavigationLink("Go to Help", destination: HelpView())
                                .padding()
                        }
                        .navigationTitle("Main View")
                        VStack {
                            NavigationLink("Meetings", destination: MeetingView(updatingTextHolder: updatingTextHolder))
                                .padding()
                        }
                        .navigationTitle("Main View")
                        VStack {
                            NavigationLink("Protein", destination: ProteinView())
                                .padding()
                        }
                        .navigationTitle("Main View")
                    }
                }
            }
        }
                
    
        
        .padding()
        .onAppear {
            Task {
                await openImmersiveSpace(id: "ImmersiveSpace")
            }
        }
    };
    
    func getTextHolder() -> UpdatingTextHolder {
        return updatingTextHolder
    }
    
}




#Preview(windowStyle: .automatic) {
    ContentView(updatingTextHolder: UpdatingTextHolder())
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
    @Published var mode: String = "none"
    @Published var meetingManagers: [MeetingManager] = []
}
