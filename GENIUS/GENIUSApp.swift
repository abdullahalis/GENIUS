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

    var body: some SwiftUI.Scene {
        WindowGroup {
            TabView {
                ContentView().environmentObject(ConversationManager.shared)
                ChatView()
            }
        }

//        ImmersiveSpace(id: "ImmersiveSpace") {
//            ImmersiveView()
//        }
        
        WindowGroup(id: "volume", for: String.self) { $modelName in
            if let modelName {
                VolumeView(modelName: modelName)
                    .useFullGesture()
            }
            
        }.windowStyle(.volumetric)
    }
}
