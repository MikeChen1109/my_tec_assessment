# TEC Meeting Room Assessment

This repository contains a Flutter app for the TEC meeting room assessment.

## Flutter Version

- Flutter SDK: 3.38.9 (stable)
- Dart: 3.10.8

## Setup / Build Instructions

### 1) Prerequisites

- Flutter SDK 3.38.9 (stable)
- Xcode (for iOS) or Android Studio (for Android)
- A simulator or physical device

### 2) Install Dependencies

```bash
flutter pub get
```

### 3) Run on Simulator

```bash
flutter run
```

Note for iOS Simulator:
- Configure mock location in Simulator: Feature -> Location -> Custom Location
- Set a valid latitude/longitude before using "Select Nearest City"

### 4) Run on Physical Device

```bash
flutter run
```

Notes:
- No extra configuration is required for location on physical devices.
- If running on iOS, replace the signing team with your own in Xcode.

## Architecture Overview

The meeting room feature is organized using a feature-first layout:

- `lib/features/meeting_room/domain`: entities and use cases
- `lib/features/meeting_room/data`: data sources and repositories (if any)
- `lib/features/meeting_room/presentation`: UI, widgets, state, and utilities

State management uses Riverpod with `StateNotifier`. UI composition is in
`presentation/widgets`, and page-level screens live in `presentation/pages`.

## Folder Structure (High Level)

- `lib/`
  - `core/`: shared helpers, DI, and app-wide utilities
  - `features/`: feature modules (meeting_room is the main focus)
  - `main.dart`: app entry point
- `assets/`: images and static assets
- `test/`: unit/widget tests

## Assumptions / Known Issues

- Location in simulator must be set manually; otherwise "Select Nearest City"
  may not resolve correctly.
- The app expects the backend responses to include valid city/centre codes
  for pricing and grouping; missing mappings may group under "Other".
- Distance is not displayed yet.
- The map is currently a placeholder only.
- Room detail page is not available yet.
- Debug mode uses an HTTP override to allow the backend host
  (`octo.pr-product-core.executivecentre.net`) with a bad certificate. This is
  to unblock development against the staging backend and should not be used in
  production.
- Offline access is not supported.
