# Flutter Task Manager App

A Firebase-powered task management app built with Flutter for CSC 4360 Mobile App Development. The app supports full CRUD operations with Cloud Firestore and includes nested subtasks with real-time synchronization.

## Features

- Add new tasks
- View tasks in real time with Firestore streams
- Mark tasks complete or incomplete
- Delete tasks with confirmation dialog
- Add, toggle, and delete nested subtasks
- Search/filter tasks by title in real time
- Dark mode support using `ThemeMode.system`
- Loading, empty, and error UI states

## Tech Stack

- Flutter
- Dart
- Firebase Core
- Cloud Firestore

## Folder Structure

```text
lib/
  models/
    task.dart
  services/
    task_service.dart
  screens/
    task_list_screen.dart
  main.dart
```

## Setup Instructions

1. Clone the repository.
2. Run `flutter pub get`.
3. Install FlutterFire CLI if needed.
4. Run `flutterfire configure` inside the project folder.
5. Make sure Firestore Database is enabled in Firebase Console.
6. Run the app using `flutter run`.

## Firestore Collection

Collection name: `tasks`

Each task document stores:

- `title` → String
- `isCompleted` → bool
- `subtasks` → List<Map<String, dynamic>>
- `createdAt` → ISO-8601 String

## Enhanced Features

### 1. Real-time search/filter
I added a search field that filters the task list as the user types. I chose this because it improves usability once the list grows larger.

### 2. Dark mode support
The app follows the system device theme using `ThemeMode.system`. I chose this because it improves user experience and makes the interface feel more polished.

## Known Limitations

- No user authentication yet
- No due dates or priority labels yet
- Firestore rules may be open during development and should be tightened for production

## APK

Build with:

```bash
flutter build apk --release
```

APK output path:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Reflection Summary

This project taught me how `StatefulWidget`, `setState()`, and `StreamBuilder` work together with Firestore. The biggest lesson was learning that Firestore streams update the UI live, so I did not need to manually manage a local list after each CRUD action.
