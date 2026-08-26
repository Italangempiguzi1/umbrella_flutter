# Umbrella Flutter MVP Architecture

## Mobile architecture

The app uses a modular feature structure:

```text
lib/src/
  core/                 Shared configuration, theme, routing, widgets, API client
  data/                 Models, repositories, providers and state controllers
  features/auth/        Login, registration and splash
  features/home/        Streaming home, discovery and content cards
  features/content/     Content detail and video player
  features/reels/       Vertical reels feed
  features/creator/     Creator dashboard, profile, uploads, earnings and creator channel
  features/subscriptions/ Subscription plans and payment initiation
  features/profile/     Profile, edit profile and payment history
  features/engagement/  Comments, voting and awards
  features/moderation/  Reporting and report history
  features/notifications/ Notifications list and mark-read
  features/admin/       Admin quick approval tools
```

## Backend-to-mobile mapping

| Backend app | Mobile coverage |
|---|---|
| users | Login, register, logout, token refresh, profile update |
| subscriptions | Plans, current subscription, developer activation |
| payments | Payment initiation and payment history |
| content | Content list, content detail, create, submit for review, stream, admin approve |
| reels | Reels feed, create reel, submit for review, stream, admin approve |
| creators | Creator profile, public creator profile, dashboard, verification status display |
| engagement | Like, vote, follow, award, comments |
| analytics | Watch start and watch end from the video player |
| rewards | Earnings and payouts screen |
| moderation | Create reports and list own reports |
| notifications | List notifications and mark read |

## State management

The MVP uses Riverpod providers and repositories. Each repository maps directly to Django REST endpoints. Authentication tokens are stored with Flutter Secure Storage and automatically attached to requests through Dio interceptors. Access token refresh is handled automatically when the backend returns HTTP 401.

## Video playback

The player requests the backend `/stream/` endpoint, picks the best available URL in this order:

1. HLS manifest URL
2. MP4 URL
3. Reel video URL
4. DASH manifest URL fallback

The MVP starts a watch session before playback and sends watch duration when the player closes.
