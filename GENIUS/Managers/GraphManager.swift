//
//  GraphManager.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 6/12/24.
//

import SwiftUI
import RealityKit

// Class to model protein graph objects
class Graph: ObservableObject {
    private var proteins: [Protein] = []
    private var interactions: [Interaction] = []
    private var nodes: [ModelEntity] = []
    private var edges: [ModelEntity] = []
    private var layout: GraphLayout = FRA91()
    
    // Declare singleton instance of Graph
    static let shared = Graph()
    private init() { }
    
    func setProteins(p: [Protein]) {self.proteins = p}
    func setInteractions(i: [Interaction]) {self.interactions = i}
    func getNodes() -> [ModelEntity] {return self.nodes}
    func getEdges() -> [ModelEntity] {return self.edges}
        
    func createModel() {
        createNodes()
        createEdges()
    }
    
    private func createNodes() {
        let colors: [UIColor] = [.black, .blue, .brown, .cyan, .darkGray, .gray, .green, .lightGray, .magenta, .orange, .purple, .red, .white, .yellow]
            
        // Create a template entity for protein descriptions
        let descTemplate = ModelEntity(mesh: MeshResource.generateText(""),
                                       materials: [UnlitMaterial(color: .black)])
        descTemplate.position = SIMD3<Float>(-0.07, -0.045, 0.000001)
        descTemplate.name = "desc"
            
        let window = MeshResource.generatePlane(width: 0.15, height: 0.1, cornerRadius: 0.01)
        let windowTemplate = ModelEntity(mesh: window, materials: [UnlitMaterial(color: .white)])
        windowTemplate.position = SIMD3<Float>(0.09, 0, 0)
        windowTemplate.name = "descWindow"
        windowTemplate.addChild(descTemplate)
        windowTemplate.isEnabled = false
            
        // Create entities for proteins
        for p in proteins {
            let sphere = MeshResource.generateSphere(radius: 0.01)
            let sphereMaterial = SimpleMaterial(color: colors.randomElement()!, isMetallic: false)
            let proteinObject = ModelEntity(mesh: sphere, materials: [sphereMaterial])
                
            // Assign random position to each protein within the bounding box of parent window
            // Bounds configured based on default window size
            proteinObject.position = SIMD3<Float>(Float.random(in: -0.8 ... 0.8),
                                                  Float.random(in: 1 ... 2),
                                                  Float.random(in: -1 ... -0.1))
                
            proteinObject.name = p.getPreferredName()
                
            // Set interactivity
            proteinObject.components.set(HoverEffectComponent())
            proteinObject.components.set(InputTargetComponent())
            proteinObject.generateCollisionShapes(recursive: true)
            
            // Add protein name
            let label = MeshResource.generateText(p.getPreferredName(),
                                                  extrusionDepth: 0,
                                                  font: .systemFont(ofSize: 0.01),
                                                  alignment: .left)
            
            let labelEntity = ModelEntity(mesh: label, materials: [UnlitMaterial(color: .white)])
            labelEntity.position = SIMD3<Float>(-0.015, 0.01, 0)
            labelEntity.name = "label"
                
            // Clone template and replace mesh
            let windowEntity = windowTemplate.clone(recursive: true)
            if let descEntity = windowEntity.children.first as? ModelEntity {
                let newMesh = MeshResource.generateText(p.getAnnotation(),
                                                        extrusionDepth: 0,
                                                        font: .systemFont(ofSize: 0.008),
                                                        containerFrame: CGRect(x: 0, y: 0,
                                                                               width: 0.14,
                                                                               height: 0.09),
                                                        alignment: .left,
                                                        lineBreakMode: .byWordWrapping)
                descEntity.model?.mesh = newMesh
            }
                
            // Add children entites to proteinObject
            proteinObject.addChild(windowEntity)
            proteinObject.addChild(labelEntity)
                
            nodes.append(proteinObject)
        }
    }
    
    private func createEdges() {
        // Create a template entity for edge descriptions
        let descTemplate = ModelEntity(mesh: MeshResource.generateText(""),
                                       materials: [UnlitMaterial(color: .black)])
        descTemplate.position = SIMD3<Float>(-0.07, -0.045, 0.000001)
        descTemplate.name = "desc"
            
        let window = MeshResource.generatePlane(width: 0.17, height: 0.115, cornerRadius: 0.01)
        let windowTemplate = ModelEntity(mesh: window, materials: [UnlitMaterial(color: .white)])
        windowTemplate.position = SIMD3<Float>(0.1, 0, 0)
        windowTemplate.name = "descWindow"
        windowTemplate.addChild(descTemplate)
        windowTemplate.isEnabled = false
            
        // Create entities for edges
        for i in interactions {
                
            // Retrieve proteins
            let p1 = nodes.first(where: { $0.name == i.getProteinA()})
            let p2 = nodes.first(where: { $0.name == i.getProteinB()})
                
            let startPos = p1?.position ?? SIMD3(0, 0, 0)
            let endPos = p2?.position ?? SIMD3(1, 1, 1)
            let midPos = (startPos + endPos) / 2
                
            // Calculate orientation and length of edge
            let dist = simd_distance(startPos, endPos)
            let dir = endPos - startPos
            let rotation = simd_quatf(from: [0, 1, 0], to: simd_normalize(dir))
            let line = MeshResource.generateCylinder(height: dist, radius: 0.001)
            
            let lineMaterial = SimpleMaterial(color: .white, isMetallic: false)
            let lineEntity = ModelEntity(mesh: line, materials: [lineMaterial])
            lineEntity.position = midPos
            lineEntity.orientation = rotation
            lineEntity.name = (p1?.name ?? "Unknown") + " -> " + (p2?.name ?? "Unknown")
                
            // Set interactivity
            lineEntity.components.set(HoverEffectComponent())
            lineEntity.components.set(InputTargetComponent())
            lineEntity.generateCollisionShapes(recursive: true)
                
            // Clone template and replace mesh
            let edgeDescString = """
                \(i.getProteinA()) -> \(i.getProteinB())
                
                Combined score:                       \(String(format: "%.2f", i.getScore()))
                Gene neighborhood score:        \(String(format: "%.2f", i.getNScore()))
                Gene fusion score:                    \(String(format: "%.2f", i.getFScore()))
                Phylogenetic profile score:       \(String(format: "%.2f", i.getPScore()))
                Coexpression score:                 \(String(format: "%.2f", i.getAScore()))
                Experimental score:                  \(String(format: "%.2f", i.getEScore()))
                Database score:                       \(String(format: "%.2f", i.getDScore()))
                Textmining score:                     \(String(format: "%.2f", i.getTScore()))
            """
            let windowEntity = windowTemplate.clone(recursive: true)
            if let descEntity = windowEntity.children.first as? ModelEntity {
                let newMesh = MeshResource.generateText(edgeDescString,
                                                        extrusionDepth: 0,
                                                        font: .systemFont(ofSize: 0.008),
                                                        containerFrame: CGRect(x: -0.015, y: -0.0075,
                                                                               width: 0.16,
                                                                               height: 0.1),
                                                        alignment: .left,
                                                        lineBreakMode: .byWordWrapping)
                descEntity.model?.mesh = newMesh
            }
            
            windowEntity.orientation = simd_conjugate(lineEntity.orientation)
            lineEntity.addChild(windowEntity)
            edges.append(lineEntity)
        }
    }
    
    func updateEdges(entity: Entity) {
        let edgesToChange = edges.filter {$0.name.contains(entity.name)}
                    
        for edge in edgesToChange {
            let edgeNodes = edge.name.components(separatedBy: " -> ")
                
            // Retrieve nodes
            let p1 = nodes.first(where: { $0.name == edgeNodes[0]})
            let p2 = nodes.first(where: { $0.name == edgeNodes[1]})
                
            let startPos = p1?.position ?? SIMD3(0, 0, 0)
            let endPos = p2?.position ?? SIMD3(1, 1, 1)
            let midPos = (startPos + endPos) / 2
                
            // Recalculate orientation and length of edge
            let dist = simd_distance(startPos, endPos)
            let dir = endPos - startPos
            let rotation = simd_quatf(from: [0, 1, 0], to: simd_normalize(dir))
            let newLine = MeshResource.generateCylinder(height: dist, radius: 0.001)
                
            edge.model?.mesh = newLine
            edge.position = midPos
            edge.orientation = rotation
            edge.children.first?.orientation = simd_conjugate(rotation)
        }
    }
}

// Generic superclass for graph layout algorithms
class GraphLayout {
    func performIteration(){}
}

// Fruchter-Reingold Algorithm (1991)
class FRA91: GraphLayout {
    override func performIteration() {
        print("Hello world!")
    }
}
