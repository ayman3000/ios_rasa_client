//import SwiftUI
//
//struct Messenger: View {
//    @State private var message = ""
//    @State private var recognizedText = ""
//    @State private var messages: [Message] = [
//        Message(text: "Hey, how's it going?", isBot: true),
//        Message(text: "Not bad, you?", isBot: false),
//        Message(text: "Pretty good. What have you been up to?", isBot: true),
//        Message(text: "Not much, just hanging out.", isBot: false)
//    ]
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 8) {
//                        ForEach(messages, id: \.self) { message in
//                            ChatMessageView2(message: message)
//                        }
//                    }
//                    .padding(.horizontal)
//                    .padding(.bottom, 50) // add bottom padding for the input field
//                }
//
//                HStack {
//                    ZStack {
//                        if message.isEmpty {
//                            Text("Type a message...")
//                                .foregroundColor(.gray)
//                                .padding(.leading)
//                        }
//                        TextField("", text: $message)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding(.horizontal)
//                            .accentColor(.blue)
//                    }
//                    .frame(height: 50)
//                    .background(Color(UIColor.systemGray6))
//                    .cornerRadius(25)
//                    .overlay(
//                        HStack {
////                            Button(action: {
////                                // show voice input
////                            }) {
////                                Image(systemName: "mic")
////                                    .foregroundColor(.gray)
////                                    .padding(.leading, 10)
////                            }
//                            SpeechRecognitionButton(recognizedText: $recognizedText)
//                            Spacer()
//                            Button(action: {
//                                // send message
//                                messages.append(Message(text: message, isBot: false))
//                                message = ""
//                            }) {
//                                Text("Send")
//                                    .foregroundColor(.blue)
//                                    .padding(.trailing, 10)
//                            }
//                        }
//                    )
//                    .padding(.horizontal)
//                }
//                .padding()
//                .background(Color(UIColor.systemGroupedBackground))
//                .overlay(Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
//                .padding(.horizontal)
//                .padding(.bottom)
//            }
//
//            .navigationBarTitle("AAST Bot", displayMode: .inline )
//            .navigationBarItems( trailing:
//                                    Button(action: {
//                                        
//
//                // show settings
//            }) {
//                Image(systemName: "gear")
//                    .foregroundColor(.blue)
//            }
//            )
//            
//            
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        .preferredColorScheme(.dark)
//    }
//}
//
//struct ChatMessageView2: View {
//    let message: Message
//
//    var body: some View {
//        HStack(alignment: .bottom) {
//            if message.isBot {
//                Image(systemName: "bolt.fill")
//                    .font(.system(size: 18))
//                    .foregroundColor(.blue)
//                    .padding(.trailing, 6)
//                Text(message.text)
//                    .padding(12)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            } else {
//                Spacer()
//                Text(message.text)
//                    .padding(12)
//                    .background(Color(UIColor.white))
//                    .foregroundColor(.black)
//                    .cornerRadius(10)
//                Image(systemName: "person.fill")
//                    .font(.system(size: 18))
//                    .foregroundColor(.green)
//                    .padding(.leading, 6)
//            }
//        }
//        .padding(.vertical, 4)
//    }
//}
//
//struct Message: Hashable {
//    let text: String
//    let isBot: Bool
//}
//
//
//
//
//
//
//// add a preview
//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        Messenger()
//    }
//}
//
