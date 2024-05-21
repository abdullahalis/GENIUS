import Foundation

class ConversationManager: ObservableObject {
    struct ConversationEntry: Identifiable {
        let id = UUID()
        let prompt: String
        let response: String
    }

    @Published private(set) var conversationHistory: [ConversationEntry] = []

    // Singleton instance for global access
    static let shared = ConversationManager()

    private init() { }

    func addEntry(prompt: String, response: String) {
        let entry = ConversationEntry(prompt: prompt, response: response)
        conversationHistory.append(entry)
    }

    func getConversationHistory() -> [ConversationEntry] {
        return conversationHistory
    }
    
    func getContext() -> String {
        let recent = conversationHistory.suffix(10)
        var context = "This is the recent history of our conversation: "
        recent.forEach {entry in
            context += "I prompted '" + entry.prompt + "'."
            context += "You responded '" + entry.response + "'.'"
        }
        context += "Using this context answer the following prompt: "
        return context
    }
}
