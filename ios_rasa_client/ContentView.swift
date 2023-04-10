import SwiftUI

struct ContentView: View {
    @StateObject private var rasaChatViewModel = RasaChatViewModel()
    @State private var inputText = ""
    
    var body: some View {
        NavigationView {
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
        
//        .padding()
        .navigationBarTitle("Rasa Chat", displayMode: .large)
                  .navigationBarItems(trailing:
                      Button(action: {
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
