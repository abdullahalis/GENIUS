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
            GENIUSDescription()
            Text("All Hand Gestures")
                .font(.system(size: 40, weight: .bold))
            VStack(alignment: .leading){
                HandGestureDescriptions(description: "Used to start recording audio in order to talk to Argo", imageName: "hands-together", gestureName: "Hands Together")
                HandGestureDescriptions(description: "Used to stop recording audio", imageName: "spiderman", gestureName: "Spiderman")
            }
            .padding()
            Text("All Voice Commands")
                .font(.system(size: 40, weight: .bold))
            VStack(alignment: .leading){
                VoiceCommand(command: "Hey Genius", description: "Used to indicated you are asking a questions")
                VoiceCommand(command: "Thank you", description: "Used to indicated you are finished asking a questions")
            }
        }
    }
}


#Preview(windowStyle: .automatic) {
    HelpView()
}

struct GENIUSDescription : View {
    var body: some View {
        VStack(alignment: .center) {
            Text("What is GENIUS?")
                .font(.system(size: 40, weight: .bold))
            Text("GENIUS is an AI personal assistant specifically tailored for scientists engaged in experimentation and research. It would assist them in conducting experiments, facilitate learning, and ensure safety.GENIUS is built as an integration of Argonne's in-house AI chatbot Argo with the XR capabilities of the Apple Vision Pro. Users will be able to ask Argo questions, have conversations and meetings recorded and summarized, analyze visual imagery for descriptions and so on.")
                .font(.system(size: 20, weight: .medium))
        }
    }
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

struct VoiceCommand: View {
    var command: String
    var description: String
    
    var body: some View {
        HStack{
            Text("\(command): ")
                .font(.system(size: 30, weight: .medium))
            Text("\(description)")
                .font(.system(size: 20, weight: .medium))
        }
    }
}
