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
    
    func summarizeMeeting(updatingTextHolder: UpdatingTextHolder) -> String{
        Argo().getResponse(prompt: "Summarize this information all of this " + self.meetingText, updatingTextHolder: updatingTextHolder, speechSynthesizer: self.speechSynthesizer)
        return updatingTextHolder.responseText
    }
    func extractData(updatingTextHolder: UpdatingTextHolder, dataToExtract : String) -> String{
        let prompt = "Extract everything that concerns '" + dataToExtract + "' within this passage. " + self.meetingText
        Argo().getResponse(prompt: prompt, updatingTextHolder: updatingTextHolder, speechSynthesizer: self.speechSynthesizer)
        return updatingTextHolder.responseText
    }
    func replayMeeting() {
        Argo().Speak(text: self.meetingText, speechSynthesizer: speechSynthesizer)
    }
}
