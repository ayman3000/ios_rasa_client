import SwiftUI

struct ContentView: View {
    @StateObject private var rasaChatViewModel = RasaChatViewModel()
    @State private var inputText = ""
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack {
                        ForEach(rasaChatViewModel.messages) { message in
                            ChatMessageView(message: message)
                        }
                    }
                    .onChange(of: rasaChatViewModel.messages) { _ in
                        proxy.scrollTo(rasaChatViewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            MessageInputView(recognizedText: $inputText, inputText: $inputText, rasaChatViewModel: rasaChatViewModel)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
