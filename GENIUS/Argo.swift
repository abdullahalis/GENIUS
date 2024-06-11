//
//  Argo.swift
//  GENIUS
//
//  Created by Abdullah Ali on 5/21/24.

import Foundation
import SwiftUI
import AVFAudio
import Combine

class Argo {
    var conversationManager: ConversationManager
    @State private var mode: String = "none"
    private var modelsAvailable: [String] = []
    private var modelsAvailableStr: String = "none"
    private let speaker: Speaker
    
    @Environment(\.openWindow) var openWindow

    init() {
        self.conversationManager = ConversationManager.shared
        self.speaker = Speaker()
    }
    
    // Text to Speech function
    func speak(text: String, speechSynthesizer: AVSpeechSynthesizer) {
        let audioSession = AVAudioSession() // 2) handle audio session first, before trying to read the text
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(false)
        } catch let error {
            print(":question:", error.localizedDescription)
        }
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: text)
        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(language: "en-GB")
        // Assign the voice to the utterance.
        utterance.voice = voice
        // Tell the synthesizer to speak the utterance.
        speechSynthesizer.speak(utterance)
    }
    
    func getResponse(prompt: String) async throws -> String {
        // add context with prompt
        let fullPrompt = conversationManager.getContext() + "Using this context (if applicable or if it exists) to answer the following prompt:" + prompt

        // Access Argo API
        let url = URL(string: "https://apps-dev.inside.anl.gov/argoapi/api/v1/resource/chat/")!
        
        // Form HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "user": "syed.ali",
            "model": "gpt35",
            "system": "You are a large language model with the name Genius. You are a personal assistant specifically tailored for scientists engaged in experimentation and research. You will record all interactions, transcribe them, and offer functionalities like meeting summaries, knowledge extraction, and replaying discussions.",
            "stop": [],
            "temperature": 0.1,
            "top_p": 0.9,
            "prompt": [fullPrompt]
        ]
        
        // Convert paramaters to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = jsonData
        
        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check if response is valid
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid Response")
            return "Invalid Response"
        }

        // Extract response string from JSON response
        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        if let responseString = jsonResponse?["response"] as? String {
            print("responseString in do:", responseString)
            return responseString
        }
        else {
            print("Response does not contain 'response' field or it's not a string")
            return "Error"
        }
    }
    
    // Extract mode needed based on user's recognized text
    func handleRecording(updatingTextHolder: UpdatingTextHolder, speechSynthesizer: AVSpeechSynthesizer) {
        let recording = updatingTextHolder.recongnizedText
        
        // get first 10 words to extract the desired functionality
        let words = recording.components(separatedBy: " ")
        let firstTenWords = Array(words.prefix(10))
        let firstTenWordsString = firstTenWords.joined(separator: " ")
        
        if firstTenWordsString.contains("record meeting") {
            self.handleMeeting(updatingTextHolder: updatingTextHolder)
        }
        else if firstTenWordsString.contains("tell me") {
            self.handlePrompt(updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
        }
        else if firstTenWordsString.contains("show me") {
            self.handleModel(updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
        }
        else {
            self.speak(text: "No response possible", speechSynthesizer: speechSynthesizer)
        }
    }
    
    // Summarize and punctutate recorded meeting
    func handleMeeting(updatingTextHolder: UpdatingTextHolder) {
        updatingTextHolder.mode = "meeting"
        if let range = updatingTextHolder.recongnizedText.range(of: "record meeting ") {
            do{
                Task {
                    let meeting =  try await getResponse(prompt: "Added proper punctuation and fix any spelling or grammar errors you find: " + String(updatingTextHolder.recongnizedText[(range.upperBound...)]))
                    let meetingName = try await getResponse(prompt: "Come up with a short name to describe this meeting: " + meeting)
                    let newMeeting = MeetingManager(meetingText: meeting, meetingName: meetingName)
                    newMeeting.summarizeMeeting(updatingTextHolder: updatingTextHolder)
                    updatingTextHolder.meetingManagers.append(newMeeting)
                    updatingTextHolder.responseText = "Meeting added"
                    print("Meeting added")
                }
            }
        }
    }
    
    // Sends prompt straight to Argo
    func handlePrompt(updatingTextHolder: UpdatingTextHolder, speechSynthesizer: AVSpeechSynthesizer) {
        // extract prompt from recognized speech
        if let range = updatingTextHolder.recongnizedText.range(of: "tell me ") {
            
            let question = String(updatingTextHolder.recongnizedText[(range.upperBound...)])
            
            do {
                Task {
                    // call Argo API to get response to prompt
                    let response = try await getResponse(prompt: question)
                    print("response:", response)
                    
                    // call text to speech function with the response from Argo
                    self.speak(text: response, speechSynthesizer: speechSynthesizer)
                    
                    // add converation entry
                    self.conversationManager.addEntry(prompt: question, response: response)
                    
                    // update UI
                    updatingTextHolder.mode = "prompt"
                    updatingTextHolder.responseText = response
                }
            }
        }
    }
    
    // Opens a 3D model based on user input
    func handleModel(updatingTextHolder: UpdatingTextHolder, speechSynthesizer: AVSpeechSynthesizer) {
        updatingTextHolder.mode = "model"
        
        Task {
            // generate a search query based on user input
            var prompt = "I need to display a 3d model. I am using an API which takes a search query in the form of a string and returns 3D models as a response. The user prompted: \(updatingTextHolder.recongnizedText)'. You will give me the best search query to use given this prompt. If previous context exists use that along with the prompt to decide on a search query for the 3D model API. Your response will be directly used to open the model, so you must respond with only a search query that is as short as possible with no other words and no periods. Make sure your entire response has no other words other than the search query so it can be directly used to search with the API. You must not mention model in the search query because that is implied. You must not explain why you chose the query, just return the query."
            
            let modelSearch = try await getResponse(prompt: prompt)
            print("searching for:", modelSearch)
            // search Sketchfab API for models relating to the search query
            let results = try await sketchFabSearch(q: modelSearch)
            
            // Construct dictionary from the result struct
            var models = [String:String]()
            for result in results {
                models[result.uid] = result.name
            }
            
            // Use the names of models to pick the one to open
            prompt = "Your response must be one phrase with no spaces or punctuation: You have previously created a search query for a 3D model. That search has been ran and now I have the results as a dictionary of models in the form (uid, name). Here is the dictionary of models: \(models). Based on the search: '\(modelSearch)' and our previous discussion, decide which model's name best matches. Please provide ONLY the uid of the matching model. Your response must only include the uid."
            let modelToOpen = try await getResponse(prompt: prompt)
            print("model to open:", modelToOpen)
            
            // check if model is valid
            if (models.keys.contains(modelToOpen)) {
                // open it using the main thread
                DispatchQueue.main.async {
                    self.openWindow(id: "model", value: modelToOpen)
                    print("openeed")
                }
            }
            else {
                print("Error generating model to open")
            }
        }
    }
}
