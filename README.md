![Mesh Market devices screen](docs/hero_banner.png)

# Mesh Market

Mesh Market is a serverless peer-to-peer file synchronizer for a user's own
devices. It syncs selected folders directly between paired devices without a
central storage service or application-owned discovery server.

The project is built with Flutter and targets Android, iOS, Linux, macOS, and
Windows. Web is not supported because the application depends on native network
and background capabilities that browsers do not provide.

## What It Does

- Pairs trusted devices by LAN discovery, QR/manual payload exchange, or a shared remote pairing code.
- Syncs folders between paired devices.
- Transfers changed file blocks instead of resending whole files.
- Detects concurrent edits and keeps conflict copies instead of overwriting local changes silently.
- Supports direct LAN transport, WebRTC data channels, DHT-based peer discovery, and Bluetooth fallback.
- Runs in the background on supported platforms through platform-specific services or tray integration.

## Security Model

- Device identity is based on local public/private key pairs.
- Only explicitly paired devices are accepted.
- File blocks are encrypted with XChaCha20-Poly1305 before they leave the device.
- Folder keys are derived per device pair using X25519 and HKDF-SHA256.
- DHT and STUN are used only for discovery/connectivity. File contents do not pass through them.

## Minimum Requirements

Runtime:

- Android: Flutter-supported Android device with storage access; Bluetooth features require Bluetooth LE support and runtime permissions.
- iOS: iOS 13.0 or newer.
- macOS: macOS 10.15 or newer.
- Linux: 64-bit Linux desktop with GTK, network access, and file-system permissions for synced folders.
- Windows: 64-bit Windows desktop supported by Flutter.
- Network: local network access for LAN sync; internet access is required for DHT/STUN-assisted remote discovery.
- Storage: enough free disk space for the selected synced folders and local metadata.

Development:

- Flutter SDK compatible with Dart SDK `^3.12.2`.
- Android Studio or Android command-line tools for Android builds.
- Xcode for iOS and macOS builds.
- CMake, Ninja, GTK development packages, and a C++ toolchain for Linux builds.
- Visual Studio with Desktop development with C++ for Windows builds.

## Build

Install dependencies:

```sh
flutter pub get
```

Run analysis:

```sh
dart analyze
```

Run tests:

```sh
NO_PROXY=localhost,127.0.0.1,::1 no_proxy=localhost,127.0.0.1,::1 flutter test
```

Build examples:

```sh
flutter build apk --release
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

## Current Limitations

- General WAN sync depends on peer reachability and NAT traversal conditions.
- iOS background execution is constrained by the operating system.
- Some mobile folder selection behavior is limited by platform storage APIs.

See [docs/en/architecture.md](docs/en/architecture.md) for implementation details.
