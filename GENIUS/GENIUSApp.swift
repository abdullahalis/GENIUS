//
//  GENIUSApp.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import UmainSpatialGestures
import AVFAudio


@main
struct GENIUSApp: App {
    
    @StateObject private var recorder = Recorder()
    @StateObject private var argo = Argo()

    
    // Create a shared instance of AVSpeechSynthesizer
    let synthesizer = SpeechSynthesizer.shared
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .environmentObject(recorder)
                    .environmentObject(argo)
                    
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                HelpView()
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
                ConvoView()
                    .tabItem {
                        Label("Conversation", systemImage: "message")
                    }
                MeetingView()
                    .tabItem {
                        Label("Meetings", systemImage: "person.3")
                    }
                ProteinView()
                    .tabItem {
                        Label("Protein", systemImage: "atom")
                    }
                PolarisView()
                    .tabItem {
                        Label("Polaris", systemImage: "apple.terminal")
                    }
                SimulationsView()
                    .tabItem {
                        Label("Sims", systemImage: "tv.circle")
                    }
            }
        }
//        WindowGroup {
//            ContentView()
//                .environmentObject(ConversationManager.shared)
//        }
//        WindowGroup {
//            NavView(updatingTextHolder: updatingTextHolder)
//        }
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
            .environmentObject(recorder)
            .environmentObject(argo)

        }
        
        // Window to open Sketchfab Viewer API
        WindowGroup(id: "model", for: String.self) { $uid in
            if let uid {
                ModelView(uid: uid)
            }
        }
        
        // Window to open Sketchfab Viewer API
        WindowGroup(id: "sim", for: String.self) { $url in
            if let url {
                SimView()
            }
        }
        
        WindowGroup(id: "volume", for: String.self) { $modelName in
            if let modelName {
                VolumeView(modelName: modelName)
                    .useMagnifyGesture()
                    .useRotateGesture()
            }
            
        }.windowStyle(.volumetric)
    
        WindowGroup(id: "Proteins") {
            ProteinView()
        }
        
        ImmersiveSpace(id: "ProteinSpace") {
            ProteinSpace()
        }
    }
}
