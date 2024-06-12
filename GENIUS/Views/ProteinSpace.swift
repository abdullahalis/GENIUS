//
//  ProteinSpace.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 6/10/24.
//

import SwiftUI
import RealityKit

// Immersive Space to view protein networks
struct ProteinSpace: View {
    @EnvironmentObject var graph: Graph
    var body: some View {
        RealityView { content in
            graph.createModel()
            for node in graph.getNodes() {
                content.add(node)
            }
            for edge in graph.getEdges() {
                content.add(edge)
            }
        } // Show description when object is clicked
        .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
            if let object = value.entity as? ModelEntity {
                if let descEntity = object.children.first(where: { $0.name == "descWindow"}) {
                    descEntity.isEnabled.toggle()
                    
                    // If object is an edge, highlight it in green
                    if object.name.contains("->"){
                        if descEntity.isEnabled{
                            object.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
                        } else {
                            object.model?.materials = [SimpleMaterial(color: .white, isMetallic: false)]
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

#Preview {
    ProteinSpace().environmentObject(Graph.shared)
}
