# DPGA Self-Assessment — Kɔntena

Submission URL: https://digitalpublicgoods.net/submission

---

## 1. Relevance to Sustainable Development Goals

| SDG | How Kɔntena contributes |
|-----|--------------------------|
| SDG 4 — Quality Education | Indigenous language literacy; Krio word/phrase database |
| SDG 10 — Reduced Inequalities | Offline-first for rural communities with no internet |
| SDG 17 — Partnerships | Mesh sync enables peer community data sharing |

---

## 2. Open Source License

- **License**: MIT (see LICENSE file)
- **Repository**: https://github.com/YOUR_USERNAME/kontena (public)
- **Confirmed**: All source code available, no proprietary components

---

## 3. No Harmful Content

- [ ] No personally identifiable information collected (device_id is a random UUID)
- [ ] No analytics, telemetry, or third-party trackers
- [ ] Voice processing fully on-device (Vosk model bundled in APK)
- [ ] No content moderation needed (community language data only)

---

## 4. Privacy and Applicable Laws

- [ ] Data never leaves the device without user-initiated sync
- [ ] No cloud storage — SQLite only (device + local gateway)
- [ ] BLE communications are local-only, no internet relay
- [ ] No user accounts or login required

---

## 5. Standards and Interoperability

- [ ] **protobuf v3** — language-agnostic, platform-neutral wire format
- [ ] **HTTP/JSON REST API** — standard, documented, curl-testable
- [ ] **ARB localization format** — Flutter/CLDR standard, easy to extend
- [ ] **SQLite WAL** — portable, widely supported database format
- [ ] Schema extensible: add new record types without breaking existing clients

---

## 6. Do No Harm by Design

- [ ] No vendor lock-in — all OSS dependencies, easily forkable
- [ ] Runs on sub-$50 Android devices (tested on Android 8+)
- [ ] Gateway runs on Raspberry Pi (tested) — no cloud needed
- [ ] No internet access required for any core functionality

---

## 7. Technology Choices

All dependencies are free, open source, and auditable:

| Dependency       | License    | Purpose          |
|------------------|------------|------------------|
| gorilla/mux      | BSD-3      | Go HTTP routing  |
| go-sqlite3       | MIT        | SQLite for Go    |
| sqflite          | MIT        | SQLite for Flutter |
| flutter_blue_plus| MIT        | BLE mesh         |
| Vosk             | Apache 2.0 | Offline STT      |
| flutter_tts      | BSD        | TTS output       |
| protobuf         | BSD-3      | Wire format      |

---

## Demo Video Script

**Duration**: 3 minutes | **Tools needed**: phone camera only
