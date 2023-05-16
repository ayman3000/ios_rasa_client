# aRasa Client

This is an iOS client that connects to a Rasa chatbot using Socket.IO. It allows the user to send text messages to the bot and receive responses in real time. The app also includes speech recognition capabilities to enable the user to speak their message instead of typing it.

## Requirements

- Xcode 12 or later
- iOS 14 or later
- Swift 5 or later

## Features

- Real-time communication with a Rasa chatbot using SocketIO
- Support for text-based messages and quick reply buttons
- Speech recognition for converting spoken words into text messages (iOS only)
- Text-to-speech functionality for reading chatbot responses aloud (iOS only)
- Customizable appearance and settings

## Getting Started

1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. pod install
4. Change the URL in the `setupSocket()` function of the `RasaChatViewModel` to the URL of your Rasa chatbot.
5. Build and run the app on a simulator or a physical device.
6. yoy can modify the Rasa server url via the Settings screen.

## Usage

- Launch the aRasa Chatbot app on your device or simulator.

- Enter your message in the input field at the bottom of the screen and tap the "Send" button to send the message to the chatbot.

- View the chat history in the scrolling view in the middle of the screen. Incoming messages from the chatbot will appear on the left side, while outgoing messages from the user will appear on the right side.

- If the chatbot provides quick reply buttons, you can tap on a button to send the corresponding message.

- Optionally, enable speech recognition by tapping the microphone button next to the input field. Speak your message, and it will be converted into text and sent to the chatbot.

- If enabled, the chatbot's responses will be read aloud using text-to-speech. You can control the text-to-speech functionality through the speaker button in the navigation bar.

- Customize the app's settings by tapping the gear button in the navigation bar. Adjust the socketio address or modify other preferences to suit your needs.

## Note
It's important for developers to add their own signing information when using this project. They can do this by opening the Xcode project, selecting the target, and then selecting the "Signing & Capabilities" tab. From there, they can add their own signing information. It's important to note that this step is necessary for the project to run correctly on a physical device or to be distributed through the App Store.

## Future Improvements

- Use Rasa REST APIs instead of Socket.IO
- Improve the UI and UX of the app

## Contributing

Contributions are welcome! If you find any issues or have any ideas for improvement, please open an issue or a pull request.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.
