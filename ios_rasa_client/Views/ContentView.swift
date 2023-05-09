import SwiftUI


struct ContentView: View {
    // Initialize the view model
    @StateObject private var rasaChatViewModel = RasaChatViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    // Initialize the input text
    @State private var inputText = ""
    @State var socketioAddress: String = "http://localhost:5005"
    @State private var settingsPresented = false


    var body: some View {

        NavigationView {
            ZStack {
                Color(red: 0.0, green: 0.1, blue: 0.0, opacity: 0.2)
                    .ignoresSafeArea()

                VStack {
                    // Show messages in a scrollable view
                    ScrollView {
                        ScrollViewReader { proxy in
                            // Loop through all messages and show each in a ChatMessageView
                            LazyVStack {
                                ForEach(rasaChatViewModel.messages.dropFirst()) { message in
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
                .foregroundColor(.white)
                .padding()

                // Set navigation bar title and add a speaker toggle button to the navigation bar
                .navigationBarTitle("Rasa Chatbot",
                                    displayMode: .inline)
                .font(.title)




            }
                                    .navigationBarItems(leading:
                                        Button(action: {
                    rasaChatViewModel.isTTSEnabled.toggle()
                }) {
                    Image(systemName: rasaChatViewModel.isTTSEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")

                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                },
//                                    trailing: NavigationLink(destination:  SettingsView(viewModel: settingsViewModel)) {
////                                        Text("Settings")
////                                              .font(.system(size: 20, weight: .medium))
////                                              .foregroundColor(.white)
//                    Image(systemName: "gear")
//                        .resizable()
//                        .frame(width: 20, height: 20)
//                        .foregroundColor(.white)
//                }
//                )

                trailing: Button(action: {
                       settingsViewModel.socketioAddress = socketioAddress
//                       rasaChatViewModel.updateSocketAddress(socketioAddress: settingsViewModel.socketioAddress)
//                       settingsViewModel.showSettings = true
                                        settingsPresented = true
                   }) {
                       Image(systemName: "gear")
                           .resizable()
                           .frame(width: 20, height: 20)
                   }
                   .sheet(isPresented: $settingsPresented) {
                       SettingsView(viewModel: settingsViewModel)
                   }
        )}

        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.accentColor)
        .onTapGesture {
//            settingsPresented = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}
let contentView = ContentView() // assigning to a variable


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
