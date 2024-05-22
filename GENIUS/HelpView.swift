//
//  HelpView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/22/24.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView() {
            Text("All Hand Gestures")
                .font(.system(size: 30, weight: .medium))
            VStack(alignment: .leading){
                HandGestureDescriptions(description: "Used to start recording audio in order to talk to Argo", imageName: "hands-together", gestureName: "Hands Together")
                HandGestureDescriptions(description: "Used to stop recording audio", imageName: "spiderman", gestureName: "Spiderman")
            }
            .padding()
        }
    }
}

#Preview(windowStyle: .automatic) {
    HelpView()
}

struct HandGestureDescriptions: View {
    var description: String
    var imageName: String
    var gestureName: String
    
    var body: some View {
        
        HStack(alignment: .top) {
            Image(imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
                .padding(.trailing, 10)
            VStack(alignment: .leading) {
                Text("\(gestureName)")
                    .font(.system(size: 30, weight: .medium))
                Text("\(description)")
                    .font(.system(size: 20, weight: .medium))
            }
        }
    }
}
