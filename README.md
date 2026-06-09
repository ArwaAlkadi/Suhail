# Desert

## Overview

Desert is an off-road safety application designed to help users share their trip details with emergency contacts and automatically send alerts when a user exceeds the expected return time without any location updates.

When an alert is triggered, emergency contacts receive a WhatsApp message containing the user's latest known location and a tracking link. The recipient does not need to install the application or create an account to access the shared trip information.

## Documentation

### Xcode Documentation

Comprehensive DocC documentation is included throughout the codebase and serves as the primary source of implementation-level documentation.

The documentation covers:

- Architecture and system design
- ViewModels and Managers
- Data flow and responsibilities
- Backend integration
- Important implementation details

To view the documentation in Xcode:

Product → Build Documentation (⌃⌘D)


## Related Repositories

### DesertWebsite

Firebase Hosting website responsible for serving the public web layer of the system.

https://github.com/ArwaAlkadi/DesertWebsite

### SuhailWhatsApp

WhatsApp messaging service responsible for delivering emergency alerts.

https://github.com/ArwaAlkadi/SuhailWhatsApp
