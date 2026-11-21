# angoothape

Retailer AEPS prototype (Flutter). Mock data only — no real money, Aadhaar, or biometric capture.

## Demo login

Use these on the login and OTP screens. They are not shown in the app UI.

| Field | Value |
| --- | --- |
| Partner ID | `AP100245` |
| Password | `Demo@123` |
| OTP | `246810` |

## Run locally

```bash
flutter pub get
flutter run
```

## Web / Firebase Hosting

```bash
flutter build web --release
firebase deploy --only hosting
```

Live: https://angoothape-d77f9.web.app
