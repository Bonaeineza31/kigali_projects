# Kigali City Services Directory App

A Flutter application for exploring services and listings in Kigali, Rwanda. This project features a modern authentication flow and real-time Firestore integration.

## Features

- **Modern Authentication**: Signup, Login, and Password Reset with a premium night-view aesthetic.
- **Email Verification**: Enforced verification flow using Firebase Auth.
- **Service Directory**: Real-time listings for Hospitals, Restaurants, Garages, and more.
- **My Listings**: A dedicated section for users to manage their own service entries.
- **Interactive Map**: Built-in OpenStreetMap integration with dynamic markers.
- **Search & Filter**: Categorical filtering and real-time name search.

## Architecture

This project follows **Clean Architecture** principles with a clear separation of concerns:

- **Models**: Defines data structures (`Listing`, `AppUser`).
- **Services**: Handles direct backend interaction (`AuthService`, `FirestoreService`).
- **Providers**: Manages application state and business logic using the `Provider` package (`AuthProvider`, `ListingProvider`).
- **Screens**: Organized into feature-based subfolders (`auth`, `directory`, `home`, `settings`) for maintainability.
- **Widgets**: Reusable UI components like `ListingCard`.

## Firebase Setup
# Kigali City Services & Places Directory

A fully functional mobile application built with Flutter and Firebase to help Kigali residents locate and navigate to essential public services and leisure locations.

##  Features
- **Authentication**: Secure Sign-Up and Login using Firebase Auth with email verification.
- **Shared Directory**: Browse all services and places across Kigali (Hospitals, Cafés, Parks, etc.).
- **CRUD Operations**: Logged-in users can Create, Read, Update, and Delete their own listings.
- **Search & Filter**: Dynamically search by name or filter by category.
- **Real-time Map**: View locations on an interactive map using `flutter_map` (OpenStreetMap).
- **Navigation**: Launch turn-by-turn directions directly from the app.
- **My Listings**: A dedicated space to manage the places you've added.
- **Personalized Settings**: View profile info and toggle notification preferences.

##  Architecture & State Management
The project follows a **Clean Architecture** pattern, separating the UI from business logic:
- **Models**: Strongly-typed data structures (e.g., `Listing`, `AppUser`).
- **Services**: Dedicated layers for Firebase Auth (`AuthService`) and Cloud Firestore (`FirestoreService`).
- **Providers**: State management via the **Provider** package to handle data flow and UI updates.
- **Screens/Widgets**: Declarative UI components that react to state changes without direct backend calls.

## Database Structure (Firestore)
- **users/{uid}**: Stores user profile details.
- **listings/{id}**: Stores listing information including geographic coordinates and creator UID.

##  Setup Instructions
1. Clone the repository.
2. cd kigali_project
3. Ensure Flutter is installed.
4. Add your proprietary `.env` file with Firebase configuration.
5. Run `flutter pub get`.
6. Run on an emulator or physical device using `flutter run`.

## Navigation

Controlled via a `BottomNavigationBar` in `MainScreen`:
- **Directory**: Main explore view with filters.
- **My Listings**: User-owned content management.
- **Map View**: Geospatial visualization of all services.
- **Settings**: Profile management and logout.
