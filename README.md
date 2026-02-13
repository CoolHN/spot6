# Spot6 (Xcode 5.1.1 / iOS 5.1 - iOS 7 style client)

Spot6 is a legacy Objective-C Spotify-style client project meant for **Xcode 5.1.1** and old iOS targets.

## What it does

- Spotify-like dark UI with search + track list.
- Searches tracks using Spotify Web API (`/v1/search`).
- Plays `preview_url` when available.
- If Spotify has no results (or request fails), it automatically opens a **YouTube fallback** search.

## Compatibility targets

- Xcode 5.1.1
- iOS deployment target: 5.1
- Works with classic UIKit APIs (no storyboard required)

## Project layout

- `Spot6/Spot6.xcodeproj` - Xcode project
- `Spot6/Spot6` - app source files

## Important notes for real devices in 2026

Because this is targeting old iOS versions, modern HTTPS/TLS support may fail with some APIs.
If Spotify calls fail on-device, fallback to YouTube will still open in `UIWebView`.

## Spotify token

Tap the **Token** button in the nav bar and paste a bearer token if needed.

You can also run without a token (limited/unauthenticated behavior depends on Spotify API policy).

## Run

1. Open `Spot6/Spot6.xcodeproj` in Xcode 5.1.1.
2. Set signing/team for your Apple ID.
3. Build and run on an iOS simulator/device.

## Build an `.ipa` (on macOS)

Use the helper script from the repo root:

```bash
./build_ipa.sh
```

Output:

- `build/Spot6.ipa`

This requires macOS + Xcode (`xcodebuild`), and valid iOS signing configured in Xcode.

