import SwiftUI


struct ContentView: View {
    // Initialize the view model
    @StateObject private var rasaChatViewModel = RasaChatViewModel()
    // Initialize the input text
    @State private var inputText = ""
    @State var socketioAddress: String = "http://localhost:5005"
    @State private var settingsPresented = false
    var body: some View {
       

        NavigationView {
           
                
            ZStack {
                Color(red: 0.0, green: 0.2, blue: 0.0, opacity: 0.2)
                    .ignoresSafeArea()

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
                .foregroundColor(.white)
                .padding(.top,20)

                // Set navigation bar title and add a speaker toggle button to the navigation bar
                .navigationBarTitle("aRasa Chatbot",
                                    displayMode: .inline)
                .font(.headline)
                

            }
            
                                    .navigationBarItems(leading:
                                                            HStack(spacing: 10){
                                        Button(action: {
                    rasaChatViewModel.isTTSEnabled.toggle()
                                    }) {
                                        Image(systemName: rasaChatViewModel.isTTSEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                                        
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.white)
                                    }
                                        if rasaChatViewModel.interfaceType == .socketIO {
                                            Image(systemName: rasaChatViewModel.isConnected  ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(rasaChatViewModel.isConnected ? .green : .red)
                                        }
                },

                trailing: Button(action: {
                                        settingsPresented = true
                   }) {
                       Image(systemName: "gear")
                           .resizable()
                           .frame(width: 30, height: 30)
                   }
                   .sheet(isPresented: $settingsPresented) {
                       SettingsView( isPresented: $settingsPresented, viewModel: rasaChatViewModel)
                   }
        )}


        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.accentColor)
        .onTapGesture {
//            settingsPresented = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        .onAppear {
//            NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
//                    self.rasaChatViewModel.disconnectSocket()
//                }

                NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _ in
                    self.rasaChatViewModel.disconnectSocket()
                }
            
        }
        
        
    }
    
    
}
let contentView = ContentView() // assigning to a variable


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
