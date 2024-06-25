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
    let root = Entity()
    let session = ARKitSession()
    let worldInfo = WorldTrackingProvider()
    
    var body: some View {
        RealityView { content in
            try? await session.run([worldInfo])
            // Retrieve headeset position
            let pose = worldInfo.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
            let devicePos = (pose?.originFromAnchorTransform.translation ?? simd_float3(0,1,0)) + simd_float3(0, 0, -0.7)
            
            // Position graph in front of headset with devicePos
            root.position = devicePos
            content.add(root)
        }
        // Add/remove nodes when internal array updates
        .onChange(of: graph.nodes) { oldNodes, newNodes in
            let nodesToAdd = newNodes.filter {n in !oldNodes.contains(n)}
            for node in nodesToAdd {
                root.addChild(node)
            }
            
            let nodesToRemove = root.children.filter {n in !newNodes.contains(n) && !n.name.contains("->")}
            for node in nodesToRemove {
                root.removeChild(node)
            }
        }
        // Add/remove edges when internal array updates
        .onChange(of: graph.edges) { oldEdges, newEdges in
            let edgesToAdd = newEdges.filter {e in !oldEdges.contains(e)}
            for edge in edgesToAdd {
                root.addChild(edge)
            }
            
            let edgesToRemove = root.children.filter {e in !newEdges.contains(e) && e.name.contains("->")}
            for edge in edgesToRemove {
                root.removeChild(edge)
            }
        }
        // Update node positions when internal array updates
        .onChange(of: graph.positions) { oldPos, newPos in
            for (index, pos) in newPos.enumerated() {
                if graph.nodes.count == graph.positions.count {
                    let node = graph.nodes[index]
                    node.move(to: Transform(translation: pos), relativeTo: node.parent, duration: 1)
                }
            }
        }
        // Show description when object is clicked
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
        }) 
        // Enable drag gestures on protein objects
        .gesture(DragGesture().targetedToAnyEntity().onChanged { value in
            let object = value.entity
            // Ensure edges cannot be dragged
            if !object.name.contains("->") {
                object.position = value.convert(value.location3D, from: .local, to: object.parent!)
                
                // Update edges to reflect new positions of proteins
                let edges = graph.edges.filter {$0.name.contains(object.name)}
                graph.updateEdges(edgesToChange: edges)
            }
            
        })
    }
}

// Add attribute to retrieve headset position
extension simd_float4x4 {
    var translation: simd_float3 { return simd_float3(columns.3.x, columns.3.y, columns.3.z)}
}

#Preview {
    ProteinSpace()
}
