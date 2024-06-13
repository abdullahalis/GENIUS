//
//  ProteinSpace.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 6/10/24.
//

import SwiftUI
import RealityKit
import ARKit

// Immersive Space to view protein networks
struct ProteinSpace: View {
    @ObservedObject var graph: Graph = Graph.shared
    let session = ARKitSession()
    let worldInfo = WorldTrackingProvider()
    
    var body: some View {
        RealityView { content in
            try? await session.run([worldInfo])
            // Retrieve headeset position
            let pose = worldInfo.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
            let devicePos = (pose?.originFromAnchorTransform.translation ?? simd_float3(0,0,0)) + simd_float3(0, 0, -0.7)
            
            // Position graph in front of headset with devicePos
            graph.setDevicePos(pos: devicePos)
            
        } update: { content in
            content.entities.removeAll()
            if !graph.getNodes().isEmpty && !graph.getEdges().isEmpty {
                for node in graph.getNodes() {
                    content.add(node)
                }
                
                for edge in graph.getEdges() {
                    content.add(edge)
                }
                print("Inside proteinSpace")
                print("isLoading was: ", graph.getIsLoading())
                graph.toggleIsLoading()
                print("isLoading is: ", graph.getIsLoading())
                graph.toggleIsShown()
            }
        } // Show description when object is clicked
        .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
            if let object = value.entity as? ModelEntity {
                if let descEntity = object.children.first(where: { $0.name == "descWindow"}) {
                    descEntity.isEnabled.toggle()
                    
                    // If object is an edge, highlight it in green
                    if object.name.contains("->"){
                        if descEntity.isEnabled{
                            object.model?.materials = [SimpleMaterial(color: UIColor(white: 1.0, alpha: 1.0), isMetallic: false)]
                        } else {
                            object.model?.materials = [SimpleMaterial(color: UIColor(white: 1.0, alpha: 0.5), isMetallic: false)]
                        }
                    }
                }
            }
        }) // Enable drag gestures on protein objects
        .gesture(DragGesture().targetedToAnyEntity().onChanged { value in
            let nodeObject = value.entity
            nodeObject.position = value.convert(value.location3D, from: .local, to: nodeObject.parent!)
            // Update edges to reflect new positions of proteins
            graph.updateEdges(entity: nodeObject)
        })
    }
}

// Add attribute to retrieve headset position
extension simd_float4x4 {
    var translation: simd_float3 { return simd_float3(columns.3.x, columns.3.y, columns.3.z)}
}

#Preview {
    ProteinSpace().environmentObject(Graph.shared)
}
