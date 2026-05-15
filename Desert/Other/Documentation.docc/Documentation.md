# ``Desert``

A safety app for desert and remote trips.

## Overview

A safety app for desert and remote trips that tracks users, provides a shareable safety card, and automatically sends their last known location to emergency contacts if they don't return on time.

## Data Schema

#### Logical ERD
![LogicalERD](LogicalERD)
[View ERD (Logical/Physical) ↗](https://desert-5549e.web.app/ERD.pdf)

#### Physical ERD
![PhysicalERD](PhysicalERD)
[View ERD (Logical/Physical) ↗](https://desert-5549e.web.app/ERD.pdf)

#### UML
![UML](UML)
[View UML ↗](https://desert-5549e.web.app/UML.pdf)

## Topics

### App
- ``DesertApp``
- ``AppDelegate``
- ``RootView``

### Coordinator
- ``TripSessionManager``

### Services
- ``LocationManager``
- ``NotificationsManager``
- ``FirebaseManager``

### Models
- ``AppSettings``
- ``SavedInfo``
- ``SavedContact``
- ``Trip``
- ``Contact``
- ``LocationPoint``

### Splash Page
- ``SplashView``

### Onboarding Page
- ``OnboardingView``
- ``OnboardingViewModel``

### Home Page
- ``HomeView``
- ``HomeViewModel``
- ``WelcomeView``

### Home Page — Trips
- ``CreateTripView``
- ``ActiveTripCardView``
- ``HomePageTripsViewModel``

### History Page
- ``TripHistoryView``
- ``TripHistoryInDetailsView``
- ``RepeatTripView``
- ``TripHistoryViewModel``

### Shared
- ``TripMapView``
- ``ReplayMapView``
- ``SharedComponents``
