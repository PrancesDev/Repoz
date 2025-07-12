# La Italianu' - Restaurant Management System

A complete restaurant management solution with customer app and admin dashboard.

## Features

### Customer App
- **Splash Screen**: Beautiful animated loading screen
- **Multi-Location Support**: Choose from 3 restaurant locations
- **Category-Based Menu**: Pizza, Pasta, Desserts, Drinks
- **Location-Specific Inventory**: Real-time availability per location
- **Shopping Cart**: Add items, modify quantities
- **Favorites**: Save preferred items
- **User Authentication**: Firebase Auth integration
- **Order Management**: Submit orders to Firebase

### Admin Dashboard
- **Real-Time Orders**: View and manage incoming orders
- **Inventory Management**: Control stock per location
- **Analytics**: Sales data, popular items, location performance
- **Order Status Updates**: Pending → Preparing → Ready → Delivered

## Technical Architecture

### Customer App Structure
```
lib/
├── main.dart                 # Main app with all customer features
├── admin_app.dart           # Separate admin dashboard
└── pubspec.yaml             # Dependencies
```

### Key Technologies
- **Flutter**: Cross-platform mobile development
- **Firebase Auth**: User authentication
- **Cloud Firestore**: Real-time database for orders
- **Provider**: State management
- **SharedPreferences**: Local data persistence

### Data Models
- **Location**: Restaurant locations with coordinates
- **MenuItem**: Products with categories, sizes, prices
- **CartItem**: Shopping cart items with location tracking
- **Order**: Customer orders with status tracking

## Setup Instructions

### 1. Firebase Configuration
1. Create a Firebase project
2. Enable Authentication (Email/Password)
3. Enable Cloud Firestore
4. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 2. Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  shared_preferences: ^2.2.3
  firebase_core: ^2.31.1
  firebase_auth: ^4.19.6
  cloud_firestore: ^4.17.4
```

### 3. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /orders/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## App Flow

### Customer Journey
1. **Splash Screen** → Location Selection
2. **Location Selection** → Main App
3. **Home Page** → Category Selection or Featured Items
4. **Category Pages** → Individual Item Details
5. **Item Details** → Add to Cart
6. **Cart** → Checkout & Order Submission

### Admin Workflow
1. **Login** → Dashboard
2. **Orders Tab** → View/Update Order Status
3. **Inventory Tab** → Manage Stock per Location
4. **Analytics Tab** → View Performance Data
5. **Settings Tab** → Configure App Settings

## Key Features Explained

### Multi-Location Inventory
Each location maintains separate inventory status:
```dart
Map<String, Map<String, bool>> inventory = {
  'centru': {'pepperoni': true, 'quattro_formaggi': false},
  'manastur': {'pepperoni': true, 'carbonara': false},
  'floresti': {'pesto': false, 'tiramisu': false},
};
```

### Real-Time Order Management
Orders are stored in Firestore with status tracking:
```dart
{
  'items': [...],
  'locationId': 'centru',
  'userId': 'user123',
  'total': 45.99,
  'status': 'pending', // pending → preparing → ready → delivered
  'timestamp': Timestamp.now(),
}
```

### Category-Based Navigation
Menu items are organized by categories:
- **Pizza**: Traditional Italian pizzas
- **Pasta**: Fresh pasta with various sauces
- **Desserts**: Authentic Italian sweets
- **Drinks**: Beverages and wines

## Suggestions for Enhancement

### Customer App Improvements
1. **Push Notifications**: Order status updates
2. **GPS Integration**: Auto-select nearest location
3. **Payment Integration**: Stripe/PayPal support
4. **Order History**: View past orders
5. **Loyalty Program**: Points and rewards
6. **Reviews & Ratings**: Customer feedback system
7. **Delivery Tracking**: Real-time order tracking
8. **Promotions**: Discount codes and special offers

### Admin Dashboard Enhancements
1. **Real-Time Notifications**: New order alerts
2. **Kitchen Display**: Order queue for kitchen staff
3. **Delivery Management**: Driver assignment and tracking
4. **Advanced Analytics**: Revenue reports, customer insights
5. **Menu Management**: Add/edit items directly
6. **Staff Management**: Role-based access control
7. **Printer Integration**: Automatic receipt printing
8. **Multi-Language Support**: Romanian/English toggle

### Technical Improvements
1. **Offline Support**: Cache data for offline viewing
2. **Performance Optimization**: Image caching, lazy loading
3. **Error Handling**: Better error messages and retry logic
4. **Testing**: Unit tests and integration tests
5. **CI/CD Pipeline**: Automated builds and deployments
6. **Monitoring**: Crash reporting and analytics
7. **Security**: Enhanced data validation and encryption

## Deployment

### Customer App
1. Build for Android: `flutter build apk --release`
2. Build for iOS: `flutter build ios --release`
3. Deploy to Google Play Store / App Store

### Admin Dashboard
1. Create separate Flutter project for admin features
2. Deploy as web app: `flutter build web`
3. Host on Firebase Hosting or similar platform

## Support

For technical support or feature requests, contact the development team.

---

**La Italianu'** - Bringing authentic Italian cuisine to your fingertips! 🍕🍝