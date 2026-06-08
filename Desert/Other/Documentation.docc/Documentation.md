# ``Desert``
A safety app for desert and remote trips.

## Overview
A safety app for desert and remote trips that tracks users, provides a shareable safety card, and automatically sends their last known location to emergency contacts if they don't return on time.

## System Architecture

#### Layered Architecture
![LayeredArchitecture](LayeredArchitecture)
[View Layered Architecture ↗](https://suhail-1.web.app/system-architecture.pdf)

#### UML
![UML](UML)
[View UML ↗](https://suhail-1.web.app/system-architecture.pdf)

#### Backend Journey During a Trip
![BackendJourney](BackendJourney)
[View Backend Journey ↗](https://suhail-1.web.app/system-architecture.pdf)

## Topics

### App
- ``DesertApp``
- ``AppDelegate``
- ``RootView``

### Models
- ``AppSettings``
- ``SavedInfo``
- ``SavedContact``
- ``Trip``
- ``Contact``
- ``LocationPoint``
- ``UserDefaultsKeys``

### Managers
- ``LocationManager``
- ``NotificationsManager``
- ``FirebaseManager``

### Session
- ``ActiveTripSession``

### Pages
- <doc:AppPages>

### Helpers
- ``NetworkMonitorHelper``
- ``AppPage``
- ``NavigationGestureDisabler``
- ``OnTripStartedKey``

### Design System + Compenents
- <doc:DesignSystem>

### Other
- <doc:Others>
