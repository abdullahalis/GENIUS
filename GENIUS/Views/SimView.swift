import SwiftUI
import AVKit
import Combine

struct SimView: View {
    let parameters: String
    @ObservedObject var downloader = VideoDownloader()
    
    var body: some View {
        NavigationStack {
            VStack {
                if downloader.isLoading {
                    ProgressView("Running sim...")
                } else if let videoURL = downloader.videoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 700)
                }
            }
            .padding()
            .onAppear {
                // Parse parameters into variables and download sim using those numbers
                if let (d, s, l, v, t, f) = parseParams(from: parameters) {
                    print("successful simulation running")
                    downloader.downloadVideo(density: d, speed: s, length: l, viscosity: v, time: t, freq: f)
                }
                else {
                    print("Couldn't parse parameters")
                    UpdatingTextHolder.shared.responseText = "Sorry, an error occured when parsing the paramaters"
                }
            }
        }.background(Color(.systemGray6))
    }
    
    func parseParams(from input: String) -> (String, String, String, String, String, String)? {
        // Split the input string by commas
        let components = input.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        
        // Ensure we have exactly 6 components
        guard components.count == 6 else { return nil }
        
        // Return the parsed values as a tuple
        return (components[0], components[1], components[2], components[3], components[4], components[5])
    }
}

class VideoDownloader: ObservableObject {
    @Published var isLoading = false
    @Published var videoURL: URL?
    var cancellables = Set<AnyCancellable>()
    
    func downloadVideo(density: String, speed: String, length: String, viscosity: String, time: String, freq: String) {
        var urlComponents = URLComponents(string: "http://" + Login().getIP() + ":5000/video")
        urlComponents?.queryItems = [
            URLQueryItem(name: "density", value: density),
            URLQueryItem(name: "speed", value: speed),
            URLQueryItem(name: "length", value: length),
            URLQueryItem(name: "viscosity", value: viscosity),
            URLQueryItem(name: "time", value: time),
            URLQueryItem(name: "freq", value: freq)
        ]
        
        guard let url = urlComponents?.url else { return }
        
        isLoading = true
        
        // Configure URLSession with custom timeout intervals
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 12000 // 2 minutes
        configuration.timeoutIntervalForResource = 300 // 5 minutes
        let session = URLSession(configuration: configuration)
        
        session.dataTaskPublisher(for: url)
            .map { $0.data }
            .map { data -> URL? in
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.mp4")
                do {
                    try data.write(to: tempURL, options: .atomic)
                    return tempURL
                } catch {
                    print("Error writing video file: \(error)")
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    print("Failed to download video: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] url in
                self?.videoURL = url
            })
            .store(in: &cancellables)
    }
}
