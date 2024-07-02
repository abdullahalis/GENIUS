import SwiftUI
import AVKit
import Combine

struct SimView: View {
    @ObservedObject var downloader = VideoDownloader()
    
    var body: some View {
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
            downloader.downloadVideo(density: "1000", speed: "1.0", length: "2.5", viscosity: "1.3806", time: "8.0", freq: "0.04")
        }
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
