//
//  ImmersiveView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GestureKit
import Speech



struct ImmersiveView: View {
    var updatingTextHolder: UpdatingTextHolder
    @State private var recording = false
    let speechSynthesizer = AVSpeechSynthesizer()
    
    let detector: GestureDetector
      
    init(updatingTextHolder: UpdatingTextHolder) {
            // Attempt to find the URL for the resource
            guard let handsTogetherURL = Bundle.main.url(forResource: "hands-together", withExtension: "gesturecomposer") else {
                fatalError("hands-together.gesturecomposer not found in bundle")
            }
            guard let thumbsUpURL = Bundle.main.url(forResource: "spiderman", withExtension: "gesturecomposer") else {
                fatalError("spiderman.gesturecomposer not found in bundle")
            }

            // Initialize the configuration with the URL
            let configuration = GestureDetectorConfiguration(packages: [handsTogetherURL, thumbsUpURL])
            
            // Initialize the detector with the configuration
            detector = GestureDetector(configuration: configuration)
        self.updatingTextHolder = updatingTextHolder
        }
    
    
    @State var scene: Entity = Entity()
    var body: some View {
        RealityView { content in
            scene = try! await Entity(named: "Immersive", in: realityKitContentBundle)
            content.add(scene)


        }
        .task {
            await detectGestures()
        }
        
//        RealityView { content in
//            // Add the initial RealityKit content
//            scene = try! await Entity(named: "Immersive", in: realityKitContentBundle)
//            print("Children:", scene.children)
//            content.add(scene)
//
//        }
    }
        
    private func detectGestures() async {
       do {
           for try await gesture in detector.detectedGestures {
               if let gestureDescription = gesture.description as? String {
                   print("\(gestureDescription)")
                   if !recording && gestureDescription.contains("Detected: All fingers then thumb") {
                       recording = true
                       Recorder().startRecording(updatingTextHolder: updatingTextHolder)
                       print("Recording started")
                   }
                   else if recording && gestureDescription.contains("Detected: Spider-Man") {
                       recording = false
                       // Perform any additional actions needed when recording starts
                       Recorder().stopRecording()
                        Argo().handleRecording(updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
                       updatingTextHolder.mode = "Stopped Recording"
                   }
               }
           }
       }
    }
    
    func showEntity(name:String) {
        scene.findEntity(named: name)?.isEnabled = true
    }
    
    func removeEntity(name:String) {
        scene.findEntity(named: name)?.isEnabled = true
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(updatingTextHolder: UpdatingTextHolder())
}
