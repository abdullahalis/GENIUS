//  SimView.swift
//  GENIUS
//
//  Created by Abdullah Ali on 6/19/24.
//

import SwiftUI
import AVKit

struct SimView: View {
    let url: String

    var body: some View {
        if let videoURL = URL(string: url) {
            VideoPlayer(player: AVPlayer(url: videoURL))
                .navigationTitle("Simulation")
        } else {
            Text("Invalid URL")
                .foregroundColor(.red)
        }
    }
}
