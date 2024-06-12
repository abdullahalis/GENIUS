//
//  ProteinView.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 5/23/24.
//

import SwiftUI
import RealityKit

struct ProteinView: View {
    @EnvironmentObject var graph: Graph
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
                        getData(proteins: names, species: species) { (p,i) in
                            graph.setProteins(p: p)
                            graph.setInteractions(i: i)
                            if buttonText == " Search database " {
                                buttonText = "            Clear            "
                            } else {buttonText = " Search database "}
                        }
                    }.padding()
                    Toggle("Show model", isOn: $showImmersiveSpace)
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 170)
                        .padding(15)
                        .glassBackgroundEffect()
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
                .onChange(of: showImmersiveSpace) { _, newValue in
                    Task {
                        if newValue {
                            switch await openImmersiveSpace(id: "ProteinSpace") {
                            case .opened:
                                immersiveSpaceIsShown = true
                            case .error, .userCancelled:
                                fallthrough
                            @unknown default:
                                immersiveSpaceIsShown = false
                                showImmersiveSpace = false
                            }
                        } else if immersiveSpaceIsShown {
                            await dismissImmersiveSpace()
                            immersiveSpaceIsShown = false
                        }
                    }
                }
            }
        }.onAppear{ // Dismiss existing immersive space from main menu
            Task {
                await dismissImmersiveSpace()
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
