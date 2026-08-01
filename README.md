# RACS Reader

Flutter reader application for the Reader Access Control System. It scans and
validates cards, works from a locally synchronised campaign data set, queues
offline scans, and synchronises reader state over WebSocket and WebRTC.

## Requirements

- Flutter with Dart 3.11 or newer
- A running RACS API
- A camera-capable device or emulator for scanning

## Local setup

Install dependencies and generate dependency injection code:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Run against an HTTP development API:

```bash
flutter run --dart-define=APP_ENV=dev --dart-define=API_SECURE=false
```

Use `API_SECURE=true` for HTTPS/WSS deployments. On first launch, open Settings
and enter the API host including its port but without a scheme, for example
`localhost:5001` on desktop or `10.0.2.2:5001` on an Android emulator. Select a
campaign before synchronising cards.

## Project layout

- `lib/core` — networking, routing, and local storage
- `lib/features/cards` — card download, lookup, and local persistence
- `lib/features/campaigns` — campaign selection and API access
- `lib/features/scanner` — scan pipeline, peer sync, and scan history
- `lib/features/settings` — host, campaign, profile, and theme settings

## Verification

```bash
dart format lib test
flutter analyze
flutter test
```

Android and iOS use the application identifier `uk.co.eightmile.racs`.
