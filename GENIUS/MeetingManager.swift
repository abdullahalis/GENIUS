//
//  MeetingManager.swift
//  GENIUS
//
//  Created by Rick Massa on 5/22/24.
//

import Foundation
import AVFAudio

class MeetingManager : Identifiable {
    let speechSynthesizer = AVSpeechSynthesizer()
    var id: UUID
    private var meetingText : String
    private var meetingName : String
    private var summary = ""
    
    init(meetingText : String, meetingName : String) {
        self.id = UUID()
        self.meetingName = meetingName
        self.meetingText = meetingText
    }
    
    func summarizeMeeting(updatingTextHolder: UpdatingTextHolder) {
        do {
            Task {
                summary = try await Argo().getResponse(prompt: "Summarize this information all of this " + self.meetingText)

            }
        }
    }
//    func extractData(updatingTextHolder: UpdatingTextHolder, dataToExtract : String) -> String{
//        let prompt = "Extract everything that concerns '" + dataToExtract + "' within this passage. " + self.meetingText
//        Argo().getResponse(prompt: prompt)
//        return updatingTextHolder.responseText
//    }
    func replayMeeting() {
        Argo().speak(text: self.meetingText, speechSynthesizer: speechSynthesizer)
    }
    func getName() -> String {
       return meetingName
    }
    func getMeeting() -> String {
       return meetingText
    }
    func getSummary() -> String {
       return summary
    }
}
