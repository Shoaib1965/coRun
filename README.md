# coRun 🏃‍♂️💨

**coRun** is a gamified GPS running app where the world is your game board. Runners claim territory by running through their city, painting the map with their unique color.

## 📱 Features

### ✅ Completed
- **Authentication**: Secure Email/Password Sign Up & Login via Firebase Auth.
- **Live GPS Tracking**: Real-time location tracking with path visualization on Google Maps.
- **Territory Claiming**: Every run is saved as a "territory". The map displays runs from all users, colored by who owns them.
- **Map Visuals**: Custom Dark Mode map style with user-specific neon accent colors.
- **Run Stats**: Live calculation of Distance, Duration, and Pace (min/km).
- **Post-Run Summary**: Instant summary dialog after finishing a run.
- **Navigation**: Drawer menu with placeholders for future features.

### 🚧 Pending / Roadmap
- **Leaderboard**: Global or city-based ranking by total area claimed.
- **Run History**: List of past activities with detailed stats and map previews.
- **User Profiles**: Custom usernames, avatars, and total stats (distance/runs).
- **Smart Loading**: Geo-querying to load only nearby territories (currently loads global recent runs).
- **Social**: Friend lists and territory battles.
- **Run Details**: Tap a territory to see who ran it and when.

## 🛠️ Tech Stack
- **Flutter**: Cross-platform mobile UI.
- **Firebase Auth**: User management.
- **Cloud Firestore**: Real-time database for runs and territories.
- **Google Maps Flutter**: Map rendering and interaction.
- **Geolocator**: High-accuracy GPS tracking.
- **Provider**: State management.

## 🚀 Getting Started

**Note:** This repository contains the source code (`lib/`). You must generate the platform folders and configure keys before running.

👉 **See [SETUP.md](SETUP.md) for step-by-step instructions.**

1.  Clone the repo:
    ```bash
    git clone https://github.com/Shoaib1965/coRun.git
    cd coRun
    ```
2.  Initialize Flutter:
    ```bash
    flutter create .
    ```
3.  Configure Platforms (Android/iOS) with Permissions & API Keys.
4.  Add Firebase Config files.
5.  Run:
    ```bash
    flutter run
    ```
