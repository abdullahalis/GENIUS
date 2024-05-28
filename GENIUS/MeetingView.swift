//
//  MeetingView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/28/24.
//

import SwiftUI


struct MeetingView: View {
    
    @ObservedObject var updatingTextHolder: UpdatingTextHolder
    @State private var newMeetingName: String = ""
    @State private var newMeetingDate: Date = Date()
    
    var body: some View {
        Text("Meetings")
            .font(.system(size: 40, weight: .bold))
                                                                
        List {
            ForEach(updatingTextHolder.meetingManagers) { manager in
                VStack(alignment: .leading) {
                    Text(manager.getName())
                        .font(.headline)
                        .font(.system(size: 30, weight: .bold))
                    Text("Summary of Meeting")
                        .font(.system(size: 30, weight: .bold))
                    Text(manager.getSummary())
                        .font(.headline)
                    Text("Full Meeting")
                        .font(.system(size: 30, weight: .bold))
                    Text(manager.getMeeting())
                        .font(.headline)
                    
                }
            }
        }
        Button("test") {
            let testMeet = MeetingManager(meetingText: "Testing", meetingName: "test")
            updatingTextHolder.meetingManagers.append(testMeet)
        }

    }
}

#Preview {
    MeetingView(updatingTextHolder: UpdatingTextHolder())
}
