# Flutter BLoC Starter Template

A well-structured Flutter starter template using the BLoC (Business Logic Component) pattern.

## Features

- ✅ BLoC state management
- ✅ Feature-first folder structure
- ✅ Authentication flow (Login/Signup)
- ✅ Bottom Navigation Bar with 4 tabs
- ✅ Routing setup
- ✅ Theme configuration
- ✅ Dio network client
- ✅ Reusable widgets

## Bottom Navigation Tabs

The home screen includes a bottom navigation bar with:
1. **Dashboard** - Overview cards with quick actions
2. **Explore** - Discover new content
3. **Profile** - User profile management
4. **Settings** - App preferences and configuration

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/               # Core utilities, config, theme
├── features/           # Feature modules (auth, home, profile, settings)
│   ├── auth/          # Authentication
│   ├── home/          # Dashboard & Explore tabs
│   ├── profile/       # Profile tab
│   └── settings/      # Settings tab
├── shared/             # Shared widgets and utilities
├── routes/             # App routing
└── main.dart           # App entry point
```

## Dependencies

- `flutter_bloc` - State management
- `equatable` - Value equality
- `dio` - HTTP client

## Next Steps

- [ ] Add proper API endpoints
- [ ] Implement token storage
- [ ] Add error handling
- [ ] Write tests
- [ ] Add more features to each tab
- [ ] Implement actual settings functionality

---

Happy coding! 🚀
