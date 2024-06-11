//
//  Functions.swift
//  GENIUS
//
//  Created by Abdullah Ali on 6/3/24.
//

import Foundation

// Function to generate image names
func generateGeniusFrames() -> [String] {
    var imageNames: [String] = []
    for i in 1...120 {
        let imageName = String(format: "%04d", i) // Ensures the format is 4 digits with leading zeros
        imageNames.append(imageName)
    }
    return imageNames
}
