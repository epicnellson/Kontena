# Kɔntena 🌐

![CI](https://github.com/YOUR_USERNAME/kontena/actions/workflows/ci.yml/badge.svg)

> Offline-first indigenous language mesh data platform for Sierra Leone.
> Built for the Digital Public Goods Alliance (DPGA). MIT License.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    MESH LAYER (BLE)                     │
│                                                         │
│  [Phone A] ──────BLE GATT────── [Phone B]              │
│      │            3 hops            │                   │
│      └──────────────────────── [Phone C]                │
│                                     │                   │
└─────────────────────────────────────┼───────────────────┘
                                      │
                                     WiFi / USB
                                      │
                               ┌───────▼────────┐
                               │  Gateway :8080  │
                               │   Go + SQLite   │
                               │  REST API       │
                               └─────────────────┘
```

Sync modes:

- **HTTP:** `POST /records` → push one record; `GET /sync/batch?since=ts` → pull delta
- **BLE:** GATT write → send pending records to peer; GATT notify → receive peer's records
- **Relay:** A→B→C with 3-hop TTL and dedup by record ID

## Stack

| Layer       | Technology                           | Why                      |
|-------------|--------------------------------------|--------------------------|
| Wire format | protobuf v3                          | Compact, schema-enforced |
| Gateway     | Go 1.22 · SQLite WAL · gorilla/mux  | Headless, no Docker      |
| Android     | Flutter 3.x · sqflite               | Single codebase, offline |
| BLE mesh    | flutter_blue_plus · GATT             | No internet needed       |
| Voice input | Vosk (offline STT)                   | On-device, free          |
| TTS output  | flutter_tts                          | On-device Android engine |
| Language    | Krio (Sierra Leonean Creole)         | Indigenous language      |
| CI          | GitHub Actions (free tier)           | 0 cost                   |

## Quick Start

### Gateway

```bash
# Requires: Go 1.22+, gcc
cd gateway
go build -o bin/gateway ./cmd/server/
./bin/gateway
curl http://localhost:8080/health
```

### Android Client

```bash
# Requires: Flutter 3.x, Android phone with USB debugging
cd android_client
flutter pub get
flutter run
```

### Test Sync (HTTP)

```bash
# Terminal 1
./gateway/bin/gateway

# Terminal 2 (phone on same network)
ngrok http 8080
# Set baseUrl in SyncScreen to the ngrok URL, then tap Sink Nau
```

## Free-Tier Constraints

| Resource        | Solution                                      |
|-----------------|-----------------------------------------------|
| No cloud DB     | SQLite on gateway + sqflite on device         |
| No Firebase     | HTTP REST + BLE GATT                          |
| No paid STT     | Vosk (offline, on-device)                     |
| No emulator     | USB debugging on real Android phone           |
| No Docker       | Plain Go binary, systemd or screen on server  |
| CI              | GitHub Actions (2000 min/month free)          |

## DPG Alignment

- **Open source**: MIT License
- **Offline-first**: zero connectivity needed for core features
- **Indigenous language**: full Krio UI + voice
- **Data sovereignty**: no cloud, all data stays on community devices
- **Interoperability**: protobuf + standard HTTP/JSON REST

## License

MIT © 2025 Kɔntena Contributors
