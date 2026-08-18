# Glover Customer App

Flutter mobile app for customers using the Glover/Fuodz commerce and delivery
platform. The app lets customers discover vendors, shop products and services,
place orders, book deliveries, track orders, manage payments, and interact with
vendors or drivers from one customer-facing experience.

## Project Overview

The customer app supports multiple marketplace flows:

- Food, grocery, commerce, pharmacy, and service vendor browsing
- Cart, coupon, checkout, and payment method selection
- Single-vendor and multiple-vendor order placement
- Parcel/package delivery booking
- Taxi trip booking and live trip handling
- Order history, order details, tracking, cancellation, and rating
- Wallet, loyalty points, favourites, profile, notifications, and chat

The app communicates with the backend API configured in
`lib/constants/api.dart`. Most API calls are routed through request classes in
`lib/requests`, with shared HTTP behavior handled by `lib/services/http.service.dart`.

## Build Environment

The API endpoint can be changed at build time with Flutter's `--dart-define`
option. If no value is provided, the app uses the default endpoint configured in
`lib/constants/api.dart`.

```sh
flutter build apk --dart-define=api=https://your-domain.com/api
```

```sh
flutter build ios --dart-define=api=https://your-domain.com/api
```

The value should include the `/api` path. A trailing slash is allowed and will be
normalized by the app.

## Development

Install dependencies:

```sh
flutter pub get
```

Run the app:

```sh
flutter run --dart-define=api=https://your-domain.com/api
```

Run static analysis:

```sh
flutter analyze
```

## Important Folders

- `lib/constants`: app-wide constants, routes, colors, API endpoints, and settings
- `lib/requests`: backend request wrappers
- `lib/services`: shared services such as HTTP, auth, cart, storage, location, and navigation
- `lib/view_models`: screen and flow state management
- `lib/views`: UI pages and widgets
- `lib/models`: API and app data models
- `assets`: images, icons, localization files, and static app resources
