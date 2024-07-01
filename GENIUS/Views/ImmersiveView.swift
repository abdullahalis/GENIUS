//
//  ImmersiveView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import ARKit
import RealityKitContent
import GestureKit
import Speech

struct ImmersiveView: View {
    @EnvironmentObject var recorder: Recorder
    @EnvironmentObject var argo: Argo
    
    var updatingTextHolder = UpdatingTextHolder.shared
    @State private var recording = false
    @State private var blasting = false
    @State private var startCount = 0;
    @State private var stopCount = 0;
    let speechSynthesizer = AVSpeechSynthesizer()
    
    let detector: GestureDetector
      
    init() {
        // Attempt to find the URL for the resource
        guard let handsTogetherURL = Bundle.main.url(forResource: "hands-together", withExtension: "gesturecomposer") else {
            fatalError("hands-together.gesturecomposer not found in bundle")
        }
        
        guard let spreadURL = Bundle.main.url(forResource: "spread", withExtension: "gesturecomposer") else {
            fatalError("spread.gesturecomposer not found in bundle")
        }

//            // Initialize the configuration with the URL
//            let configuration = GestureDetectorConfiguration(packages: [handsTogetherURL, thumbsUpURL])
    
        // Initialize the configuration with the URL
        let configuration = GestureDetectorConfiguration(packages: [handsTogetherURL, spreadURL])
        
        // Initialize the detector with the configuration
        detector = GestureDetector(configuration: configuration)
        }
    
    
    @State var scene: Entity = Entity()
    @State var headTrackedEntity: Entity = {
            let headAnchor = AnchorEntity(.head)
        headAnchor.position = [0, -0.075, -0.35]
            return headAnchor
        }()
    
    var body: some View {
        // Displays Halo HUD
        RealityView { content in
            let mesh: MeshResource = .generatePlane(width: 0.83, height: 0.6)
                    
            var material = SimpleMaterial()
            material.color = .init(tint: .white.withAlphaComponent(0.999),
                                texture: .init(try! .load(named: "halo_hud.png")))
            material.metallic = .float(1.0)
            material.roughness = .float(0.0)

            let planeEntity = ModelEntity(mesh: mesh, materials: [material])
            headTrackedEntity.addChild(planeEntity)
            
            content.add(headTrackedEntity)
        }
        .task {
            await detectGestures()
        }
    }
    
    private func detectStart(gestureWanted: String, detectedGesture: String) -> Bool {
        if detectedGesture.contains("Detected: \(gestureWanted)") {
            startCount += 1
        }
        else if (detectedGesture.contains("Reset: \(gestureWanted)")){
            startCount = 0
        }
        
        if startCount == 5 {
            startCount = 0
            return true
        }
        else {
            return false
        }
    }
    
    private func detectStop(gestureWanted: String, detectedGesture: String) -> Bool {
        if detectedGesture.contains("Reset: \(gestureWanted)") {
            return true
        }
        else {
            return false
        }
    }
        
    private func detectGestures() async {
       do {
           for try await gesture in detector.detectedGestures {
               let detectedGesture = gesture.description
               
               // Check recording gesture
               if !recording && detectStart(gestureWanted: "All fingers then thumb", detectedGesture: detectedGesture) {
                   recording = true
                   recorder.startRecording()
                   updatingTextHolder.isRecording = true
               }
               else if recording && detectStop(gestureWanted: "All fingers then thumb", detectedGesture: detectedGesture) {
                   recording = false
                   recorder.stopRecording()
                   updatingTextHolder.isRecording = false
                    argo.handleRecording()
               }
               
               // Check blaster gesture
               if !blasting && detectStart(gestureWanted: "Spread", detectedGesture: detectedGesture) {
                   blasting = true
                   //updatingTextHolder.mode = "Start blasting"
               }
               else if recording && detectStop(gestureWanted: "Spread", detectedGesture: detectedGesture) {
                   blasting = false
                   //updatingTextHolder.mode = "Stop blasting"
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
    ImmersiveView()
}
