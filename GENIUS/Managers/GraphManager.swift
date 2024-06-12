//
//  GraphManager.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 6/12/24.
//

import SwiftUI
import RealityKit
import ForceSimulation

// Class to model protein graph objects
class Graph: ObservableObject {
    private var proteins: [Protein] = []
    private var interactions: [Interaction] = []
    private var nodes: [ModelEntity] = []
    private var edges: [ModelEntity] = []
    
    // Define force component
    private struct My3DForce: ForceField3D {
        typealias Vector = SIMD3<Float>
        
        var force = CompositedForce<Vector, _, _> {
            Kinetics3D.CenterForce(center: .zero, strength: 1)
            Kinetics3D.ManyBodyForce(strength: -1)
            Kinetics3D.LinkForce(stiffness: .constant(0.5))
        }
    }
    
    // Declare singleton instance of Graph
    static let shared = Graph()
    private init() { }
    
    func setProteins(p: [Protein]) {self.proteins = p}
    func setInteractions(i: [Interaction]) {self.interactions = i}
    func getNodes() -> [ModelEntity] {return self.nodes}
    func getEdges() -> [ModelEntity] {return self.edges}
    
    // Build and run simulation to obtain optimal positions
    private func buildSim() -> Simulation3D<My3DForce> {
        
        let links = self.interactions.map { i in
            let fromID = self.proteins.firstIndex { mn in
                mn.getPreferredName() == i.getProteinA()
            }!
            let toID = self.proteins.firstIndex { mn in
                mn.getPreferredName() == i.getProteinB()
            }!
            return EdgeID(source: fromID, target: toID)
        }
        
        let sim = Simulation(
            nodeCount: self.proteins.count,
            links: links,
            forceField: My3DForce()
        )
        
        for _ in 0..<720 {
            sim.tick()
        }
        return sim
    }
    
    func createNodes(_ devicePos: simd_float3) {
        let materialColors: [UIColor] = [
            UIColor(red: 17.0/255, green: 181.0/255, blue: 174.0/255, alpha: 1.0),
            UIColor(red: 64.0/255, green: 70.0/255, blue: 201.0/255, alpha: 1.0),
            UIColor(red: 246.0/255, green: 133.0/255, blue: 18.0/255, alpha: 1.0),
            UIColor(red: 222.0/255, green: 60.0/255, blue: 130.0/255, alpha: 1.0),
            UIColor(red: 17.0/255, green: 181.0/255, blue: 174.0/255, alpha: 1.0),
            UIColor(red: 114.0/255, green: 224.0/255, blue: 106.0/255, alpha: 1.0),
            UIColor(red: 22.0/255, green: 124.0/255, blue: 243.0/255, alpha: 1.0),
            UIColor(red: 115.0/255, green: 38.0/255, blue: 211.0/255, alpha: 1.0),
            UIColor(red: 232.0/255, green: 198.0/255, blue: 0.0/255, alpha: 1.0),
            UIColor(red: 203.0/255, green: 93.0/255, blue: 2.0/255, alpha: 1.0),
            UIColor(red: 0.0/255, green: 143.0/255, blue: 93.0/255, alpha: 1.0),
            UIColor(red: 188.0/255, green: 233.0/255, blue: 49.0/255, alpha: 1.0),
        ]
        
        // Define an array of node materials
        let nodeMaterials = materialColors.map { c in
            var material = PhysicallyBasedMaterial()
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: c)
            material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.0)
            material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.01)
            
            material.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(color: c)
            material.emissiveIntensity = 0.4
            return material
        }
        
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
        
        // Build and run simulation to retrieve final positions
        let sim = buildSim()
        let scaleRatio: Float = 0.0081
        let positions = sim.kinetics.position.asArray().map { pos in
            simd_float3(
                (pos[1]) * scaleRatio,
                -(pos[0]) * scaleRatio,
                (pos[2]) * scaleRatio + 0.25
        )}

        
        let sphereMesh = MeshResource.generateSphere(radius: 0.01)

        // Create entities for proteins
        for (index, p) in proteins.enumerated() {
            let proteinObject = ModelEntity(mesh: sphereMesh, materials: [nodeMaterials[index%nodeMaterials.count]])
                            
            proteinObject.position = devicePos + positions[index]
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
    
    func createEdges() {
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
                
        let lineMaterial = SimpleMaterial(color: UIColor(white: 1.0, alpha: 0.5), isMetallic: false)
        
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
