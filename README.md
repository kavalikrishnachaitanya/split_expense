# 💰 Split Expense

A modern, feature-rich expense splitting application built with Flutter and Firebase. Easily track shared expenses, manage groups, and settle debts with friends and family.

[![Flutter](https://img.shields.io/badge/Flutter-3.10.4+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🌟 Features

### 👤 **User Management**
- **Google Sign-In** - Quick authentication with Google account
- **Email/Password Authentication** - Traditional login option
- **Avatar Selection** - Choose from 6 unique avatars
- **Profile Management** - Edit display name and avatar
- **Account Deletion** - Safely delete account (only when all dues are settled)

### 👥 **Group Management**
- **Create Groups** - Organize expenses by trips, roommates, or events
- **Add Members** - Invite friends via email
- **Group Details** - View all members and their balances
- **Remove Members** - Manage group participants

### 💸 **Expense Tracking**
- **Add Expenses** - Record who paid and how much
- **Split Equally** - Automatically divide costs among selected members
- **Real-time Updates** - See changes instantly across all devices
- **Delete Expenses** - Remove incorrect entries

### 📊 **Balance & Settlements**
- **Smart Calculations** - Automatic balance computation
- **Settlement Suggestions** - Optimal payment recommendations
- **Balance Overview** - See who owes whom at a glance
- **Zero Balance Check** - Required before account deletion

### 🔒 **Security & Privacy**
- **Firebase Authentication** - Secure user management
- **Firestore Security Rules** - Protected data access
- **Logout Confirmation** - Prevent accidental sign-outs

## 🚀 Live Demo

- **Web App**: [https://splitexpense-27.web.app/](https://splitexpense-27.web.app/)
- **Android APK**: Available in [Releases](https://github.com/kavalikrishnachaitanya/split_expense/releases)


## 🛠️ Tech Stack

- **Framework**: Flutter 3.10.4+
- **Language**: Dart
- **Backend**: Firebase
  - Authentication (Google Sign-In, Email/Password)
  - Cloud Firestore (Database)
- **State Management**: Provider
- **Platforms**: Android, Web

## 📋 Prerequisites

Before you begin, ensure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.4 or higher)
- [Firebase Account](https://firebase.google.com/)
- [Git](https://git-scm.com/)
- Android Studio / VS Code with Flutter extensions

## 🔧 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/kavalikrishnachaitanya/split_expense.git
cd split_expense
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** (Google Sign-In and Email/Password)
3. Create a **Cloud Firestore** database
4. Add your apps (Android/Web) to the Firebase project
5. Run FlutterFire CLI to generate configuration:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will create `lib/firebase_options.dart` with your Firebase configuration.

### 4. Google Sign-In Configuration

#### For Web:
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Add authorized JavaScript origins:
   - `http://localhost:5000` (for local development)
   - `https://yourusername.github.io` (for production)

#### For Android:
1. Add SHA-1 fingerprint to Firebase project
2. Download and place `google-services.json` in `android/app/`

### 5. Run the App

```bash
# For Web (on port 5000)
flutter run -d chrome --web-port=5000

# For Android
flutter run -d <device-id>

# Build APK
flutter build apk --split-per-abi
```

## 📁 Project Structure

```
lib/
├── models/              # Data models (User, Group, Expense)
├── providers/           # State management (Auth, Group, Expense)
├── screens/            
│   ├── auth/           # Login, Signup, Avatar Selection
│   ├── groups/         # Group creation and details
│   ├── home/           # Main dashboard
│   └── profile/        # User profile management
├── services/           # Firebase services (Auth, Firestore)
├── utils/              # Constants and helpers
├── widgets/            # Reusable UI components
├── firebase_options.dart  # Firebase configuration
└── main.dart           # App entry point
```

## 🔑 Key Features Implementation

### Profile Management
- Edit display name and avatar
- Conditional account deletion (only when balance = 0)
- Logout confirmation dialog

### Balance Calculation
- Real-time balance updates
- Optimal settlement suggestions
- Multi-group balance tracking

### Responsive Design
- Horizontal avatar selection
- Scrollable layouts for small screens
- Adaptive UI for web and mobile

## 🚢 Deployment

### Firebase Hosting (Web)

The web app is deployed using Firebase Hosting:

**Live URL**: [https://splitexpense-27.web.app/](https://splitexpense-27.web.app/)

To deploy your own version:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase Hosting
firebase init hosting

# Build Flutter web app
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

### Android APK

Pre-built APK files are available in the repository for easy installation:

**Download Location**: `release/apk/`

Available APKs:
- `app-arm64-v8a-release.apk` (21.5 MB) - For modern 64-bit devices

**To build APKs yourself:**

```bash
# Build release APK (split by ABI for smaller file sizes)
flutter build apk --split-per-abi

# Or build a single universal APK
flutter build apk
```

**Installation on Android:**
1. Download the appropriate APK for your device
2. Enable "Install from Unknown Sources" in Android settings
3. Open the APK file and install


## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Kavali Krishna Chaitanya**

- GitHub: [@kavalikrishnachaitanya](https://github.com/kavalikrishnachaitanya)
- LinkedIn: [Kavali Krishna Chaitanya](https://www.linkedin.com/in/kavali-krishna-chaitanya/)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and users

## 📞 Support

If you have any questions or need help, please:
- Open an [issue](https://github.com/kavalikrishnachaitanya/split_expense/issues)
- Contact via [LinkedIn](https://www.linkedin.com/in/kavali-krishna-chaitanya/)

---

⭐ **Star this repo** if you find it helpful!
