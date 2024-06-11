//
//  PolarisView.swift
//  GENIUS
//
//  Created by Rick Massa on 6/6/24.
//

import SwiftUI

struct PolarisView: View {
    
    var updatingTextHolder: UpdatingTextHolder
    @State private var recording = false
    
    @State var outputs: [String] = []
    @State private var username = "fmassa"
    @State private var password = ""
    @State private var command = ""
    
    var body: some View {
            VStack {
                Text("Polaris")
                    .font(.system(size: 30, weight: .medium))
                
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(outputs, id: \.self) { line in
                            Text(line)
                            .font(.system(.body, design: .monospaced))
                            .padding(.horizontal)
                            .padding(.vertical, 2)
                            .foregroundColor(.green)
                            .cornerRadius(4)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 300)
                .background(Color.black.opacity(0.9))
                .cornerRadius(8)
                .padding()
                
                HStack {
                    TextField("username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                TextField("command", text: $command)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Submit") {
                    
                    sendPostRequest(username: username, password: password, command: command.components(separatedBy: "++")) { result in
                        print("Result: \(result)")
                        
                        for (input, output) in zip(result.inputs, result.outputs) {
                            if(output != "") {
                                outputs.append(username + ": " + input + "\n" + "Polaris: " + output)
                            }
                            else {
                                outputs.append(username + ": " + input)
                            }
                        }
                    }
                    
                    command = ""
                    password = ""
                }
                .padding()
                Button("Ask GENIUS") {
                    if(recording) {
                        //handlePolarisCommand(updatingTextHolder: updatingTextHolder, command: $command)
                        recording = false
                    }
                    else {
                        Recorder().startRecording(updatingTextHolder: updatingTextHolder)
                        recording = true
                    }
                }
            }
            .padding()
        }
}

#Preview {
    PolarisView(updatingTextHolder: UpdatingTextHolder())
}
