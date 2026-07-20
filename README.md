# Snaply Agent — iOS SDK

Consent-first screen capture for support teams. A support agent requests a screenshot — or a
live view — from the Snaply console; your user sees a native consent card and decides. **No
capture path bypasses the user's approval** — the SDK only captures after an allow is recorded
server-side.

Distributed as a compiled `SnaplyAgent.xcframework` (device + simulator slices,
library-evolution enabled). Requires **iOS 15+**. Zero third-party dependencies.

## Install (Swift Package Manager)

In Xcode: **File → Add Package Dependencies…** and enter:

```
https://github.com/Mobile-LLC/SnaplyAgent-SDK-iOS
```

Or in `Package.swift`:

```swift
.package(url: "https://github.com/Mobile-LLC/SnaplyAgent-SDK-iOS", from: "2.4.0")
```

## Usage

```swift
import SnaplyAgent   // the module is SnaplyAgent; the API entry point is the Snaply type

// At app start. environment defaults to .live; see "Environments" below.
// A completion-handler overload exists for call sites without Swift concurrency.
try await Snaply.configure(key: "snap_live_…")

// Optional — attach your signed-in user (otherwise the device is anonymous). Also available
// as the `user:` parameter on configure. phone is optional and E.164 — it lets the
// screen-pop API resolve an incoming caller-ID to this user.
Snaply.identify(id: "u_123", name: "Maya Kowalski", phone: "+14155550142")

// Every device has a permanent support code the caller can read to the support agent:
let code = Snaply.supportCode()

// …or let the SDK present it in the designed popup (works for identified users too):
Snaply.showSupportCode()

// Detach the user / rotate the support code (e.g. on logout):
Snaply.reset()

// Events:
Snaply.on(SnaplyCallbacks(
    onAllowed: { capture in print("uploaded:", capture.captureId) },
    onDenied: { print("user declined") },
    onExpired: { print("request expired (60s)") }
))

// Tear everything down (also ends an in-flight live session):
Snaply.stop()
```

## Environments

`environment:` selects which Snaply deployment to talk to — they are **separate backends**
(each its own database):

| `SnaplyEnvironment` | Backend |
| --- | --- |
| `.live` (default) | `https://snaplyagent.com` |
| `.staging` | `https://staging.snaplyagent.com` |
| `.development` | `https://dev.snaplyagent.com` |
| `.custom(url)` | self-hosted |

Each environment has its own products and keys — use the key from the matching environment's
console. (Within one environment, a product also has Test vs Live keys — `snap_test_…` /
`snap_live_…` — where test captures are excluded from quota/billing; that's a separate axis.)

## Consent model

**Screenshots** (ask-every-time / per-session products):

1. The agent requests a capture; the SDK receives it on the realtime channel.
2. A native consent card appears. The user allows or declines; requests expire after 60 seconds.
3. Only after the allow is recorded does the SDK snapshot **this app's own window** — never
   other apps or the home screen — and upload the PNG.
4. In per-session mode, an allow opens an approval window during which the backend may push
   captures without re-prompting — the approval was recorded when the window opened.

**Live view** (live-view products) is prompt-first too:

1. The agent starts live view → the user sees the *"Share your screen live?"* sheet, whose body
   discloses up front that support may save a snapshot or record the session. **Nothing streams
   before the user taps "Start sharing."**
2. While live, the SDK streams the app's own window at ~1 frame/second and shows an unmissable
   red indicator: a pulsing red frame around the screen plus a pill —
   *"● Sharing your screen · live"* with a one-tap **Stop**. The indicator never appears in the
   streamed frames.
3. If the agent saves a frame or records the session, the user sees a transient on-device toast
   (*"A snapshot of your screen was saved"* / *"Support is recording your screen"*). Recording
   length is capped (workspace-configurable).
4. Stop (user), End (agent), or expiry tears the stream down. Every consent event — including
   each saved frame and recording — lands in the workspace's immutable consent log.

## Errors

Failures surface as `SnaplyError` with the backend's error code — e.g. `403 origin_mismatch`
(the key doesn't allow this app's bundle identifier), `403 workspace_suspended`,
`429 quota_exceeded`, `410 request_expired`.

## Notes

- The device token authenticates everything after registration and is held in memory only —
  the device re-registers on every cold launch; a non-secret `installId` in UserDefaults keeps
  it the same device across launches.
- Heartbeats every 25 s; reconnects with exponential backoff (capped at 30 s).
- This repository ships only the compiled framework. Versions are immutable tags — update by
  bumping the package requirement.
