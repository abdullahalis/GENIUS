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
    private var conversationManager: ConversationManager
    @State private var mode: String = "none"
    private var modelsAvailable: String = "none"
    
    @Environment(\.openWindow) var openWindow

    init() {
        self.conversationManager = ConversationManager.shared
        makeModelString()
    }
    
    // get a string listing every model available to find options for "show me" prompt
    func makeModelString() {
        guard let ModelURLs = Bundle.main.urls(forResourcesWithExtension: "usdz", subdirectory: nil)
        else {
            print("usdz files not found")
            return
        }
        
        modelsAvailable = ""
        
        // combine file names into one string
        ModelURLs.forEach {url in
            modelsAvailable += (url.deletingPathExtension().lastPathComponent)
            modelsAvailable += ", "
        }
        // get rid of last ", "
        modelsAvailable = String(modelsAvailable.dropLast(2))
        print("models:", modelsAvailable)
    }

    func performTask() {
        // Example task using the conversation manager
        let history = conversationManager.getConversationHistory()
        print("Conversation History: \(history)")
    }
    
    func Speak(text: String, speechSynthesizer: AVSpeechSynthesizer) {
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
    
    func getResponse(prompt: String) -> String {
        var responseStringReturn = ""
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
        do {
            // Convert paramaters to JSON
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
            // Send request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                // Check if response is valid
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Invalid Response")
                    return
                }
                if let data = data {
                    do {
                        // Extract response string from JSON response
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let responseString = jsonResponse?["response"] as? String {
                            print("responsein getrep", responseString)
                            responseStringReturn = responseString
                            
                        }
                        else {
                            print("Response does not contain 'response' field or it's not a string")
                        }
                    }
                    catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            // run request
            task.resume()
        }
        catch {
            print("Error creating JSON: \(error)")
        }
        return responseStringReturn
    }
    
    func handleRecording(updatingTextHolder: UpdatingTextHolder, speechSynthesizer: AVSpeechSynthesizer) {
        let recording = updatingTextHolder.recongnizedText
        
        // get first 10 words to extract the desired functionality
        let words = recording.components(separatedBy: " ")
        let firstTenWords = Array(words.prefix(10))
        let firstTenWordsString = firstTenWords.joined(separator: " ")
        print("first tne:", firstTenWordsString)
        if firstTenWordsString.contains("record meeting") {
            self.handleMeeting(updatingTextHolder: updatingTextHolder)
        }
        
        else if firstTenWordsString.contains("tell me") {
            self.handlePrompt(updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
        }
        
        else if firstTenWordsString.contains("show me") {
            self.handleModel(updatingTextHolder: updatingTextHolder, speechSynthesizer: speechSynthesizer)
        }
        print("recognized:", updatingTextHolder.recongnizedText)

//        // React to recognized commands here
//        if updatingTextHolder.recongnizedText.contains("night mode") {
//            updatingTextHolder.nightMode.toggle()
//            self.stopRecording()
//        }
//        if updatingTextHolder.recongnizedText.contains("clear chat") {
//            updatingTextHolder.recongnizedText = ""
//            self.stopRecording()
//        }
    }
    
    func handleMeeting(updatingTextHolder: UpdatingTextHolder) {
        updatingTextHolder.mode = "meeting"
        print("meeting")
    }
    
    func handlePrompt(updatingTextHolder: UpdatingTextHolder, speechSynthesizer: AVSpeechSynthesizer) {
        updatingTextHolder.mode = "prompt"
        print("PROMPT")
        if let range = updatingTextHolder.recongnizedText.range(of: "tell me ") {
            let question = String(updatingTextHolder.recongnizedText[(range.upperBound...)])
            let responseString = getResponse(prompt: question)
            
                print("response:", responseString)
                self.Speak(text: responseString, speechSynthesizer: speechSynthesizer)
                self.conversationManager.addEntry(prompt: question, response: responseString)
                print("history:", self.conversationManager.getConversationHistory())
                updatingTextHolder.responseText = responseString
            
        }
    }
    
    func handleModel(updatingTextHolder: UpdatingTextHolder, speechSynthesizer: AVSpeechSynthesizer) {
        updatingTextHolder.mode = "model"
        
        if (modelsAvailable == "none") {
            Speak(text: "There are no models to show you", speechSynthesizer: speechSynthesizer)
            return
        }
        if (updatingTextHolder.recongnizedText.contains("earth")) {
            openWindow(id: "volume", value: "Earth")
        }
        let modelToOpen = findBestModel()
        
        print ("model to open:", modelToOpen)
        
        if modelsAvailable.contains(modelToOpen) {
            openWindow(id: "volume", value: modelToOpen)
        }
        else {
            print("no model available/matching")
        }
        
    }
    
    func findBestModel() -> String{
        var prompt = "I need to display a 3d model. using the context of our previous conversation if applicable, decide which of the following 3d model files should be displayed. Your response will be directly used to open the model so respond with only your choice of file name with no space or anything else. If you think none of the available models are applicable, respond with the word 'none'. Here are the available models: ( \(modelsAvailable))."
        
        return getResponse(prompt: prompt)
        
    }
    
    
}
