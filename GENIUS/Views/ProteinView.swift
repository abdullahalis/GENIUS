//
//  ProteinView.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 5/23/24.
//

import SwiftUI
import RealityKit

struct ProteinView: View {
    @ObservedObject var graph: Graph = Graph.shared
    @ObservedObject var updatingTextHolder: UpdatingTextHolder
    @State private var names: String = ""
    @State private var species: String = ""
    @FocusState private var TextFieldIsFocused: Bool
    @State private var buttonText = " Search database "
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = true
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    
    var body: some View {
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
                    Button(buttonText) {
                        if !graph.getIsShown() {
                            getData(proteins: names, species: species) { (p,i) in
                                graph.setProteins(p: p)
                                graph.setInteractions(i: i)
                                DispatchQueue.main.async {
                                    graph.createNodes()
                                    graph.createEdges()
                                }
                            }
                            print("isLoading was: ", graph.getIsLoading())
                            graph.toggleIsLoading()
                            print("isLoading is: ", graph.getIsLoading())
                            buttonText = "            Clear            "
                        } else {
                            graph.clear()
                            graph.toggleIsShown()
                            buttonText = " Search database "
                        }
                        
                    }.padding()
                    if graph.getIsLoading() {
                        HStack {
                            Text("Loading: \(graph.getIsLoading()) ")
                            ProgressView()
                        }.padding()
                    }
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
        }.onAppear{
            Task {
                await dismissImmersiveSpace()
                await openImmersiveSpace(id: "ProteinSpace")
            }
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

#Preview {
    ProteinView(updatingTextHolder: UpdatingTextHolder()).environmentObject(Graph.shared)
}
