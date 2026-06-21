# point-machine — Architecture

A serverless, peer-to-peer file synchronizer (a Syncthing alternative). Files move
directly between a user's own devices. **There is no server of ours anywhere** — not for
storage, not even for discovery. File bytes never touch a third party.

Platforms: Android, iOS, Linux, macOS, Windows. Web is intentionally dropped (browsers
cannot do UDP/DHT or true background work).

---

## 1. Core principles

- **No server, ever.** Discovery is replaced by three serverless paths (LAN, WAN DHT, QR).
  The only external infrastructure — DHT bootstrap nodes and optional STUN — is public,
  dataless, replaceable, and can be disabled (then only LAN + manual QR remain).
- **End-to-end encrypted.** Every file block is sealed under a per-folder key before it
  leaves the device, and stays encrypted at rest.
- **Only paired devices connect.** Identity is an Ed25519 key pair; only explicitly paired
  Device IDs are accepted.
- **Pure Dart.** No C/C++ in our code. Flutter + Riverpod, `dart:io` + `sembast` for storage.

---

## 2. Layered layout (`lib/`)

```
core/        identity, pairing, config, models, paths, folder/share codecs
crypto/      AEAD (XChaCha20-Poly1305), folder-key derivation, hex codec
storage/     FileStore — reads/writes the actual files on disk
sync/        the sync engine: index, scanner, blocks, version vectors, SyncService, SyncHost
transport/   discovery (mDNS, DHT), signaling, TCP / WebRTC / Bluetooth links, coordinator
platform/    background execution, tray, the SyncController abstraction + cross-isolate bridge
state/       Riverpod providers (UI ↔ sync glue)
ui/          screens & widgets (Material 3 Expressive)
i18n/        slang translations
```

---

## 3. Identity & pairing

Each device holds two key pairs (`core/identity.dart`):

- **Ed25519** signing key → its identity. The **Device ID** is the hash of the signing
  public key, so it is self-certifying.
- **X25519** agreement key → used to derive shared secrets for folder encryption.

Keys live in `identity.json`. A **`PairingPayload`** (`core/pairing.dart`) is the public
half a device shares: `{deviceId, name, signingKey, agreementKey}`.

**Pairing** establishes mutual trust by exchanging payloads:

- **In person / LAN** — connect to the peer's signaling port and exchange `PairRequest` /
  `PairResponse`; a short numeric **pairing code** (`transport/pairing_code.dart`) lets both
  sides confirm the same peer out of band.
- **Remote** — both sides announce under a DHT infohash derived from a shared code, find each
  other, then pair as above.
- **QR** — the payload is encoded into a QR for camera scanning.

Paired peers are persisted in `peers.json`.

---

## 4. Folders & swarm secrets

A synced folder (`FolderConfig`) carries a random 32-byte **swarm secret**
(`transport/swarm.dart`). Two things derive from it:

- **Infohash** = `sha256(secret)[0..20]` — the rendezvous key used to find peers (LAN service
  name and DHT announce key). Knowing the infohash reveals nothing about contents.
- **Folder key** — see §7.

Sharing a folder sends a `FolderShare` (`{folderId, label, swarmSecret}`) to an already-paired
peer, who chooses a local path to receive it. Per-peer permissions (`canSend` / `canReceive`)
are stored on the folder.

---

## 5. Discovery (finding peers)

Three paths feed the same outcome — a peer's `address:port` — after which a normal
connection is opened.

| Path | Mechanism | File |
|------|-----------|------|
| **LAN** | mDNS multicast + UDP broadcast beacon announcing the `PairingPayload`, signaling port and TCP sync port | `transport/lan_beacon.dart` |
| **WAN** | BitTorrent Mainline DHT: announce/lookup under the folder infohash to learn peer IP:port | `transport/dht.dart` |
| **Pairing** | QR / DHT pairing code | `transport/pairing_code.dart` |

> **DHT is discovery, not transport.** It only maps `infohash → peers`. It replaces the
> central signaling server; file bytes never travel through it.

---

## 6. Transport (moving bytes)

Once a peer is located, a **signaling** channel is opened first
(`transport/lan_signaling.dart`, a line-delimited JSON socket on port **49322**). Over it the
devices exchange `SignalHello {infohash, deviceId}` and, for WebRTC, SDP/ICE.

A **`SyncTransportCoordinator`** (`transport/sync_transport.dart`) then opens the actual
`PeerLink`, trying candidates by priority and using the first that connects:

| Priority | Kind | Link |
|---------:|------|------|
| 5  | **Direct TCP** (LAN, host-to-host) | `transport/tcp_transport.dart` |
| 10 | **WebRTC data channel** (DTLS 1.3, NAT hole-punching, optional STUN) | `transport/negotiator.dart` |
| 20 | **Bluetooth** (offline fallback) | `transport/bluetooth_transport.dart` |

Every link is a `PeerLink`: a framed, ordered message stream carrying `SyncMessage`s.

---

## 7. Security model

| Layer | Protection |
|-------|------------|
| **Identity** | Ed25519 device keys; only paired Device IDs are accepted |
| **In transit** | TCP/WebRTC under DTLS 1.3 |
| **End-to-end** | every block sealed with **XChaCha20-Poly1305** under the per-folder key |
| **At rest** | blocks are stored encrypted on disk |

The **folder key** (`crypto/folder_key.dart`) is derived per device pair:

```
shared   = X25519(my_agreement_priv, peer_agreement_pub)
folderKey = HKDF-SHA256(shared, nonce = swarmSecret, info = "folder-key/v1", 32 bytes)
```

Because the X25519 shared secret is symmetric, both devices derive the same key. Blocks are
sealed/opened by `FolderCipher` (`crypto/aead.dart`). STUN/TURN endpoints are user-configurable
in Settings and can be disabled.

---

## 8. Sync engine

The engine (`sync/engine.dart`) is a small block-level replication protocol over a `PeerLink`.

**Index.** Each folder has an index in `sembast` (`sync/index.dart`): per file a `FileMeta`
(`path, size, modified, blockHashes, deleted`) plus a **version vector**. The **scanner**
(`sync/scanner.dart`) walks the folder, splits files into **128 KiB blocks**, SHA-256-hashes
each (offloaded to an isolate, `sync/blocks.dart`), and updates the index.

**Conflict detection** uses **version vectors** (`sync/version_vector.dart`): per-device
counters with `dominates` / `concurrentWith`. Concurrent edits to the same file are kept as a
**conflict copy** rather than overwriting.

**Wire protocol** (`transport/messages.dart`):

```
A ──IndexSnapshot──▶ B      both sides announce their index
B decides which entries are newer, then for each missing block:
B ──WantBlock(hash)─▶ A
A ──BlockPayload────▶ B      sealed block bytes
… B reassembles the file once all blocks arrive, then updates its index
```

Block hashing means **unchanged blocks are never resent** — only the delta moves.

---

## 9. Background execution

Sync must keep running even when the app window is closed. This is solved differently per
platform; the UI depends on a single abstraction, **`SyncController`**
(`platform/sync_controller.dart`), with two implementations:

```
              ┌──────────────── Android ────────────────┐   ┌──── Desktop ────┐
UI isolate │  RemoteSyncController ──invoke/on──┐        │   │ LocalSyncController
           │                                    ▼        │   │        │
bg isolate │            flutter_background_service       │   │        ▼
           │            SyncHost → SyncService           │   │ SyncHost → SyncService
           └─────────────────────────────────────────────┘   └────────┘
                  (foreground service, owns sync)               (main isolate, kept
                                                                 alive by the tray)
```

- **Android.** A `flutter_background_service` background isolate is the **sole owner** of
  `SyncService` and the index database. Two isolates cannot both run it — they would fight over
  the mDNS/TCP/signaling ports, and two `sembast` handles on one file would corrupt it.
  The UI talks to the bg isolate through a small RPC bridge (`platform/sync_background.dart`,
  `remote_sync_controller.dart`, `sync_messages.dart`, `sync_codec.dart`): events, nearby
  peers, file counts, and interactive pair/share prompts cross the isolate boundary.
- **Desktop.** No OS background isolate exists, so `SyncService` runs in the main isolate via
  `LocalSyncController`. Closing the window **hides to the tray** instead of quitting
  (`platform/desktop_lifecycle.dart` + `desktop_tray.dart`), and the app registers
  **launch-at-login**. A real quit happens only from the tray menu.
- **iOS.** Deferred — there is no continuous background; only periodic `BGTaskScheduler`
  passes are even possible.

`SyncHost` (`sync/sync_host.dart`) is the Riverpod-free builder that loads identity/config/
peers/folders/db from disk and starts `SyncService`. It is shared by both controllers, so the
exact same engine runs in the bg isolate (Android) and the main isolate (desktop).

---

## 10. State management

Riverpod (`state/`) glues the engine to the UI. Key providers:

- `syncControllerProvider` — builds the platform controller, wires **outgoing** streams
  (events, folder changes, paired peers, incoming prompts) into notifiers.
- `syncBindingProvider` — wires **incoming** changes (folders, peers, config, sync window) and
  forwards `reload*` to the controller. Split out from the controller to avoid a circular
  provider dependency.
- `foldersProvider`, `pairedPeersProvider`, `configProvider`, `syncEventsProvider`,
  `nearbyDevicesProvider`, `syncActiveProvider` (schedule window).

All persistent state is plain files under the app data dir (`identity.json`, `peers.json`,
`folders.json`, `point-machine.db`) plus `SharedPreferences` for config — which is why the
headless bg isolate can rebuild everything from disk.

---

## 11. End-to-end flow (LAN example)

```
1. Both devices announce on mDNS (PairingPayload + ports).
2. Device A sees a known peer → opens signaling (port 49322) → SignalHello(infohash).
3. Coordinator opens a link: Direct TCP wins on LAN.
4. Both send IndexSnapshot. A has a newer file.
5. B requests the missing blocks by hash; A streams sealed BlockPayloads.
6. B opens each block with the folder key, reassembles the file, updates its index.
7. SyncEvents flow to the UI (Activity screen); on desktop the tray keeps this running
   after the window is closed.
```
