# Umbrella Mobile App — Flutter MVP

This is a professional Flutter MVP client for the Umbrella streaming platform backend created with Django + PostgreSQL.

## What is covered

- Authentication: register, login, token refresh, logout, profile update
- Subscriptions: Basic/Standard/Premium plans, current subscription, developer activation, payment initiation
- Content streaming: movies, series, documentaries, educational videos, premium creator content
- Reels: vertical scroll feed with interaction actions
- Creator tools: creator profile setup, dashboard, upload long-form content, upload reels, submit for review, earnings, payouts
- Engagement: likes, comments, follows, quality votes, creator awards/gifts
- Analytics: watch session start/end and valid watch time reporting
- Moderation: report content/reels and view submitted reports
- Notifications: list and mark as read
- Admin tools: mobile quick approval for content/reels using admin credentials

## Quick start

This ZIP contains the Flutter source. After extraction, generate platform folders and install packages:

```bash
cd umbrella_flutter_app
flutter create .
flutter pub get
```

Run against the Django backend on Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

Run against a physical phone on the same Wi-Fi:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_IP:8000/api
```

## Backend expectation

The app expects the Django backend endpoints created in the Umbrella MVP backend ZIP, especially:

- `/api/auth/register/`
- `/api/auth/token/`
- `/api/auth/me/`
- `/api/subscriptions/plans/`
- `/api/subscriptions/current/`
- `/api/subscriptions/activate-dev/`
- `/api/payments/initiate/`
- `/api/content/items/`
- `/api/content/items/{id}/stream/`
- `/api/reels/feed/`
- `/api/reels/{id}/stream/`
- `/api/engagement/likes/toggle/`
- `/api/analytics/watch/start/`
- `/api/analytics/watch/end/`

## Notes for production

1. Replace developer subscription activation with real payment callbacks.
2. Move video upload from URL-only MVP to real upload/object-storage workflow.
3. Add DRM, signed URLs, CDN, and stronger anti-fraud analytics.
4. Add push notification delivery through Firebase Cloud Messaging.
5. Add platform-specific app icons, splash screens, and store metadata.
