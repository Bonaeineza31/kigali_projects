# Kigali City Services - Modernized Auth & Directory App

A premium Flutter application for exploring services and listings in Kigali, Rwanda. This project features a modern authentication flow, real-time Firestore integration, and a sleek dark-themed UI.

## Features

- **Modern Authentication**: Signup, Login, and Password Reset with a premium night-view aesthetic.
- **Email Verification**: Enforced verification flow using Firebase Auth.
- **Service Directory**: Real-time listings for Hospitals, Restaurants, Garages, and more.
- **My Listings**: A dedicated section for users to manage their own service entries.
- **Interactive Map**: Built-in OpenStreetMap integration with dynamic markers.
- **Search & Filter**: Categorical filtering and real-time name search.
- **Bookmarking**: Save your favorite spots for quick access.

## Architecture

This project follows **Clean Architecture** principles with a clear separation of concerns:

- **Models**: Defines data structures (`Listing`, `AppUser`).
- **Services**: Handles direct backend interaction (`AuthService`, `FirestoreService`).
- **Providers**: Manages application state and business logic using the `Provider` package (`AuthProvider`, `ListingProvider`).
- **Screens**: Organized into feature-based subfolders (`auth`, `directory`, `home`, `settings`) for maintainability.
- **Widgets**: Reusable UI components like `ListingCard`.

## Firebase Setup

1. **Project Creation**: Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2. **Authentication**: Enable Email/Password provider.
3. **Firestore**: 
   - Create a `listings` collection.
   - Create a `users` collection.
4. **Configuration**: Add your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) to the respective platform folders.

## State Management

Application state is managed using the `Provider` package.
- `AuthProvider`: Listens to user auth state changes and reloads profile data from Firestore.
- `ListingProvider`: Subscribes to the Firestore `listings` stream for real-time UI updates reflecting CRUD operations.

## Navigation

Controlled via a `BottomNavigationBar` in `MainScreen`:
- **Directory**: Main explore view with filters.
- **My Listings**: User-owned content management.
- **Map View**: Geospatial visualization of all services.
- **Settings**: Profile management and logout.
