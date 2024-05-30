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
    private var request = ""
    
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
        Argo().Speak(text: self.meetingText, speechSynthesizer: speechSynthesizer)
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
    
    func voiceCommands(updatingTextHolder: UpdatingTextHolder) {
        Recorder().stopRecording()
        handleCommands(updatingTextHolder: updatingTextHolder)
    }
    
    func handleCommands(updatingTextHolder: UpdatingTextHolder) {
        let recording = updatingTextHolder.recongnizedText
        
        // get first 10 words to extract the desired functionality
        let words = recording.components(separatedBy: " ")
        let firstTenWords = Array(words.prefix(10))
        let firstTenWordsString = firstTenWords.joined(separator: " ")
        
        if firstTenWordsString.contains("replay meeting") {
            Argo().Speak(text: meetingText, speechSynthesizer: speechSynthesizer)
        }
        else if firstTenWordsString.contains("summary") {
            Argo().Speak(text: summary, speechSynthesizer: speechSynthesizer)
        }
        else {
            do {
                Task {
                    let response = try await Argo().getResponse(prompt: "Using this info '" + meetingText + "' " + recording)
                    Argo().Speak(text: response, speechSynthesizer: speechSynthesizer)
                    Argo().conversationManager.addEntry(prompt: recording, response: response)
                }
            }
        }
        //
    }
}
