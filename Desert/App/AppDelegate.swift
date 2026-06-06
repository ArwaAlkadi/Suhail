//
//  AppDelegate.swift
//  Desert
//
//  Created by Arwa Alkadi on 31/05/2026.
//

import Firebase

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // 1. configure Firebase
        FirebaseApp.configure()

        // 2. sign in anonymously — persists userId on device
        FirebaseManager.shared.signInAnonymously()

        // 3. set ActiveTripSession as LocationManager delegate
        LocationManager.shared.delegate = ActiveTripSession.shared

        // 4. if iOS relaunched due to location update — restore session
        if launchOptions?[.location] != nil {
            LocationManager.shared.restoreSessionAfterForceQuit()
        }

        return true
    }
}
