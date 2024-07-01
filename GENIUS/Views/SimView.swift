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
            downloader.downloadVideo()
        }
    }
}

class VideoDownloader: ObservableObject {
    @Published var isLoading = false
    @Published var videoURL: URL?
    var cancellables = Set<AnyCancellable>()
    
    func downloadVideo() {
        guard let url = URL(string: "http://" + Login().getIP() + ":5000/video") else { return }
        
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
