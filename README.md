# TAPIN. - Golf Mobile App

A Flutter mobile app designed for golfers to manage their game, book tee times, and discover new golf courses.

## Features

- **TAPIN. (Home)**: Main dashboard with quick actions and overview
- **Play**: Start different types of golf rounds (Quick Round, Group Play, Tournament, Practice)
- **Book**: Reserve tee times and manage bookings
- **Search**: Find and discover golf courses with filters and ratings
- **You**: User profile, statistics, and account management

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- A device or emulator for testing

### Installation

1. Clone or open this project in VS Code
2. Ensure you're in the project directory: `tapin_app`
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

#### Option 1: Using VS Code Tasks
1. Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
2. Type "Tasks: Run Task"
3. Select "Flutter: Run App"

#### Option 2: Using Terminal
```bash
flutter run
```

#### Option 3: Using VS Code Debug
1. Open the Debug panel (Ctrl+Shift+D / Cmd+Shift+D)
2. Select the launch configuration
3. Press F5 to start debugging

### Building for Release

To build an APK for Android:
```bash
flutter build apk
```

To build for iOS (requires macOS and Xcode):
```bash
flutter build ios
```

## Project Structure

```
lib/
├── main.dart           # App entry point with bottom navigation
├── pages/              # Individual page components
│   ├── home_page.dart  # TAPIN. homepage
│   ├── play_page.dart  # Play page with game options
│   ├── book_page.dart  # Booking management
│   ├── search_page.dart# Course search and discovery
│   └── you_page.dart   # User profile and settings
```

## Development Notes

- The app uses Material Design 3 with a golf-themed color scheme
- Bottom navigation provides easy access to all main features
- Each page is designed as a placeholder that can be extended with real functionality
- Icons are chosen to represent golf and related activities

## Next Steps

- Integrate with golf course APIs
- Add user authentication
- Implement booking system
- Add GPS and course mapping
- Include scorecard functionality
- Add social features for playing with friends

## Dependencies

This project uses the standard Flutter dependencies:
- flutter/material.dart for UI components
- No additional third-party packages currently included

## License

This project is for demonstration purposes.
