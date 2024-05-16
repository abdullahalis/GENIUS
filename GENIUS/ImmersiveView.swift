//
//  ImmersiveView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent


struct ImmersiveView: View {
    @State var scene: Entity = Entity()
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            scene = try! await Entity(named: "Immersive", in: realityKitContentBundle)
            print("Children:", scene.children)
            content.add(scene)
            
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
