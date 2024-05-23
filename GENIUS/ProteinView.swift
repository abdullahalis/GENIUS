//
//  ProteinView.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 5/23/24.
//

import SwiftUI
import RealityKit

struct ProteinView: View {
    @State private var username: String = ""
    @FocusState private var emailFieldIsFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    SphereView()
                    SphereView()
                }
                proteinMenuItems()
                VStack {
                    TextField(
                            "Enter protein name",
                            text: $username
                        )
                        .focused($emailFieldIsFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .fixedSize()


                        Text(username)
                            .foregroundColor(emailFieldIsFocused ? .red : .blue)
                    
                    Button("LoadState") {
                        loadState()
                    }.padding()
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
            Text("Welcome to the ProteinView")
                .font(.system(size: 30, weight: .medium))
            Image(systemName: "lizard.circle")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
        }
        .padding(.bottom, 40)

    }
}

#Preview {
    ProteinView()
}
