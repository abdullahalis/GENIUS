//
//  ContentView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GestureKit
import Speech

struct ContentView: View {
    @EnvironmentObject var recorder: Recorder
    @EnvironmentObject var argo: Argo
    @ObservedObject var updatingTextHolder = UpdatingTextHolder.shared
    
    @State private var handsTogether = false
    @State private var prompt = ""
    @State private var showImmersiveSpace = true
    @State private var immersiveSpaceIsShown = true
    @State private var nightMode = false
    @State private var isRecording = false
    
    @State private var question = ""
    @State private var meetingText = ""
    let speechSynthesizer = AVSpeechSynthesizer()
    
    let frameDuration = 1.0 / 30.0 // 30 fps
    
    @State private var textOpacity: Double = 0.0
    @State private var circleScale: CGFloat = 1.0
    @State private var time: CGFloat = 0.0
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [.blue, .purple, .clear]),
                                center: .center,
                                startRadius: 100 * circleScale,
                                endRadius: 500 * circleScale
                            )
                        )
                        .frame(width: 600 * circleScale, height: 600 * circleScale)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .blur(radius: 50)
                        .opacity(0.6)
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)
                    ) {
                        circleScale = 1.2
                    }
                }
                
                VStack {
                    Spacer() // Pushes content to the top
                    
                    Text("GENIUS")
                        .font(Font.custom("Dune_Rise", size: 64, relativeTo: .title))
                        .opacity(textOpacity)
                        .padding()
                        .onAppear {
                            withAnimation(.easeIn(duration: 3.0)) {
                                textOpacity = 1.0
                            }
                        }.padding()
                    
                    Text("\(updatingTextHolder.mode)")
                        .foregroundColor(.gray)
                    
                    ScrollView {
                        Text(updatingTextHolder.recongnizedText)
                            .frame(width: 1000)
                            .multilineTextAlignment(.trailing)
                    }
                    .frame(height: 60)
                    
                    ScrollView {
                        Text(updatingTextHolder.responseText)
                            .frame(width: 1000)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(height: 60)
                    
                    Spacer() // Pushes content upwards
                    
                    VStack(spacing: 30) {
//                        Button("Video") {
//                            openWindow(id: "sim", value: "https://www.w3schools.com/html/mov_bbb.mp4")
//                        }
                        
                        Button(action: {
                            updatingTextHolder.isRecording.toggle()
                            if updatingTextHolder.isRecording {
                                recorder.startRecording()
                            } else {
                                print("button stop")
                                recorder.stopRecording()
                                argo.handleRecording()
                            }
                        }) {
                            Image(systemName: updatingTextHolder.isRecording ? "stop.circle" : "record.circle")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundColor(updatingTextHolder.isRecording ? .red : .primary)
                        }
                        .frame(width: 75, height: 75)
                        .padding()
                        
                        .textFieldStyle(.roundedBorder)
                        
                        Button {
                            showAlert.toggle()
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        .padding()
                        
                        .sheet(isPresented: $showAlert) {
                            InfoPopupView(showAlert: $showAlert)
                        }
                    }
                    .padding()
                }
                .padding(.bottom) // Add padding to move content upwards
                
            }
            .frame(minWidth: 600, idealWidth: 800, maxWidth: .infinity, minHeight: 400, idealHeight: 600, maxHeight: .infinity)
        }
        .background(Color(.systemGray6))
        .onAppear {
            Task {
                await openImmersiveSpace(id: "ImmersiveSpace")
            }
        }
    }

}

#Preview(windowStyle: .automatic) {
    ContentView()
}

struct mainMenuItems: View {
    var body: some View {
        
        VStack {
            GeniusAnimView()
                .frame(width: 200, height: 200)
            
        }
    }
}



struct ImageSequenceView: View {
    let imageNames: [String]
    let frameDuration: Double
    
    @State private var currentFrame = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        Image(imageNames[currentFrame])
            .resizable()
            .scaledToFit()
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % imageNames.count
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct InfoPopupView: View {
    @Binding var showAlert: Bool
    
    var body: some View {
            VStack(spacing: 20) {
                Text("Activating GENIUS")
                    .font(.headline)
                
                // Example image; replace with your own image or 3D model view
                
                
                Text("GENIUS can be activated by clicking the record button or by putting your fingers together as shown below. Your prompt is recorded as long as you hold the gesture and will be sent to GENIUS upon release.")
                    .multilineTextAlignment(.center)
                
                Image("hands-together")
                    .resizable()
                    .frame(width: 150, height: 150)
                
                Button(action: {
                    // Dismiss action
                    showAlert = false
                }) {
                    Text("OK")
                        
                }
            }
            .padding()
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding()
            .frame(width: 400)
        }
}

struct AudioVisualizerView: View {
    @Binding var audioLevel: Float
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.green)
                    .frame(width: geometry.size.width, height: CGFloat(self.audioLevel) * geometry.size.height)
                    .animation(.linear(duration: 0.1), value: audioLevel)
            }
        }
    }
}





final class UpdatingTextHolder: ObservableObject {
    static let shared = UpdatingTextHolder()
    @Published var responseText: String = ""
    @Published var recongnizedText: String = ""
    @Published var isRecording: Bool = false
    @Published var mode: String = " "
    @Published var meetingManagers: [MeetingManager] = []
    
    private init() {
        
    }
}
