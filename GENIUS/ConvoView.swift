//
//  ConvoView.swift
//  GENIUS
//
//  Created by Abdullah Ali on 5/28/24.
//

import SwiftUI

struct ConvoView: View {
    @ObservedObject var conversationManager: ConversationManager = ConversationManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(conversationManager.getConversationHistory()) { entry in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Spacer()
                                Text(entry.prompt)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: 300, alignment: .trailing)
                            }
                            HStack {
                                Text(entry.response)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .frame(maxWidth: 300, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("History")
            .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    ConvoView()
}
