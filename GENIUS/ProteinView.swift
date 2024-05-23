//
//  ProteinView.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 5/23/24.
//

import SwiftUI

struct ProteinView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    proteinMenuItems()
                    VStack {
                        NavigationLink("Go back", destination: ContentView(updatingTextHolder: UpdatingTextHolder()))
                            .padding()
                    }
                    .navigationTitle("Protein View")
                }
            }
        }
    }
}

struct proteinMenuItems: View {
    var body: some View {
        
        VStack {
            Text("Welcome to the ProteinView")
                .font(.system(size: 30, weight: .medium))
            Image(systemName: "lizard.circle")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
        }
        .padding(.bottom, 40)

    }
}

#Preview {
    ProteinView()
}
