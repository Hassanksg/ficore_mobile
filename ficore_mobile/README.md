# Ficore Africa Mobile App

A comprehensive Flutter mobile application for Ficore Africa's Personal Finance tools (BBS - Budget, Bills & Shopping), designed to integrate seamlessly with the existing Flask backend.

## 🚀 Features

### Core Functionality
- **Budget Management**: Create, track, and edit monthly budgets with custom categories
- **Bill Tracking**: Track recurring and one-time bills with smart reminders
- **Shopping Lists**: Maintain categorized shopping lists with price tracking
- **Ficore Credits System**: Integrated credit system for app actions
- **Multi-language Support**: English and Hausa localization
- **Real-time Sync**: Seamless integration with Flask + MongoDB backend

### User Experience
- **Clean Dashboard**: Overview of financial status and quick actions
- **Session-based Authentication**: Secure login system with 30-minute sessions
- **Role-based Access**: Support for personal users and admin roles
- **PDF Export**: Generate receipts and financial summaries
- **Offline Support**: Basic offline functionality with sync when online
- **Dark Mode**: Optional dark theme support

## 🏗️ Architecture

### Project Structure
```
ficore_mobile/
├── lib/
│   ├── core/                    # Core functionality
│   │   ├── config/             # App configuration
│   │   ├── models/             # Core data models
│   │   ├── providers/          # Global state management
│   │   ├── routes/             # Navigation and routing
│   │   ├── services/           # API and storage services
│   │   ├── theme/              # App theming
│   │   └── l10n/               # Localization
│   ├── features/               # Feature modules
│   │   ├── auth/               # Authentication
│   │   ├── budget/             # Budget management
│   │   ├── bills/              # Bill tracking
│   │   ├── shopping/           # Shopping lists
│   │   ├── credits/            # Ficore Credits
│   │   ├── dashboard/          # Main dashboard
│   │   ├── profile/            # User profile
│   │   └── onboarding/         # App onboarding
│   └── shared/                 # Shared components
│       ├── screens/            # Common screens
│       └── widgets/            # Reusable widgets
├── assets/                     # Static assets
├── android/                    # Android-specific files
├── ios/                        # iOS-specific files
└── pubspec.yaml               # Dependencies
```

### Key Technologies
- **Flutter 3.x+**: Cross-platform mobile framework
- **Provider**: State management solution
- **go_router**: Navigation and routing
- **Dio**: HTTP client for API communication
- **SharedPreferences & Secure Storage**: Local data persistence
- **Google Fonts**: Poppins font family
- **Material Design 3**: Modern UI components

## 🎨 Design System

### Ficore Brand Colors
- **Primary**: Deep Blue (#1E3A8A)
- **Accent**: Rich Gold (#D4AF37)
- **Background**: Soft Cream (#FFF8F0)
- **Card Background**: Muted Blue (#B0DAFF)
- **Text**: Dark Gray (#2E2E2E)
- **Success**: Green (#16A34A)
- **Warning**: Orange (#F97316)
- **Danger**: Red (#DC2626)

### Typography
- **Font Family**: Poppins
- **Heading Large**: 32px, Bold
- **Heading Medium**: 24px, SemiBold
- **Body Large**: 16px, Regular
- **Body Medium**: 14px, Regular
- **Body Small**: 12px, Regular

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- iOS development setup (for iOS builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ficore_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   Update the `baseUrl` in `lib/core/config/app_config.dart`:
   ```dart
   static const String baseUrl = 'https://your-render-app.onrender.com';
   ```

4. **Generate code (if needed)**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Backend Integration

The app is designed to work with your existing Flask backend. Ensure your backend supports:

- **Authentication endpoints**: `/users/login`, `/users/signup`, `/users/logout`
- **Budget endpoints**: `/budget/*`
- **Bill endpoints**: `/bills/*`
- **Shopping endpoints**: `/shopping/*`
- **Credits endpoints**: `/credits/*`

### API Configuration

Update the API endpoints in `lib/core/config/app_config.dart` to match your backend routes:

```dart
// API Endpoints
static const String loginEndpoint = '/users/login';
static const String budgetEndpoint = '/budget';
static const String billEndpoint = '/bills';
static const String shoppingEndpoint = '/shopping';
// ... other endpoints
```

## 📱 Features Implementation Status

### ✅ Completed
- [x] Project structure and architecture
- [x] Core services (API, Storage, Auth)
- [x] State management with Provider
- [x] Navigation with go_router
- [x] Theming and design system
- [x] Localization (English & Hausa)
- [x] Authentication flow
- [x] Dashboard screen
- [x] Budget models and providers
- [x] Bill models and providers
- [x] Shopping models and providers

### 🚧 In Progress
- [ ] Complete budget screens (create, edit, detail)
- [ ] Complete bill screens (create, edit, detail)
- [ ] Complete shopping screens (create, edit, detail)
- [ ] Profile and settings screens
- [ ] Credits management
- [ ] PDF export functionality
- [ ] Push notifications
- [ ] Offline support

### 📋 Planned
- [ ] Advanced charts and analytics
- [ ] Biometric authentication
- [ ] Data export/import
- [ ] Backup and sync
- [ ] Advanced filtering and search
- [ ] Recurring bill automation
- [ ] Shopping list sharing
- [ ] Budget insights and recommendations

## 🌐 Localization

The app supports English and Hausa languages:

- **English**: Default language
- **Hausa**: Full translation support
- **Language Toggle**: Users can switch languages in-app
- **Persistent Settings**: Language preference is saved locally

### Adding New Languages

1. Add language code to `supportedLocales` in `app_localizations.dart`
2. Add translations to the `_translations` maps
3. Update language provider with new language support

## 🔐 Security Features

- **Secure Storage**: Sensitive data encrypted locally
- **Session Management**: 30-minute session timeout
- **Token-based Auth**: JWT tokens for API authentication
- **Input Validation**: Client and server-side validation
- **HTTPS Only**: All API communications over HTTPS

## 📊 State Management

The app uses Provider for state management with the following providers:

- **AuthProvider**: User authentication and profile
- **BudgetProvider**: Budget data and operations
- **BillProvider**: Bill tracking and management
- **ShoppingProvider**: Shopping list management
- **ThemeProvider**: App theming and dark mode
- **LanguageProvider**: Localization and language switching

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Test Structure
- **Unit Tests**: Core logic and utilities
- **Widget Tests**: UI components and screens
- **Integration Tests**: End-to-end user flows

## 📦 Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release
```

### Configuration for Release

1. **Update app version** in `pubspec.yaml`
2. **Configure signing** for Android/iOS
3. **Update API endpoints** for production
4. **Enable/disable debug features**
5. **Test on physical devices**

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting
- Write tests for new features

## 📄 License

This project is proprietary software owned by Ficore Africa. All rights reserved.

## 📞 Support

For technical support or questions:
- **Email**: support@ficoreafrica.com
- **Documentation**: [Internal Wiki]
- **Issues**: Use GitHub Issues for bug reports

## 🚀 Deployment

### Play Store Deployment
1. Build signed app bundle
2. Upload to Google Play Console
3. Configure store listing
4. Submit for review

### App Store Deployment
1. Build for iOS release
2. Upload to App Store Connect
3. Configure app metadata
4. Submit for review

---

**Built with ❤️ by the Ficore Africa Team**