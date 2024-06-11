import Foundation

struct PolarisCommands {
    var inputs: [String]
    var outputs: [String]
}

func sendPostRequest(username: String, password: String, command: [String], completion: @escaping (PolarisCommands) -> Void) {
    guard let url = URL(string: "http://127.0.0.1:5000/data") else {
        print("Invalid URL")
        completion(PolarisCommands(inputs: ["error"], outputs: ["error"]))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let parameters: [String: Any] = [
        "user": username,
        "password": password,
        "command": command
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    } catch {
        print("Failed to serialize JSON: \(error)")
        completion(PolarisCommands(inputs: ["error"], outputs: ["error"]))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"]))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid response")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"]))
            return
        }
        
        guard let data = data else {
            print("No data")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"]))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let output = json["output"] as? [String] {
                print("JSON Response: \(json)")
                completion(PolarisCommands(inputs: command, outputs: output))
            } else {
                completion(PolarisCommands(inputs: ["error2"], outputs: ["error2"]))
            }
        } catch {
            print("Failed to decode JSON: \(error)")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"]))
        }
    }
    
    task.resume()
}

//func handlePolarisCommand(updatingTextHolder: UpdatingTextHolder, command: String) {
//    let recording = updatingTextHolder.recongnizedText
//    
//    // get first 10 words to extract the desired functionality
//    let words = recording.components(separatedBy: " ")
//    let firstTenWords = Array(words.prefix(10))
//    let firstTenWordsString = firstTenWords.joined(separator: " ")
//    
//    if(firstTenWordsString.contains("create a") || firstTenWordsString.contains("make me") || firstTenWordsString.contains("write me") || firstTenWordsString.contains("make a") || firstTenWordsString.contains("write a") ) {
//        var prompt = ""
//        if(words.contains("pbs script")) {
//            prompt = "Respond with only a terminal command: Use these as defaults if not specified: queue name = test_queue, 4 nodes with 1 process per node, walltime of 1 minute, with an output file and error file, export all environment variables. Load the OpenMPI module and execute the program 4 processes. "
//        }
//        else {
//            prompt = "Respond with only a terminal command: "
//        }
//        writeCode(recording: recording, prompt: prompt)
//    }
//}
//
//
//func writeCode(recording: String, prompt: String) {
//    
//    do {
//        Task {
//            let response = try await Argo().getResponse(prompt:  prompt + recording + "' " + recording)
//            Argo().conversationManager.addEntry(prompt: recording, response: response)
//        }
//    }
//}
