# TaskFlow — Flutter To-Do App

A full-featured To-Do List application built with Flutter, Firebase, and the BLoC pattern. Users can securely authenticate, manage tasks with priorities and deadlines, and enjoy a responsive UI across all screen sizes.

---

## Features

### Authentication
- Email/password sign-up and login via Firebase Authentication
- Google Sign-In (iOS and Android)
- Session persistence — users stay logged in across app restarts
- Descriptive error messages for all common auth failures

### Task Management
- Create, edit, and delete tasks
- Mark tasks as complete/incomplete with instant UI feedback
- Set due dates using a date picker or quick shortcuts (Today, Tomorrow, Next Week)
- Assign priority levels — High, Medium, Low, or None
- Swipe-to-delete with a confirmation dialog

### Smart List
- Filter tasks by All, Active, or Done
- Sort by creation date, due date, priority, or alphabetically
- Search tasks by title or notes in real time
- Overdue badge and warning indicator for past-due tasks
- Progress card showing completion percentage

### UX & Design
- Light and dark theme support
- Fully responsive layout — works on phones and tablets
- Animated transitions and state changes
- Snackbar error feedback with a Retry action
- Optimistic UI updates for toggle, edit, and delete operations

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State Management | BLoC / Cubit (`flutter_bloc`) |
| Authentication | Firebase Authentication |
| Database | Firebase Realtime Database (REST API via Dio) |
| HTTP Client | Dio |
| Google Sign-In | `google_sign_in` |
| Equality | `equatable` |
| Date Formatting | `intl` |

---

## Project Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants (Firebase DB URL, etc.)
│   ├── network/            # Dio client configuration
│   └── theme/              # Light/dark theme and colour palette
├── features/
│   ├── auth/
│   │   ├── bloc/           # AuthBloc — events, states, logic
│   │   ├── data/           # AuthRepository (Firebase Auth + Google Sign-In)
│   │   └── presentation/   # LoginScreen, SignupScreen
│   └── todo/
│       ├── bloc/           # TodoBloc — events, states, logic
│       ├── data/           # TodoModel, TodoRepository (REST API)
│       └── presentation/
│           ├── todo_screen.dart
│           └── widgets/    # TodoItemWidget, AddEditTodoSheet
├── routes/                 # Named route configuration
├── shared/
│   └── widgets/            # PrimaryButton, SplashScreen
└── main.dart               # App entry point, DI setup
```

---

## Architecture

The app follows a clean, feature-first architecture:

- **Repository layer** handles all data operations (Firebase Auth and Realtime Database). It exposes simple async methods and maps low-level errors into readable messages.
- **BLoC layer** holds business logic. Each event triggers an async handler that emits new states. Optimistic updates are applied immediately to the UI and rolled back on failure.
- **Presentation layer** listens to BLoC states via `BlocBuilder` / `BlocConsumer` and renders accordingly.

Dependency injection is done at the root using `MultiRepositoryProvider` and `MultiBlocProvider`, so every widget in the tree can access the repositories and blocs it needs.

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- A Firebase project with:
  - **Authentication** — Email/Password and Google Sign-In enabled
  - **Realtime Database** — created and security rules configured

### Firebase Setup

1. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from the Firebase Console and place them in their respective platform folders.
2. Make sure the Firebase Realtime Database URL in `lib/core/constants/app_constants.dart` matches your project:

```dart
static const String firebaseDbUrl =
    'https://<your-project-id>-default-rtdb.firebaseio.com';
```

3. Set the following security rules in Firebase Console → Realtime Database → Rules:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

### Installation

```bash
# Install dependencies
flutter pub get

# Run on a connected device or simulator
flutter run
```

---

## Data Model

```dart
TodoModel {
  id          : String        // Firebase-generated push key
  title       : String
  description : String
  isCompleted : bool
  createdAt   : DateTime
  dueDate     : DateTime?     // Optional deadline
  priority    : TodoPriority  // high | medium | low | none
}
```

Tasks are stored under `/users/{uid}/todos/{taskId}` in the Realtime Database, ensuring each user can only read and write their own data.

---

## Screenshots

> Run the app on a simulator or device to see the UI in action.

---

## Dependencies

```yaml
firebase_core: ^4.5.0
firebase_auth: ^6.2.0
flutter_bloc: ^8.1.3
equatable: ^2.0.5
dio: ^5.4.0
google_sign_in: ^6.2.1
flutter_svg: ^2.2.4
intl: ^0.19.0
```
