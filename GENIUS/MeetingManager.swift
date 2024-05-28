//
//  MeetingManager.swift
//  GENIUS
//
//  Created by Rick Massa on 5/22/24.
//

import Foundation
import AVFAudio

class MeetingManager : ObservableObject {
    let speechSynthesizer = AVSpeechSynthesizer()
    private var meetingText : String
    private var meetingName : String
    private var summary = ""
    
    init(meetingText : String, meetingName : String) {
        self.meetingName = meetingName
        self.meetingText = meetingText
    }
    
    func summarizeMeeting(updatingTextHolder: UpdatingTextHolder) {
        do {
            Task {
                try await Argo().getResponse(prompt: "Summarize this information all of this " + self.meetingText)
            }
        }
    }
    
    func extractData(updatingTextHolder: UpdatingTextHolder, dataToExtract : String) {
        do {
            Task {
                let prompt = "Extract everything that concerns '" + dataToExtract + "' within this passage. " + self.meetingText
                let response = try await Argo().getResponse(prompt: prompt)
            }
        }
    }
    
    func replayMeeting() {
        Argo().Speak(text: self.meetingText, speechSynthesizer: speechSynthesizer)
    }
}
