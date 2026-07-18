# SnaplyAgent — iOS SDK

Consent-first screen capture for iOS apps. Distributed as a compiled binary framework.

## Install (Swift Package Manager)

In Xcode: **File → Add Package Dependencies…** and enter:

```
https://github.com/Mobile-LLC/SnaplyAgent-SDK-iOS
```

Or in `Package.swift`:

```swift
.package(url: "https://github.com/Mobile-LLC/SnaplyAgent-SDK-iOS", from: "2.3.0")
```

## Usage

```swift
import SnaplyAgent

Snaply.configure(key: "snap_live_…", environment: .live, user: SnaplyUser(id: "user-123"))
```

- `Snaply.on(...)` — register capture callbacks.
- `Snaply.identify(id:name:phone:)` / `Snaply.reset()` — set / clear the user.
- `Snaply.showSupportCode()` — present the support-code sheet.
- `Snaply.stop()` — tear down.

Requires iOS 15+.
