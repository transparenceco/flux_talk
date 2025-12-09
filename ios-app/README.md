# FluxTalk iOS App

This is a native iOS application built with SwiftUI for the Flux Talk chat system.

## Project Structure

The app is now a standard Xcode iOS App project (not a Swift Package):

```
FluxTalk.xcodeproj/     - Xcode project file
FluxTalk/               - App target directory
  ├── FluxTalkApp.swift - App entry point
  ├── Views/            - SwiftUI views
  │   ├── ChatView.swift
  │   └── SettingsView.swift
  ├── ViewModels/       - View models
  │   └── ChatViewModel.swift
  ├── Services/         - API and service layer
  │   └── APIService.swift
  ├── Models/           - Data models
  │   └── Models.swift
  └── Assets.xcassets/  - App assets and icons
```

## Dependencies

The app uses Swift Package Manager for dependencies:

- **ExyteChat** (1.2.0+): Modern chat UI components

Dependencies are managed through Xcode's Swift Package integration, referenced in the `.xcodeproj` file.

## Building the App

1. Open `FluxTalk.xcodeproj` in Xcode
2. Select a simulator or device
3. Press `Cmd+R` to build and run

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 6.0

## Configuration

The app connects to the Flux Talk backend server. Configure the server URL in the Settings view within the app.

## Features

- Real-time chat interface with message bubbles
- AI mode switching (Local/Grok/OpenAI)
- Comprehensive AI settings configuration
- Temperature control
- Model selection
- API key management
- Vector database context toggle
- Chat history management
- Server URL configuration

## Notes

This project was converted from a Swift Package to a full iOS App project to provide better integration with Xcode tooling and standard iOS app development workflows.
