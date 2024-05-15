//
//  GENIUSApp.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI

@main
struct GENIUSApp: App {

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                ChatView()
            }
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
