# Suhail

**Go off-road. Someone's always watching your back.**

Suhail is an off-road safety iOS app that helps users share their trip details with emergency contacts and automatically sends alerts when a user exceeds the expected return time without any location updates.

When an alert is triggered, emergency contacts receive a **WhatsApp message** containing the user's latest known location and a tracking link. The recipient does not need to install the application or create an account to access the shared trip information.

<br>
<img width="1920" height="1080" alt="Untitled" src="https://github.com/user-attachments/assets/ed59f31d-39f6-4901-91a7-53fa94dfa9c3" />
<br>

## Features

- **Trip planning wizard** — destination on the map, return time, group size, vehicle details (including Saudi plate letters/numbers and 4WD), and emergency contacts
- **Background GPS tracking** with a full local route history, resilient to force-quit and app relaunch
- **Automatic overdue detection** — backend monitors every active trip and escalates when the user doesn't return on time
- **WhatsApp emergency alerts** with the last known location and a public tracking link — no app needed on the recipient's side
- **Offline-first** — built for remote areas: trip data lives locally and syncs when connectivity returns, with a live network status banner
- **Trip history** with detailed route playback per trip
- **Arabic & English localization**, custom design system, and a remote maintenance mode

## How It Works

The user creates a trip through a step-by-step flow, then Suhail starts tracking in the background. A scheduled backend job checks all active trips **every 5 minutes** and escalates in stages:

| Stage | Condition | Action |
|---|---|---|
| **Overdue** | Return time passes | Trip is marked `overdue` immediately |
| **Initial alert** | Overdue + no location upload for **35 minutes** | WhatsApp alert sent to emergency contacts with last known location + tracking link |
| **Updated alerts** | New location arrives after the alert | Debounced follow-up alert (2-minute debounce, max 3 updates) so contacts see the freshest position |

The 35-minute silence window is the key safety signal: an overdue user who is still uploading locations is probably just late — an overdue user whose phone has gone quiet may be in trouble.

### Smart Location Uploads
The full GPS track is saved **locally**, but uploads to the cloud are adaptive based on speed — every 1 km when moving slowly, up to every 5 km at driving speed, with a maximum time gap as a fallback. This preserves battery and bandwidth in low-coverage areas while keeping the last known location fresh enough to be useful in an emergency.

### Hybrid Storage
Safety-critical and operational data are deliberately split: the complete route history is stored on-device with **SwiftData** (always available, even fully offline), while only what backend and emergency workflows need — trip status, contacts, destination, and latest location — is synced to **Firestore**. This reduces network dependency in remote environments and limits how much location data ever leaves the device.

## Architecture

MVVM on top of an Atomic Design system:

```
Suhail
├── App/                 # Entry, AppDelegate, RootView
├── Models/              # Trip (SwiftData @Model), contacts, settings
├── Session/             # ActiveTripSession — the live trip engine
├── Managers/            # Firebase, Location, Notifications
├── Pages/               # CreateTrip (multi-step), Home, History,
│                        # Onboarding, Splash, shared Map/Maintenance
├── DesignSystem/        # Foundations (colors, typography, spacing,
│                        # radius, grid) + Atoms → Molecules →
│                        # Organisms → Templates
├── Helpers/             # Localization, network monitor, navigation,
│                        # plate formatting, keyboard
└── desert-functions/    # Firebase Cloud Functions (Node.js)
```

- **`ActiveTripSession`** — a singleton trip engine: starts/finishes trips, saves the GPS track locally, decides when to upload, runs the overdue timer, and resumes the session after relaunch or force quit
- **`LocationManager`** — background location updates with permission handling and session restoration
- **`FirebaseManager`** — Firestore sync for trip status, contacts, and last known location
- **`checkOverdueTrips`** (Cloud Function) — the 5-minute scheduled job implementing the alert pipeline above, calling a dedicated WhatsApp service to deliver messages

## Tech Stack

| Layer | Technology |
|---|---|
| Language / UI | Swift · SwiftUI · Lottie |
| Local storage | SwiftData (full route history, offline-first) |
| Cloud | Firebase — Firestore, Cloud Functions v2, Hosting |
| Location | CoreLocation (background tracking) |
| Messaging | Dedicated WhatsApp service (see related repositories) |
| Architecture | MVVM + Atomic Design system |
| Localization | Arabic · English |

## Documentation

Comprehensive **DocC** documentation is included throughout the codebase and serves as the primary source of implementation-level documentation, covering architecture and system design, ViewModels and Managers, data flow and responsibilities, backend integration, and important implementation details — with layered-architecture, UML, and backend-journey diagrams.

To view it in Xcode: **Product → Build Documentation** (⌃⌘D)

## Related Repositories

- **[SuhailtWebsite](https://github.com/ArwaAlkadi/SuhailWebsite)** — Firebase Hosting website serving the public web layer of the system (the tracking link recipients open)
- **[SuhailWhatsApp](https://github.com/ArwaAlkadi/SuhailWhatsApp)** — WhatsApp messaging service responsible for delivering emergency alerts
