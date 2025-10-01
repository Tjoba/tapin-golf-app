# TAPIN. Golf Mobile App - Copilot Instructions

## Project Overview
This is a Flutter mobile application called "TAPIN." designed for golfers. The app features a bottom navigation bar with 5 main pages:

1. **TAPIN. (Home)** - Main dashboard with quick actions
2. **Play** - Start different types of golf rounds
3. **Book** - Reserve tee times and manage bookings
4. **Search** - Find and discover golf courses
5. **You** - User profile and account management

## Architecture
- **Framework**: Flutter with Dart
- **UI**: Material Design 3 with golf-themed color scheme
- **Navigation**: Bottom navigation with IndexedStack for state preservation
- **Structure**: Page-based architecture with separate files for each main screen

## Key Design Principles
- Golf-themed UI with green color scheme (#2E7D32)
- Material Design 3 components
- Responsive layout suitable for mobile devices
- Clean, intuitive navigation
- Card-based layouts for content organization

## Development Guidelines
- Follow Flutter/Dart best practices
- Use const constructors where possible
- Maintain consistent naming conventions
- Keep pages modular and well-organized
- Add TODO comments for future functionality

## File Structure
```
lib/
├── main.dart           # App entry point with navigation
├── pages/              # Individual page components
│   ├── home_page.dart
│   ├── play_page.dart
│   ├── book_page.dart
│   ├── search_page.dart
│   └── you_page.dart
```

## Current Status
- Basic app structure complete
- All 5 main pages implemented with placeholder content
- Bottom navigation fully functional
- Ready for feature expansion and API integration

## Future Enhancements
- User authentication system
- Golf course API integration
- Real booking functionality
- GPS and mapping features
- Scorecard tracking
- Social features for group play