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
            if isModelShown {modelView(nodes: self.proteins, edges: self.interactions)}
        }
    }
}

struct modelView: View {
    let nodes: [Protein]
    let edges: [Interaction]
    
    var body: some View {
        RealityView { content in
            let model = create3DModel(proteins: nodes, interactions: edges)
            content.add(model)
        }
    }
}

struct SphereView: View {
    @State private var scale = false
    var body: some View {
        RealityView { content in
            let model = ModelEntity(
                mesh: .generateSphere(radius: 0.05),
                materials: [SimpleMaterial(color: .white, isMetallic: true)])


            // Enable interactions on the entity.
            model.components.set(InputTargetComponent())
            model.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.05)]))
            content.add(model)
        } update: { content in
            if let model = content.entities.first {
                model.transform.scale = scale ? [1.2, 1.2, 1.2] : [1.0, 1.0, 1.0]
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            scale.toggle()
        })
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
            Text("Welcome to Gecko!")
                .font(.system(size: 35, weight: .medium))
                .padding(.bottom, 10)
            Text("Visualize protein interactions in VR")
                .font(.system(size: 25, weight: .medium))
        }
        .padding(.bottom, 40)

    }
}

func create3DModel(proteins: [Protein], interactions: [Interaction]) -> ModelEntity {
    let proteinNetwork = ModelEntity()
    
    // Define positions for each protein
    let positions: [SIMD3<Float>] = [
        SIMD3<Float>(0, 0, 0), // Adjust the positions as needed
        SIMD3<Float>(0, 0.1, 0),
        SIMD3<Float>(0, 0.2, 0),
        SIMD3<Float>(0, -0.1, 0)
    ]
    
    // Create entities for proteins
    for (index,_) in proteins.enumerated() {
        let sphere = MeshResource.generateSphere(radius: 0.01) // Adjust the radius as needed
        let proteinObject = ModelEntity(mesh: sphere, materials: [SimpleMaterial(color: .white, isMetallic: true)])
        //proteinObject.setPosition(positions[index], relativeTo: proteinNetwork)
        proteinObject.position = positions[index]
        //proteinObject.position = SIMD3<Float>(Float.random(in: -0.3 ... 0.3), Float.random(in: -0.3 ... 0.3), Float.random(in: -0.3 ... 0.3))
        proteinNetwork.addChild(proteinObject)
    }
    return proteinNetwork
}

#Preview {
    ProteinView(updatingTextHolder: UpdatingTextHolder())
}
