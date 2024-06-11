//
//  AnimationManager.swift
//  GENIUS
//
//  Created by Abdullah Ali on 6/3/24.
//

import SwiftUI
import Combine

class AnimationManager: ObservableObject {
    @Published var currentFrame = 0
    @Published var isPlaying = false
    
    var timer: Timer?
    let frameDuration: Double
    let imageFrames: [String]
    
    private init(imageFrames: [String], frameDuration: Double) {
        self.imageFrames = imageFrames
        self.frameDuration = frameDuration
    }
    
    static let geniusShared = AnimationManager(imageFrames: generateGeniusFrames(), frameDuration: 0.05)
    
    
    func startAnimation() {
        stopAnimation()
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { _ in
            self.currentFrame = (self.currentFrame + 1) % self.imageFrames.count
        }
    }
    
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }
    
    func toggleAnimation() {
        isPlaying ? stopAnimation() : startAnimation()
    }
    
    
}

