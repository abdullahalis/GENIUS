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
    
    var body: some View {
        NavigationStack {
            VStack {
                //HStack{
                //    SphereView()
                //    SphereView()
                //}
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
                        print(names, species)
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

#Preview {
    ProteinView(updatingTextHolder: UpdatingTextHolder())
}
