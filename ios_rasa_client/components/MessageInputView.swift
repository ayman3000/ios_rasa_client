import SwiftUI

struct MessageInputView: View {
    // @Binding var recognizedText: String
    @Binding var inputText: String
    @ObservedObject var rasaChatViewModel: RasaChatViewModel
//    @State private var isFocused = false
    @FocusState private var isFocused: Bool

    
    let onRecognizedText: (String) -> Void

    var body: some View {
        HStack {

            // Custom view for speech recognition button
            SpeechRecognitionButton(onRecognizedText: onRecognizedText)

            // Text field for manual message input
            TextField("Type your message...", text: $inputText)
                .font(.system(size: 18))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .fontWeight(.regular)
                .padding(.horizontal, 5)
                .focused($isFocused)
                .onSubmit {
                               self.sendButtonAction()
                           }
                .onAppear {
                    isFocused  = true
                }
            // Button to send the user's message
            Button(action: {
                print("Send button tapped")
                if !inputText.isEmpty {
                    // Call the sendMessage function of the view model to send the message
                    rasaChatViewModel.sendMessage(text: inputText)
                    // Reset the input text to an empty string
                    inputText = ""
                    isFocused = true
                }
            }) {
                Text("Send")
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .font(.system(size: 16, weight: .regular))
                    
            }
        }
//        .padding()
    }
    
    private func sendButtonAction() {
           print("Return button tapped")
           if !inputText.isEmpty {
               rasaChatViewModel.sendMessage(text: inputText)
               inputText = ""
           }
        isFocused = true
       }
}
