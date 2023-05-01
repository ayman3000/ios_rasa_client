import SwiftUI

struct ContentView: View {
    // Initialize the view model
    @StateObject private var rasaChatViewModel = RasaChatViewModel()
    // Initialize the input text
    @State private var inputText = ""

    var body: some View {
        NavigationView {
            VStack {
                // Show messages in a scrollable view
                ScrollView {
                    ScrollViewReader { proxy in
                        // Loop through all messages and show each in a ChatMessageView
                        LazyVStack {
                            ForEach(rasaChatViewModel.messages) { message in
                                ChatMessageView(message: ChatMessage(sender: message.sender, text: message.text, buttons: message.buttons), viewModel: rasaChatViewModel)
                            }
                            .onChange(of: rasaChatViewModel.messages) { _ in
                                // Scroll to the last message when a new one is added
                                proxy.scrollTo(rasaChatViewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
                // Show a message input box with a speech recognition button and a send button
                MessageInputView(inputText: $inputText, rasaChatViewModel: rasaChatViewModel, onRecognizedText: { recognizedText in
                    rasaChatViewModel.sendMessage(text: recognizedText)
                })
            }
            .padding()
        }
        // Set navigation bar title and add a speaker toggle button to the navigation bar
        .navigationBarTitle("AAST Bot", displayMode: .large)
        .navigationBarItems(trailing:
            Button(action: {
                // Toggle the text-to-speech feature
                rasaChatViewModel.isTTSEnabled.toggle()
            }) {
                Image(systemName: rasaChatViewModel.isTTSEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
