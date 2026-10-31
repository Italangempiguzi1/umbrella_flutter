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

Install packages and run the app on a connected Android device or emulator:

```bash
flutter pub get
flutter run
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

1. Replace the MVP payment flow with a complete, policy-compliant subscription flow. The app can request a payment, but it does not yet process a provider callback to unlock a plan. Google Play generally requires Play Billing for digital subscriptions; confirm the current policy and any eligible regional alternative before release.
2. Creator uploads currently submit video URLs; they are not a complete video-file upload and storage workflow.
3. Add DRM, signed URLs, CDN, and stronger anti-fraud analytics.
4. Add push notification delivery through Firebase Cloud Messaging.

## Umbrella Android release and Play Store

Jina litakaloonekana kwenye Android ni **Umbrella**. Package ID yake ya kudumu kwa Play Store ni `com.patricetech.delimitationproduction.umbrella`; ibaki hivyo kwa kila toleo lijalo. Icon na splash screen vina nembo ya mwavuli katika rangi za kijani na dhahabu.

### App inafanya nini?

App ina usajili na kuingia kwenye akaunti, kutafuta na kutazama video pamoja na reels, mipango ya subscription na kuanzisha malipo, profiles na dashibodi za creators, kutuma video/reels, comments na interactions, notifications, reports, pamoja na moderation/admin screens. Vipengele hivi vinahitaji Django API kufanya kazi.

API ya production iliyowekwa kwa sasa ni `https://delimitationproduction.com/api`. Kubadilisha kwa build, ongeza `--dart-define=API_BASE_URL=https://your-api.example/api`.

### Kabla ya kuchapisha

- Jaribu usajili, login, kutazama video, subscriptions, matokeo ya malipo, creator uploads, reports na moderation dhidi ya backend ya moja kwa moja.
- Kamilisha mfumo wa malipo. Kwa sasa app inaweza kuanzisha malipo tu; haipokei callback ya provider ili kuwasha subscription. Hakiki masharti ya sasa ya Google Play Billing kwa nchi zitakazopokea app.
- Creator uploads kwa sasa hutuma video URL; si mfumo kamili wa kupakia faili za video na kuzihifadhi.
- Andaa privacy policy ya umma, majibu sahihi ya Data safety, picha na maelezo ya Play Store, content rating, taarifa za walengwa/matangazo, na maelekezo ya kuingia kwa wakaguzi.
- Kwa kuwa app ina akaunti na maudhui ya watumiaji, weka utaratibu unaofanya kazi wa kuripoti/kudhibiti maudhui na kufuta akaunti; ongeza viungo vinavyohitajika kwenye ukurasa wa Play Store.
- Hakuna automated Flutter tests zilizopo kwa sasa; panga majaribio ya kifaa halisi kabla ya uzinduzi.

### Tengeneza upload key (mara moja tu)

Tumia upload key ya kipekee, ihifadhi mahali salama na tengeneza backup salama. Usiiweke Git; kuipoteza kunaweza kuzuia releases zijazo.

```powershell
& "$env:JAVA_HOME\bin\keytool.exe" -genkeypair -v -keystore android\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias umbrella-upload
```

Unda faili `android/key.properties` kwenye kompyuta yako tu, kisha weka taarifa ulizotumia:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=umbrella-upload
storeFile=../upload-keystore.jks
```

Keystore na `key.properties` zimeondolewa kwenye Git. Usiweke password halisi kwenye README wala kuzi-commit.

### Tengeneza na pakia app

Endesha amri hizi kwenye PowerShell ukiwa kwenye folder kuu la project. Kuweka Pub cache kwenye drive ileile na project husaidia kuepuka hitilafu ya Kotlin incremental cache kwenye Windows:

```powershell
$env:PUB_CACHE = "$PWD\.pub-cache"
flutter pub get
flutter build appbundle --release --dart-define=API_BASE_URL=https://delimitationproduction.com/api
```

Android App Bundle iliyosainiwa itatengenezwa `build\app\outputs\bundle\release\app-release.aab`. Bila signing key, release build itasimama kwa makusudi badala ya kutumia debug key. Kwenye Play Console, tengeneza app kwa application ID iliyo hapo juu, washa Play App Signing, kamilisha maelezo na fomu za sera, kisha pakia AAB kwenye internal testing kabla ya production. Ongeza namba ya `+<build number>` ndani ya `pubspec.yaml` kwa kila upload mpya.
