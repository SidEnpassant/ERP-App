# ERP Mini App

A streamlined Flutter-based Enterprise Resource Planning (ERP) application focused on sales order management with modern UI and essential features.

## 🌟 Features

- **Authentication System**: Secure login functionality
- **Sales Order Management**: Create, view, and manage sales orders
- **Dashboard**: Overview of key metrics and recent activities
- **Dark/Light Theme**: Support for both light and dark themes
- **Push Notifications**: Real-time alerts for order status changes
- **Offline Support**: Local database for offline functionality
- **Filtering & Search**: Advanced filtering options for sales orders

## 🏗️ Architecture

The application follows a clean architecture pattern with clear separation of concerns:

### Directory Structure
```
lib/
├── models/         # Data models
├── providers/      # State management using Provider
├── screens/        # UI screens
├── services/       # Business logic and external services
└── utils/          # Utility functions and helpers
```

### Key Components

- **State Management**: Provider pattern for reactive state management
- **Database**: Local storage using SQLite
- **Notifications**: Flutter Local Notifications for push notifications
- **UI Components**: Material Design widgets with custom theming
- **Services Layer**: Abstracted business logic and external service calls

## 🔧 Technical Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Database**: SQLite
- **Notifications**: Flutter Local Notifications
- **Architecture Pattern**: MVVM (Model-View-ViewModel)

## ✅ What Works

1. **Core Features**
   - User authentication
   - Sales order CRUD operations
   - Theme switching
   - Push notifications
   - Offline data persistence

2. **UI/UX**
   - Responsive design
   - Dark/Light theme support
   - Intuitive navigation
   - Filter and search functionality

## 🚧 What Was Skipped

1. **Features**
   - User registration (currently focused on login only)
   - Advanced reporting
   - Multi-language support
   - Product inventory management
   - User roles and permissions

2. **Technical**
   - Unit tests
   - Integration tests
   - CI/CD pipeline
   - Analytics integration
   - Error tracking

## 🚀 Future Enhancements

1. **Feature Additions**
   - Multi-user support with role-based access
   - Advanced analytics dashboard
   - Product catalog management
   - PDF report generation
   - Customer management module

2. **Technical Improvements**
   - Comprehensive test coverage
   - Cloud synchronization
   - Performance optimization
   - API integration
   - Enhanced security features

## 🔍 Assumptions

1. **User Base**
   - Single user system (currently)
   - Basic understanding of sales order workflow
   - Mobile-first usage

2. **Technical**
   - Offline-first approach
   - Local data storage sufficient for current scale
   - Basic notification requirements
   - Single language (English) support

## 📥 Installation

1. Clone the repository
2. Run `flutter pub get`
3. Ensure you have Flutter SDK installed
4. Run `flutter run` to start the application

## 💻 Development

To start developing:

```bash
flutter pub get
flutter run
```

