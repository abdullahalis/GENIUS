//
//  ProteinView.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 5/23/24.
//

import SwiftUI
import RealityKit

struct ProteinView: View {
    @ObservedObject var updatingTextHolder: UpdatingTextHolder
    @State private var names: String = ""
    @State private var species: String = ""
    @FocusState private var TextFieldIsFocused: Bool
    @State private var isModelShown: Bool = false
    @State private var proteins: [Protein] = []
    @State private var interactions: [Interaction] = []
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack{
            NavigationStack {
                VStack {
                    proteinMenuItems()
                    VStack {
                        TextField(
                            "  Enter protein name(s)  ",
                            text: $names
                        )
                        .focused($TextFieldIsFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .fixedSize()
                        TextField(
                            "Enter NCBI taxonomyID",
                            text: $species
                        )
                        .focused($TextFieldIsFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .fixedSize()
                        Button("Search database") {
                            getData(proteins: names, species: species) { (p,i) in
                                self.proteins = p
                                self.interactions = i
                                self.isModelShown.toggle()
                            }
                        }.padding()
                        
                        HStack {
                            Button("Record") {
                                Recorder().startRecording(updatingTextHolder: updatingTextHolder)
                            }
                            Button("Stop") {
                                Recorder().stopRecording()
                            }
                        }
                        Text(updatingTextHolder.recongnizedText)
                    }
                    .textFieldStyle(.roundedBorder)
                    .navigationTitle("Protein View")
                }
            }
            if isModelShown {modelView(proteins: self.proteins, interactions: self.interactions)}
        }
    }
}


struct proteinMenuItems: View {
    var body: some View {
        
        VStack {
            Image(systemName: "lizard.circle")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
            Text("Gecko")
                .font(.system(size: 35, weight: .medium))
                .padding(.bottom, 10)
            Text("Visualize protein interactions in VR")
                .font(.system(size: 25, weight: .medium))
        }
        .padding(.bottom, 40)

    }
}


struct modelView: View {
    let proteins: [Protein]
    let interactions: [Interaction]
    
    @State private var nodes: [ModelEntity] = []
    @State private var edges: [ModelEntity] = []
        
    var body: some View {
        RealityView { content in
            
            createNodes()
            for node in nodes {
                content.add(node)
            }
            
            createEdges()
            for edge in edges {
                content.add(edge)
            }
            
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
            if let descEntity = value.entity.children.first(where: { $0.name == "descWindow"}) {
                descEntity.isEnabled.toggle()
            }
        })
        .gesture(DragGesture().targetedToAnyEntity().onChanged { value in
            let nodeObject = value.entity
            nodeObject.position = value.convert(value.location3D, from: .local, to: nodeObject.parent!)
            
            // Iterate through interactions to find relevant edges to recalculate
            //
        })
        
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
            let proteinObject = ModelEntity(mesh: sphere, materials: [SimpleMaterial(color: colors.randomElement()!, isMetallic: false)])
            
            // Assign random position to each protein within the bounding box of parent window
            // Bounds configured based on default window size
            proteinObject.position = SIMD3<Float>(Float.random(in: -0.3 ... 0.3), Float.random(in: -0.15 ... 0.15), Float.random(in: 0 ... 0.2))
            
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
                                                        containerFrame: CGRect(x: 0, y: 0, width: 0.14, height: 0.09),
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
            
            let lineEntity = ModelEntity(mesh: line, materials: [UnlitMaterial(color: .white)])
            lineEntity.position = midPos
            lineEntity.orientation = rotation
            lineEntity.name = (p1?.name ?? "Unknown") + " -> " + (p2?.name ?? "Unknown")
            
            edges.append(lineEntity)
        }
    }
}

#Preview {
    ProteinView(updatingTextHolder: UpdatingTextHolder())
}
