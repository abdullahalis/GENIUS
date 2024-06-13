//
//  GENIUSApp.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import UmainSpatialGestures


@main
struct GENIUSApp: App {
    @ObservedObject var updatingTextHolder = UpdatingTextHolder()
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView(updatingTextHolder: updatingTextHolder).environmentObject(ConversationManager.shared)
        }
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(updatingTextHolder: updatingTextHolder)

        }
        
        // Window to open Sketchfab Viewer API
        WindowGroup(id: "model", for: String.self) { $uid in
            if let uid {
                ModelView(uid: uid)
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
            ProteinView(updatingTextHolder: updatingTextHolder)
        }
        
        ImmersiveSpace(id: "ProteinSpace") {
            ProteinSpace()
        }
    }
}
