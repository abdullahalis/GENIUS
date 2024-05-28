//
//  Protein.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 5/23/24.
//
import Foundation

// Get string of proteins, map them.
// Use the mapped identifiers to request interactions data
let method = "network"


//let myGenes = ["CDC42","CDK1","KIF23","PLK1",
//              "RAC2","RACGAP1","RHOA","RHOB"]

//let identifiers = myGenes.joined(separator: "%0d")
let identifiers = "CDC42"
let species = "9606" // species NCBI identifier
let callerIdentity = "Genius" // your app name

let params = [
    "identifiers": identifiers,
    "species": species,
    "caller_identity": callerIdentity
]


// General function to make API requests
// Returns a string with requested data
func requestAPI(method: String, params: [String:Any], completion: @escaping (String?) -> Void) {
    
    let stringAPIURL = "https://version-11-5.string-db.org/api"
    let outputFormat = "tsv-no-header"
    let requestURL = "\(stringAPIURL)/\(outputFormat)/\(method)"
    var stringResponse: String?
    let session = URLSession.shared

    if let url = URL(string: requestURL) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let requestBody = params.map { (key, value) in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        request.httpBody = requestBody.data(using: .utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            if let data = data {
                stringResponse = String(data: data, encoding: .utf8)
                completion(stringResponse)
            }
        }
        task.resume()
    } else {
        print("Invalid URL")
        completion(nil)
    }
}

// Function to get proteins
func getProteins(proteins: [String]) {
    mapIdentifiers(proteinNames: proteins) { identifiers in

        if !identifiers.isEmpty {
            let params: [String: Any] = [
                "identifiers": Array(identifiers.keys).joined(separator: "%0d"),
                "species": 9606,
                "caller_identity": "Genius"
            ]
            
            requestAPI(method: "network", params: params) { response in
                if let proteinString = response {
                    let lines = proteinString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
                    for line in lines {
                        let components = line.components(separatedBy: "\t")
                        if components.count >= 11 {
                            let p1 = components[2]
                            let p2 = components[3]
                            if let experimentalScore = Double(components[10]), experimentalScore > 0.4 {
                                print("\(p1)\t\(p2)\texperimentally confirmed (prob. \(String(format: "%.3f", experimentalScore)))")
                            }
                        }
                    }
                } else {print("The database returned NULL.")}
            }
        } else {print("Protein(s) couldn't be mapped to valid identifiers.")}
    }
}

// Function to map user-submitted protein names to STRING identifiers
// [Identifier:Name]
func mapIdentifiers(proteinNames: [String], completion: @escaping ([String:String]) -> Void) {
    var mapDict: [String:String] = [:]
    let params: [String: Any] = [
        "identifiers": proteinNames.joined(separator: "\r"),
        "species": 9606,
        "caller_identity": "Genius"
    ]
    
    requestAPI(method: "get_string_ids", params: params) { response in
        if let proteinString = response {

            let lines = proteinString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
            for line in lines {
                let components = line.components(separatedBy: "\t")
                if components.count >= 5 {
                    let name = components[4]
                    let identifier = components[1]
                    print("\(identifier): \(name)")
                    mapDict[identifier] = name
                }
            }
            completion(mapDict)
        } else {
            print("The database returned NULL.")
            completion([:])
        }
    }
}
