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
    var updatingTextHolder: UpdatingTextHolder
    @State private var recording = false
    @State private var blasting = false
    @State private var startCount = 0;
    @State private var stopCount = 0;
    let speechSynthesizer = AVSpeechSynthesizer()
    
    let detector: GestureDetector
      
    init(updatingTextHolder: UpdatingTextHolder) {
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
        self.updatingTextHolder = updatingTextHolder
        }
    
    
    @State var scene: Entity = Entity()
    @State var headTrackedEntity: Entity = {
            let headAnchor = AnchorEntity(.head)
        headAnchor.position = [0, -0.075, -0.35]
            return headAnchor
        }()
    
    var body: some View {
        RealityView { content in
            
            let mesh: MeshResource = .generatePlane(width: 0.83, height: 0.6)
                    
            var material = SimpleMaterial()
            material.color = .init(tint: .white.withAlphaComponent(0.999),
                                texture: .init(try! .load(named: "halo_hud.png")))
            material.metallic = .float(1.0)
            material.roughness = .float(0.0)

            let planeEntity = ModelEntity(mesh: mesh, materials: [material])
//            // Load the transparent PNG image as a texture
//                    guard let imageURL = Bundle.main.url(forResource: "halo_hud", withExtension: "png"),
//                          let image = UIImage(contentsOfFile: imageURL.path),
//                          let cgImage = image.cgImage else {
//                        fatalError("Failed to load image")
//                    }
//                    
//            let texture = try! TextureResource.generate(from: cgImage, options: .init(semantic: .color))
//
//            // Create a material with the texture and enable transparency
//                   var material = UnlitMaterial()
//                  
//            material.color = MaterialColorParameter.color(.white.withAlphaComponent(0)) // Transparent white base color
//                    //material.baseColor.texture = MaterialTextureResource(texture) // Assign the texture with transparency
//
//                   material.blending = .transparent(opacity: .init(floatLiteral: 1.0))
//
//                    // Create a plane mesh with the material
//            let planeMesh = MeshResource.generatePlane(width: 0.5, height: 0.5)
//                    let planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
//
//                    // Create a box entity
//                    let boxEntity = ModelEntity(
//                        mesh: .generateBox(size: 0.1),
//                        materials: [UnlitMaterial()]
//                    )

                    // Add the plane entity and box entity to the head-tracked entity
                    //headTrackedEntity.addChild(boxEntity)
                    headTrackedEntity.addChild(planeEntity)
            
            content.add(headTrackedEntity)
                    
        }
//        RealityView { content in
//            scene = try! await Entity(named: "Immersive", in: realityKitContentBundle)
//            content.add(scene)
//
//
//        }
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
               print(detectedGesture)
               
               // Check recording gesture
               if !recording && detectStart(gestureWanted: "All fingers then thumb", detectedGesture: detectedGesture) {
                   recording = true
                   Recorder().startRecording(updatingTextHolder: updatingTextHolder)
                   updatingTextHolder.isRecording = true
               }
               else if recording && detectStop(gestureWanted: "All fingers then thumb", detectedGesture: detectedGesture) {
                   recording = false
                   Recorder().stopRecording()
                   updatingTextHolder.isRecording = false
                    Argo().handleRecording(updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
               }
               
               // Check blaster gesture
               if !blasting && detectStart(gestureWanted: "Spread", detectedGesture: detectedGesture) {
                   blasting = true
                   updatingTextHolder.mode = "Start blasting"
               }
               else if recording && detectStop(gestureWanted: "Spread", detectedGesture: detectedGesture) {
                   blasting = false
                   updatingTextHolder.mode = "Stop blasting"
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
