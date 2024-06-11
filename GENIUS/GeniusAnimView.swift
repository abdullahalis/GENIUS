//
//  GeniusAnimView.swift
//  GENIUS
//
//  Created by Abdullah Ali on 6/3/24.
//

import SwiftUI

struct GeniusAnimView: View {
    @ObservedObject var animationManager: AnimationManager = AnimationManager.geniusShared
        
        var body: some View {
            Image(animationManager.imageFrames[animationManager.currentFrame])
                .resizable()
                .scaledToFit()
                .onAppear {
                    if animationManager.isPlaying {
                        animationManager.startAnimation()
                    }
                }
                .onDisappear {
                    animationManager.stopAnimation()
                }
        }
}

//#Preview {
//    GeniusAnimView(animationManager: AnimationManager())
//}
