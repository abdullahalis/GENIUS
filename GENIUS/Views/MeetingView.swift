//
//  MeetingView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/28/24.
//

import SwiftUI
import AVFAudio


struct MeetingView: View {
    
    
    @ObservedObject var updatingTextHolder: UpdatingTextHolder
    @State private var prompt = ""
    @State private var recording = false
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        NavigationStack {
            
            Text("Meetings")
                .font(.system(size: 40, weight: .bold))
                .padding()
                                                                    
            List {
                ForEach(updatingTextHolder.meetingManagers) { manager in
                    VStack(alignment: .leading) {
                        Text(manager.getName())
                            .font(.system(size: 40, weight: .bold))
                        Text("Summary of Meeting")
                            .font(.system(size: 30, weight: .bold))
                        Text(manager.getSummary())
                            .font(.headline)
                        Text("Full Meeting")
                            .font(.system(size: 30, weight: .bold))
                        Text(manager.getMeeting())
                            .font(.headline)
                        Button("") {
                            if(recording) {
                                manager.voiceCommands(updatingTextHolder: updatingTextHolder)
                                recording = false
                            }
                            else {
                                Recorder().startRecording(updatingTextHolder: updatingTextHolder)
                                recording = true
                            }
                        }
                        
                    }
                }
            }
            Button("test") {
                let testMeet = MeetingManager(meetingText: "Testing the meeting", meetingName: "test")
                updatingTextHolder.meetingManagers.append(testMeet)
            }.padding()
        }
        

    }
}

#Preview {
    MeetingView(updatingTextHolder: UpdatingTextHolder())
}
