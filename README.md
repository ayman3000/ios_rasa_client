# iOS Rasa Client

This is an iOS client that connects to a Rasa chatbot using Socket.IO. It allows the user to send text messages to the bot and receive responses in real time. The app also includes speech recognition capabilities to enable the user to speak their message instead of typing it.

## Requirements

- Xcode 12 or later
- iOS 14 or later
- Swift 5 or later

## Features

- Connect to a Rasa chatbot using Socket.IO
- Send text messages to the bot
- Receive responses from the bot in real time
- Speech recognition to enable the user to speak their message instead of typing it

## Getting Started

1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Change the URL in the `setupSocket()` function of the `RasaChatViewModel` to the URL of your Rasa chatbot.
4. Build and run the app on a simulator or a physical device.

## Note
It's important for developers to add their own signing information when using this project. They can do this by opening the Xcode project, selecting the target, and then selecting the "Signing & Capabilities" tab. From there, they can add their own signing information. It's important to note that this step is necessary for the project to run correctly on a physical device or to be distributed through the App Store.

## Future Improvements

- Use Rasa REST APIs instead of Socket.IO
- Improve the UI and UX of the app

## Contributing

Contributions are welcome! If you find any issues or have any ideas for improvement, please open an issue or a pull request.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.
