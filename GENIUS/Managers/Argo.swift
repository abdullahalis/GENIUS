//
//  Argo.swift
//  GENIUS
//
//  Created by Abdullah Ali on 5/21/24.

import Foundation
import SwiftUI
import AVFAudio
import Combine

class Argo : ObservableObject{
    var conversationManager: ConversationManager
    @State private var mode: String = "none"
    private var modelsAvailable: [String] = []
    private var modelsAvailableStr: String = "none"
    private let speaker: Speaker
    private let speechSynthesizer = SpeechSynthesizer.shared.synthesizer
    let updatingTextHolder = UpdatingTextHolder.shared
    
    @Environment(\.openWindow) var openWindow

    init() {
        self.conversationManager = ConversationManager.shared
        self.speaker = Speaker()
    }
    
    // Text to Speech function
    func speak(text: String) {
//        let audioSession = AVAudioSession() // 2) handle audio session first, before trying to read the text
//        do {
//            try audioSession.setCategory(.playback, mode: .default)
//            try audioSession.setActive(true)
//        } catch let error {
//            print(":question:", error.localizedDescription)
//        }
        
        // Stop any ongoing speech synthesis
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
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
    
    func getResponse(prompt: String, model: String) async throws -> String {
        // add context with prompt
        let fullPrompt = conversationManager.getContext() + "Using this context (if applicable or if it exists) to answer the following prompt:" + prompt
        var request: URLRequest
        var parameters: [String: Any]
        
        // Call API based on model selected
        if (model == "Argo") {
            // Access Argo API
            let url = URL(string: "https://apps-dev.inside.anl.gov/argoapi/api/v1/resource/chat/")!
            
            // Form HTTP request
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            parameters = [
                "user": "syed.ali",
                "model": "gpt35",
                "system": "You are a large language model with the name Genius. You are a personal assistant specifically tailored for scientists engaged in experimentation and research. You will record all interactions, transcribe them, and offer functionalities like meeting summaries, knowledge extraction, and replaying discussions.",
                "stop": [],
                "temperature": 0.1,
                "top_p": 0.9,
                "prompt": [fullPrompt]
            ]
        }
        else if (model == "Llama") {
            // Access Argo API
            let url = URL(string: "https://arcade.evl.uic.edu/llama/generate")!
            
            // Form HTTP request
            request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            parameters = [
              "inputs": """
              <|begin_of_text|> <|start_header_id|>system<|end_header_id|> You are a large language model with the name Genius. You are a personal assistant specifically tailored for scientists engaged in experimentation and research. You will record all interactions, transcribe them, and offer functionalities like meeting summaries, knowledge extraction, and replaying discussions. <| eot_id|> <|start_header_id|>user<|end_header_id|> \(fullPrompt) <|eot_id|> <|start_header_id|>assistant<|end_header_id|>
              """,
              "parameters": [
                "max_new_tokens": 300
              ]
            ]
        }
        else {
            return "Error: Model not found."
        }
        
        // Convert paramaters to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = jsonData
        let start = Date()
        // Send request
        let (data, response) = try await URLSession.shared.data(for: request)
        let end = Date()
        print("Time: ", end.timeIntervalSince(start))
        // Check if response is valid
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid Response")
            return "Invalid Response"
        }

        // Extract response string from JSON response
        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        if let responseString = jsonResponse?["response"] as? String {
            return responseString
        }
        else if let responseString = jsonResponse?["generated_text"] as? String {
            let startIndex = responseString.index(responseString.startIndex, offsetBy: 2)
            return String(responseString[startIndex...])
        }
        else {
            print("Response does not contain 'response' field or it's not a string")
            return "Error"
        }
    }
    
    // Extract mode needed based on user's recognized text
    func handleRecording() {
        let recording = updatingTextHolder.recongnizedText
        if recording == " " {
            self.speak(text: "Sorry I didn't get that")
            return
        }
        print("recording in Argo", recording)
        let prompt = "You will decide what type of action that needs to be taken based on user input. Respond with one of the following options with no punctuation or spaces: meeting, prompt, model, or simulation. Choose meeting if based on the user input, the user wants to start recording a meeting. Choose prompt if the user wants information about something. Choose model if the user wants to see a representation of something. Choose simulation if the user wants to run a simulation of something. Choose protein if the user wants to visualize protein interactions. Choose clear if the user wants to clear the screen. Your response must be one word. The user said: \(recording)."
        Task {
            let mode = try await getResponse(prompt: prompt, model: "Llama")
            print("Mode:", mode)
            if mode.contains("meeting") {
                self.handleMeeting()
            }
            else if mode.contains("prompt") {
                self.handlePrompt()
            }
            else if mode.contains("model") {
                self.handleModel()
            }
            else if mode.contains("simulation") {
                self.handleSimulation()
            }
            else if mode.contains("protein") {
                self.handleProtein()
            }
            else if mode.contains("clear") {
                self.handleClear()
            }
            else {
                self.speak(text: "No response possible")
            }
        }
    }
    
    // Summarize and punctutate recorded meeting
    func handleMeeting() {
        updatingTextHolder.mode = "meeting"
        if let range = updatingTextHolder.recongnizedText.range(of: "record meeting ") {
            do{
                Task {
                    let meeting =  try await getResponse(prompt: "Added proper punctuation and fix any spelling or grammar errors you find: " + String(updatingTextHolder.recongnizedText[(range.upperBound...)]), model: "Argo")
                    let meetingName = try await getResponse(prompt: "Come up with a short name to describe this meeting: " + meeting, model: "Argo")
                    let newMeeting = MeetingManager(meetingText: meeting, meetingName: meetingName)
                    newMeeting.summarizeMeeting()
                    updatingTextHolder.meetingManagers.append(newMeeting)
                    updatingTextHolder.responseText = "Meeting added"
                    print("Meeting added")
                }
            }
        }
    }
    
    // Sends prompt straight to Argo
    func handlePrompt() {
        updatingTextHolder.mode = "Loading response..."
        let question = updatingTextHolder.recongnizedText
        do {
            Task {
                // call Argo API to get response to prompt
                let response = try await getResponse(prompt: question, model: "Argo")
                print("response:", response)
                
                // call text to speech function with the response from Argo
                self.speak(text: response)
                
                // add converation entry
                self.conversationManager.addEntry(prompt: question, response: response)
                
                // update UI
                updatingTextHolder.mode = " "
                updatingTextHolder.responseText = response
            }
        }
    }
    
    // Opens a 3D model based on user input
    func handleModel() {
        updatingTextHolder.mode = "Loading model..."
        let userPrompt = updatingTextHolder.recongnizedText
        
        Task {
            // generate a search query based on user input
            var prompt = "I need to display a 3d model. I want to use an API which takes a search query in the form of a string and returns 3D models as a response. The user prompted: \(userPrompt)'. You will give me the best search query to use given this prompt. If previous context exists use that along with the prompt to decide on a search query for the 3D model API. Your response will be directly used to open the model, so you must respond with only a search query that is as short as possible with no other words and no periods. Make sure your entire response has no other words other than the search query so it can be directly used to search with the API. You must not mention model in the search query because that is implied. You must not explain why you chose the query, just return the query."
            let modelSearch = try await getResponse(prompt: prompt, model: "Llama")

            // search Sketchfab API for models relating to the search query
            let results = try await sketchFabSearch(q: modelSearch)
            
            // Construct dictionary from the result struct
            var models = [String:String]()
            for result in results {
                models[result.uid] = result.name
            }
            
            // Use the names of models to pick the one to open
            prompt = "Your response must be one phrase with no spaces or punctuation: You have previously created a search query for a 3D model. That search has been ran and now I have the results as a dictionary of models in the form (uid, name). Here is the dictionary of models: \(models). Based on the search: '\(modelSearch)' and our previous discussion, decide which model's name best matches. Please provide ONLY the uid of the matching model. Your response must only include the uid."
            let modelToOpen = try await getResponse(prompt: prompt, model: "Llama")
            print("model to open:", modelToOpen)
            
            // check if model is valid
            if (models.keys.contains(modelToOpen)) {
                // open it using the main thread
                DispatchQueue.main.async {
                    self.openWindow(id: "model", value: modelToOpen)
                }
                
                updatingTextHolder.mode = " "
                conversationManager.addEntry(prompt: updatingTextHolder.recongnizedText, response: "*Displays '\(models[modelToOpen] ?? "model")'*", modelId: modelToOpen)
            }
            else {
                print("Error generating model to open")
            }
        }
    }
    
    // Run simulation on Polaris supercomputer based on user input
    func handleSimulation() {
        // Generate the parameters for the simulation
        let prompt = "Respond only in a comma seperated string. The user would like to run a simulation of fluid dynamics. The parameters and their defaults are the following: density: 1000, speed: 1.0, length: 2.5, viscosity: 1.3806, time: 8.0, freq: 0.04. Your job is to generate the parameters for the simulation given the user prompt. If the user says to simply run the simulation, return the default values. Otherwise adjust the parameters using the numbers from previous parameters you provided and as needed to fullfill the user's request. Return the parameters as a string of numbers seperated by commas with no spaces in the order: density, speed, length, viscosity, time, freq. Here is the user's prompt: \(updatingTextHolder.recongnizedText)"
        Task {
            
            let parameters = try await getResponse(prompt: prompt, model: "Llama")
            
            // update context and UI
            conversationManager.addEntry(prompt: updatingTextHolder.recongnizedText, response: "*Ran simulation with parameters: \(parameters)*")
            updatingTextHolder.responseText = parameters
            
            // Open window to show simulation
            DispatchQueue.main.async {
                self.openWindow(id: "sim", value: parameters)
            }
        }
    }
    
    func handleProtein() {
        updatingTextHolder.mode = "Retrieving data..."
        let graph = Graph.shared
        let userPrompt = updatingTextHolder.recongnizedText
        Task {
            let prompt = "Respond only in a space-separated string of protein names. The user wishes to visualize a graph of protein interactions. You must parse the user's prompt and return the names of any proteins you recognize. Do not add any proteins of your own volition. Any proteins you return must be valid proteins, so do your best to match the user's words to protein names. Assume all proteins are human-specific. If unable to find any proteins, respond with 'Not found'. Here is the user's prompt: \(userPrompt)"
            let names = try await getResponse(prompt: prompt, model: "Llama")
            getData(proteins: names, species: "9606") { (p,i) in
                self.updatingTextHolder.mode = "Building model..."
                graph.setData(p: p, i: i)
                DispatchQueue.main.async {
                    graph.createModel()
                }
                self.updatingTextHolder.mode = " "
            }
        }
    }
    
    func handleClear() {
        updatingTextHolder.mode = ""
        let graph = Graph.shared
        Task {
            graph.clear()
        }
    }
}
