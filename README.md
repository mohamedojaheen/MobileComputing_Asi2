# Student Course App

Simple Flutter app for course enrollment with Firebase authentication.

## Features
- User registration & login
- View available courses
- Add new courses
- Enroll in courses

## Tech Stack
- Flutter & Dart
- Firebase Authentication
- Cloud Firestore

## Setup

1. **Install dependencies**
```bash
   flutter pub get
```

2. **Firebase Config**
   - Create Firebase project
   - Add Android app: `com.example.mobile_asi2`
   - Place `google-services.json` in `android/app/`
   - Enable Email/Password auth
   - Create Firestore database

3. **Run**
```bash
   flutter run
```

## Project Structure
```
lib/
├── main.dart
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    ├── course_list_screen.dart
    └── add_course_screen.dart
```

## Firestore Structure
```
users/{userId}
  - name, email, uid

courses/{courseId}
  - name, code, instructor
  └── enrollments/{userId}
      - userId, enrolledAt
```

## Usage
1. Register with name, email, password
2. Login with credentials
3. View and add courses
4. Click "Enroll" to join courses
5. Logout from top-right icon

## Dependencies
```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
```

---
Mobile Computing Assignment
