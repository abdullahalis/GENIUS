import Foundation

struct PolarisCommands {
    var inputs: [String]
    var outputs: [String]
    var directory: String
}

func sendPostRequest(command: [String], directory: String, completion: @escaping (PolarisCommands) -> Void ) {
    guard let url = URL(string: "http://" + Login().getIP() + ":5000/polaris")
    else {
        print("Invalid URL")
        completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let parameters: [String: Any] = [
        "user": Login().getUser(),
        "password": Login().getPass(),
        "command": command,
        "directory": directory
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    } catch {
        print("Failed to serialize JSON: \(error)")
        completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid response")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
            return
        }
        
        guard let data = data else {
            print("No data")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let output = json["output"] as? [String], let directory = json["directory"] as? String{
                print("JSON Response: \(json)")
                print("Directory: \(directory)")
                completion(PolarisCommands(inputs: command, outputs: output, directory: directory))
            } else {
                completion(PolarisCommands(inputs: ["error2"], outputs: ["error2"], directory: "error2"))
            }
        } catch {
            print("Failed to decode JSON: \(error)")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
        }
    }
    
    task.resume()
}


func codeRequest(command: String, completion: @escaping (String) -> Void ) {
    guard let url = URL(string: "http://" + Login().getIP() + ":5000/video") else {  //127.0.0.1:5000
        print("Invalid URL")
        completion("error")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let parameters: [String: Any] = [
        "user": Login().getUser(),
        "password": Login().getPass(),
        "command": command,
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    } catch {
        print("Failed to serialize JSON: \(error)")
        completion("error")
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            completion("error")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid response")
            completion("error")
            return
        }
        
        guard let data = data else {
            print("No data")
            completion("error")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let output = json["output"] as? [String], let directory = json["directory"] as? String{
                print("JSON Response: \(json)")
                print("Directory: \(directory)")
                completion("true")
            } else {
                completion("error2")
            }
        } catch {
            print("Failed to decode JSON: \(error)")
            completion("error")
        }
    }
    
    task.resume()
}


//func videoRequest(command: String, completion: @escaping (String) -> Void) {
//    guard let url = URL(string: "http://" + Login().getIP() + ":5000/video") else {
//        print("Invalid URL")
//        completion("error")
//        return
//    }
//    
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    
//    let parameters: [String: Any] = [
//        "user": Login().getUser(),
//        "password": Login().getPass(),
//        "command": command,
//    ]
//    
//    do {
//        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
//    } catch {
//        print("Failed to serialize JSON: \(error)")
//        completion("error")
//        return
//    }
//    
//    let task = URLSession.shared.downloadTask(with: request) { location, response, error in
//        if let error = error {
//            print("Error: \(error)")
//            completion("error")
//            return
//        }
//        
//        guard let httpResponse = response as? HTTPURLResponse,
//              (200...299).contains(httpResponse.statusCode) else {
//            print("Invalid response")
//            completion("error")
//            return
//        }
//        
//        guard let location = location else {
//            print("No file location")
//            completion("error")
//            return
//        }
//        
//        do {
//            let fileManager = FileManager.default
//            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            let destinationURL = documentsURL.appendingPathComponent("output.mp4")
//            
//            // Remove existing file if it exists
//            if fileManager.fileExists(atPath: destinationURL.path) {
//                try fileManager.removeItem(at: destinationURL)
//            }
//            
//            try fileManager.moveItem(at: location, to: destinationURL)
//            
//            // Verify that the file exists at the destination path
//            if fileManager.fileExists(atPath: destinationURL.path) {
//                completion(destinationURL.path)
//            } else {
//                print("File does not exist at the destination path")
//                completion("error")
//            }
//        } catch {
//            print("Failed to move file: \(error)")
//            completion("error")
//        }
//    }
//    
//    task.resume()
//}

//func handlePolarisCommand(updatingTextHolder: UpdatingTextHolder, command: String) -> String {
//    let recording = updatingTextHolder.recongnizedText
//
//
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
//        return codeRequest(command: prompt, completion: <#(String) -> Void#>) {
//
//        }
//    }
//    return ""
//}


